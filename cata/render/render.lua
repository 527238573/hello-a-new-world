render = {}
require"render/overmap/renderOvermap"
require"render/mainScene/renderMainScene"

function render.init()
  render.overmap.init()
  render.main.init()
end



function render.draw()
  if ui.showMainMenu then return end --
  
  if ui.show_overmap then 
    render.drawOvermap()
  else
    render.renderMainScene()
  end
  
  
end