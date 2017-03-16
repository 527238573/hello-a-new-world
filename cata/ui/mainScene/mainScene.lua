

local suit = require"ui/suit"
local panel_id = newid()
local btntest_opt = {id = newid()}
local btnZoom_opt = {id = newid()}

require "ui/mainScene/mainTouch"
require "ui/mainScene/KeyControl"

local mainpanel = require "ui/component/mainPanel"


function ui.mainScene()
  --测试
   ui.mainTouch()
  ui.mainKeyCheck()
  mainpanel(panel_id,c.win_W - ui.camera.right_w,0,ui.camera.right_w,c.win_H)
  local zoombtn = suit:S9Button("zoom change",btnZoom_opt,c.win_W-275,0,130,30)
  local obtn = suit:S9Button("overmap地图",btntest_opt,c.win_W-140,0,140,30)
  if obtn.hit then 
    ui.show_overmap = true
  end
  if zoombtn.hit then 
    if ui.camera.zoom == 0.5 then
      ui.camera.setZoom(1)
    else
      ui.camera.setZoom(ui.camera.zoom-0.25)
    end
  end
  
end

