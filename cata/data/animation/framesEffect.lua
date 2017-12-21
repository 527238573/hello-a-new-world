local list = {}

local img
img = love.graphics.newImage("data/animation/crush.png")
list["crush"] = 
{
  img = img,
  w = 1,
  h= 1,
  frameNum = 6,
  secPerFrame = 0.1,
  scaleFactor = 2,
  ox = 40,--未计算scaleFactor的中心点
  oy = 24,
  sound_id = "crush",
  love.graphics.newQuad(0,0,80,48,img:getDimensions()),
  love.graphics.newQuad(0,48,80,48,img:getDimensions()),
  love.graphics.newQuad(0,96,80,48,img:getDimensions()),
  love.graphics.newQuad(0,144,80,48,img:getDimensions()),
  love.graphics.newQuad(0,192,80,48,img:getDimensions()),
  love.graphics.newQuad(0,240,80,48,img:getDimensions()),
}
img = love.graphics.newImage("data/animation/red_dead.png")
list["red_dead"] = 
{
  img = img,
  w = 1,
  h= 1,
  frameNum = 6,
  secPerFrame = 0.1,
  scaleFactor = 2,
  ox = 43,--未计算scaleFactor的中心点
  oy = 28,
  sound_id = "kill2",
  love.graphics.newQuad(0,0,86,56,img:getDimensions()),
  love.graphics.newQuad(0,56,86,56,img:getDimensions()),
  love.graphics.newQuad(0,112,86,56,img:getDimensions()),
  love.graphics.newQuad(0,168,86,56,img:getDimensions()),
  love.graphics.newQuad(0,224,86,56,img:getDimensions()),
  love.graphics.newQuad(0,280,86,56,img:getDimensions()),
}

img = love.graphics.newImage("data/animation/green_dead.png")
list["green_dead"] = 
{
  img = img,
  w = 1,
  h= 1,
  frameNum = 6,
  secPerFrame = 0.1,
  scaleFactor = 2,
  ox = 42,--未计算scaleFactor的中心点
  oy = 24,
  sound_id = "kill1",
  love.graphics.newQuad(0,0,84,48,img:getDimensions()),
  love.graphics.newQuad(0,48,84,48,img:getDimensions()),
  love.graphics.newQuad(0,96,84,48,img:getDimensions()),
  love.graphics.newQuad(0,144,84,48,img:getDimensions()),
  love.graphics.newQuad(0,192,84,48,img:getDimensions()),
  love.graphics.newQuad(0,240,84,48,img:getDimensions()),
}

img = love.graphics.newImage("data/animation/bash1.png")
list["bash1"] = 
{
  img = img,
  w = 1,
  h= 1,
  frameNum = 6,
  secPerFrame = 0.05,
  scaleFactor = 2,
  ox = 16,--未计算scaleFactor的中心点
  oy = 16,
  sound_id = "bash1",
  love.graphics.newQuad(0,0,32,32,img:getDimensions()),
  love.graphics.newQuad(32,0,32,32,img:getDimensions()),
  love.graphics.newQuad(64,0,32,32,img:getDimensions()),
  love.graphics.newQuad(96,0,32,32,img:getDimensions()),
  love.graphics.newQuad(128,0,32,32,img:getDimensions()),
  love.graphics.newQuad(160,0,32,32,img:getDimensions()),
}
img = love.graphics.newImage("data/animation/quanhit.png")
list["quan_hit"] = 
{
  img = img,
  w = 1,
  h= 1,
  frameNum = 7,
  secPerFrame = 0.05,
  scaleFactor = 2,
  ox = 16,--未计算scaleFactor的中心点
  oy = 16,
  sound_id = "bash1",
  love.graphics.newQuad(0,0,32,32,img:getDimensions()),
  love.graphics.newQuad(32,0,32,32,img:getDimensions()),
  love.graphics.newQuad(64,0,32,32,img:getDimensions()),
  love.graphics.newQuad(96,0,32,32,img:getDimensions()),
  love.graphics.newQuad(128,0,32,32,img:getDimensions()),
  love.graphics.newQuad(160,0,32,32,img:getDimensions()),
  love.graphics.newQuad(192,0,32,32,img:getDimensions()),
}

