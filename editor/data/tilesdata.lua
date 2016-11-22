local tiles_img = love.graphics.newImage("data/tiles.png")

return {
  
  {
    name = "ground",
    img = tiles_img,
    quad = love.graphics.newQuad(32*8,32*6,32,32,tiles_img:getDimensions())
    
  },
  {
    name = "snowground",
    img = tiles_img,
    quad = love.graphics.newQuad(32*13,32*6,32,32,tiles_img:getDimensions())
    
  },

}