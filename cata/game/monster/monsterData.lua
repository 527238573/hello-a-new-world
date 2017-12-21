
local loaded = false
--只映射名字到数据
data.monsterType = {}

local default_value = {
  id = "noid",
  name = "no_name_monster",
  description = "no_decription",
  anim_id = "zombie1",
  species="ZOMBIE",
  size = 3, --1，TINY 2 SMALL，3 MEDIUM，4 LARGE，5 HUGE
  material = "flesh", --material 只有一种类型，不同于item
  diff=0,
  aggression=100,
  morale=100,
  speed=70,
  hp=80,
  attack_cost = 150,
  melee_skill=4,
  melee_dice=2,
  melee_dice_sides=3,
  melee_cut=0,
  dodge=0,
  defence = 0,--防御挨打等级
  armor_bash=0,
  armor_cut=0,
  armor_stab=0,
  armor_acid=0,
  armor_fire=0,
  vision_day=40,
  vision_night=3,
  flags= {},
}

local function addOneMonsterType(mtype)
  for k,v in pairs(default_value) do
    if mtype[k]==nil then
      mtype[k] = v
    end
  end
  data.monsterType[mtype.id] = mtype
  
  
  
  
end



function data.loadMonsterData()
  if loaded then return else loaded = true end
  local tmp = dofile("data/monster/monster_type.lua")
  
  for _,v in ipairs(tmp) do
    addOneMonsterType(v)
  end
  
end