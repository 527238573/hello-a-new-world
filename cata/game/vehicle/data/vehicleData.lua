require"game/vehicle/data/componentData"



data.veh_prototypes = {}








local function loadOnePrototype(veh)
  data.veh_prototypes[veh.id] = veh
end


local lovefs = require("file/lovefs")
local function loadAllPrototypes()
  local fs = lovefs(love.filesystem.getSource().."/data/vehicle/prototype")
  for _, v in ipairs(fs.files) do --
    local tmp = dofile("data/vehicle/prototype/"..v) -- 执行文件夹内所有文件，载入所有itemtype列表
    debugmsg("veh prototype file:"..v.." length:"..#tmp)
    for i=1,#tmp do
      loadOnePrototype(tmp[i])--载入一项
    end
  end
  
end






function data.loadVehicles()
  data.load_vehicle_components()
  loadAllPrototypes()
end