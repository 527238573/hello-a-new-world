local list = {}

list[#list+1] = {
  id = "wheel",
  name = tl("车轮","wheel"),
  quads = {
    img = "veh_components1",
    [1] = {0,4},
    },
  cover_all =false,
  location = "under",
  durability = 200,
  dmg_mod =50,
  difficulty =3,
  flags = flagt{"WHEEL"},
  item_id = nil,--未填的两项
  breaks_into = nil,
}


list[#list+1] = {
  id = "wheel_steerable",
  name = tl("车轮(可转向)","wheel(steerable)"),
  quads = {
    img = "veh_components1",
    [1] = {0,4},
    },
  cover_all =false,
  location = "under",
  durability = 200,
  dmg_mod =50,
  difficulty =3,
  flags = flagt{"WHEEL","STEERABLE",},
  item_id = nil,--未填的两项
  breaks_into = nil,
}
return list