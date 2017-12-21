local list = {}

list[#list+1] = {
  id = "trunk",
  name = tl("后备箱","trunk"),
  quads = {
    img = "veh_components1",
    [1] = {4,1},
    },
  cover_all =true,
  location = "center",
  durability = 350,
  dmg_mod =80,
  difficulty =1,
  flags = flagt{"COVERED"},
  item_id = nil,--未填的两项
  breaks_into = nil,
  
  cargo = 650,--存储空间。
}

list[#list+1] = {
  id = "floor_trunk",
  name = tl("地板行李箱","floor trunk"),
  quads = {
    img = "veh_components1",
    [1] = {6,1},
    },
  cover_all =true,
  location = "center",
  durability = 400,
  dmg_mod =100,
  difficulty =1,
  flags = flagt{"AISLE", "BOARDABLE","COVERED"},
  item_id = nil,--未填的两项
  breaks_into = nil,
  
  cargo = 350,--存储空间。
}



return list