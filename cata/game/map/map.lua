g.map = {}
local gmap = g.map
g.overmap = {}
local overmapBase = g.overmap
require"game/map/overmap"
require"game/map/overmapBuffer"
require"game/map/overmapGenerate"

require "game/map/generateSetting"
require "game/map/submap"
require "game/map/submapBuffer"
require "game/map/submapGen"

require "game/map/cache/gridCache"
require "game/map/cache/unitCache"

function gmap.init()
  overmapBase.initOvermapBuffer()
  gmap.initSubmapBuffer()
  gmap.loadSubmapGen()
  
  gmap.initGridCache()
  gmap.initUnitCache()
  
  gmap.cur_overmapGenSetting = gmap.getDefaultOvermapOption()
  gmap.cur_submapGenSetting = gmap.getDefaultSubmapOption()
  
  
  --测试
  overmapBase.generate(0,0)
  --gmap.generateSubmap(0,0,1)
  --gmap.generateSubmap(-1,0,1)
  --gmap.generateSubmap(0,-1,1)
  --gmap.generateSubmap(-1,-1,1)
  gmap.setGridCenterSquare(0,0,1)
  debugmsg("gen end")
end









