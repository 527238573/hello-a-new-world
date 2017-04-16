local gmap = g.map
local grid = g.map.grid


local unitCache  ={}
gmap.unitCache = unitCache

function gmap.initUnitCache()
  
end


local function inbounds(unit)
  return unit.z>=grid.minZsub and unit.z<=grid.maxZsub and unit.x>=grid.minXsquare and unit.x<=grid.maxXsquare and unit.y>=grid.minYsquare and unit.y<=grid.maxYsquare 
end


--unit必须有xyz属性
function gmap.leaveUnitCache(unit)
  if inbounds(unit)==false then return end
  
  local index = (unit.z-grid.minZsub)*20736+(unit.x-grid.minXsquare)*144+(unit.y-grid.minYsquare)+1
  if unitCache[index] ==unit then 
    unitCache[index] = nil
  elseif unitCache[index]~=nil then
    debugmsg("warnging:unit Leave Cache find another in position")
  end
end


function gmap.enterUnitCache(unit)
  if inbounds(unit)==false then return end
  local index = (unit.z-grid.minZsub)*20736+(unit.x-grid.minXsquare)*144+(unit.y-grid.minYsquare)+1
  if unitCache[index]~=nil then
    debugmsg("error:unit Enter Cache find another in positon,could cause error")
  end
  unitCache[index] = unit
end


function gmap.rebuildUnitCache()
  unitCache  ={}
  gmap.unitCache = unitCache
  
  if player then gmap.enterUnitCache(g.player)end --先插入player
  g.monster.resetUnitCache()--重插入所有怪物
end

function gmap.getUnitInGrid(x,y,z)
  local index = (z-grid.minZsub)*20736+(x-grid.minXsquare)*144+(y-grid.minYsquare)+1
  return unitCache[index]
end
function gmap.getUnitInGridWithCheck(x,y,z)
  if not gmap.isSquareInGrid(x,y,z) then return nil end
  local index = (z-grid.minZsub)*20736+(x-grid.minXsquare)*144+(y-grid.minYsquare)+1
  return unitCache[index]
end
