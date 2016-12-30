local suit = require 'suit'



local touch = {}

return function()
  local actived = suit.isActive(touch)
  
  if actived then
      -- mouse update
      local mx,my = love.mouse.getX(),love.mouse.getY()
      mx = (mx - touch.startX)/editor.workZoom
      my = (my - touch.startY)/editor.workZoom
      
      editor.setCenter(touch.centerX-mx,touch.centerY+my)
      
    end
  suit.registerHitFullScreen(nil,touch)
  if suit.isActive(touch) and not actived then
    -- mouse update
    touch.startX,touch.startY = love.mouse.getPosition()
    touch.centerX,touch.centerY = editor.centerX,editor.centerY
  end
  if suit.isHovered(touch) and suit.wasHovered(touch) then
    local dy  = suit.getWheelNumber()
    editor.setWorkZoom(editor.workZoom +dy*0.25)
  end
  
  
end
