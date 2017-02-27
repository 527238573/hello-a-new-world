c={}


c.win_W = love.graphics.getWidth()
c.win_H = love.graphics.getHeight()

c.squarePixels= 64
c.submapSide = 16
c.bufferSide = 32
c.overmapSide = 256   --1 overmap = 256*256 submap    1 submap = 16*16square      1 buffer = 32*32 submap

c.topbar_H = 30
c.painterPanel_W = 300


function c.clamp(x,min,max)
  return x>max and max or x<min and min or x
end


c.btn_font = love.graphics.newFont("assets/fzh.ttf",14);
c.cn12_font = love.graphics.newFont("assets/fzh.ttf",12);