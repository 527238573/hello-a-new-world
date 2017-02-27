


local sh_water = tid("t_water_shallow")
local dp_water = tid("t_water_deep")
local river_otid = oid("river")
local function river(oter_id,subm,gendata,setting)
  local raw = subm.raw
  subm:fillTer(dp_water) --初始全部为深水
  
  local function isRiver(oid)
    return oid == river_otid
  end
  
  local terWeightT = setting.default_groundcover
  local pick = c.getWeightValue
  local nr,sr,wr,er = false,false,false,false
  
  --主要河岸 铺设河岸
  if not isRiver(gendata[1]) then--上方north
    nr = true
    for x= 0,15 do
      local goundstep = rnd(1,3)
      local shwaterstep = rnd(4,6)
      local step = 0
      for y = 15,0,-1 do
        if step<goundstep then
          raw:setTer(pick(terWeightT),x,y) 
        elseif step<=shwaterstep then
          raw:setTer(sh_water,x,y)
        else
          break
        end
        step= step+1
      end
    end
  end
  --右方
  if not isRiver(gendata[2]) then--
    er = true
    for y= 0,15 do
      local goundstep = rnd(1,3)
      local shwaterstep = rnd(4,6)
      local step = 0
      for x= 15,0,-1 do
        if step<goundstep then
          raw:setTer(pick(terWeightT),x,y) 
        elseif step<=shwaterstep then
          raw:setTer(sh_water,x,y)
        else
          break
        end
        step= step+1
      end
    end
  end
  --下方
  if not isRiver(gendata[3]) then--
    sr= true
    for x= 0,15 do
      local goundstep = rnd(1,3)
      local shwaterstep = rnd(4,6)
      local step = 0
      for y= 0,15 do
        if step<goundstep then
          raw:setTer(pick(terWeightT),x,y) 
        elseif step<=shwaterstep then
          raw:setTer(sh_water,x,y)
        else
          break
        end
        step= step+1
      end
    end
  end
  --左方
  if not isRiver(gendata[4]) then-- 
    wr = true
    for y= 0,15 do
      local goundstep = rnd(1,3)
      local shwaterstep = rnd(4,6)
      local step = 0
      for x= 0,15 do
        if step<goundstep then
          raw:setTer(pick(terWeightT),x,y) 
        elseif step<=shwaterstep then
          raw:setTer(sh_water,x,y)
        else
          break
        end
        step= step+1
      end
    end
  end
  --左上
  if (not isRiver(gendata[5]) )and nr==wr then
    local edge1 = rnd(4,6)
    local edge2 = rnd(4,6)
    for step1 = 0,edge1 do
      for step2 = 0,edge2 do
        local x,y = step1,15-step2
        local circle = step1*step1 + step2*step2+rnd(-3,3)
        if(circle <= 9)then
          local ter = raw:getTer(x,y)
          if ter==sh_water or ter == dp_water then raw:setTer(pick(terWeightT),x,y) end
        elseif(circle <= 36)then
          local ter = raw:getTer(x,y)
          if ter == dp_water then raw:setTer(sh_water,x,y)end
        end
      end
    end
  end
  
  --右上
  if (not isRiver(gendata[6]) )and nr==er then
    local edge1 = rnd(4,6)
    local edge2 = rnd(4,6)
    for step1 = 0,edge1 do
      for step2 = 0,edge2 do
        local x,y = 15-step1,15-step2
        local circle = step1*step1 + step2*step2+rnd(-3,3)
        if(circle <= 9)then
          local ter = raw:getTer(x,y)
          if ter==sh_water or ter == dp_water then raw:setTer(pick(terWeightT),x,y) end
        elseif(circle <= 36)then
          local ter = raw:getTer(x,y)
          if ter == dp_water then raw:setTer(sh_water,x,y)end
        end
      end
    end
  end
  
  --右下
  if (not isRiver(gendata[7]) )and er==sr then
    local edge1 = rnd(4,6)
    local edge2 = rnd(4,6)
    for step1 = 0,edge1 do
      for step2 = 0,edge2 do
        local x,y = 15-step1,step2
        local circle = step1*step1 + step2*step2+rnd(-3,3)
        if(circle <= 9)then
          local ter = raw:getTer(x,y)
          if ter==sh_water or ter == dp_water then raw:setTer(pick(terWeightT),x,y) end
        elseif(circle <= 36)then
          local ter = raw:getTer(x,y)
          if ter == dp_water then raw:setTer(sh_water,x,y)end
        end
      end
    end
  end
  
  --左下
  if (not isRiver(gendata[8]) )and sr==wr then
    local edge1 = rnd(4,6)
    local edge2 = rnd(4,6)
    for step1 = 0,edge1 do
      for step2 = 0,edge2 do
        local x,y = step1,step2
        local circle = step1*step1 + step2*step2+rnd(-3,3)
        if(circle <= 9)then
          local ter = raw:getTer(x,y)
          if ter==sh_water or ter == dp_water then raw:setTer(pick(terWeightT),x,y) end
        elseif(circle <= 36)then
          local ter = raw:getTer(x,y)
          if ter == dp_water then raw:setTer(sh_water,x,y)end
        end
      end
    end
  end
