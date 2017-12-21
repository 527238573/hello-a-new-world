local rm = render.main
local camera = ui.camera



function rm.drawSquareEffect(list,x,y,z)
  local screenx,screeny = camera.modelToScreen(x*64+32,y*64+32)
  for i=1,#list do
    local effect = list[i]
    local effectData = effect.data
    local img = effectData.img
    local frameIndex = math.ceil(effect.pastTime/effectData.secPerFrame)
    local curFrame = effectData[frameIndex]
    if curFrame then --有帧存在时
      local scale = camera.zoom*effectData.scaleFactor
      love.graphics.draw(img,curFrame,screenx,screeny,0,scale,scale,effectData.ox,effectData.oy)
    end
  end
end

function rm.drawMapEffect(curZ)
  local list = g.animManager.getMapEffectList()
  for i=1,#list do
    local effect = list[i]
    local effectData = effect.data
    if camera.seen_minX<=effect.maxX and camera.seen_maxX>=effect.minX and camera.seen_minY<=effect.maxY and camera.seen_maxY >=effect.minY and effect.z ==curZ then
      local img = effectData.img
      local frameIndex = math.ceil(effect.pastTime/effectData.secPerFrame)
      local curFrame = effectData[frameIndex]
      if curFrame then --有帧存在时
        local screenx,screeny = camera.modelToScreen(effect.x,effect.y)
        local scale = camera.zoom*effectData.scaleFactor
        love.graphics.draw(img,curFrame,screenx,screeny,0,scale,scale,effectData.ox,effectData.oy)
      end
    end
  end
end



function rm.drawProjectiles(curZ)
  local list = g.animManager.getProjectileList()
  for i=1,#list do
    local projectile = list[i]
    local px,py,pz = projectile:getAnim_position()
    if pz>= curZ-0.5 and pz<curZ+0.5 then --属于本层的projectile
      local rotation = projectile.rotation
      local anim_data = projectile.anim
      local frameIndex =projectile:getCurAnimFrameIndex()
      local screenx,screeny = camera.modelToScreen(px,py)
      local scale = camera.zoom*anim_data.scaleFactor
      love.graphics.draw(anim_data.img,anim_data[frameIndex],screenx,screeny,rotation,scale,scale,anim_data.ox,anim_data.oy)
    end
  end
end



function rm.drawAimCross(tx,ty)
  --先画十字 
  if camera.seen_minX<=tx*64+128 and camera.seen_maxX>=tx*64-64 and camera.seen_minY<=ty*64+128 and camera.seen_maxY >=ty*64-64 then
    
    local time = (love.timer.getTime()%2) *math.pi/4
    local scale = camera.zoom
    local screenx,screeny = camera.modelToScreen(tx*64+32,ty*64+32)
    love.graphics.draw(ui.res.aim_cross,screenx,screeny,time,scale,scale,32,32)
  end
  
  
end

