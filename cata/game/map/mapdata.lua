
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
end

local function loadBlockTable(block_t)
  for _,v in ipairs(block_t) do
    table.insert(block_list,v)
    block_name2info[v.name] = v
    block_name2id[v.name] = #block_list
    v.id = #block_list --记录id
  end
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