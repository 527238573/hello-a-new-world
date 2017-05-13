
local suit = require"ui/suit"
local hp_img = love.graphics.newImage("assets/ui/hpbar.png")
local spriteBatch = love.graphics.newSpriteBatch(hp_img,50,"stream")
local hp_back_quad = love.graphics.newQuad(0,0,60,73,hp_img:getDimensions())




local hp_c = {
  arm = {
    [1] = {
        love.graphics.newQuad(65,0,5,7,hp_img:getDimensions()),
        love.graphics.newQuad(71,0,5,7,hp_img:getDimensions()),
        love.graphics.newQuad(77,0,5,7,hp_img:getDimensions()),
      },
    [2] = {
        love.graphics.newQuad(65,8,5,7,hp_img:getDimensions()),
        love.graphics.newQuad(71,8,5,7,hp_img:getDimensions()),
        love.graphics.newQuad(77,8,5,7,hp_img:getDimensions()),
      },
    [3] = {
        love.graphics.newQuad(65,16,5,7,hp_img:getDimensions()),
        love.graphics.newQuad(71,16,5,7,hp_img:getDimensions()),
        love.graphics.newQuad(77,16,5,7,hp_img:getDimensions()),
      },
    [4] = {
        love.graphics.newQuad(65,24,5,7,hp_img:getDimensions()),
        love.graphics.newQuad(71,24,5,7,hp_img:getDimensions()),
        love.graphics.newQuad(77,24,5,7,hp_img:getDimensions()),
      },
  },
  head = {
    [1] = {
        love.graphics.newQuad(85,0,21,6,hp_img:getDimensions()),
        love.graphics.newQuad(85,7,21,6,hp_img:getDimensions()),
        love.graphics.newQuad(85,14,21,6,hp_img:getDimensions()),
      },
    [2] = {
        love.graphics.newQuad(85,21,21,6,hp_img:getDimensions()),
        love.graphics.newQuad(85,28,21,6,hp_img:getDimensions()),
        love.graphics.newQuad(85,35,21,6,hp_img:getDimensions()),
      },
    [3] = {
        love.graphics.newQuad(85,42,21,6,hp_img:getDimensions()),
        love.graphics.newQuad(85,49,21,6,hp_img:getDimensions()),
        love.graphics.newQuad(85,56,21,6,hp_img:getDimensions()),
      },
    [4] = {
        love.graphics.newQuad(85,63,21,6,hp_img:getDimensions()),
        love.graphics.newQuad(85,70,21,6,hp_img:getDimensions()),
        love.graphics.newQuad(85,77,21,6,hp_img:getDimensions()),
      },
  },
  torso = {
    [1] = {
        love.graphics.newQuad(3,79,15,8,hp_img:getDimensions()),
        love.graphics.newQuad(3,88,15,7,hp_img:getDimensions()),
        love.graphics.newQuad(3,96,15,7,hp_img:getDimensions()),
      },
    [2] = {
        love.graphics.newQuad(21,79,15,8,hp_img:getDimensions()),
        love.graphics.newQuad(21,88,15,7,hp_img:getDimensions()),
        love.graphics.newQuad(21,96,15,7,hp_img:getDimensions()),
      },
    [3] = {
        love.graphics.newQuad(3,105,15,8,hp_img:getDimensions()),
        love.graphics.newQuad(3,114,15,7,hp_img:getDimensions()),
        love.graphics.newQuad(3,122,15,7,hp_img:getDimensions()),
      },
    [4] = {
        love.graphics.newQuad(21,105,15,8,hp_img:getDimensions()),
        love.graphics.newQuad(21,114,15,7,hp_img:getDimensions()),
        love.graphics.newQuad(21,122,15,7,hp_img:getDimensions()),
      },
  },
  lleg = {
    [1] = {
        love.graphics.newQuad(43,79,11,5,hp_img:getDimensions()),
        love.graphics.newQuad(40,85,11,5,hp_img:getDimensions()),
        love.graphics.newQuad(38,91,11,5,hp_img:getDimensions()),
      },
    [2] = {
        love.graphics.newQuad(43,97,11,5,hp_img:getDimensions()),
        love.graphics.newQuad(40,103,11,5,hp_img:getDimensions()),
        love.graphics.newQuad(38,109,11,5,hp_img:getDimensions()),
      },
    [3] = {
        love.graphics.newQuad(43,115,11,5,hp_img:getDimensions()),
        love.graphics.newQuad(40,121,11,5,hp_img:getDimensions()),
        love.graphics.newQuad(38,127,11,5,hp_img:getDimensions()),
      },
    [4] = {
        love.graphics.newQuad(43,133,11,5,hp_img:getDimensions()),
        love.graphics.newQuad(40,139,11,5,hp_img:getDimensions()),
        love.graphics.newQuad(38,145,11,5,hp_img:getDimensions()),
      },
  },
  
}
local weather_icons = {
  sunny = love.graphics.newQuad(161,0,19,19,hp_img:getDimensions()),
  clear_night = love.graphics.newQuad(142,0,19,19,hp_img:getDimensions()),
  cloudy = love.graphics.newQuad(123,0,19,19,hp_img:getDimensions()),
  drizzle = love.graphics.newQuad(161,19,19,19,hp_img:getDimensions()),
  rainy = love.graphics.newQuad(161,38,19,19,hp_img:getDimensions()),
  thunder = love.graphics.newQuad(142,19,19,19,hp_img:getDimensions()),
  lightning = love.graphics.newQuad(142,38,19,19,hp_img:getDimensions()),
  acid_drizzle = love.graphics.newQuad(161,57,19,19,hp_img:getDimensions()),
  acid_rainy = love.graphics.newQuad(142,57,19,19,hp_img:getDimensions()),
  flurries = love.graphics.newQuad(123,19,19,19,hp_img:getDimensions()),
  snow = love.graphics.newQuad(123,38,19,19,hp_img:getDimensions()),
  snowstorm = love.graphics.newQuad(123,57,19,19,hp_img:getDimensions()),
}
local morale_icons = { -- 1-7级
  love.graphics.newQuad(79,116,13,14,hp_img:getDimensions()),
  love.graphics.newQuad(108,101,13,14,hp_img:getDimensions()),
  love.graphics.newQuad(94,101,13,14,hp_img:getDimensions()),
  love.graphics.newQuad(80,86,13,14,hp_img:getDimensions()),
  love.graphics.newQuad(94,86,13,14,hp_img:getDimensions()),
  love.graphics.newQuad(108,86,13,14,hp_img:getDimensions()),
  love.graphics.newQuad(80,101,13,14,hp_img:getDimensions()),
}

