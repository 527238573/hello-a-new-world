local suit = require 'suit'
local s9util = require("suit/s9util")
local back_img = love.graphics.newImage("assets/greybar.png")
local back_s9t = s9util.createS9Table(back_img,0,0,96,27,3,3,3,3)

local filebtn_img = love.graphics.newImage("assets/anniu.png")

local win_width = love.graphics.getWidth()
local win_height = love.graphics.getHeight()

local panel_opt = {id={}}
local newfile_opt = {id={},[1] = love.graphics.newQuad(0,0,32,32,32,128),img = filebtn_img}
local open_opt = {id={},[1] = love.graphics.newQuad(0,32,32,32,32,128),img = filebtn_img}
local save_opt = {id={},[1] = love.graphics.newQuad(0,64,32,32,32,128),img = filebtn_img}
local saveas_opt = {id={},[1] = love.graphics.newQuad(0,96,32,32,32,128),img = filebtn_img}
local changeSize_btn_opt = {id={},font = c.btn_font}
local btn1_opt = {id={}}
local btn2_opt = {id={}}
local btn3_opt = {id={}}
local direction_opt ={font = c.btn_font,color = {0,0,0}}
local dircection_str= {"朝向:↑","朝向:→","朝向:↓","朝向:←"}
local test_opt = {id={}}

local showMesh = {text = "showGrid",checked = false}
local showSetting_btn = {id={},font = c.btn_font}
local changesize_dlg = require"eui/changeSizeDlg"
local floor_setter = require"eui/component/floorSetter"
local mapfile = require"file/mapfile"

return function()
  local x,y,w,h = 0,0,win_width,30
  suit.Image(back_s9t,panel_opt,x,y,w,h)
  
  local s_newfile  = eui.PicButton(newfile_opt,newfile_opt,4,0,false)
  local s_open  = eui.PicButton(open_opt,open_opt,49,0,false)
  local s_save  = eui.PicButton(save_opt,save_opt,94,0,false)
  local s_saveas  = eui.PicButton(saveas_opt,saveas_opt,139,0,false)
  
  --local showgrid_state = suit.Checkbox(showMesh, 410,2,90,26)
  
  local showSetting_state = suit.S9Button("show menu",showSetting_btn,410,2,90,26)
  
  local s_sizebtn = suit.S9Button(editor.size_str,changeSize_btn_opt,500,2,170,26)
  
  floor_setter(680,4)
  
  
  --eui.Panel(panel_opt,x,y,w,h)
  local d1 = suit.S9Button("rotate<",btn1_opt,800,2,80,26)
  local d2 = suit.S9Button("rotate>",btn2_opt,880,2,80,26)
  local d3 = suit.S9Button("reset",btn3_opt,960,2,80,26)
  suit.Label(dircection_str[editor.curDirection],direction_opt,1040,4,100,26)
  
  local tests = suit.S9Button("test",test_opt,1200,2,60,26)
  
  if(s_newfile.hit) then mapfile.newFile() end
  if(s_open.hit) then eui.popwindow = eui.openFileDialog end
  if(s_save.hit) then mapfile.saveOld() end
  if(s_saveas.hit) then eui.popwindow = eui.saveFileDialog end
  --if(showgrid_state.change) then editor.showGrid = showMesh.checked end
  if(showSetting_state.hit) then eui.popwindow = eui.showSetting end
  
  if(s_sizebtn.hit) then eui.popwindow = changesize_dlg end
  if d3.hit then editor.changeDirection(1) end
  if d1.hit then editor.changeDirection(editor.curDirection -1) end
  if d2.hit then editor.changeDirection(editor.curDirection +1)end
  
  
  if tests.hit then
    print(love.math.random(0,-17.43))
    io.flush()
    
  end
end
