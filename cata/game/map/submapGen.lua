local bit = require("bit")
local lovefs = require("file/lovefs")
--submap generate
local gmap = g.map
local overmapBase = g.overmap

local mapgen_functions -- 总 表
local mapgen_weights  --权重表 

local function empty_gen(oter) error("oter mapgen function empty:"..oter) end  --空

--初始化 mapgen需要的基本数据
local loaded= false
function gmap.loadSubmapGen()
  if loaded then return else loaded = true end
  mapgen_functions = {}
  mapgen_weights = {}
  --全表初始化为空 每个oterid都能在表上找到生成函数
  for i =1,#(data.oter) do
    mapgen_functions[i] = empty_gen
    mapgen_weights[i] = 0
  end
  
  local fs = lovefs(love.filesystem.getSource().."/data/mapgen_builtin")
  for _, v in ipairs(fs.files) do --
    local tmp = dofile("data/mapgen_builtin/"..v) -- 执行文件夹内所有文件，载入所有mapgenfunction
  end
  --读取building生成数据
  fs:cd(love.filesystem.getSource().."/data/mapgen_editor")
  for _, v in ipairs(fs.files) do --
    local tmp = dofile("data/mapgen_editor/"..v) -- 执行文件夹内所有文件，载入所有mapgenfunction
    --
    local building = data.building_name2info[tmp.building_name]--找到对应的
    if(building ==nil) then error("cant find building : "..tmp.building_name) end
    local check = building.xlen == tmp.subx and building.ylen == tmp.suby and building.zmin == tmp.lowz and building.zmax == tmp.highz
    if not check then error("building size not equal ") end
    if tmp.weight<=0 then error("weight must >0") end
    building.mapgen  = c.pushWeightVal(building.mapgen,tmp,tmp.weight)
      
    
    
  end
end

--将func添加到mapgen_functions,考虑权重
function gmap.add_mapgen_function(otername,func,weight)
  weight = weight or 100 --默认权重，100点
  local oter_info  = data.oter_name2info[otername]
  local startid  = oter_info.base_id
  if mapgen_functions[startid] ==empty_gen then
    mapgen_functions[startid] = func
    mapgen_weights[startid] = weight
  elseif type(mapgen_functions[startid])==  "function" then -- 两个，建立weight table
    mapgen_functions[startid] = {mapgen_functions[startid],func}
    mapgen_weights[startid] = {mapgen_weights[startid],mapgen_weights[startid]+weight}
  else --两个以上，插入新函数
    local func_t = mapgen_functions[startid]
    local weight_t = mapgen_weights[startid]
    local curlen = #func_t
    func_t[curlen+1] = func
    weight_t[curlen+1] = weight + weight_t[curlen]
    return --不用修改多个oter_id,省去下面的步奏
  end
  if oter_info.ex_id>0 then --有多个oterid 的情况，共用一个
    for i=1,oter_info.ex_id do
      mapgen_functions[startid+i] = mapgen_functions[startid]
      mapgen_weights[startid+i]= mapgen_weights[startid]
    end
  end
end







--[[生成新的Submap，xyz为submap的绝对坐标.生成完毕后自动加入buffer内,并返回xyz对应的submap
不能重复生成已有的submap，调用之前需确认不存在，（lookupSubmap无法找到并且 无相应保存文件）
可能一次调用会生成多个submap(特殊的overmap建筑，连续的地形等)。可能会生成新的overmap (没有相应的overmap ter，先生成overmap)
--]]
local gendata = {}
function gmap.generateSubmap(x,y,z)
  --先取得oter基本信息
  local oter_id = overmapBase.get_or_create_oterid(x,y,z)
  if oter_id>data.lastOter_nb_id then--类型为building
    return gmap.generateBuilding(oter_id,x,y,z)
  end
  
  --周边信息
  gendata[1] =  overmapBase.get_or_create_oterid(x,y+1,z)
  gendata[2] =  overmapBase.get_or_create_oterid(x+1,y,z)
  gendata[3] =  overmapBase.get_or_create_oterid(x,y-1,z)
  gendata[4] =  overmapBase.get_or_create_oterid(x-1,y,z)
  gendata[5] =  overmapBase.get_or_create_oterid(x-1,y+1,z)
  gendata[6] =  overmapBase.get_or_create_oterid(x+1,y+1,z)
  gendata[7] =  overmapBase.get_or_create_oterid(x+1,y-1,z)
  gendata[8] =  overmapBase.get_or_create_oterid(x-1,y-1,z)
  -- generator function
  local gfunc =  mapgen_functions[oter_id]
  
  if type(gfunc) == "table" then
    local weight_t = mapgen_weights[oter_id]
    local rnd = love.math.random(weight_t[#weight_t])
    gfunc = gfunc[c.search_weight(weight_t,rnd)] --权重搜索
  end
  local subm = gmap.create_submap()
  gfunc(oter_id,subm,gendata,gmap.cur_submapGenSetting)
  
  --[[
  for y= 0,15 do
    for x = 0,15 do
      io.write(tostring(subm.raw:getBlock(x,y)))
      io.write(" ")
    end
    io.write("\n")
  end
  io.flush()
  --]]
  
  gmap.addSubmap(x,y,z,subm)
  return subm
end

require "game/map/buildingGen/buildingGen"
--生成building
function gmap.generateBuilding(oter_id,x,y,z)
  
  local oter_info =data.oter[oter_id] 
  local building = oter_info.building
  if building.mapgen ==nil then 
    local subm = gmap.create_submap()
    subm:fillTer(gmap.cur_submapGenSetting.openair)
    gmap.addSubmap(x,y,z,subm)
    debugmsg("building magen missing:"..building.name)
    return subm
  end
  local mapdata = c.getWeightValue(building.mapgen)
  local rotation = oter_id - oter_info.base_id
  
  
  local function indexsubmap(x,y,z)
    return (z)*mapdata.subx*mapdata.suby +y*mapdata.subx +x +1
  end
  --已初始点0，0旋转相对xy到实际dir变换后的xy
  local function dirXY(dir,x,y)
    if dir==1 then 
      return y,-x
    elseif dir ==2 then 
      return -x,-y
    elseif dir ==3 then 
      return -y,x
    else
      return x,y
    end
  end
  
  
  local submaps = gmap.genBuidlingFromData(mapdata)
  local subm = submaps[indexsubmap(oter_info.rx,oter_info.ry,oter_info.rz)]
  
  local dx,dy = dirXY(rotation,oter_info.rx,oter_info.ry)
  local dz = oter_info.rz
  local ox,oy,oz = x-dx,y-dy,z-dz--原点的位置(位于最下层)
  for x= 0,building.xlen-1 do
    for y = 0,building.ylen-1 do
      for z = 0,building.zlen-1 do
        local subm = submaps[indexsubmap(x,y,z)]
        subm:rotate(rotation)
        local ax,ay = dirXY(rotation,x,y)
        ax =ax+ox
        ay =ay+oy
        local az = oz +z
        if z>=-10 and z<=12 then gmap.addSubmap(ax,ay,az,subm) end --添加
        
        
      end
    end
  end
  
  
  
  return subm
end





