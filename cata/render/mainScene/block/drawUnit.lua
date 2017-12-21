local rm = render.main
local camera = ui.camera




--从下面两个函数中提取的共通的过程，整合成一个函数
local function common_draw(unit,x,y,z,animList,image,face,dx,dy,rotation,scaleX,scaleY)
  local sacleface= (face<2 or face>5) and -1 or 1
  local scale = camera.zoom*animList.scalefactor
  local screenx,screeny = camera.modelToScreen(x*64 +32+dx+unit.impact_dx,y*64+dy+unit.impact_dy+0.5*animList.height*animList.scalefactor)--正中心
  local weapon_appearance = unit:get_weapon_appearance()
  
  local draw_scalex,draw_scaley = scale*sacleface*scaleX,scale*scaleY
  --后置武器
  local drawfront = true 
  if weapon_appearance and (weapon_appearance.always_back or face<=3) then
    drawfront = false
    local centx = weapon_appearance.start_cord[1]
    local centy = weapon_appearance.start_cord[2]
    love.graphics.draw(weapon_appearance.img,screenx,screeny,rotation,draw_scalex*weapon_appearance.scaleFactor/2,draw_scaley*weapon_appearance.scaleFactor/2,centx,centy)--绘制中心点
  end
  
  if animList.use_quad then
    --image是个quad，这个画
    --assert(image~=nil,"error userate:"..userate)
    love.graphics.draw(animList.img,image,screenx,screeny,rotation,draw_scalex,draw_scaley,0.5*animList.width,0.5*animList.height)--绘制中心点
  else
    love.graphics.draw(image,screenx,screeny,rotation,draw_scalex,draw_scaley,0.5*animList.width,0.5*animList.height)--绘制中心点
  end
  
  if weapon_appearance and drawfront then
    local centx = weapon_appearance.start_cord[1]
    local centy = weapon_appearance.start_cord[2]
    love.graphics.draw(weapon_appearance.img,screenx,screeny,rotation,draw_scalex*weapon_appearance.scaleFactor/2,draw_scaley*weapon_appearance.scaleFactor/2,centx,centy)--绘制中心点
  end
  
  rm.drawUnitFrontEffect(unit,x,y,z,screenx,screeny)--前置特效
  
end





local function drawAnimation(unit,x,y,z)
  local anim = unit.anim 

  --寻找animation处理函数，
  if anim.method ==nil then
    return
  end
  local face,rate,dx,dy,rotation,scaleX,scaleY = anim.method()--交给特定的函数处理,计算动画进度
  rotation = rotation or 0
  scaleX = scaleX or 1
  scaleY = scaleY or 1
  local animList = unit:getAnimList()
  
  --选择动画的哪张图
  local animNum = animList.num
  local len = animNum
  if(len>2 and animList.pingpong) then len = len*2 -2 end   -- 来回动画
  local onerate = 1/len
  local userate = onerate *0.5 +rate
  userate = math.floor(userate/onerate) % len +1
  if(animList.pingpong and userate>animNum) then
    userate = animNum - (userate - animNum)
  end
  if animList.type == "twoSide" and face<=3 then userate = userate+animNum end
  local image = animList[userate]
  --哪张图选择完毕

  if anim.scissor then
    local scissor_x,scissor_y = camera.modelToScreen(x*64+anim.scissor[1],y*64+anim.scissor[2])
    love.graphics.setScissor(scissor_x+rm.shiftX,scissor_y+rm.shiftY,anim.scissor[3],anim.scissor[4])--有camera缩放吗？
  end

  common_draw(unit,x,y,z,animList,image,face,dx,dy,rotation,scaleX,scaleY)

  if anim.scissor then
    love.graphics.setScissor()
  end

end

--在无animation时候画出第一帧固定图像
local function drawIdle(unit,x,y,z)
  local animList = unit:getAnimList()
  local image
  if animList.type == "twoSide" and unit.face<=3 then --多重朝向
    image = animList[animList.num+1]
  else
    image = animList[1]
  end
  
  common_draw(unit,x,y,z,animList,image,unit.face,0,0,0,1,1)

end



function rm.drawUnit(unit,x,y,z,screenx,screeny)


  if unit.anim then 
    drawAnimation(unit,x,y,z)
  else
    drawIdle(unit,x,y,z)
  end

end