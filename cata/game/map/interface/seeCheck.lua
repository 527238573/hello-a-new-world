local gmap = g.map

--cdda原本算法写的太屎了，直接换个算法使用4舍五入，并且部分平面3d都用一个
local function bresenham3d(fx,fy,fz,tx,ty,tz,interactFunc)
  local dx = tx - fx
  local dy = ty - fy
  local dz = tz - fz
  local ax = math.abs(dx) ;
  local ay = math.abs(dy) ;
  local az = math.abs(dz) ;
  --Signs of slope values.
  if dx>0 then dx = 1 elseif dx<0 then dx = -1 else dx = 0 end
  if dy>0 then dy = 1 elseif dy<0 then dy = -1 else dy = 0 end
  if dz>0 then dz = 1 elseif dz<0 then dz = -1 else dz = 0 end
  local maxa = math.max(ax,ay,az)
  if maxa ==0 then interactFunc(fx,fy,fz);return end
  if maxa ==ax then
    for cx = fx,tx,dx do
      local cy  = math.floor((cx - fx)/(tx - fx) *(ty - fy)+fy+0.5)--四舍五入
      local cz  = math.floor((cx - fx)/(tx - fx) *(tz - fz)+fz+0.5)--四舍五入
      if not interactFunc(cx,cy,cz) then
          break
      end
    end
  elseif maxa ==ay then
    for cy = fy,ty,dy do
      local cx  = math.floor((cy - fy)/(ty - fy) *(tx - fx)+fx+0.5)--四舍五入
      local cz  = math.floor((cy - fy)/(ty - fy) *(tz - fz)+fz+0.5)--四舍五入
      if not interactFunc(cx,cy,cz) then
          break
      end
    end
  else
    for cz = fz,tz,dz do
      local cx  = math.floor((cz - fz)/(tz - fz) *(tx - fx)+fx+0.5)--四舍五入
      local cy  = math.floor((cz - fz)/(tz - fz) *(ty - fy)+fy+0.5)--四舍五入
      if not interactFunc(cx,cy,cz) then
          break
      end
    end
  end
end



function gmap.canSee(fx,fy,fz,tx,ty,tz,maxRange)
  local dist= c.dist_3d(fx,fy,fz,tx,ty,tz)
  if (maxRange>=0 and dist>maxRange) or dist>65 or(not gmap.isSquareInGrid(tx,ty,tz)) then
    return false
  end
  local visible = true;
  gmap.zLevelCache.buildAllTransparent()
  local istrans = gmap.zLevelCache.isTranspant
  local function seeThroghSquare(x,y,z)
    if x==tx and y==ty and z==tz then return false end
    if x==fx and y==fy and z==fz then return true end
    if not istrans(x,y,z)then 
      visible = false
      return false
    end
    return true
  end
  bresenham3d(fx,fy,fz,tx,ty,tz,seeThroghSquare)
  return visible
end



function testSeeSpeed()
  local num = 10000
  local testdata = {}
  for i=1,num do
    testdata[#testdata+1] = {rnd(1,100),rnd(1,100),rnd(1,100),rnd(1,100),rnd(1,100),rnd(1,100)}
  end
  
  local function callback1(x1,y1,z1)
    print("passNode:",x1,y1,z1)
    io.flush()
    return true
  end
  --mybresenham3d(1,12,2,1,12,1,callback1)
  --[[
  local time1  = love.timer.getTime()
  for i=1,num do
    local daa = testdata[i]
    bresenham3d(daa[1],daa[2],daa[3],daa[4],daa[5],daa[6],callback1)
  end
  local time2 = love.timer.getTime() 
  for i=1,num do
    local daa = testdata[i]
    mybresenham3d(daa[1],daa[2],daa[3],daa[4],daa[5],daa[6],callback1)
  end
  local time3 = love.timer.getTime() 
  print("testcallNum:"..num,time2 - time1,time3 - time2)
  io.flush()
  ]]
  
end