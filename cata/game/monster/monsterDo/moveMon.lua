--一些monster类的成员函数
local gmon = g.monster
local monster_mt = gmon.monster_mt
local gmap= g.map

function monster_mt:can_move_to(x,y,z)
  local dest_movecost = gmap.square_movecost(x,y,z)
  return dest_movecost>0 
  --todo 其他地格 状态 和MF flag
end
function monster_mt:set_dest(x,y,z,f)
  f= f or 60--持续时间（路程）
  
  if self.goal then  
    self.goal.x= x;self.goal.y= y;self.goal.x= x;self.goal.z= z;self.goal.f = f
  else
    self.goal = {x= x,y=y,z=z,f=f}
  end
end
function monster_mt:unset_dest()  self.goal = nil end








function monster_mt:attack_at(x,y,z)
  local targert = gmap.getUnitInGridWithCheck(x,y,z)
  if targert~=nil then
    if targert ==self then return false end
    
    if self.type.melee_dice <= 0 then return false end --不能攻击
    
    if self:isHostile(targert) or self:has_flag("MF_ATTACKMON") then
      self:melee_attack(targert)
      return true
    end
  end
  return false
end


function monster_mt:bash_at(x,y,z)
  local trybash = (not self:can_move_to(x,y,z)) or one_in(3)
  local canbash = gmap.is_bashable(x,y,z) and (self:has_flag("MF_BASHES") or self:has_flag("MF_BORES"))
  if(trybash and canbash) then
    --实际执行bash
    local bash_t = gmap.bashSquare(x,y,z,self:bash_skill())
    if bash_t.did_bash then
      local dx,dy = x -self.x,y-self.y
      self.face = c.face(dx,dy)
      self:setAnimation(g.animManager.createMoveAndBackAnim(self,24*dx,24*dy,0.4,0.1))
      self:addDelay(0.6)--标准化1.5turn左右
      return true
    end
  end
  return false
end

function monster_mt:push_to(x,y,z,boost,depth)
  if (not self:has_flag("MF_PUSH_MON")) or depth>2 or self:has_effect("pushed") then return false end
  local targert = gmap.getUnitInGridWithCheck(x,y,z)
  if not targert:is_monster() or targert==self then return false end --只能推monster
  if not self:can_move_to(x,y,z) then return false end
  
  
  return false
end

function monster_mt:move_to(x,y,z)
  if z~=self.z then return false end--暂不支持上下楼
  
  local dest_movecost = gmap.square_movecost(x,y,z)
  if dest_movecost<=0 then return false end --不能移动，不可移动的地点
  local destunit = gmap.getUnitInGridWithCheck(x,y,z)
  if destunit then return false end --有单位占据，不能移动
  
  local costtime  = dest_movecost/c.timeSpeed 
  costtime = (x~=self.x and y~=self.y) and costtime*1.4 or costtime 
  costtime = costtime/self:get_speed()
  
  local dx = x - self.x;
  local dy = y - self.y;
  self:setPosition(x,y,z)
  --动画效果
  self:setAnimation(g.animManager.createMoveAnim(self,-64*dx,-64*dy,costtime))
  self:addDelay(costtime)
  --debugmsg("mon move:"..costtime.."  mondelay:"..self.delay.." pastemtime:"..self.anim.pastTime)
  self.face =  c.face(dx,dy)
  return true
end
  

  
function monster_mt:planAndMove()
  
  --有些特效导致不能移动，在此添加延迟
  --
  --特殊攻击，在移动之前发出，
  --effect处理，特性处理，很杂乱
  
  --先确定态度，无视等态度会stumble
  --取得destination，若都没取得则也会stumble
  --self:move_to_destination(player.x,player.y,player.z)
  
  ---[[
  self:plan()
  
  
  local dest_x,dest_y,dest_z
  if self.goal then
    if self.x==self.goal.x and self.y==self.goal.y and self.z ==self.goal.z then
      self.goal = nil --已达目标点
    else
      dest_x,dest_y,dest_z = self.goal.x,self.goal.y,self.goal.z --获取目标
      self.goal.f= self.goal.f-1 
      if self.goal.f<=0 then self.goal = nil end--unset-dest  回合数已到
    end
  end
  --气味移动（如果有此能力）
  
  --wander（wander_pos  听觉为主）的移动
 
  if dest_x then
    self:move_to_destination(dest_x,dest_y,dest_z) --获取到目标就朝目标移动
  else
    self:stumble();--没有就stumble
  end
  --]]
end

function monster_mt:plan()
  
  --注 cdda 的firendly 正数为限时友好，负数为永久友好
  --一阶段 遍历可能的target ，选出rate最大的target。并确定状态攻击，跟随，逃跑
  
  --采取相应状态的 攻击，跟随，逃跑  实际设定目标地点
  
  local target --目标。 
  local priority --威胁度
  local attitude  = "attack"--采取的态度  flee 逃跑， follow 跟随， 其他的无视等不设为target
  local dist  --真实距离
  --这三个变量都从 ratetarget返回
  
  --简单化的,正式版需要修改
  if self:seesUnit(player) then
    target = player
    attitude = "attack"
    dist = c.dist_3d(self.x,self.y,self.z,player.x,player.y,player.z)
  end
  --npc等 和其他怪物需要等 怪物阵营系统 和npc系统作出后，才能遍历
  
  if target then
    if attitude == "attack" then
      self:set_dest(target.x,target.y,target.z,30)
    elseif attitude=="follow" then
      if dist<5 then
        self:unset_dest()
      else
        self:set_dest(target.x,target.y,target.z,10)
      end
    elseif attitude=="flee" then
      self:set_dest(self.x*2-target.x,self.y*2-target.y,self.z,30)--反向逃跑
    end
  end
