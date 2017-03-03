
local overmapBase = g.overmap
local Om_Gen = {}
overmapBase.Om_Gen = Om_Gen
require "game/map/omGen/spawnCities"
require "game/map/omGen/spawnSpecials"

local cur_option
local cur_om
local north_om,south_om,west_om,east_om
local random = love.math.random

local function clearCache()
  cur_om = nil
  cur_option = nil
  north_om = nil
  south_om = nil
  west_om = nil
  east_om = nil
end




--[[生成新的overmap，xy为overmap的绝对坐标，生成完毕后自动加入buffer内 并返回
不能重复生成已有的overmap，调用之前需确认不存在
--]]
function overmapBase.generate(x,y)
  local time1  = love.timer.getTime()
  
  local omgen_option = g.map.cur_overmapGenSetting
  
  
  cur_option = omgen_option
  cur_om = overmapBase.create_overmap()
  --暂时设为默认ter 为field
  for x= 0,255 do
    for y=0,255 do
      for z = -10,0 do
        cur_om:setOter(omgen_option.default_rock,x,y,z)
        cur_om:setSeen(true,x,y,z)
      end
      cur_om:setOter(omgen_option.default_oter,x,y,1)
      cur_om:setSeen(true,x,y,1)
      for z = 2,12 do
        cur_om:setOter(omgen_option.default_air,x,y,z)
        cur_om:setSeen(true,x,y,z)
      end
    end
  end
  --取得四周之overmap
  north_om = overmapBase.get_existing_overmap(x,y+1)
  south_om = overmapBase.get_existing_overmap(x,y-1)
  west_om = overmapBase.get_existing_overmap(x-1,y)
  east_om = overmapBase.get_existing_overmap(x+1,y)
  
  local roadOut = Om_Gen.placeRiver()
  
  local cities = Om_Gen.placeCities(cur_om,cur_option)
  Om_Gen.placeForest(cities)
  Om_Gen.placeRoad(roadOut,cities)
  
  Om_Gen.placeSpecials(cities,cur_om,cur_option)
  ---[[
  
  local building = data.building_name2info["house22"]
  cur_om:setOter(building[0*2*1+0*1+0+1].base_id,10,10,1)
  cur_om:setOter(building[1*2*1+0*1+0+1].base_id,11,10,1)
  cur_om:setOter(building[0*2*1+1*1+0+1].base_id,10,11,1)
  cur_om:setOter(building[1*2*1+1*1+0+1].base_id,11,11,1)
  
  print(building[0*2*1+0*1+0+1].base_id)
  io.flush()
  
  
  --]]
  --[[
  for x =1,4 do
    for y = 1,3 do
      if x==2 and y==2 then
        cur_om:setOter(data.oter_name2id["house1x1"]+1,x,y,1)
      else
        cur_om:setOter(data.oter_name2id["road"],x,y,1)
      end
    end
  end
  --]]
  
  
  
  --创建完成后，加入内存buffer
  overmapBase.addOvermap(cur_om,x,y)
  local toreturn = cur_om
  clearCache()
  
  local time2 = love.timer.getTime() 
  print("generate map time:"..time2 - time1,x,y)
  io.flush()
  
  return toreturn
end




