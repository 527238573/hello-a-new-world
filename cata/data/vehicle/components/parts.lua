local list = {}

list[#list+1] = {
  id = "aisle",
  name = tl("过道","aisle"),
  quads = {
    img = "veh_components1",
    [1] = {0,1},
    },
  cover_all =true,
  location = "center",
  durability = 400,
  dmg_mod =100,
  difficulty =1,
  flags = flagt{"AISLE", "BOARDABLE",},
  item_id = nil,--未填的两项
  breaks_into = nil,
}


list[#list+1] = {
  id = "windshield",
  name = tl("挡风玻璃","windshield"),
  styles = {
    {img = "veh_components1",[1]={1,1},},
    {img = "veh_components1",[1]={9,1},},--侧面
    {img = "veh_components1",[1]={9,1},sx=-1},
  },
  
  cover_all =true,
  location = "center",
  durability = 50,
  dmg_mod =70,
  difficulty =1,
  flags = flagt{"OVER", "OBSTACLE", "WINDOW"},
  item_id = nil,--未填的两项
  breaks_into = nil,
}

list[#list+1] = {
  id = "roof",
  name = tl("车顶盖","roof"),
  quads = {
    img = "veh_components1",
    [1] = {7,1},
    },
  cover_all =false,
  location = "roof",
  durability = 240,
  dmg_mod =100,
  difficulty =1,
  flags = flagt{"ROOF"},
  item_id = nil,--未填的两项
  breaks_into = nil,
}




list[#list+1] = {
  id = "seat",
  name = tl("座椅","seat"),
  quads = {
    img = "veh_components1",
    [1] = {3,1},
    },
  cover_all =true,
  location = "center",
  durability = 200,
  dmg_mod =60,
  difficulty =1,
  flags = flagt{"SEAT", "BOARDABLE","BELTABLE", "TOOL_WRENCH"},
  item_id = nil,--未填的两项
  breaks_into = nil,
  
  cargo = 100,--存储空间。
}


list[#list+1] = {
  id = "reclining_seat",
  name = tl("可躺座椅","reclining seat"),
  quads = {
    img = "veh_components1",
    [1] = {3,1},
    },
  cover_all =true,
  location = "center",
  durability = 100,
  dmg_mod =60,
  difficulty =2,
  flags = flagt{"SEAT", "BOARDABLE","BELTABLE", "TOOL_WRENCH","BED",},
  item_id = nil,--未填的两项
  breaks_into = nil,
  
  cargo = 25,--存储空间。
}


list[#list+1] = {
  id = "military_seat",
  name = tl("军用座椅","military seat"),
  quads = {
    img = "veh_components1",
    [1] = {3,1},
    },
  cover_all =true,
  location = "center",
  durability = 300,
  dmg_mod =50,
  difficulty =1,
  flags = flagt{"SEAT", "BOARDABLE","BELTABLE", },
  item_id = nil,--未填的两项
  breaks_into = nil,
  
}

list[#list+1] = {
  id = "controls",
  name = tl("载具控制器","vehicle controls"),
  quads = {
    img = "veh_components1",
    [1] = {8,2},
    },
  cover_all =false,
  location = "top",
  durability = 250,
  dmg_mod =10,
  difficulty =2,
  flags = flagt{"CONTROLS", "CTRL_ELECTRONIC", "FOLDABLE", "DOME_LIGHT" },
  item_id = nil,--未填的两项
  breaks_into = nil,
  
}





return list