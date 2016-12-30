local suit = require 'suit'
local s9util = require("suit/s9util")
local back_img = love.graphics.newImage("assets/greybar.png")
local back_s9t = s9util.createS9Table(back_img,0,0,96,27,3,3,3,3)

local win_width = love.graphics.getWidth()
local win_height = love.graphics.getHeight()
local panel_opt = {id={}}
local changeSize_btn_opt = {id={},font = c.btn_font}
local btn1_opt = {id={}}
local btn2_opt = {id={}}
local btn3_opt = {id={}}
local direction_opt ={font = c.btn_font,color = {0,0,0}}
local dircection_str= {"朝向:↑","朝向:→","朝向:↓","朝向:←"}


local changesize_dlg = require"eui/changeSizeDlg"
local floor_setter = require"eui/component/floorSetter"

return function()
  local x,y,w,h = 0,0,win_width,30
  suit.Image(back_s9t,panel_opt,x,y,w,h)
  
  local s_sizebtn = suit.S9Button(editor.size_str,changeSize_btn_opt,500,2,170,26)
  
  floor_setter(680,4)
  
  
  --eui.Panel(panel_opt,x,y,w,h)
  local d1 = suit.S9Button("rotate<",btn1_opt,800,2,80,26)
  local d2 = suit.S9Button("rotate>",btn2_opt,880,2,80,26)
  local d3 = suit.S9Button("reset",btn3_opt,960,2,80,26)
  suit.Label(dircection_str[editor.curDirection],direction_opt,1040,4,100,26)
  
  if(s_sizebtn.hit) then eui.popwindow = changesize_dlg end
  if d3.hit then editor.curDirection = 1 end
  if d1.hit then editor.curDirection = editor.curDirection -1; if editor.curDirection<1 then editor.curDirection = 4 end end
  if d2.hit then editor.curDirection = editor.curDirection +1; if editor.curDirection>4 then editor.curDirection = 1 end end
  
end
