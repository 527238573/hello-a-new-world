local player_mt = g.player_mt
local gmap= g.map
local animManager = g.animManager

function player_mt:setPosition(x,y,z)
  if z<c.Z_MIN or z>c.Z_MAX then debugmsg("error: set player postion :z out of range");return end
  gmap.leaveUnitCache(self)
  self.x = x
  self.y = y
  self.z = z
  gmap.enterUnitCache(self)
  gmap.setGridCenterSquare(x,y,z)
  gmap.zLevelCache.setSeenDirty()--使缓存重置
end

local face_table = {7,6,5,8,1,4,1,2,3}
--[[face
 123
 8 4
 765
 --]]
--尝试walk，成功返回true，失败返回false
local function walkMove(self,dest_x,dest_y,dest_z,dx,dy)
  self.face =  face_table[(dy+1)*3 +dx+2] --转向无代价？
  local move_cost = gmap.square_movecost(dest_x,dest_y,dest_z)
  if move_cost<=0 then return false end --不能移动
  local destunit = gmap.getUnitInGridWithCheck(dest_x,dest_y,dest_z)
  if destunit then 
    debugmsg("error walk to unit") --出现这个证明有错。
    return false --有单位不能移动
  end
  
  local costtime  = move_cost/100
  costtime = (dx~=0 and dy~=0) and costtime*1.4 or costtime
  costtime = costtime/c.timeSpeed
  self:setPosition(self.x+dx,self.y+dy,self.z)
  self:setAnimation(animManager.createMoveAnim(self,-64*dx,-64*dy,costtime))
  ui.camera.setZ(self.z)
  g.cameraLock.cameraMove(self.x-dx,self.y-dy,self.x,self.y,costtime,-self.delay)
  self:addDelay(costtime)
  return true
end
--平面移动,垂直移动有其他方法
function player_mt:moveAction(dx,dy)
  --先检定能否move
  local dest_x = self.x+dx
  local dest_y = self.y+dy
  local dest_z = self.z
  
  local destunit = gmap.getUnitInGridWithCheck(dest_x,dest_y,dest_z)
  if destunit then --有单位挡在前面，不能前进了，尝试其他的操作，攻击等。
    if destunit:isFriendly() then
      --其他操作等
    else
      --近战攻击
      self.face =  face_table[(dy+1)*3 +dx+2]
      self:melee_attack(destunit)
    end
    return
  end
  
  
  
  if walkMove(self,dest_x,dest_y,dest_z,dx,dy) then
    return --成功
  end
  --尝试开门
  if gmap.open_door(dest_x,dest_y,dest_z) then
    self:setAnimation(animManager.createMoveAndBackAnim(self,18*dx,18*dy,0.5,0.3))
    self:addDelay(0.5)
    return
  end
  
end

--press space key
function player_mt:spaceAction()
  debugmsg("space pressed")
  --if self:go_stairs() then return end
  local dx,dy,dz = gmap.check_stairs(self.x,self.y,self.z)
  if dx then --有楼梯
    self:go_stairs(dx,dy,dz)
  elseif dy>0 then --出口被堵住
    --todo ：提示被堵住的楼梯
    debugmsg("stairs blocked")
  end
  
end

function player_mt:go_stairs(dx,dy,dz)
  debugmsg("go stairs")
  --检查
  local costtime = 2.1/c.timeSpeed
  self:setPosition(self.x+dx,self.y+dy,self.z+dz)
  local start_x,start_y = -64*dx,-64*dy
  if dx~=0 then start_y = start_y-20*dz else start_y = start_y-20*dz end
  local anim = animManager.createMoveAnim(self,start_x,start_y,costtime)
  if dz>0 then anim.scissor = {0,64,64,85}end
  self.face =  face_table[(dy+1)*3 +dx+2]
  self:setAnimation(anim)
  self:addDelay(costtime)
  g.cameraLock.cameraSet(self.x,self.y,self.z)
