require "ui/window/inventoryWin"


local btn_charactor_opt = {id = newid()}
local btn_equipment_opt = {id = newid()}
local btn_backpack_opt = {id = newid()}
local btn_quest_opt = {id = newid()}
local btn_help_opt = {id = newid()}
local btn_system_opt = {id = newid()}

local suit = require"ui/suit"
local picButton = require"ui/component/picButton"
local icon_img = love.graphics.newImage("assets/ui/bottomMenu.png")
local quad_charactor = love.graphics.newQuad(0,0,17,17,icon_img:getDimensions())
local quad_equipment = love.graphics.newQuad(17,0,17,17,icon_img:getDimensions())
local quad_backpack = love.graphics.newQuad(34,0,17,17,icon_img:getDimensions())
local quad_quest = love.graphics.newQuad(51,0,17,17,icon_img:getDimensions())
local quad_help = love.graphics.newQuad(68,0,17,17,icon_img:getDimensions())
local quad_system = love.graphics.newQuad(85,0,17,17,icon_img:getDimensions())


local small_key = true
local shortcut_img = love.graphics.newImage("assets/ui/shortcut_key.png")
local shortcut_quad = love.graphics.newQuad(0,6,364,38,shortcut_img:getDimensions())
local key_quad = love.graphics.newQuad(0,0,364,6,shortcut_img:getDimensions())


local border_eximg = love.graphics.newImage("assets/ui/border_extend.png")
local borderex_quad1 = love.graphics.newQuad(0,0,2,28,border_eximg:getDimensions())
local borderex_quad2 = love.graphics.newQuad(2,0,1,28,border_eximg:getDimensions())
local function drawBorderExtend(x,y)
  local length  = (c.win_W - ui.camera.right_w -x+6)
  love.graphics.setColor(255,255,255)
  love.graphics.draw(border_eximg,borderex_quad1,x-6,y-6,0,2,2)
  love.graphics.draw(border_eximg,borderex_quad2,x-2,y-6,0,length,2)
end

local function drawShortCutKey(leftborder,topborder,size)
  
  love.graphics.setColor(255,255,255)
  love.graphics.draw(shortcut_img,shortcut_quad,leftborder,topborder,0,size,size)
  love.graphics.draw(shortcut_img,key_quad,leftborder+4*size,topborder+5*size,0,size,size)
end

return function ()
  local size = small_key and 1.5 or 2
  local x,y = c.win_W-288,c.win_H-50
 suit:registerDraw(drawBorderExtend,x,y)
  
  picButton(quad_charactor,icon_img,btn_charactor_opt,x,y,46,50)
  picButton(quad_equipment,icon_img,btn_equipment_opt,x+48,y,46,50)
  local state_backpack  = picButton(quad_backpack,icon_img,btn_backpack_opt,x+96,y,46,50)
  picButton(quad_quest,icon_img,btn_quest_opt,x+144,y,46,50)
  picButton(quad_help,icon_img,btn_help_opt,x+192,y,46,50)
  picButton(quad_system,icon_img,btn_system_opt,x+240,y,46,50)
  
  local leftborder = (c.win_W - ui.camera.right_w)/2 - 364/2*size+40
  local clampb = x - 364*size-4
  leftborder = math.min(leftborder,clampb)
  suit:registerDraw(drawShortCutKey,leftborder,c.win_H - 38*size,size)
  
  if state_backpack.hit then
    ui.inventoryOpen()
    
  end
  
end