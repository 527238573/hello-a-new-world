local list = {}

list[#list+1] = {
  id = "car_battery",
  name = tl("汽车电池","car battery"),
  --无图像
  cover_all =false,
  location = "tank2",
  durability = 120,
  dmg_mod =80,
  difficulty =2,
  flags = flagt{"FUEL_TANK","TOOL_NONE",},
  item_id = nil,--未填的两项
  breaks_into = nil,
  
  tank = {elec = 2500},
}

list[#list+1] = {
  id = "car_alternator",
  name = tl("汽车发电机","car alternator"),
  --无图像
  cover_all =false,
  location = "anywhere",
  durability = 275,
  dmg_mod =80,
  difficulty =2,
  flags = flagt{"ALTERNATOR","TOOL_WRENCH",},
  item_id = nil,--未填的两项
  breaks_into = nil,
  
  power = -4,
  epower = 780,
}

return list