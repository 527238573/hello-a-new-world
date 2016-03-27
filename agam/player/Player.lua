require"core/Unit"

player = {}


player.unit = Unit()



local mc1,mc2,mc3,mc4

mc1 = love.graphics.newImage("assets/mc1.png")
mc2 = love.graphics.newImage("assets/mc2.png")
mc3 = love.graphics.newImage("assets/mc3.png")
mc4 = love.graphics.newImage("assets/mc4.png")

local animeList = {mc1,mc2,mc3,mc4}

animeList.len = #animeList
animeList.width = 64
animeList.height = 64
animeList.pingpong  = true -- 来回播放
player.unit.animeList = animeList

gameWorld.addToWorld(player.unit)

--移动，dx dy 取值1或-1 或0
function player.doMove(dx,dy)
  local unit = player.unit
  
  
  if(mapLayer.isLegal(unit.mapx +dx,unit.mapy +dy))then
    local act = Action()
    act.fromX,act.fromY= mapLayer.mapToRootCrood(unit.mapx,unit.mapy)
    unit.mapx = unit.mapx+dx
    unit.mapy = unit.mapy+dy
    act.toX,act.toY= mapLayer.mapToRootCrood(unit.mapx,unit.mapy)
    if(dx<0)then
      act.turnface = true;   act.faceRight = false
    elseif(dx==0)then
      act.turnface = false
    else
      act.turnface = true;   act.faceRight = true
    end
    
    if(dx~=0 and dy~=0)then
      act.time = act.time*1.4
    end
    player.unit:pushAction(act)
    return act.time

  else return 0 end
end




