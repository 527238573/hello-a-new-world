require "render/mainScene/block/drawUnit"
local rm = render.main
local camera = ui.camera


local bid_info
function rm.initDrawBlocks()
  bid_info = data.block
end

local conectedLowWall_index = {4,3,1,2,8,7,5,6}
local getblock = g.map.getBlockInGrid
--screenx,screeny是square底部中心点
local function drawOneBlock(bid,screenx,screeny,x,y,z)
  if bid==nil or bid<2 then return end
  local info  = bid_info[bid]
  
  if info.drawtype ==3 or  info.drawtype ==2 then return end
  local scale = camera.zoom*info.scalefactor
  love.graphics.draw(info.img,info[1],screenx,screeny,0,scale,scale,0.5*info.width,info.height)--绘制，根据位置（左下点）和缩放
  
  
end

local getblockDataInGrid = g.map.getblockDataInGrid

local function drawOneSquare(x,y,z)
  local screenx,screeny = camera.modelToScreen(x*64 +32,y*64)
  local bid,unit = getblockDataInGrid(x,y,z)
  drawOneBlock(bid,screenx,screeny,x,y,z)
  if unit then rm.drawUnit(unit,x,y,z,screenx,screeny)end
end

local function drawLowWallSquare(x,y,z)
  local screenx,screeny = camera.modelToScreen(x*64 +32,y*64)
  local bid= getblock(x,y,z)
  if bid==nil or bid<2 then return end
  local info  = bid_info[bid]
  if info.drawtype ~=3 and  info.drawtype ~=2 then return end
  local quad = info[1]
  local use_scc = false
  if info.drawtype ==3 then
    local up  = getblock(x,y+1,z)
    local right  = getblock(x+1,y,z)
    local left  = getblock(x-1,y,z)
    local statecode = 1
    if up~=nil and up == bid then statecode = statecode +4 end
    if right~=nil and right == bid then statecode = statecode +2 end
    if left~=nil and left == bid then statecode = statecode +1 end
    quad = info[conectedLowWall_index[statecode]]
  end
  local scale = camera.zoom*info.scalefactor
  
  if g.map.isWallTerInGrid(x,y-1,z) then
    use_scc = true
    love.graphics.setScissor(screenx-info.width*scale*0.5,screeny-info.height*scale,info.width*scale,info.height*scale)
  end
  love.graphics.draw(info.img,quad,screenx,screeny,0,scale,scale,0.5*info.width,info.height)--绘制，根据位置（左下点）和缩放
  if use_scc then love.graphics.setScissor() end--disable scissor
  
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
      drawLowWallSquare(x,y,z)
    end
  end
  
  for y= starty,endy,-1 do -- 从上至下
    for x= startx,endx do
      drawOneSquare(x,y,z)
    end
  end
end