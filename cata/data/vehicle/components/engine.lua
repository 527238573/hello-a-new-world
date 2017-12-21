local list = {}

list[#list+1] = {
  id = "engine_v2",
  name = tl("双缸发动机","V-twin engine"),
  quads = {
    img = "veh_components1",
    [1] = {8,4},
    },
  cover_all =false,
  location = "anywhere",
  durability = 200,
  dmg_mod =80,
  difficulty =2,
  flags = flagt{"ENGINE", "GASOLINE", "TOOL_WRENCH"},
  item_id = nil,--未填的两项
  breaks_into = nil,
}

list[#list+1] = {
  id = "engine_v4",
  name = tl("四缸发动机","V4 engine"),
  quads = {
    img = "veh_components1",
    [1] = {7,3},
    },
  cover_all =false,
  location = "under",
  durability = 300,
  dmg_mod =80,
  difficulty =2,
  flags = flagt{"ENGINE", "GASOLINE", "TOOL_WRENCH"},
  item_id = nil,--未填的两项
  breaks_into = nil,
}

list[#list+1] = {
  id = "engine_v6",
  name = tl("六缸发动机","V6 engine"),
  quads = {
    img = "veh_components1",
    [1] = {8,3},
    },
  cover_all =false,
  location = "under",
  durability = 400,
  dmg_mod =80,
  difficulty =3,
  flags = flagt{"ENGINE", "GASOLINE", "TOOL_WRENCH"},
  item_id = nil,--未填的两项
  breaks_into = nil,
}

list[#list+1] = {
  id = "engine_v8",
  name = tl("八缸发动机","V8 engine"),
  quads = {
    img = "veh_components1",
    [1] = {9,3},
    },
  cover_all =false,
  location = "under",
  durability = 400,
  dmg_mod =80,
  difficulty =3,
  flags = flagt{"ENGINE", "GASOLINE", "TOOL_WRENCH"},
  item_id = nil,--未填的两项
  breaks_into = nil,
}



list[#list+1] = {
  id = "gas_tank_60",
  name = tl("汽油箱(60L)","gasoline tank (60L)"),
  quads = {
    img = "veh_components1",
    [1] = {7,4},
    },
  cover_all =false,
  location = "tank",
  durability = 150,
  dmg_mod =80,
  difficulty =1,
  flags = flagt{"FUEL_TANK"},
  item_id = nil,--未填的两项
  breaks_into = nil,
  
  tank = {gas = 60000},
}




return list