local gmap = g.map



function gmap.genBuidlingFromData(mapdata)
  local submaps = {}
  local function indexsubmap(x,y,z)
    return (z-mapdata.lowz)*mapdata.subx*mapdata.suby +y*mapdata.subx +x +1
  end
  
  
  for z = mapdata.lowz,mapdata.highz do
    for y = 0,mapdata.suby-1 do
      for x = 0,mapdata.subx-1 do
        local subm = gmap.create_submap()
        submaps[indexsubmap(x,y,z)] = subm
        local datasubmap = mapdata[z][x][y]
        for sx = 0,15 do
          for sy=0,15 do
            local square = datasubmap[sx][sy]
            subm.raw:setTer(data.ster_name2id[square.ter],sx,sy)
            if square.block then
              subm.raw:setBlock(data.block_name2id[square.block],sx,sy)
            end
          end
        end
      end
    end
  end
  
  return submaps
  
  
end