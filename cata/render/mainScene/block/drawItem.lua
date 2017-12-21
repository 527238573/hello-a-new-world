local rm = render.main
local camera = ui.camera


function rm.drawItem(itemlist,x,y,z,screenx,screeny)
  local item_undergound,timg,tquad,scale
  
  item_undergound = itemlist[1]
  if item_undergound==nil then return end
  timg,tquad = item_undergound:getImgAndQuad()
  scale = camera.zoom*2
  love.graphics.draw(timg,tquad,screenx,screeny+scale*2,0,scale,scale,0.5*32,32)--绘制，根据位置（左下点）和缩放
  
  item_undergound = itemlist[2]
  if item_undergound==nil then return end
  timg,tquad = item_undergound:getImgAndQuad()
  scale = camera.zoom*2
  love.graphics.draw(timg,tquad,screenx,screeny-scale*4,0,scale,scale,0.5*32,32)--绘制，根据位置（左下点）和缩放
  
  item_undergound = itemlist[3]
  if item_undergound==nil then return end
  timg,tquad = item_undergound:getImgAndQuad()
  scale = camera.zoom*2
  love.graphics.draw(timg,tquad,screenx,screeny-scale*10,0,scale,scale,0.5*32,32)--绘制，根据位置（左下点）和缩放
  
  --只显示前三样
end