
--宽度为9*16= 144

local ffi = require("ffi")
ffi.cdef[[
typedef struct {  
  float transparent[144][144];
  float seen[144][144];
  bool transparent_dirty;
  bool seen_dirty;
  bool floor_dirty;
  bool floor[144][144];
  bool submapfloor[9][9];
  
} zLevelCache;
]]


local gmap = g.map
local grid = g.map.grid
local zLevelCache = {}
gmap.zLevelCache = zLevelCache

require "game/map/cache/transparentCache"


function zLevelCache.init()
  for i=0,4 do --总共5层cache，与grid一致
    local zcache =  ffi.new("zLevelCache")
    zcache.transparent_dirty = true
    zcache.seen_dirty = true
    zcache.floor_dirty = true
    zLevelCache[i] = zcache
  end
end


function zLevelCache.getCache(z)
  if not(z>=grid.minZsub and z<=grid.maxZsub and z<=12 and z>=-10) then error("get z cache out of range")end
  z= z- grid.minZsub
  return zLevelCache[z],z
end


function zLevelCache.setAllDirty()
  for i=0,4 do
      zLevelCache[i].transparent_dirty = true
      zLevelCache[i].seen_dirty = true
      zLevelCache[i].floor_dirty = true
  end
end

function zLevelCache.setOneLayerTransDirty(z)
  if (z>=grid.minZsub and z<=grid.maxZsub and z<=12 and z>=-10) then
    z= z- grid.minZsub
    zLevelCache[z].transparent_dirty = true
    zLevelCache[z].seen_dirty = true
    --zLevelCache[z].floor_dirty = true
  end
end


function zLevelCache.setSeenDirty()
  --debugmsg("seen dirty")
  gmap.minimap_dirty = true
  for i=0,4 do
      zLevelCache[i].seen_dirty = true
  end
end
  
function zLevelCache.buildAllTransparent()
  for i=0,4 do
    if zLevelCache[i].transparent_dirty == true then
      zLevelCache.buildTransparentCache(zLevelCache[i],i)
    end
  end
end
  
function zLevelCache.isTranspant(x,y,z)
  if gmap.isSquareInGrid(x,y,z) then
    z = z- grid.minZsub
    
    local mx,my = x-grid.minXsquare,y-grid.minYsquare
    --assert(mx>=0 and mx<=143 and math.floor(mx)==mx and my>=0 and my<=143 and math.floor(my)==my,"error! ffi border")
    --return true
    local target_c = zLevelCache[2]
    local value = 0
    --debugmsg("enter trans mx:"..mx.."my:"..my)
    mx,my = math.floor(mx),math.floor(my)
    value = target_c.transparent[mx][my]
    return value>0
    --return zLevelCache[z].transparent[x-grid.minXsquare][y-grid.minYsquare]>0
  else
    return false
  end
end

function zLevelCache.isFloorTranspant(x,y,z)
  if gmap.isSquareInGrid(x,y,z) then
    z = z- grid.minZsub
    return not(zLevelCache[z].floor[x-grid.minXsquare][y-grid.minYsquare])
  else
    return false
  end
end

function zLevelCache.canPlayerSees(x,y,z)
  if gmap.isSquareInGrid(x,y,z) then
    z = z- grid.minZsub
    return (zLevelCache[z].seen[x-grid.minXsquare][y-grid.minYsquare]>0)
  else
    return false
  end
end

