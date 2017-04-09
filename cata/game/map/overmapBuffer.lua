local bit = require("bit")
local overmapBase=g.overmap

--overmap系统的对外接口
--[[--
overmap格式
om=overmaps[x][y] 存储一个overmap

--]]--




local overmaps = {}--存储数据的网格

local unseen_id--用于返回值
local river_id--用于判定
local road_id

function overmapBase.initOvermapBuffer()
  unseen_id = data.oter_name2id["unseen"]
  river_id = data.oter_name2id["river"]
  road_id = data.oter_name2id["road"]
end
local last_request_overmap--最近取得的overmap坐标
local last_ro_x,last_ro_y -- 最近的读取坐标
local function get_existing_overmap(x,y)
  if(last_request_overmap and x==last_ro_x and y == last_ro_y) then return last_request_overmap end
  local a = overmaps[x]
  if a==nil then return nil end
  last_request_overmap = a[y]
  last_ro_x,last_ro_y = x,y
  return last_request_overmap  
end
overmapBase.get_existing_overmap = get_existing_overmap

--[[添加新的overmap,不能覆盖原有的。通常由generate完毕后调用
--]]
function overmapBase.addOvermap(om,x,y)
  if overmaps[x] ==nil then overmaps[x] = {} end
  if overmaps[x][y] ==nil then 
    overmaps[x][y] = om
    last_request_overmap = nil --重置缓存
    last_ro_x = nil
    last_ro_y = nil
  else
    debugmsg("addOvermap:already existing x:"..x.." y:"..y)
  end
end

function overmapBase.resetAll()
  overmaps = {}
  last_request_overmap = nil --重置缓存
  last_ro_x = nil
  last_ro_y = nil
end


--全局oter坐标，最速读取  返回整数类型的 oter类型  (对于任何未生成的或不可见的均返回unseen)
function overmapBase.get_visible_oterid(x,y,z)
  --取得overmap块坐标
  local om_x = bit.arshift(x,8)--使用固定常数，不再修改，一个overmap256*256个ter。
  local om_y = bit.arshift(y,8)
  local om = get_existing_overmap(om_x,om_y)
  if om==nil then return unseen_id end
  local tx = bit.band(x,255)
  local ty = bit.band(y,255)
  local seen =  om:getSeen(tx,ty,z)
  if seen then return om:getOter(tx,ty,z) else return unseen_id end
end

--全局oter坐标，强行get坐标，对于不存在的overmap进行创建
function overmapBase.get_or_create_oterid(x,y,z)
  local om_x = bit.arshift(x,8)--使用固定常数，不再修改，一个overmap256*256个ter。
  local om_y = bit.arshift(y,8)
  local om = get_existing_overmap(om_x,om_y)
  if om==nil then om =overmapBase.generate(om_x,om_y) end
  local tx = bit.band(x,255)
  local ty = bit.band(y,255)
  return om:getOter(tx,ty,z)
end


--判定oter是否是river 
function overmapBase.isRiver(oter_id)
  return oter_id == river_id
end

--判定oter是否是road
function overmapBase.isRoad(oter_id)
  return oter_id == road_id
end

function overmapBase.save()
  local dirname = g.profileName.."/overmap"
  local abs_dir = g.profile_savedir.."/overmap"
  if not love.filesystem.exists(dirname) then
    assert(love.filesystem.createDirectory(dirname),"create dir error")
  end
  for x,ylist in pairs(overmaps) do
    for y,om in pairs(ylist) do
      overmapBase.saveOneOvermap(om,x,y,abs_dir)
    end
  end
end

function overmapBase.load()
  overmapBase.resetAll()
  local omdirpath = g.profile_savedir.."/overmap"
  local files = love.filesystem.getDirectoryItems(g.profileName.."/overmap")
   for _, filename in ipairs(files) do 
    debugmsg("load omfile:"..filename)
    if filename:sub(1,2)=="o." then
      local dot = string.find(filename,"%.",3)
      local xstr = string.sub(filename,3,dot-1)
      local ystr = string.sub(filename,dot+1)
      local ox = tonumber(xstr)
      local oy = tonumber(ystr)
      if ox==nil or oy==nil then
        debugmsg("error overmap filename:"..filename)
      else
        local onepath = omdirpath.."/"..filename
        local omtable = table.load(onepath) 
        if omtable==nil then debugmsg("error overmap load unknow:"..filename)end
        local om = overmapBase.load_overmap_from_table(omtable)
        overmapBase.addOvermap(om,ox,oy)
      end
    end
  end
  
end
