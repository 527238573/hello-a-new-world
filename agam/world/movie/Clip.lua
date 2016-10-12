--[[
动作片段

--]]


Clip = class("Clip")

Clip.id = "none"
Clip.host = nil--  roguelike单位，
Clip.target = nil
Clip.from_x=0
Clip.from_y=0
Clip.to_x=0
Clip.to_y=0
Clip.time=0.1  --持续时间（游戏中单位）




function Clip:applyToUnit(time,host, target)
  if(self.id =="move") then
    local act = Action()
    act.fromX,act.fromY = mapLayer.mapToRootCrood(self.from_x,self.from_y)
    act.toX,act.toY= mapLayer.mapToRootCrood(self.to_x,self.to_y)
    act.faceRight = self.to_x>self.from_x
    act.turnface = self.to_x ~= self.from_x
    act.time = time
    host:pushAction(act)
  end
end
