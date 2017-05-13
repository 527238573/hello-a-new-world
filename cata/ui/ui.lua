
ui={res= {}}

require "ui/component/commonRes"
require "ui/mainMenu/mainMenu"
require "ui/mainScene/mainView"
require "ui/mainScene/mainScene"
require "ui/overmap/overmapView"
require "ui/overmap/overmapScene"

require "ui/component/waitingMessage"

require "ui/component/numberAsk"
require "ui/window/pickupOrDropWin"

function ui.init()
  ui.camera.init()
  ui.overmap.init()
  ui.showMainMenu = true
  
  ui.popout = nil
  ui.current_keypressd = nil
  
end


local function mainSceneUpdate(dt)
  g.preUpdate(dt)
  ui.mainScene(dt)
  if ui.popout then
    ui.popout()
  end
  g.update(dt) --game时间经过
  ui.camera.update()
end





function ui.update(dt)
  if ui.showMainMenu then ui.enterMainMenu();return end --主菜单
  
  if ui.show_overmap then 
    ui.overmapScene(dt)
  else
    mainSceneUpdate(dt)
  end
end




function ui.keypressed(key)
  if ui.showMainMenu then return end --主菜单
  
  if ui.current_keypressd then
    ui.current_keypressd(key)
  elseif ui.show_overmap then 
    ui.overmapSceneKeypressed(key)
  else
    ui.mainKeypressed(key)
  end
  
end




