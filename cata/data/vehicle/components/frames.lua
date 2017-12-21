local list = {}

list[#list+1] = {
  id = "frame",
  name = tl("车架","frame"),
  quads = {
    img = "veh_components1",
    [1] = {4,2},
    [2] = {3,2},
    [3] = {2,2},
    [4] = {1,2},
    [5] = {0,2},
    nborder = true, --相邻类型。
    },
  cover_all =false,
  location = "structure",
  durability = 400,
  dmg_mod =100,
  difficulty =1,
  flags = flagt{"WELDING10", "MOUNTABLE",},
  item_id = nil,--未填的两项
  breaks_into = nil,
  
}

return list