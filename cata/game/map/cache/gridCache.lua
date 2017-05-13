local bit = require("bit")
local gmap = g.map

local null_t = c.null_t--空置占位
local grid_length = 9 -- grid为9*9的submap  在unitcache中使用了常数，加速
local grid_height = 5 --高度为5的submap

local grid  ={} -- 存储所有submap 
gmap.grid = grid
grid.grid_length = grid_length
grid.grid_height = grid_height
gmap.minimap_dirty = true--关系到minimap是否重建
local updateLimitedField --函数声明


function gmap.initGridCache()
  for x =0,grid_length-1 do 
    for y = 0,grid_length-1 do
      for z = 0,grid_height -1 do
        grid[z*81+x*9+y+1] = null_t --全部初始化为null.对于超出边界的submap，全使用null_t占位
      end
    end
  end
  grid.csquareX = 0
  grid.csquareY = 0
  grid.centerX = 0
  grid.centerY = 0
  grid.centerZ = -100   --不可能的值，用做初始状态
  updateLimitedField()
end

--随即更新镜头field的限制范围  submap范围， square范围
function updateLimitedField()
  --submap范围
  grid.minXsub = grid.centerX -4 -- 范围数据
  grid.maxXsub = grid.centerX +4
  grid.minYsub = grid.centerY -4
  grid.maxYsub = grid.centerY +4
  grid.minZsub = grid.centerZ -2
  grid.maxZsub = grid.centerZ +2
  --square范围 z 使用和submap相同
  grid.minXsquare = grid.minXsub*c.SUBMAP_L
  grid.maxXsquare = grid.maxXsub*c.SUBMAP_L+15
  grid.minYsquare = grid.minYsub*c.SUBMAP_L
  grid.maxYsquare = grid.maxYsub*c.SUBMAP_L+15
  
  --镜头field的限制范围  
  grid.field_minX = grid.minXsub*c.SQUARE_L*c.SUBMAP_L
  grid.field_maxX = (grid.maxXsub+1)*c.SQUARE_L*c.SUBMAP_L --计算右侧边缘，所以+1
  grid.field_minY = grid.minYsub*c.SQUARE_L*c.SUBMAP_L
  grid.field_maxY = (grid.maxYsub+1)*c.SQUARE_L*c.SUBMAP_L
  grid.fieldz_min = math.max(grid.minZsub,c.Z_MIN)
  grid.fieldz_max = math.min(grid.maxZsub,c.Z_MAX) --z层数的限制范围
end

--[[修改中心坐标
--]]
--输入坐标为square坐标 ,必须是合法值，即z在范围内
function gmap.setGridCenterSquare(x,y,z)
  grid.csquareX = x;grid.csquareY = y;--记录详细square位置
  x= bit.arshift(x,4)
  y= bit.arshift(y,4)--取得submap坐标
  
  if x~= grid.centerX or y~= grid.centerY or z~= grid.centerZ then --中心submap改变，所有cache需要改变
    local dx,dy,dz = x-grid.centerX,y-grid.centerY,z-grid.centerZ
    grid.centerX  = x
    grid.centerY  = y
    grid.centerZ  = z
    --更新镜头限制范围
    updateLimitedField()
    
    print("gridCenter:",x,y,z,"min-max:",grid.minXsub,grid.maxXsub,grid.minYsub,grid.maxYsub)
    io.flush()
    if math.abs(dx)<=1 and math.abs(dy)<=1 and math.abs(dz)<=1 then
      gmap.shift(dx,dy,dz)
    else
      gmap.reloadGrid()
    end
    gmap.rebuildUnitCache()
    gmap.zLevelCache.setAllDirty()
    gmap.minimap_dirty = true
  end
end




--位移地图 --写的太复杂， 其实效率并没有高多少
function gmap.shift(dx,dy,dz)
  --[[
  local startx,endx,stepx,loadx
  local starty,endy,stepy,loady
  local startz,endz,stepz,loadz
  if dx>=0 then
    startx,endx,stepx,loadx = grid.minXsub,grid.maxXsub,1,grid.maxXsub+1 -dx
  else
    startx,endx,stepx,loadx = grid.maxXsub,grid.minXsub,-1,grid.minXsub
  end
  if dy>=0 then 
    starty,endy,stepy,loady = grid.minYsub,grid.maxYsub,1,grid.maxYsub+1 - dy
  else
    starty,endy,stepy,loady = grid.maxYsub,grid.minYsub,-1,grid.minYsub
  end
  if dz>=0 then 
    startz,endz,stepz,loadz = grid.minZsub,grid.maxZsub,1,grid.maxZsub+1 - dz
  else
    startz,endz,stepz,loadz = grid.maxZsub,grid.minZsub,-1,grid.minZsub
  end
  for x = startx,endx,stepx do 
    for y = starty,endy,stepy do
      for z = startz,endz,stepz do 
        if x ==loadx or y == loady or z ==loadz then
          grid[z*81+x*9+y+1] = gmap.loadSubmapToGridCache(x,y,z)
        else
          grid[z*81+x*9+y+1] = grid[(z+dz)*81+(x+dx)*9+(y+dy)+1]
        end
      end
    end
  end
  --]]
  gmap.reloadGrid()