img = love.graphics.newImage("data/animation/bitehit.png")
list["bitehit"] = 
{
  img = img,
  w = 1,
  h= 1,
  frameNum = 7,
  secPerFrame = 0.07,
  scaleFactor = 2,
  ox = 16,--未计算scaleFactor的中心点
  oy = 16,
  sound_id = "bash1",
  love.graphics.newQuad(0,0,32,32,img:getDimensions()),
  love.graphics.newQuad(32,0,32,32,img:getDimensions()),
  love.graphics.newQuad(64,0,32,32,img:getDimensions()),
  love.graphics.newQuad(96,0,32,32,img:getDimensions()),
  love.graphics.newQuad(128,0,32,32,img:getDimensions()),
  love.graphics.newQuad(160,0,32,32,img:getDimensions()),
  love.graphics.newQuad(192,0,32,32,img:getDimensions()),
}
img = love.graphics.newImage("data/animation/clawhit.png")
list["clawhit"] = 
{
  img = img,
  w = 1,
  h= 1,
  frameNum = 6,
  secPerFrame = 0.06,
  scaleFactor = 2,
  ox = 16,--未计算scaleFactor的中心点
  oy = 16,
  sound_id = "bash1",
  random_mirror = true,--随机水平翻转
  love.graphics.newQuad(0,0,32,32,img:getDimensions()),
  love.graphics.newQuad(32,0,32,32,img:getDimensions()),
  love.graphics.newQuad(64,0,32,32,img:getDimensions()),
  love.graphics.newQuad(96,0,32,32,img:getDimensions()),
  love.graphics.newQuad(128,0,32,32,img:getDimensions()),
  love.graphics.newQuad(160,0,32,32,img:getDimensions()),
}

img = love.graphics.newImage("data/animation/bash_hit.png")
list["bash_hit"] = 
{
  img = img,
  w = 1,
  h= 1,
  frameNum = 7,
  secPerFrame = 0.06,
  scaleFactor = 2,
  ox = 16,--未计算scaleFactor的中心点
  oy = 16,
  sound_id = "bash_hit1",
  random_mirror = true,--随机水平翻转
  love.graphics.newQuad(0,0,32,32,img:getDimensions()),
  love.graphics.newQuad(32,0,32,32,img:getDimensions()),
  love.graphics.newQuad(64,0,32,32,img:getDimensions()),
  love.graphics.newQuad(96,0,32,32,img:getDimensions()),
  love.graphics.newQuad(128,0,32,32,img:getDimensions()),
  love.graphics.newQuad(160,0,32,32,img:getDimensions()),
  love.graphics.newQuad(192,0,32,32,img:getDimensions()),
}


img = love.graphics.newImage("data/animation/cut_hit2.png")
list["cut_hit"] = 
{
  img = img,
  w = 1,
  h= 1,
  frameNum = 7,
  secPerFrame = 0.05,
  scaleFactor = 2,
  ox = 16,--未计算scaleFactor的中心点
  oy = 16,
  sound_id = "cut_hit1",
  random_mirror = true,--随机水平翻转
  love.graphics.newQuad(0,0,32,32,img:getDimensions()),
  love.graphics.newQuad(32,0,32,32,img:getDimensions()),
  love.graphics.newQuad(64,0,32,32,img:getDimensions()),
  love.graphics.newQuad(96,0,32,32,img:getDimensions()),
  love.graphics.newQuad(128,0,32,32,img:getDimensions()),
  love.graphics.newQuad(160,0,32,32,img:getDimensions()),
  love.graphics.newQuad(192,0,32,32,img:getDimensions()),
}

img = love.graphics.newImage("data/animation/stab_hit.png")
list["stab_hit"] = 
{
  img = img,
  w = 1,
  h= 1,
  frameNum = 8,
  secPerFrame = 0.05,
  scaleFactor = 2,
  ox = 6,--未计算scaleFactor的中心点
  oy = 16,
  sound_id = "stab_hit1",
  --random_mirror = true,--随机水平翻转
  love.graphics.newQuad(0,0,32,32,img:getDimensions()),
  love.graphics.newQuad(32,0,32,32,img:getDimensions()),
  love.graphics.newQuad(64,0,32,32,img:getDimensions()),
  love.graphics.newQuad(96,0,32,32,img:getDimensions()),
  love.graphics.newQuad(128,0,32,32,img:getDimensions()),
  love.graphics.newQuad(160,0,32,32,img:getDimensions()),
  love.graphics.newQuad(192,0,32,32,img:getDimensions()),
  love.graphics.newQuad(224,0,32,32,img:getDimensions()),
}



return list