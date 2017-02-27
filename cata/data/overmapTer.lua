local img = love.graphics.newImage("data/overmapTer.png")
local imgw,imgh = img:getDimensions()
local otersize = 16

local overmapter_data = {img = img}
local name_index = {}--用于sametile功能，后加入的只能搜索之前的

local function add_oter(name,x,y,tiletype,option)
  option = option or {}
  option.name = name
  if tiletype =="single" or tiletype==nil then
    option.tiletype = 1
    table.insert(option,love.graphics.newQuad(x,y,otersize,otersize,imgw,imgh))
  elseif tiletype == "border" then
    option.tiletype = 2
    table.insert(option,love.graphics.newQuad(x,y,otersize,otersize,imgw,imgh))
    table.insert(option,love.graphics.newQuad(x+otersize,y,otersize,otersize,imgw,imgh))
    table.insert(option,love.graphics.newQuad(x+2*otersize,y,otersize,otersize,imgw,imgh))
    table.insert(option,love.graphics.newQuad(x+3*otersize,y,otersize,otersize,imgw,imgh))
    table.insert(option,love.graphics.newQuad(x+4*otersize,y,otersize,otersize,imgw,imgh))
    table.insert(option,love.graphics.newQuad(x+5*otersize,y,otersize,otersize,imgw,imgh))
    
  elseif tiletype == "sametile" then
    local sameInfo = name_index[option.sametile]
    if sameInfo==nil then error("cant find tile:"..option.sametile ) end
    option.tiletype = sameInfo.tiletype
    for k,v in ipairs(sameInfo) do
      option[k] = v
    end
  end
  table.insert(overmapter_data,option)
  name_index[option.name ] = option
end
 
local function addOneBuilding(name,x,y,topx,topy,option)
  option = option or {}
  option.name = name
  option.tiletype = 3 --building
  table.insert(option,love.graphics.newQuad(x,y,otersize,otersize,imgw,imgh))
  table.insert(option,love.graphics.newQuad(topx,topy,otersize,otersize,imgw,imgh))
  
  option.rotate = true--
  
  
  table.insert(overmapter_data,option)
  name_index[option.name] = option
  
  
end




add_oter("field",0,0,"single")

add_oter("forest",otersize*1,0*otersize,"border",{border_share = {"forest_thick"}})
add_oter("forest_thick",otersize,0,"sametile",{sametile = "forest",border_share = {"forest"}}) --
add_oter("unseen",otersize*7,0,"border")--暂无用到

add_oter("open_air",otersize*0,otersize*1,"single")
add_oter("solid_rocks",otersize*7,otersize*0,"border")

add_oter("river",otersize*13,otersize*0,"border",{background = love.graphics.newQuad(13*otersize,1*otersize,otersize,otersize,imgw,imgh)})
add_oter("road",otersize*1,otersize*1,"border",{})

--单house
addOneBuilding("house1x1",otersize*1,otersize*2,otersize*2,otersize*2,{sidewalk = true})--非野外buildingsidewalk都为true

return overmapter_data