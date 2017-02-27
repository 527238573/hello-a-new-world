




local block_data = require "data/block_data"


local name_info = {}

for i=1,#block_data do
  local info = block_data[i]
  name_info[info.name] = info
end


local function drawOneBlock(square,x,y,z)
  
  local info = name_info[square.block]--取得图像--
  local modelx = x*64 +32
  local modely = y*64
  local screenx,screeny = editor.modelToScreen(modelx,modely)
  local factor = info.scalefactor
  local scale = editor.workZoom*factor
  love.graphics.draw(info.img,info[1],screenx,screeny,0,scale,scale,0.5*info.width,info.height)--绘制，根据位置（左下点）和缩放
  
end








function draw.drawAllBlocks()--绘制屏幕内
  love.graphics.setColor(255,255,255)
  local perSquarel = c.squarePixels
  local z = editor.curZ
  
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