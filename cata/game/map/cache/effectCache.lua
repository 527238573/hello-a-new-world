local gmap = g.map
local grid = g.map.grid

--square effect
local effectCache  ={}
gmap.effectCache = effectCache

function gmap.initEffectCache()
  
end



function gmap.enterEffectCache(squareEffect)
  if gmap.isSquareInGrid(squareEffect.x,squareEffect.y,squareEffect.z)==false then return end
  local index = (squareEffect.z-grid.minZsub)*20736+(squareEffect.x-grid.minXsquare)*144+(squareEffect.y-grid.minYsquare)+1
  if effectCache[index]==nil then
    local list = {}
    list[1] = squareEffect
    effectCache[index] = list --新建列表
  else
    local list = effectCache[index]
    list[#list+1] = squareEffect
  end
end

function gmap.leaveEffectCache(squareEffect)
  if gmap.isSquareInGrid(squareEffect.x,squareEffect.y,squareEffect.z)==false then return end
  local index = (squareEffect.z-grid.minZsub)*20736+(squareEffect.x-grid.minXsquare)*144+(squareEffect.y-grid.minYsquare)+1
  local list = effectCache[index]
  if list ==nil then
    debugmsg("error:leaveEffectCache cant find list")
    return
  end
  for i=1,#list do
    if list[i] ==squareEffect then
      table.remove(list,i)
      break
    end
  end
  if #list ==0 then --删除空表
    effectCache[index] = nil
  end
end

function gmap.rebuildEffectCache()
  effectCache  ={}
  gmap.effectCache = effectCache
  --重插入所有square effect
  g.animManager.resetEffectCache() --
end


function gmap.getEffectListInGrid(x,y,z)
  local index = (z-grid.minZsub)*20736+(x-grid.minXsquare)*144+(y-grid.minYsquare)+1
  return effectCache[index]
end