function Om_Gen.placeRiver()
  local roadOut = {}--在此处取值road
  
  local river_start = {}-- West/North endpoints of rivers
  local river_end = {} -- East/South endpoints of rivers
  
  local river_oter = cur_option.river_oter
  local is_river = overmapBase.isRiver
  local is_road = overmapBase.isRoad
  --取得四个方向上的河流
  if north_om then
    roadOut.north = {}
    for i = 1,254 do
      local oter = north_om:getOter(i,0,1)
      if is_river(oter) then
        cur_om:setOter(river_oter,i,255,1)
        if is_river(north_om:getOter(i-1,0,1)) and is_river(north_om:getOter(i+1,0,1)) then
          local length = #river_start
          if length ==0 or river_start[length][1] <i-6 then
            river_start[length+1] = {i,255}
          end
        end
      end
      if is_road(oter) then--find road
        local length = #roadOut.north
        if length ==0 or roadOut.north[length][1] <i-4 then
          roadOut.north[length+1] = {i,255}
        end
      end
    end
  end
  local rivers_from_north = #river_start
  if west_om then
    roadOut.west = {}
    for i = 1,254 do
      local oter = west_om:getOter(255,i,1)
      if is_river(oter) then
        cur_om:setOter(river_oter,0,i,1)
        if is_river(west_om:getOter(255,i-1,1)) and is_river(west_om:getOter(255,i+1,1)) then
          local length = #river_start
          if length ==rivers_from_north or river_start[length][2] <i-6 then
            river_start[length+1] = {0,i}
          end
        end
      end
      if is_road(oter) then--find road
        local length = #roadOut.west
        if length ==0 or roadOut.west[length][2] <i-4 then
          roadOut.west[length+1] = {0,i}
        end
      end
    end
  end
  if south_om then
    roadOut.south = {}
    for i = 1,254 do
      local oter = south_om:getOter(i,255,1)
      if is_river(oter) then
        cur_om:setOter(river_oter,i,0,1)
        if is_river(south_om:getOter(i-1,255,1)) and is_river(south_om:getOter(i+1,255,1)) then
          local length = #river_end
          if length ==0 or river_end[length][1] <i-6 then
            river_end[length+1] = {i,0}
          end
        end
      end
      if is_road(oter) then--find road
        local length = #roadOut.south
        if length ==0 or roadOut.south[length][1] <i-4 then
          roadOut.south[length+1] = {i,0}
        end
      end
    end
  end
  local rivers_from_south = #river_end
  if east_om then
    roadOut.east = {}
    for i = 1,254 do
      local oter = east_om:getOter(0,i,1)
      if is_river(oter) then
        cur_om:setOter(river_oter,255,i,1)
        if is_river(east_om:getOter(0,i-1,1)) and is_river(east_om:getOter(0,i+1,1)) then
          local length = #river_end
          if length ==rivers_from_south or river_end[length][2] <i-6 then
            river_end[length+1] = {255,i}
          end
        end
      end
      if is_road(oter) then--find road
        local length = #roadOut.east
        if length ==0 or roadOut.east[length][2] <i-4  then
          roadOut.east[length+1] = {255,i}
        end
      end
    end
  end
  --Even up the start and end points of rivers. (difference of 1 is acceptable)
  --Also ensure there's at least one of each.
  if north_om==nil or west_om==nil then
    while( #river_start<1 or #river_start+1<#river_end) do
      if north_om then
        river_start[#river_start+1] = {0,random(10,245)}--add west
      elseif west_om then
        river_start[#river_start+1] = {random(10,245),255}--add north
      elseif random(2)==1 then
        river_start[#river_start+1] = {0,random(10,245)}--add west
      else
        river_start[#river_start+1] = {random(10,245),255}--add north
      end
    end
  end
  if south_om ==nil or east_om ==nil then
    while( #river_end<1 or #river_end+1<#river_start) do
      if south_om then
        river_end[#river_end+1] = {255,random(10,245)}--add east
      elseif east_om then
        river_end[#river_end+1] = {random(10,245),0}--add south
      elseif random(2)==1 then
        river_end[#river_end+1] = {255,random(10,245)}--add east
      else
        river_end[#river_end+1] = {random(10,245),0}--add south
      end
    end
  end
  -- Now actually place those rivers.
  if #river_end>0 then
    if #river_start ==0 then 
      river_start[1] = {random(64,192),random(64,192)}
    end
    local river_start_copy = {}
    local river_end_copy = {}
    for i = 1,#river_start do river_start_copy[i] = river_start[i] end
    for i = 1,#river_end do river_end_copy[i] = river_end[i] end
    
    while (#river_start_copy>0 or #river_end_copy>0) do
      local startpoint,endpoint
      if #river_start_copy>0 then
        local rnd = random(#river_start_copy)
        startpoint = river_start_copy[rnd]
        table.remove(river_start_copy,rnd)
      else
        startpoint = river_start[random(#river_start)]
      end
      if #river_end_copy>0 then
        local rnd = random(#river_end_copy)
        endpoint = river_end_copy[rnd]
        table.remove(river_end_copy,rnd)
      else
        endpoint = river_end[random(#river_end)]
      end
      --选定了结束起始点，开始生成river
      Om_Gen.connectRiver(startpoint,endpoint,river_oter)
    end
  end
  return roadOut
end

function Om_Gen.connectRiver(startp,endp,river_oter)
  debugmsg("connenct river")
  
  local function setRiverter(x,y)
    if(x>=0 and x<=255 and y>=0 and y<=255) then cur_om:setOter(river_oter,x,y,1) end
  end
  
  local x,y = startp[1],startp[2]
  local time = 0
  repeat
    time = time+1
    x=c.clamp(x+random(-1,1),0,255)
    y=c.clamp(y+random(-1,1),0,255)
    setRiverter(x-1,y+1);setRiverter(x,y+1);setRiverter(x+1,y+1)
    setRiverter(x-1,y);setRiverter(x,y);setRiverter(x+1,y)
    setRiverter(x-1,y-1);setRiverter(x,y-1);setRiverter(x+1,y-1)
    local disx = math.abs(endp[1] -x)
    local disy = math.abs(endp[2] - y)
    if random(0,307)<disx or ( random(0,50)>disx and random(0,50)>disy) then 
      if endp[1]>x then x=x+1 else x= x-1 end--advance X
    end
    if random(0,307)<disy or ( random(0,50)>disx and random(0,50)>disy) then 
      if endp[2]>y then y=y+1 else y= y-1 end--advance Y
    end
    x=c.clamp(x+random(-1,1),0,255)
    y=c.clamp(y+random(-1,1),0,255)
    local function setRiver2(x,y)
      if(x>=1 and x<=254 and y>=1 and y<=254) or (math.abs(endp[1] -x)<4 and math.abs(endp[2] - y)) then setRiverter(x,y) end
    end
    setRiver2(x-1,y+1);setRiver2(x,y+1);setRiver2(x+1,y+1)
    setRiver2(x-1,y);setRiver2(x,y);setRiver2(x+1,y)
    setRiver2(x-1,y-1);setRiver2(x,y-1);setRiver2(x+1,y-1)
    
    
  until(x==endp[1] and y == endp[2] or time>10000)
end





function Om_Gen.placeForest(cities)
  local forests_placed = 0
  local growfunc = Om_Gen.grow_Frost_oter
  for i=0,cur_option.num_forests do 
    local forx,fory,forsize;
    local tries = 100;
    while tries>0 do
      tries = tries -1
      forx = random(0,c.OMAP_L-1)
      fory = random(0,c.OMAP_L-1)
      forsize = random(cur_option.forest_size_min,cur_option.forest_size_max)
      local success =true 
      
      for j=1,#cities do
         --// is this city too close?
        local dis = (cities[j][1] - forx)^2 + (cities[j][2]-fory)^2
        local dis2 =  (cities[j][3] + forsize/4)^2
        if  dis<dis2 and tries > rnd(-1000/(i-forests_placed+1),2) then--// occasionally accept near a city if we've been failing
          success = false
          break;
        end
      end
      
      if success then break end
      
    end
    if tries<=0 then  debugmsg("fail to placing all forest");return end --跳出
    
    forests_placed=forests_placed+1
    
    local x,y = forx,fory
    for j= 0 ,forsize do
      
      growfunc(x-1,y-1,1)
      growfunc(x-1,y  ,1)
      growfunc(x-1,y+1,1)
      growfunc(x  ,y-1,1)
      growfunc(x  ,y  ,1)
      growfunc(x  ,y+1,1)
      growfunc(x+1,y-1,1)
      growfunc(x+1,y  ,1)
      growfunc(x+1,y+1,1)
      x = c.clamp(x + random(-2,2),0,c.OMAP_L-1)
      y = c.clamp(y + random(-2,2),0,c.OMAP_L-1)
      
    end
  end
end

function Om_Gen.grow_Frost_oter(x,y,z)
  if cur_om:inbounds(x,y,z) then
    local togrow = cur_om:getOter(x,y,z)
    if togrow == cur_option.default_oter then
      cur_om:setOter(cur_option.forest_oter,x,y,z)
    elseif togrow == cur_option.forest_oter then
      cur_om:setOter(cur_option.forest_thick_oter,x,y,z)
    end
  end
end


function Om_Gen.placeRoad(roadOut,cities)
  local roadPoint = {}
  local is_river = overmapBase.isRiver
  if roadOut.north then
    for i=1,#roadOut.north do
      roadPoint[#roadPoint+1] = roadOut.north[i]
    end
  else--生成一个新roadout
    local try = 0
    while try<12 do
      try =try+1
      local tmp = rnd(10, 244);
      if (not is_river(cur_om:getOter(tmp,255,1))) and (not is_river(cur_om:getOter(tmp+1,255,1))) and (not is_river(cur_om:getOter(tmp-1,255,1)))  or try>10 then
        roadPoint[#roadPoint+1] = {tmp,255}
        break;
      end
    end
  end
  if roadOut.west then
    for i=1,#roadOut.west do
      roadPoint[#roadPoint+1] = roadOut.west[i]
    end
  else--生成一个新roadout
    local try = 0
    while try<12 do
      try =try+1
      local tmp = rnd(10, 244);
      if (not is_river(cur_om:getOter(0,tmp,1))) and (not is_river(cur_om:getOter(0,tmp+1,1))) and (not is_river(cur_om:getOter(0,tmp-1,1)))  or try>10 then
        roadPoint[#roadPoint+1] = {0,tmp}
        break;
      end
    end
  end
  
  if roadOut.south then
    for i=1,#roadOut.south do
      roadPoint[#roadPoint+1] = roadOut.south[i]
    end
  else--生成一个新roadout
    local try = 0
    while try<12 do
      try =try+1
      local tmp = rnd(10, 244);
      if (not is_river(cur_om:getOter(tmp,0,1))) and (not is_river(cur_om:getOter(tmp+1,0,1))) and (not is_river(cur_om:getOter(tmp-1,0,1)))  or try>10 then
        roadPoint[#roadPoint+1] = {tmp,0}
        break;
      end
    end
  end
  if roadOut.east then
    for i=1,#roadOut.east do
      roadPoint[#roadPoint+1] = roadOut.east[i]
    end
  else--生成一个新roadout
    local try = 0
    while try<12 do
      try =try+1
      local tmp = rnd(10, 244);
      if (not is_river(cur_om:getOter(255,tmp,1))) and (not is_river(cur_om:getOter(255,tmp+1,1))) and (not is_river(cur_om:getOter(255,tmp-1,1)))  or try>10 then
        roadPoint[#roadPoint+1] = {255,tmp}
        break;
      end
    end
  end
  
  
  --连接city
  --[[
  local readCities = {city={},dis = {},disCity = {}}
  local writeCities = {city={},dis = {},disCity = {}}
  local curCity = cities[1]
  local index = 0
  local bestCity
  local bestIndex
  local closest = -1
  
  for i=2,#cities do
    index = index +1
    local distance = (cities[i][1] - curCity[1])^2 + (cities[i][2] - curCity[2])^2
    readCities.city[index] = cities[i]
    readCities.dis[index] = distance
    readCities.disCity[index] = curCity
    if(distance<closest or closest<0) then
      bestCity = cities[i]
      closest = distance
      bestIndex = index
    end
  end
  readCities.len = index
  while closest>=0 do
    
    --make最近的road
    local startcity = readCities.disCity[bestIndex]
    Om_Gen.make_hiway(startcity[1],startcity[2],bestCity[1],bestCity[2])--做出一条路
    
    curCity = bestCity -- 当前城市换为此城
    index = 0
    closest = -1
    local last_bestIndex = bestIndex
    for i=1,readCities.len do
      if i~=last_bestIndex then --除去当前city
        index = index +1
        local thisCity = readCities.city[i]
        writeCities.city[index] = thisCity
        local distance = (thisCity[1] - curCity[1])^2 + (thisCity[2] - curCity[2])^2
        if(distance<readCities.dis[i]) then--发现更近的city
          writeCities.dis[index] = distance
          writeCities.disCity[index] = curCity
        else
          writeCities.dis[index] = readCities.dis[i] --保留原始最近的
          writeCities.disCity[index] = readCities.disCity[i]
          distance = readCities.dis[i]
        end
        if(distance<closest or closest<0) then
          bestCity = thisCity
          closest = distance
          bestIndex = index
        end
      end
    end
    writeCities.len = index
    readCities,writeCities = writeCities,readCities --交换
  end
  
  --]]
  ---[[链接city2
  local best
  for i=1,#cities do
    local closest = -1
    for j = i+1,#cities do
      local distance = (cities[i][1] - cities[j][1])^2 + (cities[i][2] - cities[j][2])^2
      if distance<closest or closest <0 then
        closest = distance
        best = cities[j]
      end
    end
    if closest>0 then
      Om_Gen.make_hiway(cities[i][1],cities[i][2],best[1],best[2])
    end
  end
  --]]
  
  
  
  
  
  --conect roadpoint to city
  
  local bestc
  for i=1,#roadPoint do
    local closest = -1
    for j = 1,#cities do
      local distance = (roadPoint[i][1] - cities[j][1])^2 + (roadPoint[i][2] - cities[j][2])^2
      if distance<closest or closest <0 then
        closest = distance
        bestc = cities[j]
      end
    end
    if closest>0 then
      Om_Gen.make_hiway(roadPoint[i][1],roadPoint[i][2],bestc[1],bestc[2])
    end
    
  end
  
  
  
end

function Om_Gen.make_hiway(startx,starty,endx,endy)
  local is_river = overmapBase.isRiver
  local is_road = overmapBase.isRoad
  local road_id = cur_option.road_oter
  local function estimate(pn,cn)
    --return (math.abs(endx - cn[1])+math.abs(endy - cn[2]))/5
    ---[[
    if cn[1]==0 or cn[1]==255 or cn[2]==0 or cn[2] ==255 then
      if not (cn[1]==endx and cn[2] == endy) then return -1 end
    end
    
    local cid = cur_om:getOterOrNil(cn[1],cn[2],1)
    local info_c = data.oter[cid]
    if info_c.allow_road~=true then return -1 end
    local pid = cur_om:getOterOrNil(pn[1],pn[2],1)
    if pn.dir~=cn.dir and (is_river(cid) or is_river(pid)) then return -1 end
    local est = (math.abs(endx - cn[1])+math.abs(endy - cn[2]))/5
    if not is_road(cid) then  est = est+3 end
    if is_river(cid) then est = est+2 end
    return est
    --]]--
  end
  
  local res_list = g.base.simple_find_path(startx,starty,endx,endy,256,256,estimate)
  for i = #res_list,1 ,-1 do
    cur_om:setOter(road_id,res_list[i][1],res_list[i][2],1)
  end
  
end

