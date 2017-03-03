local Om_Gen = g.overmap.Om_Gen








local dir_dx = {[0]=0,1,0,-1}
local dir_dy = {[0]=1,0,-1,0}


local function put_buildings(x,y,dir,cur_om,cur_option)
  local house_id = cur_option.house_oter
  local dir_left = (dir-1)%4
  local dir_right = (dir+1)%4
  if one_in(2) and cur_om:getOterOrNil(x+dir_dx[dir_left],y+dir_dy[dir_left],1)==cur_option.default_oter then
    cur_om:setOter(house_id+dir_left,x+dir_dx[dir_left],y+dir_dy[dir_left],1) --房子方向相反
  end
  if one_in(2) and cur_om:getOterOrNil(x+dir_dx[dir_right],y+dir_dy[dir_right],1)==cur_option.default_oter then
    cur_om:setOter(house_id+dir_right,x+dir_dx[dir_right],y+dir_dy[dir_right],1) --房子方向相反
  end
  
end

local function makeRoad(x,y,cs,dir,cur_om,cur_option)
  local road_id = cur_option.road_oter
  local default_id = cur_option.default_oter
  
  local c_size = cs
  local dx = dir_dx[dir]
  local dy = dir_dy[dir]
  
  local remain_c = 0
  while(c_size>0) do
    if (not cur_om:inbounds(x+dx,y+dy,1)) or cur_om:getOter(x+dx,y+dy,1)~=default_id  then
      remain_c = remain_c+c_size
      c_size = -1  --发现前方侧面路，不能再伸展
      break 
    end--遇到边界，遇阻
    x = x+dx
    y = y+dy
    c_size = c_size -1
    cur_om:setOter(road_id,x,y,1)
    if cur_om:getOterOrNil(x+dy,y+dx,1)==road_id and cur_om:getOterOrNil(x+dy+dx,y+dx+dy,1)== road_id then
      remain_c = remain_c+c_size
      c_size = -1  --发现前方侧面路，不能再伸展
    end
    if cur_om:getOterOrNil(x-dy,y-dx,1)==road_id and cur_om:getOterOrNil(x-dy+dx,y-dx+dy,1)== road_id then
      remain_c = remain_c+c_size
      c_size = -1  --发现前方侧面路，不能再伸展
    end
    put_buildings(x,y,dir,cur_om,cur_option)
    --分支十字路口
    if c_size>=2 and c_size<cs-1 and cur_om:getOterOrNil(x+dy,y+dx,1)==default_id and cur_om:getOterOrNil(x-dy,y-dx,1)==default_id then
      local dir_left  = (dir-1)%4
      if cur_om:getOterOrNil(x+dir_dx[dir_left]-dx,y+dir_dy[dir_left]-dy,1)~=road_id then
        makeRoad(x,y,cs-rnd(1,3),dir_left,cur_om,cur_option)
      end
      local dir_right = (dir+1)%4
      if cur_om:getOterOrNil(x+dir_dx[dir_right]-dx,y+dir_dy[dir_right]-dy,1)~=road_id then
        makeRoad(x,y,cs-rnd(1,3),dir_right,cur_om,cur_option)
      end
    end
  end
   --// Now we're done growing, if there's a road ahead, add one more road segment to meet it.
  if cur_om:getOterOrNil(x+dx*2,y+dy*2,1)==road_id or cur_om:getOterOrNil(x+dy+dx,y+dx+dy,1)==road_id or cur_om:getOterOrNil(x-dy+dx,y-dx+dy,1)==road_id then
    --前方有可连接的道路
    if cur_om:getOterOrNil(x+dx,y+dy,1)==default_id then cur_om:setOter(road_id,x+dx,y+dy,1) end
  end
     -- // If we're big, make a right turn at the edge of town.
    --// Seems to make little neighborhoods.
  cs =cs - rnd(1, 3) 
  
  if cs>=2 and c_size==0 then 
    local dir2 = (dir+1)%4
    if one_in(2) then dir2 = (dir2+2)%4 end
    if cur_om:getOterOrNil(x+dir_dx[dir2]-dx,y+dir_dy[dir2]-dy,1)~=road_id then
      makeRoad(x,y,cs,dir2,cur_om,cur_option)
    end
    if one_in(5) then 
      dir2 = (dir2+2)%4
      if cur_om:getOterOrNil(x+dir_dx[dir2]-dx,y+dir_dy[dir2]-dy,1)~=road_id then
        makeRoad(x,y,cs,dir2,cur_om,cur_option)
      end
    end
    
  end
end



function Om_Gen.placeCities(cur_om,cur_option)
  
  local option_city_size = cur_option.city.size;
  local option_city_spacing  =cur_option.city.spacing;
  local num_cities = math.floor(256*256 /(2^option_city_spacing) / ((option_city_size*2+1)*(option_city_size*2+1)*0.75));
  
  local cities = {}
  
  debugmsg("num_cities:"..num_cities)
  while #cities<num_cities do
    local size = rnd(option_city_size-1, option_city_size+1)
    if one_in(3) then
      size =math.floor(size * 2 / 3)          --// 33% tiny
    elseif one_in(2) then
      size = math.floor(size * 2 / 3);-- // 33% small
    elseif (one_in(2)) then
      size = math.floor(size * 3 / 2); --// 17% large
    else
      size = size*2    --// 17% huge
    end
    size = math.max(size,1);
    local cx = rnd(size - 1, 256 - size);
    local cy = rnd(size - 1, 256 - size);
    if (cur_om:getOter(cx,cy,1) == cur_option.default_oter ) then
      cur_om:setOter(cur_option.road_oter,cx,cy,1)
      cities[#cities+1] = {cx,cy,size}
      local startdir = rnd(0,3)
      for j = 0,3 do 
        makeRoad(cx,cy,size,(startdir+j)%4,cur_om,cur_option)
      end
      
    end
  end
  return cities
  
end