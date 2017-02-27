
local overmapBase = g.overmap
local Om_Gen = {}
local cur_option
local cur_om
local north_om,south_om,west_om,east_om
local random = love.math.random

local function clearCache()
  cur_om = nil
  cur_option = nil
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
  
  Om_Gen.placeRiver()
  Om_Gen.placeForest()
  for x =1,4 do
    for y = 1,3 do
      if x==2 and y==2 then
        cur_om:setOter(data.oter_name2id["house1x1"]+1,x,y,1)
      else
        cur_om:setOter(data.oter_name2id["road"],x,y,1)
      end
    end
    
  end
  
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
  local river_start = {}-- West/North endpoints of rivers
  local river_end = {} -- East/South endpoints of rivers
  
  local river_oter = cur_option.river_oter
  local function is_river(oter) --判断 是否river，
    return oter== river_oter
  end
  --取得四个方向上的河流
  if north_om then
    for i = 1,254 do
      if is_river(north_om:getOter(i,0,1)) then
        cur_om:setOter(river_oter,i,255,1)
        if is_river(north_om:getOter(i-1,0,1)) and is_river(north_om:getOter(i+1,0,1)) then
          local length = #river_start
          if length ==0 or river_start[length][1] <i-6 then
            river_start[length+1] = {i,255}
          end
        end
      end
    end
  end
  local rivers_from_north = #river_start
  if west_om then
    for i = 1,254 do
      if is_river(west_om:getOter(255,i,1)) then
        cur_om:setOter(river_oter,0,i,1)
        if is_river(west_om:getOter(255,i-1,1)) and is_river(west_om:getOter(255,i+1,1)) then
          local length = #river_start
          if length ==rivers_from_north or river_start[length][2] <i-6 then
            river_start[length+1] = {0,i}
          end
        end
      end
    end
  end
  if south_om then
    for i = 1,254 do
      if is_river(south_om:getOter(i,255,1)) then
        cur_om:setOter(river_oter,i,0,1)
        if is_river(south_om:getOter(i-1,255,1)) and is_river(south_om:getOter(i+1,255,1)) then
          local length = #river_end
          if length ==0 or river_end[length][1] <i-6 then
            river_end[length+1] = {i,0}
          end
        end
      end
    end
  end
  local rivers_from_south = #river_end
  if east_om then
    for i = 1,254 do
      if is_river(east_om:getOter(0,i,1)) then
        cur_om:setOter(river_oter,255,i,1)
        if is_river(east_om:getOter(0,i-1,1)) and is_river(east_om:getOter(0,i+1,1)) then
          local length = #river_end
          if length ==rivers_from_south or river_end[length][2] <i-6 then
            river_end[length+1] = {255,i}
          end
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



function Om_Gen.placeForest()
  local forests_placed = 0
  local growfunc = Om_Gen.grow_Frost_oter
  for i=0,cur_option.num_forests do 
    local forx = random(0,c.OMAP_L-1)
    local fory = random(0,c.OMAP_L-1)
    local forsize = random(cur_option.forest_size_min,cur_option.forest_size_max)
    
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
