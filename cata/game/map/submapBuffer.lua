local bit = require("bit")
local gmap = g.map

local null_t = c.null_t

local all_overmaps = {} --数据结构根table
local buffermap_in_use = {}--使用中的buffermap

local last_request_overmap --最近取得的overmap坐标
local last_ro_x,last_ro_y -- 最近的读取坐标
local function get_existing_overmap(x,y)  --这里指的overmap 指的是一个overmap大小的容器table，只在本buffer内使用
  if(x==last_ro_x and y == last_ro_y) then return last_request_overmap end
  local a = all_overmaps[x]
  if a==nil then return nil end
  last_request_overmap = a[y]
  last_ro_x,last_ro_y = x,y
  return last_request_overmap  
end

local function get_or_create_overmap(x,y)
  local om = get_existing_overmap(x,y)
  if om~=nil then return om end
  om = {}
  for i = 1,16*16*23 do om[i] = null_t end --depth常数
  if all_overmaps[x] ==nil then all_overmaps[x] = {} end --插入
  all_overmaps[x][y] = om
  last_request_overmap = om
  last_ro_x,last_ro_y = x,y
  return om
end

local function get_or_create_buffermap(overmap, x,y,z)
  local index = (z+10)*256+x*16+y+1
  local bm = overmap[index]
  if bm~= null_t then return bm end
  bm = {}
  for i = 1,256 do bm[i] = null_t end --预填充，保证数据结构为数组
  overmap[index] = bm
  table.insert(buffermap_in_use,bm)
  return bm
end



function gmap.initSubmapBuffer()
  
  
end

function gmap.resetSubmapBuffer()
  all_overmaps = {}
  buffermap_in_use = {}
  last_request_overmap= nil
  last_ro_y = nil
  last_ro_x = nil
end

--将submap保存在mapbuffer中，如果已有值，不能替代
function gmap.addSubmap(x,y,z,subm)
  local sx = bit.arshift(x,8)--使用固定常数 
  local sy = bit.arshift(y,8)
  local om = get_or_create_overmap(sx,sy)
  sx = bit.arshift(bit.band(x,255),4)
  sy = bit.arshift(bit.band(y,255),4)
  local bm = get_or_create_buffermap(om,sx,sy,z)
  sx = bit.band(x,15)
  sy = bit.band(y,15)
  if bm[sx*16+sy+1] ==null_t then
    bm[sx*16+sy+1] = subm
  else
    debugmsg("addSubmap:already existing x:"..x.." y:"..y.."z:"..z)
  end
end

--在内存中急速查找已有的submap
function gmap.lookupSubmap(x,y,z)
  local sx = bit.arshift(x,8)--使用固定常数 
  local sy = bit.arshift(y,8)
  local om = get_existing_overmap(sx,sy)
  if om ==nil then return nil end
  sx = bit.arshift(bit.band(x,255),4)
  sy = bit.arshift(bit.band(y,255),4)
  local bm = om[(z+10)*256+sx*16+sy+1]
  if bm ==null_t then return nil end
  sx = bit.band(x,15)
  sy = bit.band(y,15)
  local sm = bm[sx*16+sy+1]
  if sm ==null_t then return nil end
  return sm
end