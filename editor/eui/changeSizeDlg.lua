local suit = require 'suit'


local dlg = {x=400,y=130,font = c.btn_font, dragopt = {id={}}}
local closeBtn_Opt = {id ={}}
local xlen_info ={value =1, min = 1,max=6,opt = {id={}}}
local ylen_info ={value =1, min = 1,max=6,opt = {id={}}}
local z_height_info ={value =1, min = 1,max=12,opt = {id={}}}
local z_depth_info ={value =1, min = -10,max=1,opt = {id={}}}

local confirm_opt = {id={}}
local cancel_opt = {id={}}
local label_opt = {color={33,33,33}}

local read_value = false

return function()
  
  if not read_value then 
    read_value = true
    local map = editor.map
    xlen_info.value = map.subx; ylen_info.value = map.suby;
    z_height_info.value = map.highz; z_depth_info.value = map.lowz;
  end
  suit.DragArea(dlg,true,dlg.dragopt)
  suit.Dialog("调整地图尺寸",dlg,dlg.x,dlg.y, 400,220)
  suit.DragArea(dlg,false,dlg.dragopt,dlg.x,dlg.y,400,30)
  
  local s_close = eui.closeBtn(closeBtn_Opt,dlg.x+369,dlg.y+3)
  
  suit.Label("X:",label_opt,dlg.x+30,dlg.y+60,50,22)
  eui.numberStepper(xlen_info,xlen_info.opt,dlg.x+80,dlg.y+60)
  suit.Label("Y:",label_opt,dlg.x+30,dlg.y+110,50,22)
  eui.numberStepper(ylen_info,ylen_info.opt,dlg.x+80,dlg.y+110)
  
  suit.Label("Z_height:",label_opt,dlg.x+210,dlg.y+60,70,22)
  eui.numberStepper(z_height_info,z_height_info.opt,dlg.x+280,dlg.y+60)
  suit.Label("Z_depth:",label_opt,dlg.x+210,dlg.y+110,70,22)
  eui.numberStepper(z_depth_info,z_depth_info.opt,dlg.x+280,dlg.y+110)
  
  local s_confirm = suit.S9Button("Confirm",confirm_opt,dlg.x+70,dlg.y+170,80,26)
  local s_cancel = suit.S9Button("Cancel",cancel_opt,dlg.x+250,dlg.y+170,80,26)
  
  if(s_cancel.hit or s_close.hit) then
    read_value = false
    eui.popwindow = nil
  end
  if s_confirm.hit then
    read_value = false
    eui.popwindow = nil
    editor.changeMapSize(z_depth_info.value,z_height_info.value,xlen_info.value,ylen_info.value)
  end
end