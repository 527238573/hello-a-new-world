
local loaded = false
local ter_list = {}
local ter_name2info = {}
local ter_name2id = {}

local block_list={}
local block_name2info={}
local block_name2id={}

data.ster = ter_list
data.ster_name2info = ter_name2info
data.ster_name2id = ter_name2id

data.block = block_list
data.block_name2info = block_name2info
data.block_name2id = block_name2id




local function loadTerTable(ter_t)
  for _,v in ipairs(ter_t) do
    table.insert(ter_list,v)
    ter_name2info[v.name] = v
    ter_name2id[v.name] = #ter_list
    v.id = #ter_list --记录id
  end
  
  --连接字符串为id
  for i= 1 ,#ter_list do
    if ter_list[i].rotate then
      local rt = ter_list[i].rotate
      rt[1] = ter_name2id[rt[1]]
      rt[2] = ter_name2id[rt[2]]
      rt[3] = ter_name2id[rt[3]]
    end
  end
  
end

local function loadBlockTable(block_t)
  for _,v in ipairs(block_t) do
    table.insert(block_list,v)
    block_name2info[v.name] = v
    block_name2id[v.name] = #block_list
    v.id = #block_list --记录id
  end
  --连接字符串为id
  for i= 1 ,#block_list do
    if block_list[i].rotate then
      local rt = block_list[i].rotate
      rt[1] = block_name2id[rt[1]]
      rt[2] = block_name2id[rt[2]]
      rt[3] = block_name2id[rt[3]]
    end
  end
  block_list[0] = block_name2info["f_null"] --空的block，
  
end



function data.loadTerAndBlockData()
  if loaded then return else loaded = true end
  local tmp = dofile("data/terrain_data.lua")
  loadTerTable(tmp)
  data.Ster_BigImage = tmp.img
  tmp = dofile("data/block_data.lua")
  loadBlockTable(tmp)
  data.Block_BigImage = tmp.img
  
end