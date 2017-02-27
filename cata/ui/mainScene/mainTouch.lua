local suit = require"ui/suit"


local touch_id = newid()
local touch_startX
local touch_startY
local touch_centerX
local touch_centerY


function ui.mainTouch()
  local actived = suit:isActive(touch_id)
  
  if actived then
      local mx,my = love.mouse.getX(),love.mouse.getY()
      mx = (mx - touch_startX)/ui.camera.zoom
      my = (my - touch_startY)/ui.camera.zoom
      ui.camera.setCenter(touch_centerX-mx,touch_centerY+my)
      
    end
  suit:registerHitFullScreen(nil,touch_id)
  if suit:isActive(touch_id) and not actived then
    touch_startX,touch_startY = love.mouse.getPosition()
    touch_centerX,touch_centerY = ui.camera.centerX,ui.camera.centerY
    print("center:",touch_centerX,touch_centerY)
    io.flush()
  end
end
