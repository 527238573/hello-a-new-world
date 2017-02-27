
local floor = tid("t_floor")
local sidewalk = tid("t_sidewalk")
local wall = tid("t_wall_house")
local function house(oter_id,subm,gendata,setting)
  subm:fillTer(floor)
  subm:lineTer(sidewalk,0,0,15,0)
  subm:lineTer(sidewalk,0,0,0,15)
  subm:lineTer(sidewalk,0,15,15,15)
  subm:lineTer(sidewalk,15,0,15,15)
  subm:lineTer(wall,1,1,14,1)
  subm:lineTer(wall,1,1,1,14)
  subm:lineTer(wall,1,14,14,14)
  subm:lineTer(wall,14,1,14,14)
  
  
end

g.map.add_mapgen_function("house1x1",house);