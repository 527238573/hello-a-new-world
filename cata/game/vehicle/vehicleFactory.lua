local gveh = g.vehicle


local vehicle_list = {}

function gveh.get_vehicle_list()
  return vehicle_list
end


function gveh.create_vehicle_Prototype(pid)
  
  local pt = data.veh_prototypes[pid]
  if pt ==nil then error("Cant find vehicle prototype:"..pid) end
  
  local veh = gveh.create_vehicle()
  veh.name = pt.name
  for _,part_info in ipairs(pt) do
    for _,c_info in ipairs(part_info) do
      veh:intstall_component_force(part_info.x,part_info.y,c_info.id,-1,c_info.style,c_info.color)
    end
  end
  --可能进行车辆损坏。
  --安装完后
  veh:refresh()
  
  return veh
end

function gveh.spawnNewVehicle(pid,x,y)
  local v = gveh.create_vehicle_Prototype(pid)
  vehicle_list[#vehicle_list+1] = v
  v.x= x
  v.y = y
  --v.rotation = math.pi/3
end