local suit = require"ui/suit"

local closeImg = love.graphics.newImage("assets/ui/closeBtn.png")
ui.res.close_quads = 
{
  normal = love.graphics.newQuad(0,0,30,24,30,72),
  hovered=  love.graphics.newQuad(0,24,30,24,30,72),
  active =  love.graphics.newQuad(0,48,30,24,30,72),
  img = closeImg,
}
local tabImg = love.graphics.newImage("assets/ui/tab.png")
ui.res.tab_quads = 
{
  normal = suit.createS9Table(tabImg,0,0,24,24,6,6,6,6),
  hovered=  suit.createS9Table(tabImg,0,24,24,24,6,6,6,6),
  active =  suit.createS9Table(tabImg,0,48,24,24,6,6,6,6),
}


local tableftImg= love.graphics.newImage("assets/ui/tab_left.png")
ui.res.tab_left_quads = 
{
  normal = suit.createS9Table(tableftImg,0,0,32,32,6,8,6,6),
  hovered=  suit.createS9Table(tableftImg,0,32,32,32,6,8,6,6),
  active =  suit.createS9Table(tableftImg,0,64,32,32,6,8,6,6),
}


local somebarImg= love.graphics.newImage("assets/ui/somebar.png")
ui.res.somebar = {
  back = suit.createS9Table(somebarImg,0,0,32,32,6,6,6,6),
  front = suit.createS9Table(somebarImg,0,32,32,32,8,8,8,8),
  triangle = love.graphics.newQuad(0,64,32,32,32,96),
  img = somebarImg,
}
