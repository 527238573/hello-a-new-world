

local function open_air(oter_id,subm,gendata,setting)
  local raw = subm.raw
  for x=0,15 do
    for y = 0,15 do
      raw:setTer(setting.openair,x,y)              
    end
  end   
  raw.is_uniform = true
end

g.map.add_mapgen_function("open_air",open_air);

local function solid_rocks(oter_id,subm,gendata,setting)
  local raw = subm.raw
  for x=0,15 do
    for y = 0,15 do
      raw:setTer(setting.rocks,x,y)              
    end
  end   
  raw.is_uniform = true
end

g.map.add_mapgen_function("solid_rocks",solid_rocks);