local function cutPointInScreen(screenfx,screenfy,screentx,screenty)
  
  if  (screenfx>= camera.seen_maxX and screentx>=camera.seen_maxX) or (screenfx<= camera.seen_minX and screentx<=camera.seen_minX)
              or (screenfy>= camera.seen_maxY and screenty>=camera.seen_maxY) or (screenfy<= camera.seen_minY and screenty<=camera.seen_minY) then return end --线段
              
  if (screenfx<= camera.seen_maxX and screentx<=camera.seen_maxX) and (screenfx>= camera.seen_minX and screentx>=camera.seen_minX)
              and (screenfy<= camera.seen_maxY and screenty<=camera.seen_maxY) and (screenfy>= camera.seen_minY and screenty>=camera.seen_minY) then 
    return screenfx,screenfy,screentx,screenty --不用剪裁
  end --线段
  
  if screenfx == screentx then --平行线
    return screenfx,math.max(math.min(screenfy,camera.seen_maxY),camera.seen_minY),screentx,math.max(math.min(screenty,camera.seen_maxY),camera.seen_minY)
  elseif  screenfy == screenty then --横平行线
    return math.max(math.min(screenfx,camera.seen_maxX),camera.seen_minX),screenfy,math.max(math.min(screentx,camera.seen_maxX),camera.seen_minX),screenty
  end
  
  local t= (screenfy - screenty)/(screenfx - screentx)
  local min_y = t*(camera.seen_minX - screentx)+screenty
  local max_y = t*(camera.seen_maxX - screentx)+screenty
  if screenfx<camera.seen_minX then screenfx,screenfy = camera.seen_minX,min_y end
  if screenfx>camera.seen_maxX then screenfx,screenfy = camera.seen_maxX,max_y end
  if screentx<camera.seen_minX then screentx,screenty = camera.seen_minX,min_y end
  if screentx>camera.seen_maxX then screentx,screenty = camera.seen_maxX,max_y end
  
  if (screenfy>= camera.seen_maxY and screenty>=camera.seen_maxY) or (screenfy<= camera.seen_minY and screenty<=camera.seen_minY) then return end --剪裁Y
  
  local min_x = (camera.seen_minY - screenty)/t +screentx
  local max_x = (camera.seen_maxY - screenty)/t +screentx
  if screenfy<camera.seen_minY then screenfx,screenfy = min_x,camera.seen_minY end
  if screenfy>camera.seen_maxY then screenfx,screenfy = max_x,camera.seen_maxY end
  if screenty<camera.seen_minY then screentx,screenty = min_x,camera.seen_minY end
  if screenty>camera.seen_maxY then screentx,screenty = max_x,camera.seen_maxY end
  
 
  
  return screenfx,screenfy,screentx,screenty
end


function rm.drawAimPoint(fx,fy,fz,tx,ty,tz)
  if fx==tx and fy==ty then return end  --无连线
  
  fx,fy  = fx*64+32,fy*64+32
  tx,ty = tx*64+32,ty*64+32
  local dist= c.dist_2d(fx,fy,tx,ty)
  if dist<=66 then return end --太短，不用画
  local dx,dy = (tx - fx)/dist,(ty - fy)/dist--方向向量
  --fx,fy = fx+dx*30,fy+dy*30
  --tx,ty = tx+dx*-29,ty+dy*-29
  
  --先确定屏幕两个点始末坐标
  --local screenfx,screenfy = camera.modelToScreen(fx*64+32,fy*64+32)
  --local screentx,screenty = camera.modelToScreen(tx*64+32,ty*64+32)
  
  fx,fy,tx,ty = cutPointInScreen(fx,fy,tx,ty)
  if fx==nil then return end --不再屏幕内
  fx,fy = camera.modelToScreen(fx,fy)
  tx,ty = camera.modelToScreen(tx,ty)
  
  love.graphics.setColor(255,255,255)
  dist= c.dist_2d(fx,fy,tx,ty)
  dx,dy = (tx - fx)/dist,(ty - fy)/dist--方向向量
  
  
  local scale = camera.zoom*2
  
  local i=2
  local step = 32*scale/2
  local time = ((love.timer.getTime()%1) /1-1 )*step
  fx,fy = fx+time*dx,fy+time*dy
  
  while (i*step <dist-step*0.5) do
    love.graphics.draw(ui.res.aim_point,fx+step*i*dx,fy+step*i*dy,0,scale,scale,2,2)
    i=i+1
  end
end

function rm.draw_AimLine(curZ)
  if ui.getCurrentWindow() ~= ui.aimWin then return end
  if not ui.aimWin.show_aimCross then return end
  
  local fx,fy,fz = player.x,player.y,player.z
  local tx,ty,tz = ui.aimWin.aim_x,ui.aimWin.aim_y,ui.aimWin.aim_z
  if curZ == fz then 
    rm.drawAimPoint(fx,fy,fz,tx,ty,tz,curZ)
  end
  if curZ == tz then
    rm.drawAimCross(tx,ty)
  end
  
end
