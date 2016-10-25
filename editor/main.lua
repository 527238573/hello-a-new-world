-- suit up
local suit = require 'suit'

-- storage for text input
local input = {text = ""}
local slider = {value = 1, max = 2}
local checkbox = {text = "asdasd2"}

local subwin = {x=400,y=130}
local myScroll = {h_value =0,v_value =0,hbar_percent=0.45,vbar_percent=0.45,hopt ={id={},vertical = false},vopt ={id={},vertical = true}}
local myRect = {w =300,h=300, opt ={id={},vertical = true,horizontal = true}}
local mpos = {x=0,y=0}

-- all the UI is defined in love.update or functions that are called from here
function love.update(dt)
    -- put the layout origin at position (100,100)
    -- the layout will grow down and to the right from this point
    suit.layout:reset(100,100)

    -- put an input widget at the layout origin, with a cell size of 200 by 30 pixels
    suit.Input(input, suit.layout:row(200,30))

    -- put a label that displays the text below the first cell
    -- the cell size is the same as the last one (200x30 px)
    -- the label text will be aligned to the left
    suit.Label("Hello, "..tostring(subwin)..input.text, {align = "left"}, suit.layout:row())

    -- put an empty cell that has the same size as the last cell (200x30 px)
    suit.layout:row()

    -- put a button of size 200x30 px in the cell below
    -- if the button is pressed, quit the game
    if suit.Button("Close", suit.layout:row()).hit then
        love.event.quit()
    end
    
    
    
     suit.layout:row()

    suit.Slider(slider, suit.layout:row(200,30))
    suit.Label(tostring(slider.value), {align = "left"}, suit.layout:row(200,30))
    
    suit.layout:row()
    suit.Checkbox(checkbox, suit.layout:row(200,30))
    
    
    suit.DragArea(subwin,true)
    suit.Dialog("dig1",subwin.x,subwin.y, 300,300)
    suit.DragArea(subwin,false,subwin.x,subwin.y,300,30)
    --suit.Button("Close2", 200,150,200,70)
    --suit.S9Button("Close2", subwin.x+10,subwin.y+50,80,30)
    
   -- suit.ScrollBar(myScroll,myScroll.hopt, subwin.x+10,subwin.y+270,200,17)
   -- suit.ScrollBar(myScroll,myScroll.vopt, subwin.x+210,subwin.y+70,17,200)
   suit.ScrollRect(myRect,myRect.opt,subwin.x+10,subwin.y+70,200,200)
   
    suit.S9Button("Close2", myRect.x+10,myRect.y+10,80,30)
    
   suit.endScissor()
    
end

function love.draw()
    -- draw the gui
    suit.draw()
    
   -- love.graphics.circle("fill", mpos.x, mpos.y, 5, 6)
end

function love.textinput(t)
    -- forward text input to SUIT
    suit.textinput(t)
end

function love.keypressed(key)
    -- forward keypresses to SUIT
    suit.keypressed(key)
end