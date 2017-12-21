


local rm = render.main

local camera = ui.camera




local function drawOneVehicle(vehicle) 
  local screenx,screeny = camera.modelToScreen(vehicle.x*64,vehicle.y*64)--正中心
  local scale = camera.zoom*2
  
  love.graphics.draw(vehicle.batch,screenx,screeny,vehicle.rotation,scale,scale)
end





function rm.drawVehicleLayer()
  love.graphics.setColor(255,255,255)
  local list = g.vehicle.get_vehicle_list()
  for i=1,#list do
    drawOneVehicle(list[i])
  end
end