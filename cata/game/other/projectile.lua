local gmap = g.map

--飞弹
local projectile_mt = {}
projectile_mt.__index = projectile_mt

--创建飞弹
function g.create_projectile()
  local pjt_ins= {}
  setmetatable(pjt_ins,projectile_mt)
  pjt_ins.dam_mul = 1 
  pjt_ins.speed = 1000
  pjt_ins:set_animation("bullet1")
  
  pjt_ins.effects = {}
  
  return pjt_ins
  --shot_dispersion 初始散布
  --dam_ins --可重复利用，并不会修改其中的值
  --max_range最大飞行距离 
  --speed --animation飞行速度
  --accurateness -- 准确值，原cddaspeed
  --dam_mul--伤害修正
  --drop_item --掉落物品，一个物品
  --effects --特殊效果，flag table类型 ｛xx=true，。。｝这样
  --爆炸1
  
  --ammo 弹药类型
  --hit_unit --击中后会设置的变量，击中单位
  ---hit_delay --击中延迟（飞行时间）
  
  --未加入
  --missed_by， 目标，目标地，源，起始地   --是否击中等
end


function projectile_mt:set_drop(item_ammo)
  if item_ammo and item_ammo.type.recover_rate>0 then
    if rnd()<item_ammo.type.recover_rate then
      self.drop_item = item_ammo
    end
  end
end

function projectile_mt:getFlyPostionDelay(x,y,z)
  local dist=  c.dist_3d(self.source_x*64+32,self.source_y*64+32,self.source_z*96,x*64+32,y*64+32,z*96)
  return dist/self.speed
end


function projectile_mt:set_animation(id)
  local anim_t = data.projectile[id]
  if anim_t ==nil then
    debugmsg("error: projectile anim id not found:"..id)
    anim_t = data.projectile["bullet1"] --尝试替换为默认
  end
  self.anim = anim_t
end

function projectile_mt:getAnim_position()
  if self.pastTime>self.timeFlying then --2阶段
    return self.end_x,self.end_y,self.end_z
  else
    local rate = 1-self.pastTime/self.timeFlying 
    return self.end_x - self.move_x*rate, self.end_y- self.move_y*rate,self.end_z- self.move_z*rate
  end
end
--取得当前层
function projectile_mt:getCurAnimFrameIndex()
  if self.pastTime>=self.timeFlying then --2阶段
    local anim_data = self.anim
    local stage2time = self.pastTime - self.timeFlying
    local frame = math.floor(stage2time/anim_data.secPerFrame)+2 --2以上
    return math.min(frame,anim_data.frameNum)
  else
    return 1 --飞行中，第一帧
  end
end

function projectile_mt:playAnim(tx,ty,tz)
  local startx,starty,startz = self.source_x*64+32,self.source_y*64+32,self.source_z
  local endx,endy,endz = tx*64+32,ty*64+32,tz
  self.end_x = endx;self.end_y = endy;self.end_z = endz;
  self.move_x = endx-startx;self.move_y = endy-starty;self.move_z = endz-startz;
  local dist = c.dist_3d(startx,starty,startz*96,endx,endy,endz*96)
  self.timeFlying = dist/self.speed
  self.totalTime = self.timeFlying + self.anim.secPerFrame*(self.anim.frameNum-1)
  
  --local arct = math.atan2 (self.move_y, self.move_x)
  --debugmsg(" arct:"..arct.." y:"..self.move_y.." x:"..self.move_x)
  self.rotation =   -math.atan2 (self.move_y, self.move_x)
  --debugmsg("rotation:"..self.rotation)
  g.animManager.addProjectile(self)
end




