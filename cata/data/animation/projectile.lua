local list = {}
local img

img = love.graphics.newImage("data/animation/projectile/bullet1.png")
list["bullet1"] = 
{
  img = img,
  w = 1,
  h= 1,
  frameNum = 4,
  secPerFrame = 0.05,
  scaleFactor = 2,
  ox = 16,--未计算scaleFactor的中心点
  oy = 16,
  love.graphics.newQuad(0,0,32,32,img:getDimensions()),
  love.graphics.newQuad(32,0,32,32,img:getDimensions()),
  love.graphics.newQuad(64,0,32,32,img:getDimensions()),
  love.graphics.newQuad(96,0,32,32,img:getDimensions()),
}


img = love.graphics.newImage("data/animation/projectile/arrow_wood.png")
list["arrow_wood"] = 
{
  img = img,
  w = 1,
  h= 1,
  frameNum = 4,
  secPerFrame = 0.05,
  scaleFactor = 2,
  ox = 16,--未计算scaleFactor的中心点
  oy = 16,
  love.graphics.newQuad(0,0,32,32,img:getDimensions()),
  love.graphics.newQuad(32,0,32,32,img:getDimensions()),
  love.graphics.newQuad(64,0,32,32,img:getDimensions()),
  love.graphics.newQuad(96,0,32,32,img:getDimensions()),
}
return list