local atr_quad = love.graphics.newQuad(123,78,44,39,hp_img:getDimensions())
local time_quad = love.graphics.newQuad(93,119,87,21,hp_img:getDimensions())
local calendar = g.calendar


local function getHpStateCode(hp_percent)
  local r1 = 1
  if hp_percent <=0.3 then r1= 4
  elseif hp_percent <=0.6 then r1 = 3
  elseif hp_percent <=0.9 then r1 = 2 end
  local r2 = 1
  if hp_percent <=0.2 then r2= 4
  elseif hp_percent <=0.5 then r2 = 3
  elseif hp_percent <=0.8 then r2 = 2 end
  local r3 =1 
  if hp_percent <=0.1 then r2= 4
  elseif hp_percent <=0.4 then r2 = 3
  elseif hp_percent <=0.7 then r2 = 2 end
  return r1,r2,r3
end


local function defaultDraw(x,y)
  
  love.graphics.setColor(110,110,110)
  love.graphics.rectangle("fill",x,y,270,170)
  love.graphics.setColor(255,255,255)
  spriteBatch:clear()
  spriteBatch:add(hp_back_quad,0,0)
  --head 
  local r1,r2,r3
  r1,r2,r3 = getHpStateCode(player.hp_cur[1]/player.hp_max[1])
  spriteBatch:add(hp_c.head[r1][1],20,3)
  spriteBatch:add(hp_c.head[r2][2],20,10)
  spriteBatch:add(hp_c.head[r3][3],20,17)
  --torso
  r1,r2,r3 = getHpStateCode(player.hp_cur[2]/player.hp_max[2])
  spriteBatch:add(hp_c.torso[r1][1],23,27)
  spriteBatch:add(hp_c.torso[r2][2],23,36)
  spriteBatch:add(hp_c.torso[r3][3],23,44)
  --arm_l
  r1,r2,r3 = getHpStateCode(player.hp_cur[3]/player.hp_max[3])
  spriteBatch:add(hp_c.arm[r1][1],3,27)
  spriteBatch:add(hp_c.arm[r2][2],9,27)
  spriteBatch:add(hp_c.arm[r3][3],15,27)
  --arm_r
  r1,r2,r3 = getHpStateCode(player.hp_cur[4]/player.hp_max[4])
  spriteBatch:add(hp_c.arm[r1][3],53,27)
  spriteBatch:add(hp_c.arm[r2][2],47,27)
  spriteBatch:add(hp_c.arm[r3][1],41,27)
  --leg_l 
  r1,r2,r3 = getHpStateCode(player.hp_cur[5]/player.hp_max[5])
  spriteBatch:add(hp_c.lleg[r1][1],17,54)
  spriteBatch:add(hp_c.lleg[r2][2],14,60)
  spriteBatch:add(hp_c.lleg[r3][3],12,66)
  --legr
  r1,r2,r3 = getHpStateCode(player.hp_cur[6]/player.hp_max[6])
  spriteBatch:add(hp_c.lleg[r1][1],44,54,0,-1,1)
  spriteBatch:add(hp_c.lleg[r2][2],47,60,0,-1,1)
  spriteBatch:add(hp_c.lleg[r3][3],49,66,0,-1,1)
  
  --士气
  spriteBatch:add(morale_icons[4],2,2)
  
  --天气，属性
  spriteBatch:add(weather_icons.sunny,115,1)
  spriteBatch:add(time_quad,48,0)
  spriteBatch:add(atr_quad,65,15)
  
  spriteBatch:flush()
  
  love.graphics.draw(spriteBatch,x,y,0,2,2)
  
  
  love.graphics.setFont(c.font_c16)
  love.graphics.setColor(1,1,1)
  love.graphics.printf(calendar.getTimeStr(),x+100,y+5,128,"center")
  love.graphics.print(player.speed_cur,x+155,y+33)
  love.graphics.print(player.str_cur,x+155,y+61)
  love.graphics.print(player.dex_cur,x+221,y+61)
  love.graphics.print(player.int_cur,x+155,y+89)
  love.graphics.print(player.per_cur,x+221,y+89)
end






function ui.stateWin(x,y)
  suit:registerDraw(defaultDraw,x,y)
end