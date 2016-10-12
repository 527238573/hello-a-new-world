class = require "30log"
require "z_util/help"
require "world/rtEnter"


function love.load()
   if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
   
   loadRT()
   initRT()
   
   local f = love.graphics.newFont("assets/ZhunYuan_.ttf",24);
   love.graphics.setFont(f)
end



function love.update(dt)
  gameWorld.update(dt)
end

function love.draw()
  love.graphics.setBackgroundColor(150,150,150)
  love.graphics.print("as我dasdas",100,100)
  gameWorld.draw()
end


function love.keypressed(key,scancode)
  keyControl.keypressed(key)
end




