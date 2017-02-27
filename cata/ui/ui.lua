
ui={}

require "ui/mainScene/mainView"
require "ui/mainScene/mainScene"
require "ui/overmap/overmapView"
require "ui/overmap/overmapScene"

function ui.init()
  ui.camera.init()
  ui.overmap.init()
  
  
  
  
end


local function mainSceneUpdate(dt)
  g.preUpdate(dt)
  ui.mainScene()
  
  g.update(dt) --game时间经过
  ui.camera.update()
end





function ui.update(dt)
  if ui.show_overmap then 
    ui.overmapScene(dt)
  else
    mainSceneUpdate(dt)
  end
  
end


function ui.keypressed(key)
  if ui.show_overmap==false then
    ui.mainKeypressed(key)
  else
    ui.overmapSceneKeypressed(key)
  end
end