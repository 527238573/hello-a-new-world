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

local function setLastTileData(display_name,move_cost,color,flag)
  local tile = tiles_data[#tiles_data]
  tile.displayname = display_name
  tile.move_cost = move_cost
  tile.color = color
  tile.flag = flag
end




addTile("t_grass",  0,0,    32,"hierarchy",15)
setLastTileData(tl("草地","grass"),100,"green",nil)
addTile("t_sgrass",  0,32,   32,"hierarchy",13)
setLastTileData(tl("草地","grass"),100,"green",nil)
addTile("t_dirt",   0,64,   32,"hierarchy",12)
setLastTileData(tl("泥地","dirt"),100,"brown",nil)
addTile("t_rock",   0,96,   32,"hierarchy",14)
setLastTileData(tl("岩石地面","rocky ground"),100,"brown",nil)
addTile("t_air",    0,128,  32,"hierarchy",1)
setLastTileData(tl("空","open air"),100,"light blue",nil)
addTile("t_air_indoor",    0,128,  32,"hierarchy",1)
setLastTileData(tl("空","open air"),100,"light blue",nil)

addTile("t_water_shallow",    7*32,0,  32,"hierarchy",4)
setLastTileData(tl("浅水","shallow water"),250,"blue",nil)
addTile("t_water_deep",    7*32,32,  32,"hierarchy",3)
setLastTileData(tl("深水","deep water"),400,"blue",nil)
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
addTile("t_stairs_down1",    14*32,32*4,  32,"single",0)
addTile("t_stairs_down2",    15*32,32*4,  32,"single",0)
addTile("t_stairs_down3",    16*32,32*4,  32,"single",0)
addTile("t_stairs_down4",    17*32,32*4,  32,"single",0)



return tiles_data