--弹道  tx,ty,tz,不一定是整数， fx,fy,fz 是整数
local function trajectory(fx,fy,fz,tx,ty,tz,interactFunc)
  local dx = tx - fx
  local dy = ty - fy
  local dz = tz - fz
  local ax = math.abs(dx) ;
  local ay = math.abs(dy) ;
  local az = math.abs(dz) ;
  if dx>0 then dx = 1 elseif dx<0 then dx = -1 else dx = 0 end
  if dy>0 then dy = 1 elseif dy<0 then dy = -1 else dy = 0 end
  if dz>0 then dz = 1 elseif dz<0 then dz = -1 else dz = 0 end
  
  local maxa = math.max(ax,ay,az)
  if maxa ==0 then interactFunc(fx,fy,fz,fx,fy);return end
  if maxa ==ax then
    for cx = fx,tx,dx do
      
      local oy = (cx - fx)/(tx - fx) *(ty - fy)+fy
      local cy  = math.floor(oy+0.5)--四舍五入
      local cz  = math.floor((cx - fx)/(tx - fx) *(tz - fz)+fz+0.5)--四舍五入
      if not interactFunc(cx,cy,cz,cx,oy) then
         return false
      end
    end
  elseif maxa ==ay then
    for cy = fy,ty,dy do
      local ox = (cy - fy)/(ty - fy) *(tx - fx)+fx
      local cx  = math.floor(ox+0.5)--四舍五入
      local cz  = math.floor((cy - fy)/(ty - fy) *(tz - fz)+fz+0.5)--四舍五入
      if not interactFunc(cx,cy,cz,ox,cy) then
          return false
      end
    end
  else
    for cz = fz,tz,dz do
      local ox = (cz - fz)/(tz - fz) *(tx - fx)+fx
      local oy = (cz - fz)/(tz - fz) *(ty - fy)+fy
      local cx  = math.floor(ox+0.5)--四舍五入
      local cy  = math.floor(oy+0.5)--四舍五入
      if not interactFunc(cx,cy,cz,ox,oy) then
          return false
      end
    end
  end
  return true--正常射程结束的
end





--确定目标，发射
function projectile_mt:attack(source_unit,sx,sy,sz,dest_unit,dx,dy,dz)
  self.source_unit = source_unit;self.dest_unit = dest_unit
  self.source_x = sx;self.source_y = sy;self.source_z = sz;
  self.dest_x = dx;self.dest_y = dy;self.dest_z = dz;
  
  --补充
  self.shot_dispersion = self.shot_dispersion or 1000
  self.max_range =self.max_range or 7
  
  
  local range = c.dist_3d(sx,sy,sz*1.5,dx,dy,dz*1.5) --Z距离是普通的1.5倍，这样修正
  local missed_by = self.shot_dispersion * 0.000216666 * range*1.33;
  
  
  
  local tx,ty,tz = dx,dy,dz --最终射击地点
  --[[if missed_by>1 then   --根据射击角偏斜，不再用此处的偏斜
    local offset = math.floor(math.min(math.sqrt(missed_by),range))
    missed_by = 1
    tx = tx+rnd(-offset,offset)
    ty = ty+rnd(-offset,offset)--偏斜
  end--]]
  
  --根据missed_by将最终目标分散
  if missed_by>0 then
    local offset_x = (rnd()-0.5)*missed_by
    local offset_y =  (missed_by*0.5 - math.abs(offset_x))--根据x求出Y
    if rnd()<0.5 then offset_y = -offset_y end--Y随机正负
    tx = tx+offset_x
    ty = ty+offset_y
    debugmsg("missedby:"..missed_by.." offsetx:"..offset_x.." offsety:"..offset_y)
  end
  
  
  --debugmsg("range :"..range.." max:"..self.max_range)
  if range>0 then --画出延长线
    --debugmsg("tobefore x:"..tx.." y:"..ty.." z:"..tz)
    local beishu  = self.max_range /range
    tx = (tx- sx)*beishu+sx
    ty = (ty- sy)*beishu+sy
    tz = (tz- sz)*beishu+sz
  end
  
  --前一个地点
  local pre_x,pre_y,pre_z = sx,sy,sz
  local pre_ox, pre_oy = sx,sy
  local pre_blindage = false
  --遍历 路径点，返回false就半途终止   ox,oy,为浮点数命中的点大部分情况下其中一个为整数（sz==dz）,
  local function traversePoint(x,y,z,ox,oy)
    if x ==sx and y==sy and z==sz then return true end--起始点，继续
    
    if z~= pre_z then
      if (z>pre_z and gmap.has_floor_or_support(x,y,z)) then
        --shot floor,射在floor上 x,yz
        debugmsg("z shoot ground")
        gmap.shootSquare(self,x,y,z,true,false)
        
        self:shot_end(x,y,z,ox,oy ,pre_x,pre_y,pre_z)
        return false
      end
      if (z<pre_z and gmap.has_floor_or_support(pre_x,pre_y,pre_z)) then
        --shot floor,射在floor上pre_x,pre_y,pre_z,
        debugmsg("z shoot ground")
        gmap.shootSquare(self,pre_x,pre_y,pre_z,true,false)
        self:shot_end(pre_x,pre_y,pre_z,pre_ox, pre_oy ,pre_x,pre_y,pre_z)
        return false
      end
    end
    if not gmap.isSquareInGrid(x,y,z) then
      --不射中任何东西,丢失掉
      self:shot_end(x,y,z,ox,oy,pre_x,pre_y,pre_z)
      return false
    end
    --获得该格的单位
    local unit =gmap.getUnitInGrid(x,y,z)
    --是否射中单位
    if unit then
      local cur_missed_by = missed_by
      if unit~=dest_unit or cur_missed_by >=1 then
        cur_missed_by = math.max(rnd_float(0.2,3.0-math.min(cur_missed_by,1)),0.4)--// Unintentional hit
      end
      if cur_missed_by<1 then --有可能射中
        local hit_delay = self:getFlyPostionDelay(ox,oy,z) +0.02--计算命中delay，
        self.dam_ins.delay = hit_delay
        local dealt_dam  = unit:deal_projectile_attack(self,cur_missed_by)
        if dealt_dam then
          self.hit_unit = unit --射击
          self.hit_delay = hit_delay
          self:shot_end(x,y,z,ox,oy ,pre_x,pre_y,pre_z,dealt_dam)
          --射中！已递交
          return false
        end
      end
    end
    --射中地形？
    local blocked,blindage = gmap.shootThroughSquare(self,x,y,z)
    if blocked then
      self:shot_end(x,y,z,ox,oy ,pre_x,pre_y,pre_z)
      --已被地形完全阻挡住，可能是到达终点或遮挡的地形
      --todo是否有穿墙特性，子弹穿墙后削减威力但是继续穿行
      debugmsg("blocked!")
      return false
    end
    
    --下一个点
    pre_x,pre_y,pre_z = x,y,z
    pre_ox,pre_oy = ox,oy
    pre_blindage =blindage --是否是掩体（躲在掩体后的敌人较难命中） 
    --debugmsg("add point x:"..x.." y:"..y.." z:"..z.." ox:"..ox.." oy:"..oy)
    return true
  end
  --debugmsg("org x:"..sx.." y:"..sy.." z:"..sz)
  --debugmsg("to x:"..tx.." y:"..ty.." z:"..tz)
  if trajectory(sx,sy,sz,tx,ty,tz,traversePoint) then --返回true为到射程尽头没射到东西
    self:shot_end(pre_x,pre_y,pre_z,pre_ox, pre_oy ,pre_x,pre_y,pre_z)
  end
  
