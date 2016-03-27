
Action = class("Action")

Action.id = "moveLine"
Action.fromX = 0
Action.fromY = 0
Action.toX =64
Action.toY = 0
Action.time = 0.4
Action.faceRight = true
Action.turnface = false -- 是否应用朝向


function Action:applyByRate(unit,rate)
  
  
  if(self.time==0)then rate =1 end
  if(self.id =="moveLine")then
    
    
    unit.x = self.fromX  + rate * (self.toX - self.fromX)
    unit.y = self.fromY  + rate * (self.toY - self.fromY)
    
    if(self.turnface) then unit.faceRight = self.faceRight end
    unit.animRate = rate
  end
end


function Action:applyAction(unit)
  local rate  = unit.actionPastTime/self.time
  self:applyByRate(unit,rate)
end