end




local function get_candidate_step_list(fromx,fromy,fromz,tox,toy,toz)
  local dx,dy,dz = tox-fromx, toy-fromy, toz- fromz
  local ax,ay = math.abs(dx),math.abs(dy)
  local sgn_x = dx>0 and 1 or -1
  local sgn_y = dy>0 and 1 or -1
  local sgn_z = dz>0 and 1 or -1
  local list = {}
  if dz~=0 then table.insert(list,{fromx,fromy,fromz+sgn_z}) end
  if ax>ay then
    table.insert(list,{fromx+sgn_x,fromy,fromz})
    table.insert(list,{fromx+sgn_x,fromy+sgn_y,fromz})
    table.insert(list,{fromx+sgn_x,fromy-sgn_y,fromz})
    if dy~=0 then table.insert(list,{fromx,fromy+sgn_y,fromz}) end
  elseif ax<ay then
    table.insert(list,{fromx,fromy+sgn_y,fromz})
    table.insert(list,{fromx+sgn_x,fromy+sgn_y,fromz})
    table.insert(list,{fromx-sgn_x,fromy+sgn_y,fromz})
    if dx~=0 then table.insert(list,{fromx+sgn_x,fromy,fromz}) end
  else
    table.insert(list,{fromx+sgn_x,fromy+sgn_y,fromz})
    table.insert(list,{fromx+sgn_x,fromy,fromz})
    table.insert(list,{fromx,fromy+sgn_y,fromz})
  end
  return list
end






--单纯的朝目标移动，动起来！
function monster_mt:move_to_destination(x,y,z)
  local moved = false
  local switch_chance = 0
  local can_bash =  self:has_flag( "MF_BASHES" ) or self:has_flag( "MF_BORES" );
  local can_fly = self:has_flag( "MF_FLIES")
  local distance_to_target  = c.dist_3d(self.x,self.y,self.z,x,y,z)
  local step_list = get_candidate_step_list(self.x,self.y,self.z,x,y,z)
  local next_x,next_y,next_z = 0,0,0
  for i=1,#step_list do
    local candidate = step_list[i]
    local canmove,badchoice,cx,cy,cz = self:pick_candidate_nextstep(candidate[1],candidate[2],candidate[3],can_fly,can_bash)
    if canmove then
      local progress = distance_to_target-c.dist_3d(cx,cy,cz,x,y,z)
      switch_chance = switch_chance+ 2*progress
      if moved==false or x_in_y(progress,switch_chance) then
        moved = true
        next_x,next_y,next_z = cx,cy,cz
        if not badchoice then break end
      end
    end
  end
  self:move_nextStep(moved,next_x,next_y,next_z)--进行下一步
end
--接上一个函数的子方法 返回 move badchoice  cx，cy，cz
function monster_mt:pick_candidate_nextstep(cx,cy,cz,can_fly,can_bash)
  if cz~= self.z then
    local can_conitnue = false
    local ndz = cz - self.z
    local dx,dy,dz = gmap.check_stairs(self.x,self.y,self.z)
    if dz ==ndz then
      cx,cy,cz = self.x+dx,self.y+dy,self.z+dz --确定从楼梯移动
      can_conitnue = true
    end
    if can_fly and (not gmap.impassable(self.x,self.y,cz)) and gmap.has_floor_or_support(self.x,self.y,math.max(self.z,cz)) then --可飞行，且地点可达，没有地板阻挠
      can_conitnue = true
    end
    if not can_conitnue then return false end --撤离，不可行的途径
  end
  
   local bad_choice = false
  --平面移动或可行的垂直移动
  local target = gmap.getUnitInGridWithCheck(cx,cy,cz)
  if target then
    if self:isHostile(target) then
      return true,false,cx,cy,cz --可行的移动，进行攻击
    else
      if (not self:has_flag( "MF_ATTACKMON")) and (not self:has_flag( "MF_PUSH_MON")) then
        return false --不能走有怪的地方
      end
      bad_choice = true
    end
  end
  if cz == self.z and not self:can_move_to(cx,cy,cz) then
    if not can_bash then return false end --不可行 的路径
    local estimate = gmap.bash_rating( self:bash_skill(),cx,cy,cz)
    if estimate<=0 then return false end
    if estimate<5 then bad_choice = true end
  end
  return true,bad_choice,cx,cy,cz
  
end


--实际执行下一步的移动
function monster_mt:move_nextStep(moved,x,y,z)
  if moved then
    local didsomething = false
    if not didsomething then didsomething = self:attack_at(x,y,z) end
    if not didsomething then didsomething = self:bash_at(x,y,z) end
    if not didsomething then didsomething = self:push_to(x,y,z,0,0) end
    if not didsomething then didsomething = self:move_to(x,y,z) end
    if not didsomething then self:addDelay(0.5) end--原地愣着近1回合
  else
    self:stumble();
  end
end


function monster_mt:stumble()
  if not one_in(3) then --有三分之一的可能会移动
    self:addDelay(0.5) --近似1turn
    return
  end
  local can_moveList = {}
  
  for dx =-1,1 do
    for dy = -1,1 do
      local nx = self.x+dx
      local ny = self.y+dy
      local z = self.z
      local dest_movecost = gmap.square_movecost(nx,ny,z)
      local destunit = gmap.getUnitInGridWithCheck(nx,ny,z)
      if dest_movecost>0 and destunit==nil then
        can_moveList[#can_moveList+1] = {nx,ny,z}
      end
    end
  end
  if #can_moveList==0 then return end
  local moveTo = can_moveList[rnd(#can_moveList)]
  self:move_to(moveTo[1],moveTo[2],moveTo[3])
  
end




