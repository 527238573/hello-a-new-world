local gmap = g.map


function gmap.getDefaultOvermapOption()
  return {
    default_air = data.oter_name2id["open_air"],
    default_rock = data.oter_name2id["solid_rocks"],
    default_oter = data.oter_name2id["field"],
    forest_oter = data.oter_name2id["forest"],
    forest_thick_oter = data.oter_name2id["forest_thick"],
    num_forests= 300,                   --"//": "# of forest chunks",
    forest_size_min= 25,               -- "//": "size range of forest chunk",
    forest_size_max=66,               -- "//": "note: 32400 tiles in omap, 250*minmax = 3750-10000 default_oters become forests",
    
    river_oter=  data.oter_name2id["river"],
    
  }

end






local function ti(name)
  local id = data.ster_name2id[name]
  if id ==nil then error("wrong ter name:"..name) end
  return id
end

local function bi(name)
  local id = data.block_name2id[name]
  if id ==nil then error("wrong block name:"..name) end
  return id
end


function gmap.getDefaultSubmapOption()
  return {
    default_groundcover = c.weightT{[ti("t_dirt")]=50,[ti("t_grass")]=1,[ti("t_sgrass")]=4}, --默认地图ter覆盖
    field_coverage = {
        default_coverage = c.weightT{ 
          [bi("f_none")]=460,
          [bi("f_shrub")]=3,
          [bi("f_underbush")]=1,
        },
    },
    
    forest = 
    {
      groundcover = c.weightT{[ti("t_dirt")]=3,[ti("t_grass")]=3,[ti("t_sgrass")]=2}, --森林地面
      tree = c.weightT{[bi("f_tree")]=3,},        --森林 大树组
      tree_young = c.weightT{[bi("f_tree_young")]=3,}, --森林 小树组
      underbush = c.weightT{[bi("f_shrub")]=5,[bi("f_underbush")]=2,}, --森林灌木组
    },
    openair = ti("t_air"),
    rocks = ti("t_wall_rock"),
    
  }
end