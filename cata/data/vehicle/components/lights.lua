local list = {}


list[#list+1] = {
  id = "headlight",
  name = tl("车头灯","head light"),
  styles = {
    {img = "veh_components1",[1]={2,1},},
    {img = "veh_components1",[1]={2,1},sx = -1},--左右车灯
    {img = "veh_components1",[1]={8,1},},--小
    {img = "veh_components1",[1]={8,1},sx = -1},--
  },
  cover_all =false,
  location = "top",
  durability = 20,
  dmg_mod =10,
  difficulty =1,
  flags = flagt{"CONE_LIGHT", "TOOL_SCREWDRIVER", "FOLDABLE"},
  item_id = nil,--未填的两项
  breaks_into = nil,
  
  --还有灯的数据
}

return list