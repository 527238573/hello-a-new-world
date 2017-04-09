local bit = require("bit")
local gmap = g.map

local null_t = c.null_t

local all_overmaps = {} --数据结构根table
local submap_in_use = {}--使用中的所有submap

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
  return bm
end



function gmap.initSubmapBuffer()
  
  
end


local last_request_submap--缓存
local last_rs_x,last_rs_y,last_rs_z
function gmap.get_submap(x,y,z)
  if x==last_rs_x and y==last_rs_y and z==last_rs_z then
    return last_request_submap
  else
    last_request_submap = gmap.lookupSubmap(x,y,z)
    return last_request_submap
  end
end



function gmap.resetSubmapBuffer()
  all_overmaps = {}
  submap_in_use = {}
  last_request_overmap= nil
  last_ro_y = nil
  last_ro_x = nil
  last_request_submap= nil
  last_rs_x =nil;last_rs_y=nil;last_rs_z=nil
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
    if x==last_rs_x and y==last_rs_y and z==last_rs_z then last_request_submap = subm end--改变时更新缓存
    submap_in_use[#submap_in_use+1] = subm --插入单一列表，方便统计总数，查看内存占用
    --坐标
    subm.raw.x = x
    subm.raw.y = y
    subm.raw.z = z
  else
    debugmsg("ERROR:addSubmap:already existing x:"..x.." y:"..y.."z:"..z)
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

function gmap.unserialize_submap(x,y,z)
  if g.newCreatedPorfile then return nil end
  
  local bx = bit.arshift(x,5)--使用固定常数
  local by = bit.arshift(y,5)--使用固定常数
  local path = g.profile_savedir.."/submap/"..bx.."."..by.."/"..x.."."..y.."."..z..".submap"
  local submtable,err = table.load( path )
  if submtable==nil then return nil end
  local subm = gmap.load_submap_from_table(submtable)
  gmap.addSubmap(x,y,z,subm)--添加到内存中
  return subm
end




--保存所有submap，顺便释放内存
function gmap.saveAllSubmaps()
  local dirname = g.profileName.."/submap"
  local abs_dir = g.profile_savedir.."/submap"
  if not love.filesystem.exists(dirname) then
    assert(love.filesystem.createDirectory(dirname),"create dir error")
  end
  
  for i=1,#submap_in_use do
    local subm = submap_in_use[i]
    local sx = subm.raw.x
    local sy = subm.raw.y
    local sz = subm.raw.z
    local bx = bit.arshift(sx,5)--使用固定常数
    local by = bit.arshift(sy,5)--使用固定常数
    local bname = "/"..bx.."."..by
    local subdir_name = dirname..bname
    local file_name = abs_dir..bname.."/"..sx.."."..sy.."."..sz..".submap"
    gmap.save_one_submap(subm,subdir_name,file_name)
  end
  
  gmap.resetSubmapBuffer()--删除所有
  gmap.grid.addUsingSubmap()--将还有引用的加进来
end




