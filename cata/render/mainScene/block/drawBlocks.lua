require "render/mainScene/block/drawUnit"
local rm = render.main
local camera = ui.camera


local bid_info
function rm.initDrawBlocks()
  bid_info = data.block
end

--screenx,screeny是square底部中心点
local function drawOneBlock(bid,screenx,screeny)
  if bid and bid>1 then
    local info  = bid_info[bid]
    local scale = camera.zoom*info.scalefactor
    love.graphics.draw(info.img,info[1],screenx,screeny,0,scale,scale,0.5*info.width,info.height)--绘制，根据位置（左下点）和缩放
  end
end



local getblockDataInGrid = g.map.getblockDataInGrid
local function drawOneSquare(x,y,z)
  local screenx,screeny = camera.modelToScreen(x*64 +32,y*64)
  local bid,unit = getblockDataInGrid(x,y,z)
  drawOneBlock(bid,screenx,screeny)
  if unit then rm.drawUnit(unit,x,y,z,screenx,screeny)end
end



local squareLength = 64
function rm.drawBlocksLayer()
  --love.graphics.setColor(255,255,255)
  local startx = math.floor(camera.seen_minX/squareLength)-1
  local starty = math.floor(camera.seen_maxY/squareLength)+1
  local endx = math.floor((camera.seen_maxX)/squareLength)+1
  local endy = math.floor((camera.seen_minY-64)/squareLength)
  
  local z = camera.cur_Z
  for y= starty,endy,-1 do -- 从上至下
    for x= startx,endx do
      drawOneSquare(x,y,z)
    end
  end
end