end


--dxdy在 -1，0，1中
function player_mt:pickOrDrop(dx,dy)
  local posx,posy,posz = self.x+dx,self.y+dy,self.z
  
  --获取地格上的物品
  if gmap.hasFlag("NOITEM",posx,posy,posz) then
    return
  end--更多的检查有待添加
  
  local itemlist = gmap.getSquareItemList(posx,posy,posz)
  local use_tmplist = false
  local tmplist 
  if itemlist ==c.null_t then 
    use_tmplist = true
    tmplist = {}
  else
    tmplist=itemlist
  end
  local function callback()
    debugmsg("pdwin callback")
    if use_tmplist then
      if #tmplist>0 then
        gmap.setSquareItemList(tmplist,posx,posy,posz)
      end
    else
      --源list
      if #tmplist==0 then
        --空了
        gmap.setSquareItemList(c.null_t,posx,posy,posz)
      end
    end
  end
  ui.pickupOrDropWin:Open(#tmplist>0,tmplist,callback)
end



--回调函数
local function bashDirection(dx,dy)
  if dx==0 and dy==0 then return end --无变化
  
  --原cdda有 smash field web 和 smash corpse 的代码，不应放在这里
  
  --确定bash 力量
  local strength = 50 --暂默认
  local tx,ty,tz = player.x+dx,player.y+dy,player.z
  local bash_t = gmap.bashSquare(tx,ty,tz,strength)
  player.face =  face_table[(dy+1)*3 +dx+2]--转向
  if bash_t.did_bash then
    player:setAnimation(animManager.createMoveAndBackAnim(player,24*dx,24*dy,0.4,0.1))
    player:addDelay(0.35)
    
    --消耗体力，提升近战技能
    --可能手持玻璃制品，碎裂并受伤？
    
    --提示不能击穿
    if bash_t.cant_be_damaged  and one_in(10) then
      local tid,bid = gmap.getTerIdAndBlockId(tx,ty,tz)
      local block_info
      if bid>1 then
        local bi = data.block[bid]
        if bi.bash and bi.bash.str_min ~= -1 then
          block_info = bi
        end
      end
      if block_info then
        g.message.addmsg(string.format(tl("你看起来没有对%s造成任何损伤。","You don't seem to be damaging the %s."),block_info.displayname),"bad")
      else
        local terinfo = data.ster[tid]
        g.message.addmsg(string.format(tl("你看起来没有对%s造成任何损伤。","You don't seem to be damaging the %s."),terinfo.displayname),"bad")
      end
    end
  else
    g.message.addmsg(tl("没有可以砸碎的东西！","There's nothing there to smash!"),"info")
    --提示没有东西可砸。
    player:addDelay(0.15)--缓冲
  end
end

--启用bash命令，打开方向选择窗口，将回调函数传与
function player_mt:Bash()
  --屏幕移动回主角中心
  ui.camera.resetToPlayerPosition()
  ui.directionSelectWin:Open(bashDirection,tl("砸碎哪里？","Smash where?"))

end


local function closeDirection(dx,dy)
  if dx==0 and dy==0 then  
    g.message.addmsg(tl("你挡住了你自己！","There's some buffoon in the way!"),"info")
    return 
  end
  
  
  --省略了大量的检测，家具，怪物，物品，载具等。 需要提示不能关的原因
  player.face =  face_table[(dy+1)*3 +dx+2]--转向
  local didit = gmap.close_door(player.x+dx,player.y+dy,player.z)
  if didit then
    player:setAnimation(animManager.createMoveAndBackAnim(player,16*dx,16*dy,0.3,0.2))
    player:addDelay(0.3)
  end
  
  
end

function player_mt:close_door()
  
  ui.camera.resetToPlayerPosition()
  ui.directionSelectWin:Open(closeDirection,tl("关闭哪里？","Close where?"))
end

