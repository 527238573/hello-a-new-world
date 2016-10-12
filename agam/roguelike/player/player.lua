
--单例，有关

g.player = {}
local player = g.player
player.posx =1
player.posy =1

--local pl = g.player


function player.plmove(x,y)
  local tox = player.posx+x
  local toy = player.posy+y
  local movecost = map.move_cost(tox,toy)
  if(movecost>0) then
    if(x~=0 and y~=0) then movecost = movecost+40 end --斜向走增加40点消耗
    movie.pushPlayerWalkAction(player.posx,player.posy,tox,toy)
    player.posx =tox
    player.posy =toy
    return movecost/75
  else
    movie.playerFaceDirection(x)
    return 0
  end
end
