




local block_data = require "data/block_data"


local name_info = {}

for i=1,#block_data do
  local info = block_data[i]
  name_info[info.name] = info
end

local function getSquare(x,y,z)
  if x>=0 and x< editor.square_x_num and y>=0 and y<editor.square_y_num then
    return editor.getSquareFormVirtualXY(x,y,z)
  else
    return nil
  end
end

local conectedLowWall_index = {4,3,1,2,8,7,5,6}

local function drawOneBlock(square,x,y,z)
  
  local info = name_info[square.block]--取得图像--
  local quad = info[1]
  local use_scc = false
  if info.drawtype ==3 then
    local up  = getSquare(x,y+1,z)
    local right  = getSquare(x+1,y,z)
    local left  = getSquare(x-1,y,z)
    local statecode = 1
    if up~=nil and up.block == square.block then statecode = statecode +4 end
    if right~=nil and right.block == square.block then statecode = statecode +2 end
    if left~=nil and left.block == square.block then statecode = statecode +1 end
    quad = info[conectedLowWall_index[statecode]]
  end
  
  
  
  local modelx = x*64 +32
  local modely = y*64
  local screenx,screeny = editor.modelToScreen(modelx,modely)
  local factor = info.scalefactor
  local scale = editor.workZoom*factor
  
  if info.drawtype ==3 or info.drawtype ==2 then
    local down  = getSquare(x,y-1,z)
    if down~=nil and draw.isWall(down.ter) then
      use_scc = true
      love.graphics.setScissor(screenx-info.width*scale*0.5+draw.shiftX,screeny-info.height*scale+draw.shiftY,info.width*scale,info.height*scale)
      
    end
  end
  
  
  love.graphics.draw(info.img,quad,screenx,screeny,0,scale,scale,0.5*info.width,info.height)--绘制，根据位置（左下点）和缩放
  
  if use_scc then love.graphics.setScissor() end--disable scissor
  
end








function draw.drawAllBlocks(z)--绘制屏幕内
  love.graphics.setColor(255,255,255)
  local perSquarel = c.squarePixels
  
  local startx = math.floor(editor.seen_minX/perSquarel)
  local starty = math.floor(editor.seen_maxY/perSquarel)
  local endx = math.floor(editor.seen_maxX/perSquarel)
  local endy = math.floor(editor.seen_minY/perSquarel)-1 --多画一列，
  
  for y= starty,endy,-1 do -- 从上至下
    for x= startx,endx do
      local square = editor.getSquareFormVirtualXY(x,y,z)
      if square~=nil and square.block~= nil then
        drawOneBlock(square,x,y,z)
      end
    end
  end
  
  
end