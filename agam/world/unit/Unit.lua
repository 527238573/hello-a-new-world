
Unit = class("Unit")
Unit.layer = 5


Unit.mapx = 1
Unit.mapy = 1
Unit.x = 32
Unit.y = 0
Unit.animRate = 0  --帧播放的百分比
Unit.faceRight = true   --朝向


Unit.actionPastTime = 0

function Unit:init()
  self.actionList = {}
end


function Unit:pushAction(action)
  if(self.actionList==nil)then self.actionList = {} end
  self.actionList[#self.actionList +1] = action
end



function Unit:update(dt)
  
  if(#self.actionList ==0) then return end
  self.actionPastTime  = self.actionPastTime +dt
  
  while(#self.actionList>0 and self.actionPastTime>=self.actionList[1].time) do -- 超时
      self.actionList[1]:applyByRate(self,1)
      self.actionPastTime = self.actionPastTime - self.actionList[1].time
      table.remove(self.actionList,1)
  end
  if(#self.actionList ==0)then
    --播放结束
    return
  end
  self.actionList[1]:applyAction(self)
  
end


function Unit:draw()
  
  local len = self.animeList.len
  if(len>2 and self.animeList.pingpong) then len = len*2 -2 end   -- 来回动画
  
  local onerate = 1/len
  local userate = onerate *0.5 +self.animRate
  userate = math.floor(userate/onerate) % len +1
  if(self.animeList.pingpong and userate>self.animeList.len) then
    userate = self.animeList.len - (userate - self.animeList.len)
  end
  
  
  local image = self.animeList[userate]
  
  local drawx = self.x - 0.5 *self.animeList.width
  local drawy = self.y + self.animeList.height
  drawx,drawy = worldToScreen(drawx,drawy)
  local scaleX;
  if(self.faceRight) then scaleX = 1 else scaleX = -1  ;drawx = drawx + self.animeList.width end
    
  love.graphics.draw(image,drawx,drawy,0,scaleX,1)
end




function createUnit(animeName)
  local u = Unit()
  u.animeList = animeLists[animeName]
  if(u.animeList == nil) then error("error animeName not found") end
  return u
end