end
g.map.add_mapgen_function("river",river);

local pavement = tid("t_pavement")
local sidewalk = tid("t_sidewalk")
local yellowLinex = tid("t_pavement_x")
local yellowLiney = tid("t_pavement_y")
local yellowLinep = tid("t_pavement_p")
local yellowLinen = tid("t_pavement_n")
local road_otid = oid("road")
local roadStateList = {[0] = 0,1,1,5,1,2,6,3,1,7,2,3,8,3,3,4}
local diag_rot = {3,2,0,1}
local diag_1 = {}
local diag_2 = {}
local function road(oter_id,subm,gendata,setting)
  local raw = subm.raw
  local terWeightT = setting.default_groundcover
  local pick = c.getWeightValue
  local function isRoad(oid)
    return oid == road_otid
  end
  local is_road_t = {}
  for i= 1,8 do is_road_t[i] = isRoad(gendata[i]) end
  local sidewalk_t = {}
  for i=1,4 do 
    sidewalk_t[i] = data.oter[gendata[i]].sidewalk 
  end
  
  
  local state_code = 0
  if is_road_t[1] then state_code = state_code+8 end
  if is_road_t[2] then state_code = state_code+4 end
  if is_road_t[3] then state_code = state_code+2 end
  if is_road_t[4] then state_code = state_code+1 end
  local state = roadStateList[state_code]
  
  local function fillSideWalk()
    if not is_road_t[1] then
      if sidewalk_t[1] then
        subm:lineTer(sidewalk,0,15,15,15)
        subm:lineTer(sidewalk,0,14,15,14)
      else
        for x =0,15 do raw:setTer(pick(terWeightT),x,15) end--一格野地
      end
      if is_road_t[5] and is_road_t[4] then
        raw:setTer(pavement,0,15)--制造拐弯 挖角
        raw:setTer(pavement,0,14)
        raw:setTer(pavement,1,14)
      end
      if is_road_t[6] and is_road_t[2] then
        raw:setTer(pavement,15,15)--制造拐弯 挖角
        raw:setTer(pavement,15,14)
        raw:setTer(pavement,14,14)
      end
    end
    if not is_road_t[2] then
      if sidewalk_t[2] then
        subm:lineTer(sidewalk,15,0,15,15)
        subm:lineTer(sidewalk,14,0,14,15)
      else
        for y =0,15 do raw:setTer(pick(terWeightT),15,y) end--一格野地
      end
      if is_road_t[6] and is_road_t[1] then
        raw:setTer(pavement,15,15)--制造拐弯 挖角
        raw:setTer(pavement,14,15)
        raw:setTer(pavement,14,14)
      end
      if is_road_t[7] and is_road_t[3] then
        raw:setTer(pavement,15,0)--制造拐弯 挖角
        raw:setTer(pavement,14,0)
        raw:setTer(pavement,14,1)
      end
    end
    if not is_road_t[3] then
      if sidewalk_t[3] then
        subm:lineTer(sidewalk,0,0,15,0)
        subm:lineTer(sidewalk,0,1,15,1)
      else
        for x =0,15 do raw:setTer(pick(terWeightT),x,0) end--一格野地
      end
      if is_road_t[7] and is_road_t[2] then
        raw:setTer(pavement,15,0)--制造拐弯 挖角
        raw:setTer(pavement,15,1)
        raw:setTer(pavement,14,1)
      end
      if is_road_t[8] and is_road_t[4] then
        raw:setTer(pavement,0,0)--制造拐弯 挖角
        raw:setTer(pavement,0,1)
        raw:setTer(pavement,1,1)
      end
    end
    if not is_road_t[4] then
      if sidewalk_t[4] then
        subm:lineTer(sidewalk,0,0,0,15)
        subm:lineTer(sidewalk,1,0,1,15)
      else
        for y =0,15 do raw:setTer(pick(terWeightT),0,y) end--一格野地
      end
      if is_road_t[8] and is_road_t[3] then
        raw:setTer(pavement,0,0)--制造拐弯 挖角
        raw:setTer(pavement,1,0)
        raw:setTer(pavement,1,1)
      end
      if is_road_t[5] and is_road_t[1] then
        raw:setTer(pavement,0,15)--制造拐弯 挖角
        raw:setTer(pavement,1,15)
        raw:setTer(pavement,1,14)
      end
    end
  end
  
  
  if state ==0 or state ==4 then
    subm:fillTer(pavement)
    
  elseif state ==1 or state==2 or state ==3 then
    subm:fillTer(pavement)
    --画出黄线
    if is_road_t[1] and is_road_t[3] then
      for y = 0,15 do 
        if y%4 ~= 3 then 
          raw:setTer(yellowLiney,7,y);
          raw:setTer(yellowLiney,8,y);
        end
      end
    elseif is_road_t[2] and is_road_t[4] then
      for x = 0,15 do
        if x%4 ~= 3 then 
          raw:setTer(yellowLinex,x,7);
          raw:setTer(yellowLinex,x,8);
        end
      end
    end
  else
    --拐角
    local usesidewalk = sidewalk_t[1] or sidewalk_t[2] or sidewalk_t[3] or sidewalk_t[4]
    if state ==5 then -- 拐角 左下
      for x = 0,15 do
        for y = 0,15 do
          if x+y>15 then
            raw:setTer(pick(terWeightT),x,y)
          else
            raw:setTer(pavement,x,y)
          end
        end
      end
      if usesidewalk then
        subm:lineTer(sidewalk,1,15,15,1)
        subm:lineTer(sidewalk,2,15,15,2)
      end
      --黄线
      raw:setTer(yellowLinen,0,6);raw:setTer(yellowLinen,1,5);raw:setTer(yellowLinen,2,4)
      raw:setTer(yellowLinen,1,6);raw:setTer(yellowLinen,2,5);raw:setTer(yellowLinen,3,4)
      raw:setTer(yellowLinen,4,2);raw:setTer(yellowLinen,5,1);raw:setTer(yellowLinen,6,0)
      raw:setTer(yellowLinen,5,2);raw:setTer(yellowLinen,6,1);raw:setTer(yellowLinen,7,0)
    elseif state ==6 then ---- 拐角 右下
      for x = 0,15 do
        for y = 0,15 do
          if (15-x)+y>15 then
            raw:setTer(pick(terWeightT),x,y)
          else
            raw:setTer(pavement,x,y)
          end
        end
      end
      if usesidewalk then
        subm:lineTer(sidewalk,0,1,14,15)
        subm:lineTer(sidewalk,0,2,13,15)
      end
      --黄线
      raw:setTer(yellowLinep,8,0);raw:setTer(yellowLinep,9,1);raw:setTer(yellowLinep,10,2)
      raw:setTer(yellowLinep,9,0);raw:setTer(yellowLinep,10,1);raw:setTer(yellowLinep,11,2)
      raw:setTer(yellowLinep,12,4);raw:setTer(yellowLinep,13,5);raw:setTer(yellowLinep,14,6)
      raw:setTer(yellowLinep,13,4);raw:setTer(yellowLinep,14,5);raw:setTer(yellowLinep,15,6)
    elseif state ==7 then ---- 拐角 左上
      for x = 0,15 do
        for y = 0,15 do
          if x+(15-y)>15 then
            raw:setTer(pick(terWeightT),x,y)
          else
            raw:setTer(pavement,x,y)
          end
        end
      end
      if usesidewalk then
        subm:lineTer(sidewalk,1,0,15,14)
        subm:lineTer(sidewalk,2,0,15,13)
      end
      --黄线
      raw:setTer(yellowLinep,0,8);raw:setTer(yellowLinep,1,9);raw:setTer(yellowLinep,2,10)
      raw:setTer(yellowLinep,1,8);raw:setTer(yellowLinep,2,9);raw:setTer(yellowLinep,3,10)
      raw:setTer(yellowLinep,4,12);raw:setTer(yellowLinep,5,13);raw:setTer(yellowLinep,6,14)
      raw:setTer(yellowLinep,5,12);raw:setTer(yellowLinep,6,13);raw:setTer(yellowLinep,7,14)
    elseif state ==8 then ---- 拐角 右上
      for x = 0,15 do
        for y = 0,15 do
          if (15-x)+(15-y)>15 then
            raw:setTer(pick(terWeightT),x,y)
          else
            raw:setTer(pavement,x,y)
          end
        end
      end
      if usesidewalk then
        subm:lineTer(sidewalk,0,14,14,0)
        subm:lineTer(sidewalk,0,13,13,0)
      end
      --黄线
      raw:setTer(yellowLinen,8,14);raw:setTer(yellowLinen,9,13);raw:setTer(yellowLinen,10,12)
      raw:setTer(yellowLinen,9,14);raw:setTer(yellowLinen,10,13);raw:setTer(yellowLinen,11,12)
      raw:setTer(yellowLinen,12,10);raw:setTer(yellowLinen,13,9);raw:setTer(yellowLinen,14,8)
      raw:setTer(yellowLinen,13,10);raw:setTer(yellowLinen,14,9);raw:setTer(yellowLinen,15,8)
    end
    
  end
  fillSideWalk();--画出人行道
  
  
end
  


  
  g.map.add_mapgen_function("road",road);
  