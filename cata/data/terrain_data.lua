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

local function setLastTileData(display_name,move_cost,color,transparent,flags)
  local tile = tiles_data[#tiles_data]
  tile.displayname = display_name
  tile.move_cost = move_cost
  tile.color = color
  tile.transparent = transparent
  if flags then 
    for k,v in pairs(flags) do
      tile[k] = v
    end
  end
end
local function autoFlags(flags_table)
  local tile = tiles_data[#tiles_data]
  if flags_table then 
    for _,v in ipairs(flags_table) do
      tile[v] = true
    end
  end
end



addTile("t_grass",  0,0,    32,"hierarchy",15)
setLastTileData(tl("草地","grass"),100,"green",true,nil)
addTile("t_sgrass",  0,32,   32,"hierarchy",13)
setLastTileData(tl("草地","grass"),100,"green",true,nil)
addTile("t_dirt",   0,64,   32,"hierarchy",12)
setLastTileData(tl("泥地","dirt"),100,"brown",true,nil)
addTile("t_rock",   0,96,   32,"hierarchy",14)
setLastTileData(tl("岩石地面","rocky ground"),100,"brown",true,nil)
addTile("t_air",    0,128,  32,"hierarchy",1)
setLastTileData(tl("空","open air"),100,"light_blue",true,{nofloor = true});autoFlags{"NOITEM"}
addTile("t_air_indoor",    0,128,  32,"hierarchy",1)
setLastTileData(tl("空","open air"),100,"light_blue",true,{nofloor = true});autoFlags{"NOITEM"}

addTile("t_water_shallow",    7*32,0,  32,"hierarchy",4)
setLastTileData(tl("浅水","shallow water"),250,"light_blue",true,nil)
addTile("t_water_deep",    7*32,32,  32,"hierarchy",3)
setLastTileData(tl("深水","deep water"),400,"blue",true,nil)
addTile("t_sidewalk",    7*32,32*3,  32,"hierarchy",17)
setLastTileData(tl("人行道","sidewalk"),100,"light_grey",true,nil)
addTile("t_pavement",    7*32,32*2,  32,"hierarchy",16)
setLastTileData(tl("路面","pavement"),100,"black",true,nil)

addTile("t_wall_rock",0,160,  32,"wall",100)
setLastTileData(tl("岩壁","rock wall"),0,"dark_brown",false,nil);autoFlags{"NOITEM"}
addTile("t_wall_concrete",32*5,160,  32,"wall",100)
setLastTileData(tl("墙壁","wall"),0,"grey",false,nil);autoFlags{"NOITEM"}
addTile("t_wall_house",32*10,160,  32,"wall",100)
setLastTileData(tl("墙壁","wall"),0,"grey",false,nil);autoFlags{"NOITEM"}

addTile("t_floor",    11*32,32*4,  32,"single",0)
setLastTileData(tl("地板","floor"),100,"floor",true,nil)
addTile("t_roof",    12*32,32*4,  32,"single",0)
setLastTileData(tl("屋顶","roof"),100,"orange",true,nil)
addTile("t_pavement_x",    7*32,32*4,  32,"single",0)
setLastTileData(tl("路面","pavement"),100,"yellow",true,{rotate = {"t_pavement_y","t_pavement_x","t_pavement_y"}})
addTile("t_pavement_y",    8*32,32*4,  32,"single",0)
setLastTileData(tl("路面","pavement"),100,"yellow",true,{rotate = {"t_pavement_x","t_pavement_y","t_pavement_x"}})
addTile("t_pavement_p",    9*32,32*4,  32,"single",0)
setLastTileData(tl("路面","pavement"),100,"yellow",true,{rotate = {"t_pavement_n","t_pavement_p","t_pavement_n"}})
addTile("t_pavement_n",    10*32,32*4,  32,"single",0)
setLastTileData(tl("路面","pavement"),100,"yellow",true,{rotate = {"t_pavement_p","t_pavement_n","t_pavement_p"}})
addTile("t_stairs_down2",    14*32,32*4,  32,"single",0)
setLastTileData(tl("向下楼梯","stairs down"),150,"dark_grey",true,{stairs = "down",stairs_dir ={1,0},rotate = {"t_stairs_down3","t_stairs_down4","t_stairs_down1"}})
addTile("t_stairs_down4",    15*32,32*4,  32,"single",0)
setLastTileData(tl("向下楼梯","stairs down"),150,"dark_grey",true,{stairs = "down",stairs_dir ={-1,0},rotate = {"t_stairs_down1","t_stairs_down2","t_stairs_down3"}})
addTile("t_stairs_down1",    16*32,32*4,  32,"single",0)
setLastTileData(tl("向下楼梯","stairs down"),150,"dark_grey",true,{stairs = "down",stairs_dir ={0,1},rotate = {"t_stairs_down2","t_stairs_down3","t_stairs_down4"}})
addTile("t_stairs_down3",    17*32,32*4,  32,"single",0)
setLastTileData(tl("向下楼梯","stairs down"),150,"dark_grey",true,{stairs = "down",stairs_dir ={0,-1},rotate = {"t_stairs_down4","t_stairs_down1","t_stairs_down2"}})



return tiles_data
