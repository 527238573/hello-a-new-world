


local dp_water = tid("t_water_deep")
local function field(oter_id,subm,gendata,setting)
  local terWeightT = setting.default_groundcover  ------todo：   setting不完整时应有默认生成选项
  local blockWeightT = setting.field_coverage.default_coverage
  local raw = subm.raw
  local pick = c.getWeightValue
  for x=0,15 do
    for y = 0,15 do
      raw:setTer(pick(terWeightT),x,y)              --设置每个ter根据权重表
      raw:setBlock(pick(blockWeightT),x,y)
    end
  end    
end


g.map.add_mapgen_function("field",field);


local forest_otid = oid("forest")
local forest_thick_otid = oid("forest_thick")
local function forest(oter_id,subm,gendata,setting)
  local forest_setting = setting.forest
  local raw = subm.raw
  local pick = c.getWeightValue


  local basefactor = 0
  if oter_id == forest_otid then 
    basefactor = 0
  elseif oter_id == forest_thick_otid then
    basefactor = 4
  end
  local factors = {} --每个方向上的参数 1=上北 2 = 右东 3 = 下南 4= 左西 

  for i=1,4 do
    if gendata[i] == forest_otid then
      factors[i] = basefactor +12
    elseif gendata[i] == forest_thick_otid then
      factors[i] = basefactor+16
    else
      factors[i] = basefactor
    end
  end

  for x = 0,15 do
    for y =0,15 do
      local forest_chance = 0
      local num = 0
      if 15-y< factors[1] then
        forest_chance = forest_chance+ factors[1] -(15-y)
        num = num +1
      end
      if 15-x< factors[2] then
        forest_chance = forest_chance+ factors[2] -(15-x)
        num = num +1
      end
      if y< factors[3] then
        forest_chance = forest_chance+ factors[3] -y
        num = num +1
      end
      if x< factors[4] then
        forest_chance = forest_chance+ factors[4] -x
        num = num +1
      end
      if num>0 then forest_chance = forest_chance/num end

      local rn = rnd(0,forest_chance)
      if rn>11 or one_in(100-forest_chance) then  -- 大型树木
        raw:setBlock(pick(forest_setting.tree),x,y)
      elseif rn>8 or one_in(100-forest_chance) then  --小树
        raw:setBlock(pick(forest_setting.tree_young),x,y)
      elseif rn>6 or one_in(100-forest_chance) then  -- 灌木
        raw:setBlock(pick(forest_setting.underbush),x,y)
      end
      raw:setTer(pick(forest_setting.groundcover),x,y)
    end
  end
end

g.map.add_mapgen_function("forest",forest)
g.map.add_mapgen_function("forest_thick",forest)
