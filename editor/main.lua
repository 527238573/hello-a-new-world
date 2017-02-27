require "strict"
love.graphics.setDefaultFilter("linear","nearest")

local suit = require 'suit'
require "core/constant"
require "eui/eui"
require "core/editor"
require "draw/draw"

function love.load()
   if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
   
   eui.init()
   editor.init()
   love.graphics.setBackgroundColor(050,050,050)
   --love.graphics.setFont(c.btn_font)
   --love.graphics.setDefaultFilter("nearest","nearest")
end


function love.update(dt)
    
    eui.uiLayer()
    
end

function love.draw()
  --draw the work seen
  draw.drawMap()
    -- draw the gui
  suit.draw()
  --love.graphics.circle("fill",love.mouse.getX(),love.mouse.getY(),10)
end


function love.wheelmoved(dx,dy)
  suit.updateMouseWheel(dx,dy)
  --print(package.cpath)
  --io.flush()
  --[[
  print("loaded")
  for k,v in pairs(package.loaded) do
    print(k)
  end--]]
  --[[
  for k,v in pairs(_G) do
    print(k)
  end--]]
end

function love.textinput(t)
    -- forward text input to SUIT
    suit.textinput(t)
end

function love.keypressed(key)
    -- forward keypresses to SUIT
    suit.keypressed(key)
   if not suit.anyKeyboardFocus() then eui.handleKeyPressed(key) end
end