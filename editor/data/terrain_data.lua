local tiles_img = love.graphics.newImage("data/terrain.png")

local tiles_data = {img = tiles_img}

--[[
subdata 
hierarchy =1 分层，有优先级的，依次读取左边5格 4,2>v,1<,2><,3>v<
self =2  自适应
none =3 单个格子
]]--

local function addTile(name,x,y,size,subdata,priority)
  local tile ={name = name,img = tiles_img}
  if size ==32 then
    tile.scalefactor = 2
  elseif size == 64 then 
    tile.scalefactor =1
  else
    error("tile must be 32*32 or 64*64")
  end
  if subdata == "hierarchy" then 
    tile.type = 1
    tile.priority = priority
    table.insert(tile,love.graphics.newQuad(x,y,size,size,tiles_img:getDimensions()))
    table.insert(tile,love.graphics.newQuad(x+size,y,size,size,tiles_img:getDimensions()))
    table.insert(tile,love.graphics.newQuad(x+2*size,y,size,size,tiles_img:getDimensions()))
    table.insert(tile,love.graphics.newQuad(x+3*size,y,size,size,tiles_img:getDimensions()))
    table.insert(tile,love.graphics.newQuad(x+4*size,y,size,size,tiles_img:getDimensions()))
    table.insert(tile,love.graphics.newQuad(x+5*size,y,size,size,tiles_img:getDimensions()))
  elseif subdata =="self" then
    tile.type = 2
    table.insert(tile,love.graphics.newQuad(x,y,size,size,tiles_img:getDimensions()))
  elseif subdata =="single" then
    tile.type = 3
    table.insert(tile,love.graphics.newQuad(x,y,size,size,tiles_img:getDimensions()))
  elseif subdata =="wall" then --实体墙
    tile.type = 4
    table.insert(tile,love.graphics.newQuad(x,y,size,size,tiles_img:getDimensions()))
    table.insert(tile,love.graphics.newQuad(x+size,y,size,size,tiles_img:getDimensions()))
    table.insert(tile,love.graphics.newQuad(x+2*size,y,size,size,tiles_img:getDimensions()))
    table.insert(tile,love.graphics.newQuad(x+3*size,y,size,size,tiles_img:getDimensions()))
    table.insert(tile,love.graphics.newQuad(x+4*size,y,size,size,tiles_img:getDimensions()))
    table.insert(tile,love.graphics.newQuad(x,y+size,size,size*1.5,tiles_img:getDimensions()))
    table.insert(tile,love.graphics.newQuad(x+size,y+size,size,size*1.5,tiles_img:getDimensions()))
    table.insert(tile,love.graphics.newQuad(x+2*size,y+size,size,size*1.5,tiles_img:getDimensions()))
    table.insert(tile,love.graphics.newQuad(x+3*size,y+size,size,size*1.5,tiles_img:getDimensions()))
  else
    error("subdata error")
  end
  table.insert(tiles_data,tile)
end



addTile("t_grass",  0,0,    32,"hierarchy",15)
addTile("t_sgrass",  0,32,   32,"hierarchy",13)
addTile("t_dirt",   0,64,   32,"hierarchy",12)
addTile("t_rock",   0,96,   32,"hierarchy",14)
addTile("t_air",    0,128,  32,"hierarchy",1)
addTile("t_water_shallow",    7*32,0,  32,"hierarchy",4)
addTile("t_water_deep",    7*32,32,  32,"hierarchy",3)
addTile("t_sidewalk",    7*32,32*3,  32,"hierarchy",17)
addTile("t_pavement",    7*32,32*2,  32,"hierarchy",16)

addTile("t_wall_rock",0,160,  32,"wall",100)
addTile("t_wall_concrete",32*5,160,  32,"wall",100)
addTile("t_wall_house",32*10,160,  32,"wall",100)

addTile("t_floor",    11*32,32*4,  32,"single",0)
addTile("t_roof",    12*32,32*4,  32,"single",0)
addTile("t_pavement_x",    7*32,32*4,  32,"single",0)
addTile("t_pavement_y",    8*32,32*4,  32,"single",0)
addTile("t_pavement_p",    9*32,32*4,  32,"single",0)
addTile("t_pavement_n",    10*32,32*4,  32,"single",0)

return tiles_data
