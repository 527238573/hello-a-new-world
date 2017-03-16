
--
local suit = require 'suit'
local blockFullScreen = {}
local showMesh = {text = "showGrid",checked = false}
local showBlock = {text = "showblock",checked = true}
local showDownLayer = {text = "showDownLayer",checked = false}
function eui.showSetting()
  
  suit.registerHitFullScreen(nil,blockFullScreen)
  
  eui.Panel(410,30,140,120)
  
  local showgrid_state = suit.Checkbox(showMesh, 410,32,130,26)
  local showblock_state = suit.Checkbox(showBlock, 410,62,130,26)
  local showDownLayer_state = suit.Checkbox(showDownLayer, 410,92,130,26)
  
  if suit.mouseReleasedOn(blockFullScreen) then
    eui.popwindow = nil
  end
  
  if(showgrid_state.change) then editor.showGrid = showMesh.checked end
  if(showblock_state.change) then editor.showBlock = showBlock.checked end
  if(showDownLayer_state.change) then editor.showDownLayer = showDownLayer.checked end
end
  
  
  