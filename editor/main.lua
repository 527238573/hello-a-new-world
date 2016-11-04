local suit = require 'suit'
require "eui/eui"

function love.update(dt)
    
    eui.uiLayer()
    
end

function love.draw()
    -- draw the gui
    suit.draw()
    
   -- love.graphics.circle("fill", mpos.x, mpos.y, 5, 6)
end


function love.wheelmoved(dx,dy)
  suit.updateMouseWheel(dx,dy)
end

function love.textinput(t)
    -- forward text input to SUIT
    suit.textinput(t)
end

function love.keypressed(key)
    -- forward keypresses to SUIT
    suit.keypressed(key)
end