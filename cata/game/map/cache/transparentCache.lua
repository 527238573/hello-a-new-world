local gmap = g.map
local grid = g.map.grid
local zLevelCache = gmap.zLevelCache

local LIGHT_TRANSPARENCY_OPEN_AIR = 0.038376418216
local LIGHT_TRANSPARENCY_SOLID = 0
local LIGHT_TRANSPARENCY_CLEAR = 1

function zLevelCache.buildTransparentCache(zcache,z)
  if not(z>=0 and z<=4) then error("building transparent cache out of grid")end
  if not zcache.transparent_dirty then return end
  if z+grid.minZsub<-10 or z+grid.minZsub>12 then return end --不能超出
  local smz = z 
  --debugmsg("build transparnet rz:"..z)
  
  
  for smx = 0,8 do
    for smy = 0,8 do
      local submap = gmap.getRelativeSubmapInGrid(smx,smy,smz)
      --每个格子
      for sx = 0,15 do
        for sy = 0,15 do
          local x  =smx *16+sx
          local y = smy *16+sy
          local transparent = data.ster[submap.raw:getTer(sx,sy)].transparent
          local bid = submap.raw:getBlock(sx,sy)
          if bid>1 then
            local binfo = data.block[submap.raw:getBlock(sx,sy)]
            if binfo==nil then debugmsg("no info id :"..bid.."info len:"..#data.block) end
            
            if binfo.resetTM then
              transparent = binfo.transparent
            else
              transparent = transparent and binfo.transparent
            end
          end
          zcache.transparent[x][y] = transparent and LIGHT_TRANSPARENCY_OPEN_AIR or LIGHT_TRANSPARENCY_SOLID
        end
      end
    end
  end
  zcache.transparent_dirty = false
  zcache.seen_dirty = true
end






--计算当前格子明度
local function sight_caculate(numerator,transparency,dx,dy)
  return numerator/ math.exp(transparency*math.sqrt(dx*dx+dy*dy))
end

--检查能否继续透光
local function sight_check(transparency,intensity)
  return transparency>LIGHT_TRANSPARENCY_SOLID
end


local function castLight(xdx,xdy,ydx,ydy,orginx,orginy,input,output,calc_func,check_func,numerator,row,startangle,endangle,cumulative_transparency)
  startangle = startangle or 0
  endangle = endangle or 1
  if startangle>endangle then return end
  local max_distance = 60
  numerator = numerator or 1
  row = row or 1 --默认
  cumulative_transparency = cumulative_transparency or LIGHT_TRANSPARENCY_OPEN_AIR --透明度平均值
  
  local new_start = 0
  for dx = row,max_distance,1 do
    local row_unstart = true
    local current_transparency = 0
    local this_intensity = 0
    for dy = 0,dx,1 do
      local realx = orginx+dx*xdx +dy*ydx
      local realy = orginy+dx*xdy +dy*ydy
      local trailing_angle = (dy-0.5)/(dx+0.5)
      local leading_angle = (dy+0.5)/(dx-0.5)
      if realx>=0 and realx<=143 and realy>=0 and realy<=143 and startangle<=leading_angle then
        if trailing_angle>endangle then break end
        if row_unstart then 
          row_unstart = false
          current_transparency = input[realx][realy]
        end
        this_intensity = calc_func(numerator,cumulative_transparency,dx,dy) --计算当前烈度
        if this_intensity>output[realx][realy] then output[realx][realy] = this_intensity end --写入当前格子烈度
        local new_transparency = input[realx][realy]
        
        if new_transparency ~= current_transparency then
          if check_func(current_transparency,this_intensity) then
            local next_t = ((dx - 1) * cumulative_transparency + current_transparency) / dx --求得平均值
            castLight(xdx,xdy,ydx,ydy,orginx,orginy,input,output,calc_func,check_func,numerator,dx+1,startangle,trailing_angle,next_t)
          end
          if current_transparency == LIGHT_TRANSPARENCY_SOLID then
            startangle = new_start --完全不透光，从上次的边界开始  ，（切割本次部分的空间）
          else
            startangle = trailing_angle --上一层是透光的，从本次分割处开始
          end
          current_transparency = new_transparency --转换到新的
        end
        new_start = leading_angle;--记录本次上边界，
      end
    end--y循环结束
    if not check_func(current_transparency,this_intensity) then
      break--不能向下一层透光，不再循环下一层
    else
      --继续循环下一row，计算平均值
      cumulative_transparency = ((dx - 1) * cumulative_transparency + current_transparency) / dx 
    end
  end--x循环结束
end


local function castZSeen(xdx,xdy,ydx,ydy,orginx,orginy,delz,input,output,floorcache,orginz_seen)
  
  --一次完成，不再递归。
  --分割角度时紧密排列
  local max_distance = 60
  local cumulative_transparency = LIGHT_TRANSPARENCY_OPEN_AIR --透明度平均值,不再计算此值，就以此为准
  local angles = {}
  angles[1] = {startangle = 0,endangle = 1,lastseen_row = 0} --
  local seen_z_factor = 2 --lastseen_row 
  if delz ==2 or delz ==-2 then seen_z_factor = 1.5 end
  --
  local function addSolid(startang,endang)
    assert(endang>startang,"castz error")
    --找到开始idnex
    local startindex =1
    local endindex = #angles
    for i=1,#angles do
      if angles[i].startangle<=startang and angles[i].endangle>startang then
        startindex = i;break;
      end
    end
    for i=1,#angles do
      if angles[i].endangle>=endang and angles[i].startangle<endang then
        endindex = i;break;
      end
    end
    --end是否要切割
    if angles[endindex].lastseen_row~=0 and angles[endindex].endangle>endang then
      local cut_angle = angles[endindex]
      --切割
      table.insert(angles,endindex+1,{startangle = endang,endangle = cut_angle.endangle,lastseen_row=cut_angle.lastseen_row})
      cut_angle.endangle = endang
    end
    --start是否要切割
    if angles[startindex].lastseen_row~=0 and angles[startindex].startangle<startang then
      local cut_angle = angles[startindex]
      table.insert(angles,startindex,{startangle = cut_angle.startangle,endangle = startang,lastseen_row=cut_angle.lastseen_row})
      cut_angle.startangle = startang
      startindex = startindex+1
      endindex = endindex+1 --因插入序号增加
    end
    
    if startindex ==endindex then
      angles[startindex].lastseen_row = 0 --只改一个
    else
      angles[startindex].lastseen_row = 0 --合并
      angles[startindex].endangle = angles[endindex].endangle
      for i= 1,endindex-startindex do
        table.remove(angles,startindex+1)
      end
    end
  end

  local function addSeenLight(startang,endang,last_row)
    assert(endang>startang,"castz error")
    --找到开始idnex
    local startindex =1
    local endindex = #angles
    for i=1,#angles do
      if angles[i].startangle<=startang and angles[i].endangle>startang then
        startindex = i;break;
      end
    end
    for i=1,#angles do
      if angles[i].endangle>=endang and angles[i].startangle<endang then
        endindex = i;break;
      end
    end
    --end是否要切割
    if angles[endindex].endangle>endang then
      local cut_angle = angles[endindex]
      --切割
      table.insert(angles,endindex+1,{startangle = endang,endangle = cut_angle.endangle,lastseen_row=cut_angle.lastseen_row})
      cut_angle.endangle = endang
    end
    --start是否要切割
    if angles[startindex].startangle<startang then
      local cut_angle = angles[startindex]
      table.insert(angles,startindex,{startangle = cut_angle.startangle,endangle = startang,lastseen_row=cut_angle.lastseen_row})
      cut_angle.startangle = startang
      startindex = startindex+1
      endindex = endindex+1 --因插入序号增加
    end
    if startindex ==endindex then
      angles[startindex].lastseen_row = last_row --只改一个
    else
      angles[startindex].lastseen_row = last_row --合并
      angles[startindex].endangle = angles[endindex].endangle
      for i= 1,endindex-startindex do
        table.remove(angles,startindex+1)
      end
    end
  end
  
  
  for dx = 1,max_distance,1 do
    local start_angle_index = 1--从此处搜索
    --第一步:计算上一排散步的光
    for dy = 0,dx,1 do
      local realx = orginx+dx*xdx +dy*ydx
      local realy = orginy+dx*xdy +dy*ydy
      local trailing_angle = (dy-0.5)/(dx+0.5)
      local leading_angle = (dy+0.5)/(dx-0.5)
      if realx>=0 and realx<=143 and realy>=0 and realy<=143 then
        
        local search_aindex = start_angle_index
        while(search_aindex<=#angles) do
          local cur_angle = angles[search_aindex]
          if (cur_angle.endangle>=trailing_angle and cur_angle.startangle<leading_angle) then
            --囊括在角度内
            --panduan可见性
            if cur_angle.lastseen_row*seen_z_factor>=dx then
              --可见！
              local this_intensity = 1/ math.exp(cumulative_transparency*math.sqrt(dx*dx+dy*dy))--怪怪的公式
              if this_intensity>output[realx][realy] then output[realx][realy] = this_intensity end --写入当前格子烈度
              break;
            end
          else
            --未在
            if cur_angle.endangle<trailing_angle then
              --还未到
              start_angle_index = search_aindex+1
            else
              break; --后面的angle，已超出
            end
          end
          search_aindex = search_aindex+1
        end
      end--grid内判断结束
    end--y循环结束
    
    
    --第二步：加入额外的透视点
    local row_unstart = true
    local startangle = 0
    local new_start = 0
    local current_seenformz = false
    for dy = 0,dx,1 do
      local realx = orginx+dx*xdx +dy*ydx
      local realy = orginy+dx*xdy +dy*ydy
      local trailing_angle = (dy-0.5)/(dx+0.5)
      local leading_angle = (dy+0.5)/(dx-0.5)
      if realx>=0 and realx<=143 and realy>=0 and realy<=143 and startangle<=leading_angle then
        local new_seenformz = orginz_seen[realx][realy]>0 and (floorcache[realx][realy]==false)
        if new_seenformz then
          --可见
          local this_intensity = 1/ math.exp(cumulative_transparency*math.sqrt(dx*dx+dy*dy))--怪怪的公式
          if this_intensity>output[realx][realy] then output[realx][realy] = this_intensity end --写入当前格子烈度
          
        end
        
        if row_unstart then 
          row_unstart = false
          current_seenformz = new_seenformz
        end
        if new_seenformz ~= current_seenformz then
          if current_seenformz == true then
            addSeenLight(startangle,new_start,dx)
            startangle = new_start --完全不透光，从上次的边界开始  ，（切割本次部分的空间）
          else
            startangle = trailing_angle --上一层是透光的，从本次分割处开始
          end
          current_seenformz = new_seenformz --转换到新的
        end
        new_start = leading_angle;--记录本次上边界，
      end
    end--y循环结束
    if current_seenformz == true then
      addSeenLight(startangle,1,dx)
    end
    
    
    
    --第三步：检测遮挡并添加到angles数据中
    row_unstart = true
    startangle = 0
    new_start = 0
    local current_transparency = 0
    for dy = 0,dx,1 do
      local realx = orginx+dx*xdx +dy*ydx
      local realy = orginy+dx*xdy +dy*ydy
      local trailing_angle = (dy-0.5)/(dx+0.5)
      local leading_angle = (dy+0.5)/(dx-0.5)
      if realx>=0 and realx<=143 and realy>=0 and realy<=143 and startangle<=leading_angle then
        local new_transparency = input[realx][realy]
        if row_unstart then 
          row_unstart = false
          current_transparency = new_transparency
        end
        if new_transparency ~= current_transparency then
          if current_transparency == LIGHT_TRANSPARENCY_SOLID then
            addSolid(startangle,new_start)
            startangle = new_start --完全不透光，从上次的边界开始  ，（切割本次部分的空间）
          else
            startangle = trailing_angle --上一层是透光的，从本次分割处开始
          end
          current_transparency = new_transparency --转换到新的
        end
        new_start = leading_angle;--记录本次上边界，
      end
    end--y循环结束
    if current_transparency == LIGHT_TRANSPARENCY_SOLID then
      addSolid(startangle,1)
    end
    
    
  end--x循环结束
  
  
end

function zLevelCache.buildSeenCache(zcache,z)
  if not(z>=0 and z<=4) then error("building transparent cache out of grid")end
  zLevelCache.buildTransparentCache(zcache,z) 
  if not zcache.seen_dirty then return end
  if z+grid.minZsub<-10 or z+grid.minZsub>12 then return end --不能超出
  --debugmsg("build seen rz:"..z)
  
  zcache.seen_dirty  = false
  for x = 0,143 do
    for y =0,143 do
      zcache.seen[x][y] = LIGHT_TRANSPARENCY_SOLID
    end
  end
  --确定原点
  local orginx,orginy,orginz = grid.getSeenOrigen()
  if z==orginz then--同一平面
    if orginx>=0 and orginx<=143 and orginy>=0 and orginy<=143 then  zcache.seen[orginx][orginy] = LIGHT_TRANSPARENCY_CLEAR end
    
    castLight(1,0,0,1,orginx,orginy,zcache.transparent,zcache.seen,sight_caculate,sight_check)
    castLight(1,0,0,-1,orginx,orginy,zcache.transparent,zcache.seen,sight_caculate,sight_check)
    
    castLight(0,1,1,0,orginx,orginy,zcache.transparent,zcache.seen,sight_caculate,sight_check)
    castLight(0,1,-1,0,orginx,orginy,zcache.transparent,zcache.seen,sight_caculate,sight_check)
    
    castLight(-1,0,0,1,orginx,orginy,zcache.transparent,zcache.seen,sight_caculate,sight_check)
    castLight(-1,0,0,-1,orginx,orginy,zcache.transparent,zcache.seen,sight_caculate,sight_check)
    
    castLight(0,-1,1,0,orginx,orginy,zcache.transparent,zcache.seen,sight_caculate,sight_check)
    castLight(0,-1,-1,0,orginx,orginy,zcache.transparent,zcache.seen,sight_caculate,sight_check)
  else  
    local delz = z-orginz
    local floorCache --前置cache
    local orginz_seenCache
    if delz>0 then
      orginz_seenCache = zLevelCache[z-1]
      zLevelCache.buildSeenCache(orginz_seenCache,z-1)
      floorCache = zcache
      zLevelCache.buildFloorCache(floorCache,z)
    else
      orginz_seenCache = zLevelCache[z+1]
      zLevelCache.buildSeenCache(orginz_seenCache,z+1)
      floorCache= orginz_seenCache
      zLevelCache.buildFloorCache(floorCache,z+1)
    end
    --debugmsg("build zseen:"..z)
    --castZSeen(xdx,xdy,ydx,ydy,orginx,orginy,delz,input,output,floorcache,orginz_seen)
    castZSeen(1,0,0,1,orginx,orginy,delz,zcache.transparent,zcache.seen,floorCache.floor,orginz_seenCache.seen)
    castZSeen(1,0,0,-1,orginx,orginy,delz,zcache.transparent,zcache.seen,floorCache.floor,orginz_seenCache.seen)
    
    castZSeen(0,1,1,0,orginx,orginy,delz,zcache.transparent,zcache.seen,floorCache.floor,orginz_seenCache.seen)
    castZSeen(0,1,-1,0,orginx,orginy,delz,zcache.transparent,zcache.seen,floorCache.floor,orginz_seenCache.seen)
    
    castZSeen(-1,0,0,1,orginx,orginy,delz,zcache.transparent,zcache.seen,floorCache.floor,orginz_seenCache.seen)
    castZSeen(-1,0,0,-1,orginx,orginy,delz,zcache.transparent,zcache.seen,floorCache.floor,orginz_seenCache.seen)
    
    castZSeen(0,-1,1,0,orginx,orginy,delz,zcache.transparent,zcache.seen,floorCache.floor,orginz_seenCache.seen)
    castZSeen(0,-1,-1,0,orginx,orginy,delz,zcache.transparent,zcache.seen,floorCache.floor,orginz_seenCache.seen)
    
    if orginx>=1 and orginx<=142 and orginy>=1 and orginy<=142 then
      if floorCache.floor[orginx][orginy]==false and orginz_seenCache.seen[orginx][orginy]>0 then  
        zcache.seen[orginx+1][orginy+1] = LIGHT_TRANSPARENCY_CLEAR 
        zcache.seen[orginx+1][orginy] = LIGHT_TRANSPARENCY_CLEAR 
        zcache.seen[orginx+1][orginy-1] = LIGHT_TRANSPARENCY_CLEAR 
        zcache.seen[orginx][orginy+1] = LIGHT_TRANSPARENCY_CLEAR 
        zcache.seen[orginx][orginy] = LIGHT_TRANSPARENCY_CLEAR 
        zcache.seen[orginx][orginy-1] = LIGHT_TRANSPARENCY_CLEAR 
        zcache.seen[orginx-1][orginy+1] = LIGHT_TRANSPARENCY_CLEAR 
        zcache.seen[orginx-1][orginy] = LIGHT_TRANSPARENCY_CLEAR 
        zcache.seen[orginx-1][orginy-1] = LIGHT_TRANSPARENCY_CLEAR 
      end
    end
  
  end
  
end

function zLevelCache.buildFloorCache(zcache,z)
  if not(z>=0 and z<=4) then error("building transparent cache out of grid")end
  if not zcache.floor_dirty then return end
  if z+grid.minZsub<-10 or z+grid.minZsub>12 then return end --不能超出
  local smz = z 
  debugmsg("build floor rz:"..z)
  for smy = 8,0,-1 do
    for smx = 0,8 do
      zcache.submapfloor[smx][smy] = true 
      local submap = gmap.getRelativeSubmapInGrid(smx,smy,smz)
      --每个格子
      for sx = 0,15 do
        for sy = 0,15 do
          local x  =smx *16+sx
          local y = smy *16+sy
          local nofloor = data.ster[submap.raw:getTer(sx,sy)].nofloor==true
          zcache.floor[x][y] = not nofloor
          
          if nofloor then
            zcache.submapfloor[smx][smy] = false
            if sy==15 and smy<8 then
              zcache.submapfloor[smx][smy+1] = false--额外一格
            end
          end
        end
      end
    end
  end
  zcache.floor_dirty = false
end

