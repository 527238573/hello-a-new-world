local bit = require("bit")
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
require "game/map/cache/zLevelCache"

require "game/map/interface/seeCheck"
function gmap.init()
  overmapBase.initOvermapBuffer()
  gmap.initSubmapBuffer()
  gmap.loadSubmapGen()
  
  gmap.initGridCache()
  gmap.initUnitCache()
  gmap.zLevelCache.init()
  
  gmap.cur_overmapGenSetting = gmap.getDefaultOvermapOption()
  gmap.cur_submapGenSetting = gmap.getDefaultSubmapOption()
  
  
end

function gmap.createGame()
  --
  overmapBase.generate(0,0)
  gmap.setGridCenterSquare(0,0,1)
  debugmsg("gen end")
end
function gmap.save()
  overmapBase.save()
  gmap.saveAllSubmaps()
end
function gmap.load()
  overmapBase.load()
  gmap.resetSubmapBuffer()
end


--地形与家具的结合，目前只查询grid内的
function gmap.square_movecost(x,y,z)
  local sx= bit.arshift(x,4)
  local sy= bit.arshift(y,4)--取得submap坐标
  local sm = gmap.getSubmapInGrid(sx,sy,z)
  if sm==nil then return -1 end -- 不存在的地图标为-1
  local lx = bit.band(x,15)
  local ly = bit.band(y,15)
  
  local ter_info = data.ster[sm.raw:getTer(lx,ly)]
  local move_cost = ter_info.move_cost
  local bid = sm.raw:getBlock(lx,ly)
  if bid>1 then
    local blockinfo = data.block[bid]
    if blockinfo.resetTM then
      move_cost = blockinfo.move_cost
    else
      move_cost = move_cost +blockinfo.move_cost
    end
  end
  return move_cost
end

function gmap.getTerIdAndBlockId(x,y,z)
  local sx= bit.arshift(x,4)
  local sy= bit.arshift(y,4)--取得submap坐标
  local sm = gmap.get_submap(sx,sy,z)
  if sm==nil then return -1,-1 end -- 不存在的地图标为-1
  local lx = bit.band(x,15)
  local ly = bit.band(y,15)
  return sm.raw:getTer(lx,ly),sm.raw:getBlock(lx,ly)
end


local function getStairsOnSquare(x,y,z)
  local tid,bid =gmap.getTerIdAndBlockId(x,y,z)--取得当前地格
  if tid ==-1 then return nil end --超出范围或不存在
  local terinfo = data.ster[tid]
  if terinfo.move_cost<=0 then return nil end--没有楼梯。不可通行的地形。todo：悬空地形的处理
  if bid>1 then --检查block有无
    local blockinfo = data.block[bid]
    if blockinfo.stairs==nil then return nil end
    local dz = blockinfo.stairs=="up" and 1 or -1
    return blockinfo.stairs_dir[1],blockinfo.stairs_dir[2],dz
  else--没有block，可影藏的入口
    if terinfo.stairs==nil then return nil end
    local dz = terinfo.stairs=="up" and 1 or -1
    return terinfo.stairs_dir[1],terinfo.stairs_dir[2],dz
  end
end

--返回dx，dy，dz，没有则返回nil ,msgid,typeid
function gmap.check_stairs(x,y,z)
  local tx,ty,tz = getStairsOnSquare(x,y,z)
  if tx then
    --有了楼梯，检查是否有出入口
    if tx==0 and ty==0  then  --直梯
      local mx,my,mz = getStairsOnSquare(x,y,z+tz)
      if mx ==0 and my==0 and mz == -tz then
        return tx,ty,tz 
      else
        return nil,1,1 --未找到楼梯出口，直梯
      end
    else--有向楼梯
      local mx,my,mz = getStairsOnSquare(x+tx,y+ty,z+tz) --第一个检查正常一格外
      if  mx ==-tx and my==-ty and mz == -tz then
        return tx,ty,tz
      end
      mx,my,mz = getStairsOnSquare(x+2*tx,y+2*ty,z+tz)--第二个检查2格外
      if  mx ==-tx and my==-ty and mz == -tz then
        return tx*2,ty*2,tz
      end
      return nil,1,2 --未找到楼梯出口，有向
    end
  else
    --没有楼梯
    return nil,0,0--本格不是楼梯
  end
end