end

--射击结束， dealt_dam可能为nil，如果没射到东西的话
function projectile_mt:shot_end(x,y,z,ox,oy,pre_x,pre_y,pre_z,dealt_dam)
  self:playAnim(ox,oy,z)
  
  --播放击中音效，目前就一例？
  if self.hit_unit and self.hit_unit:made_of("flesh") and self.ammo and self.ammo.type.ammotype =="arrow" then
    local delay = math.max(self.hit_delay - 0.2 ,0)
    if delay==0 then
      g.playSound("ranged_hit_flesh",true)--reload声音
    else
      g.insertDelayFunction(delay,function() 
        g.playSound("ranged_hit_flesh",true)--reload声音
      end)
    end
  end
  
  
  local function drop_item()
    local mon = self.hit_unit
      --是否嵌入
    local embed = mon~=nil and mon:is_monster() and not mon:is_dead_state() and not self.effects["NO_EMBED"]
    if embed then
      local vol = self.drop_item:getVolume()
      local msize = mon:get_size()
      if msize<=2 then embed = embed and vol<msize end
      local d_bash = dealt_dam["bash"] or 0
      local d_cut = dealt_dam["cut"] or 0
      local d_stab = dealt_dam["stab"] or 0
      embed = embed and (d_cut/2+d_stab)>d_bash+vol*3+rnd(0,5)--随机嵌入条件
    end
    if embed then
      mon.inventory:addItem( self.drop_item );
      if player:seesUnit(mon) then
        addmsg(string.format(tl("%s嵌进了%s！","The %s embeds in %s!"),self.drop_item:getNormalName(),mon:getName()))
      end
    else
      --掉物品在地上
      if gmap.hasFlag("NOITEM",x,y,z) then
        gmap.addItemToSqaure(self.drop_item,pre_x,pre_y,pre_z)
      else
        gmap.addItemToSqaure(self.drop_item,x,y,z)
      end
      --可能有声音或触发陷阱什么的  todo --hav
    end
  end
  
  
  
  
  
  local delay =  self.hit_delay or (self:getFlyPostionDelay(ox,oy,z) +0.02)--计算命中delay，
  
  --产生掉落物，在x,y,z处，不行就在pre_x,pre_y,pre_z
  if self.drop_item then
    g.insertDelayFunction(delay,drop_item)
  end
  --产生field，在x,y,z处，不行就在pre_x,pre_y,pre_z
end