end

--全部重读取
function gmap.reloadGrid()
  for x = 0,grid_length-1 do 
    for y = 0,grid_length-1 do
      for z = 0,grid_height -1 do 
        grid[z*81+x*9+y+1] = gmap.loadSubmapToGridCache(grid.minXsub+x,grid.minYsub+y,grid.minZsub+z)
      end
    end
  end
  
  
end



--[[获得该坐标的submap 
若z超出范围则返回null_t
首先从内存中查找， 查不到则从存档文件 中查找， 再查不到则generate新的。(其中可能产生联动generate多个submap或generate新的overmap，导致游戏暂停)
--]]
function gmap.loadSubmapToGridCache(x,y,z)
  if z<c.Z_MIN or z>c.Z_MAX then return null_t end
  local sm  =gmap.lookupSubmap(x,y,z) -- 在内存中查找
  --读取文件:内存中找不到，在磁盘中找
  if sm ==nil then 
    sm =gmap.unserialize_submap(x,y,z)
  end
  if sm ==nil then --都没找到，新生成
    sm = gmap.generateSubmap(x,y,z)
  end
  return sm
end



--[[在grid中取得submap，会检查范围，超出返回nil 可能返回null_t,
--]]
function gmap.getSubmapInGrid(x,y,z)
  if x>= grid.minXsub and x<= grid.maxXsub and y>=grid.minYsub and y<=grid.maxYsub and z>=grid.minZsub and z<= grid.maxZsub then 
    return grid[(z-grid.minZsub)*81+(x-grid.minXsub)*9+(y-grid.minYsub)+1]
  end
  return nil
end
function gmap.getRelativeSubmapInGrid(x,y,z) --未检查，小心使用
  return grid[z*81+x*9+y+1]
end


--取得连续的blockdata, 范围 blockid ，该格上的unit
function gmap.getblockDataInGrid(x,y,z)
  local sx= bit.arshift(x,4)
  local sy= bit.arshift(y,4)--取得submap坐标
  local sm = gmap.getSubmapInGrid(sx,sy,z)
  if sm==nil then return nil,nil end
  local lx,ly = bit.band(x,15),bit.band(y,15)
  return sm.raw:getBlock(lx,ly),gmap.getUnitInGrid(x,y,z),sm.item[lx*16+ly+1]--物品table
end

function gmap.getBlockInGrid(x,y,z)
  local sx= bit.arshift(x,4)
  local sy= bit.arshift(y,4)--取得submap坐标
  local sm = gmap.getSubmapInGrid(sx,sy,z)
  if sm==nil then return nil end
  return sm.raw:getBlock(bit.band(x,15),bit.band(y,15))
end

function gmap.getBlockAndItemsInGrid(x,y,z)
  local sx= bit.arshift(x,4)
  local sy= bit.arshift(y,4)--取得submap坐标
  local sm = gmap.getSubmapInGrid(sx,sy,z)
  if sm==nil then return nil,nil end
  local lx,ly = bit.band(x,15),bit.band(y,15)
  return sm.raw:getBlock(lx,ly),sm.item[lx*16+ly+1]--物品table
end


function gmap.isWallTerInGrid(x,y,z)
  local sx= bit.arshift(x,4)
  local sy= bit.arshift(y,4)--取得submap坐标
  local sm = gmap.getSubmapInGrid(sx,sy,z)
  if sm==nil then return false end
  local info = data.ster[sm.raw:getTer(bit.band(x,15),bit.band(y,15))]
  return info.type==4
  
end

function grid.getSeenOrigen()
  --就已palyer为中心
  return player.x - grid.minXsquare,player.y - grid.minYsquare,player.z - grid.minZsub
end


function grid.addUsingSubmap()
  for x = 0,grid_length-1 do 
    for y = 0,grid_length-1 do
      for z = 0,grid_height -1 do 
        local subm = grid[z*81+x*9+y+1]
        if subm~= null_t then
          gmap.addSubmap(grid.minXsub+x,grid.minYsub+y,grid.minZsub+z,subm)
        end
      end
    end
  end
end

--检查坐标是否在grid内
function gmap.isSquareInGrid(x,y,z)
  return z>=-10 and z<=12 and z>=grid.minZsub and z<=grid.maxZsub and x>=grid.minXsquare and x<=grid.maxXsquare and y>=grid.minYsquare and y<=grid.maxYsquare 
end

