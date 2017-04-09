
local null_t = c.null_t
local gmap = g.map
local ffi = require("ffi")
ffi.cdef[[
typedef struct { uint16_t ter[16][16];  uint16_t block[16][16]; bool is_uniform; int x;int y;int z;} submap;
]]
local mt = {
  __index = {
    getTer = function(sm,x,y) 
      assert(x>=0 and x<16,"ter X out of index!")
      assert(y>=0 and y<16,"ter Y out of index!")
      return sm.ter[x][y]
    end,
    getBlock = function(sm,x,y) 
      assert(x>=0 and x<16,"block X out of index!")
      assert(y>=0 and y<16,"block Y out of index!")
      return sm.block[x][y]
    end,
    setTer = function(sm,value,x,y) 
      assert(x>=0 and x<16,"ter X out of index!")
      assert(y>=0 and y<16,"ter Y out of index!")
      sm.ter[x][y] = value
    end,
    setBlock = function(sm,value,x,y) 
      assert(x>=0 and x<16,"block X out of index!")
      assert(y>=0 and y<16,"block Y out of index!")
      sm.block[x][y]= value
    end,
    inbounds = function(sm,x,y,z)
      return x>=0 and x<16 and y>=0 and y<16 
    end,
  },
}
local create_raw_submap = ffi.metatype("submap", mt)
local submap_metaTable = {}
submap_metaTable.__index = submap_metaTable

function gmap.create_submap()
  local subm = {}
  local raw = create_raw_submap()
  subm.raw = raw
  raw.is_uniform = false
  subm.item = {}
  for x = 0,15 do
    for y =0,15 do
      subm.item[x*16+y+1] = null_t
    end
  end
  setmetatable(subm,submap_metaTable)
  
  return subm
end


function submap_metaTable:fillTer(tid)
  for x = 0,15 do
    for y = 0,15 do
      self.raw.ter[x][y] = tid
    end
  end
end
  
function submap_metaTable:lineTer(tid,startx,starty,endx,endy)
  local dx = endx - startx
  local dy = endy- starty
  if math.abs(dx)>math.abs(dy) then
    for x = startx,endx,dx<0 and -1 or 1 do
      local y = math.floor((x - startx)/dx *dy+starty+0.5)--四舍五入
      self.raw:setTer(tid,x,y)
    end
  else
    for y = starty,endy,dy<0 and -1 or 1 do
      local x = math.floor((y - starty)/dy *dx+startx+0.5)--四舍五入
      self.raw:setTer(tid,x,y)
    end
  end
end

--必须是，1，2，3   （*90度， 顺时针）
function submap_metaTable:rotate(turns)
  debugmsg("rotate:"..turns)
  turns = turns %4
  if turns==0 then return end
  local function old_xy(nx,ny)
    if turns ==1 then return 15-ny,nx
    elseif turns ==2 then return 15-nx,15-ny
    else return  ny,15-nx end
  end
  local new_raw = create_raw_submap()
  local oldraw = self.raw
  
  for x= 0,15 do --只转ter furniture目前
    for y = 0,15 do
      local oldx,oldy = old_xy(x,y)
      local ter_id = oldraw.ter[oldx][oldy]
      local ter_info = data.ster[ter_id]
      if ter_info.rotate then ter_id = ter_info.rotate[turns] end
      new_raw.ter[x][y] = ter_id
      local block_id = oldraw.block[oldx][oldy]
      if block_id>1 then
        local block_info = data.block[block_id]
        if block_info.rotate then block_id = block_info.rotate[turns] end
      end
      new_raw.block[x][y] = block_id
    end
  end
  self.raw = new_raw
end

local function dumpToTable(subm)
  if subm.raw.is_uniform then return nil end
  local raw = subm.raw
  
  local ret = {version = 1}
  ret.coordinates = {raw.x,raw.y,raw.z}
  ret.squares = {}
  for x = 0,15 do
    for y = 0,15 do
      local square = {}
      local ter_id = raw.ter[x][y]
      square[1] = data.ster[ter_id].name
      local block_id = raw.block[x][y]
      if block_id>1 then square[2] = data.block[block_id].name end
      ret.squares[#ret.squares+1] = square
    end
  end
  return ret
end


function gmap.save_one_submap(subm,dirpath,filepath)
  --先确定是否必要保存，  uniform的块不需保存，只需重新生成
  local tableToSave = dumpToTable(subm)
  if tableToSave==nil then return end
  if not love.filesystem.isDirectory(dirpath) then
    assert(love.filesystem.createDirectory(dirpath),"create submap dir error")
  end
  table.save(tableToSave,filepath)
end

function gmap.load_submap_from_table(submtable)
  local subm = gmap.create_submap()
  local raw = subm.raw
  local index = 1
  for x = 0,15 do
    for y = 0,15 do
      local square = submtable.squares[index]
      
      index = index+1
      local tid = data.ster_name2id[square[1]]
      if tid==nil then 
        debugmsg("error terrain name:"..square[1])
        tid= data.ster_name2id["t_dirt"]
      end
      raw.ter[x][y] = tid
      if square[2] then
        local bid = data.block_name2id[square[2]]
        if bid==nil then
          debugmsg("error block name:"..square[2])
        else
          raw.block[x][y] = bid
        end
      end
    end
  end
  return subm
  
end


