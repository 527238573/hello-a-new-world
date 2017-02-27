render.overmap = {}
local rov = render.overmap
require "render/overmap/drawOter"
require "render/overmap/drawOvBuffer"

function render.overmap.init()
  rov.initDrawOvBuffer()
  rov.initDrawOter()
end




function render.drawOvermap()
  rov.drawAllBufferMap()
end

