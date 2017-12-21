local list = {}


list[#list+1] = {
  id = "bonnet",
  name = tl("车前盖","bonnet"),
  styles = {
    {img = "veh_components1",[1]={0,0}},
    {img = "veh_components1",[1]={1,0}},
    {img = "veh_components1",[1]={1,0},sx = -1},
    {img = "veh_components1",[1]={9,0},},
    {img = "veh_components1",[1]={10,0}},
    {img = "veh_components1",[1]={10,0},sx = -1},
  },
  cover_all =true,
  location = "center",
  durability = 192,
  dmg_mod =100,
  difficulty =1,
  flags = flagt{},
  item_id = nil,--未填的两项
  breaks_into = nil,
}

list[#list+1] = {
  id = "quarterpanel",
  name = tl("侧板","quarterpanel"),
  styles = {
    {img = "veh_components1",[1]={2,0},},
    {img = "veh_components1",[1]={2,0},rot = math.pi/2},
    {img = "veh_components1",[1]={3,0},},
    {img = "veh_components1",[1]={3,0},sx = -1},
    {img = "veh_components1",[1]={4,0},},
    {img = "veh_components1",[1]={4,0},rot = math.pi*0.5},
    {img = "veh_components1",[1]={4,0},rot = math.pi*1.5},
    {img = "veh_components1",[1]={11,0},},
    {img = "veh_components1",[1]={11,0},sx = -1},
    {img = "veh_components1",[1]={12,0}},
    {img = "veh_components1",[1]={12,0},sx = -1},
  },
  cover_all =true,
  location = "center",
  durability = 192,
  dmg_mod =100,
  difficulty =1,
  flags = flagt{"OBSTACLE"},
  item_id = nil,--未填的两项
  breaks_into = nil,
}










return list