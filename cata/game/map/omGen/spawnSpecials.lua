local Om_Gen = g.overmap.Om_Gen






local function can_belong_to_city(special,px,py,city)
  if special.city_distance==nil or special.city_size==nil then
    return true
  end
  if city==nil then return false end
  if city[3]<special.city_size[1] or city[3]>special.city_size[2] then return false end
  
  local dis = math.sqrt((city[1]-px)^2+(city[2]-py)^2)-city[3]
  return  special.city_distance[1]<=dis and special.city_distance[2]>= dis
end

--已初始点0，0旋转相对xy到实际dir变换后的xy
local function dirXY(dir,x,y)
  if dir==1 then 
    return y,-x
  elseif dir ==2 then 
    return -x,-y
  elseif dir ==3 then 
    return -y,x
  else
    return x,y
  end
end

local function attempt_place_special(cur_om,special,px,py,city)
  local start_dir = rnd(0,3)
  local building = data.building_name2info[special.name]
  local can_place_on = {}--能放置的oterid
  
  for i= 1,#special.locations do
    local id = data.oter_name2id[special.locations[i]]
    if id ==nil then error("error oter_name:"..special.locations[i]) end
    can_place_on[data.oter_name2id[special.locations[i]]] = true
  end
  
  for i=0,3 do
    local dir = (start_dir+i)%4
    local valid = true
    
    for x= 0,building.xlen-1 do
      for y = 0,building.ylen-1 do
        local rx,ry = dirXY(dir,x,y)
        rx = rx+px
        ry = ry+py
        local oter_id = cur_om:getOterOrNil(rx,ry,1)
        if(oter_id==nil or can_place_on[oter_id]==nil) then valid = false end
      end
    end
    --检测路起始
    local roadx,roady
    if valid and special.roadstart then
      roadx,roady = dirXY(dir,special.roadstart[1],special.roadstart[2])
      roadx = roadx+px
      roady = roady+py
      local oter_id = cur_om:getOterOrNil(roadx,roady,1)
      if oter_id==nil or (not data.oter[oter_id].allow_road) then valid = false end --todo： 不能放置在river旁
    end
    
    if valid then
      local xlen,ylen,zlen = building.xlen,building.ylen,building.zlen
      --检测到合法，放置
      
      
      for x= 0,xlen-1 do
        for y = 0,ylen-1 do
          for z = 0,zlen-1 do
            local index = x*ylen*zlen+y*zlen+z+1
            local rx,ry = dirXY(dir,x,y)
            rx = rx+px
            ry = ry+py
            local rz =z+building.zmin  --z的范围未检测，
            local terinfo = building[index]
            local oter_id = terinfo.base_id + dir
            cur_om:setOter(oter_id,rx,ry,rz)
            
            --print("place oter_id:",oter_id,rx,ry,rz)
            --io.flush()
          end
        end
      end
      
      if special.roadstart then
        --print("make spc way:",roadx,roady,city[1],city[2])
        --io.flush()
        Om_Gen.make_hiway(roadx,roady,city[1],city[2])
      end
      
      
      
      
      return true--返回，否则继续下一个方向
    end
  end
  return false--所有方向都失败
  
  
end




local function getNearestCity(cities,x,y)
  local nearestCity
  local closest = -1
  
  for i= 1,#cities do
    local distance = (cities[i][1] - x)^2 + (cities[i][2] - y)^2
    if distance<closest or closest <0 then
      closest = distance
      nearestCity = cities[i]
    end
  end
  return nearestCity
end






function Om_Gen.placeSpecials(cities,cur_om,cur_option)
  
  local mandatory = {}
  local optional = {}
  
  for i=1,#cur_option.specials do
    local special = cur_option.specials[i]
    local min  = special.occurrences[1]
    local max = special.occurrences[2]
    if min>0 then mandatory[#mandatory+1] = {special = special,number = min} end
    if min>=0 and max-min>0 then optional[#optional+1] = {special = special,number = max-min} end
  end
  if #mandatory==0 and #optional==0 then return end
  c.random_shuffle(mandatory)
  c.random_shuffle(optional)
  
  local sectors = {}
  local sector_len  =16
  local sector_side_num =math.floor(256/ sector_len)
  for x= 0,sector_side_num-1 do
    for y=0,sector_side_num-1 do
      sectors[#sectors+1] = {x*sector_len,y*sector_len}
    end
  end
  c.random_shuffle(sectors)--随机区域
  
  for i=1,#sectors do --一个sector 放置最多一个
    local x = sectors[i][1]
    local y = sectors[i][2]
    local  attempts = 20;
    local attempts_mandatory = 10;
    local j = 0
    while(j<attempts) do
      j = j+1
      local px,py = x+rnd(0,sector_len),y+rnd(0,sector_len)
      local nearestCity = getNearestCity(cities,px,py)
      local candidates  = mandatory
      if(#mandatory==0 or j>attempts_mandatory) then candidates = optional end
      for k = 1,#candidates do
        local special = candidates[k].special
        if can_belong_to_city(special,px,py,nearestCity) then
            --合法范围内，可以使用
            --尝试放置special
          if attempt_place_special(cur_om,special,px,py,nearestCity) then --尝试摆放，如果成功就 摆放并返回true
            --减去数目
            candidates[k].number = candidates[k].number-1
            if candidates[k].number<=0 then
              table.remove(candidates,k)
              if(#mandatory==0 and #optional==0) then return end --job done
            end
            --跳出两层循环,转去下一个sector
            j = attempts
            break;
          end
        end
      end
    end
  end
  if #mandatory>0 then
    debugmsg("Om_Gen.placeSpecials: have unplaced  mandatory specials ")
  end
end