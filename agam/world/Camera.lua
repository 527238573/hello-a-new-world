
SCREEN_WIDTH,SCREEN_HEIGHT = love.window.getMode()
local halfW = 0.5 * SCREEN_WIDTH
local halfH = 0.5 * SCREEN_HEIGHT


camera = {}

function setCameraXY(cx,cy)
  camera.X = cx
  camera.Y = cy
  camera.minX = cx - halfW
  camera.maxX = cx + halfW
  camera.minY = cy - halfH
  camera.maxY = cy + halfH
end

setCameraXY(320,320) -- 初始化为0，0

function worldToScreen(x,y)  --太常用，全局
  return x -camera.X+ halfW, halfH +camera.Y- y
end


function camera.update(dt)
  setCameraXY(movie.plu.x,movie.plu.y)
end
