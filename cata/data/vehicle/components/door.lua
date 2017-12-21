local list = {}

list[#list+1] = {
  id = "door",
  name = tl("车门","door"),
  styles = {
    {img = "veh_components1",[1]={7,0},open = {8,0}},
    {img = "veh_components1",[1]={7,0},open = {8,0},rot = math.pi/2},--横向车门
    {img = "veh_components1",[1]={13,0},open = {14,0}},--侧边车门
    {img = "veh_components1",[1]={13,0},open = {14,0},sx=-1},--侧边车门
  },
  cover_all =true,
  location = "center",
  durability = 225,
  dmg_mod =80,
  difficulty =2,
  flags = flagt{"OBSTACLE", "OPENABLE", "BOARDABLE", "WINDOW","TOOL_WRENCH","CARGO"},
  item_id = nil,--未填的两项
  breaks_into = nil,
  
  cargo = 10,--10体积的存储空间。
}


list[#list+1] = {
  id = "door_trunk",
  name = tl("行李箱门","trunk door"),
  quads = {
    img = "veh_components1",
    [1] = {5,0},
    open = {6,0},
    },
  cover_all =true,
  location = "center",
  durability = 150,
  dmg_mod =80,
  difficulty =2,
  flags = flagt{"OBSTACLE", "OPENABLE", "MULTISQUARE", "BOARDABLE", "TOOL_WRENCH"},
  item_id = nil,--未填的两项
  breaks_into = nil,
}


return list