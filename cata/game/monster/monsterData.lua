
local loaded = false
--只映射名字到数据
data.monsterType = {}



function data.loadMonsterData()
  if loaded then return else loaded = true end
  local tmp = dofile("data/monster/monster_type.lua")
  
  for _,v in ipairs(tmp) do
    data.monsterType[v.id] = v
  end
  
end