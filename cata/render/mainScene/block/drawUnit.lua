local rm = render.main
local camera = ui.camera




local function drawAnimation(unit,x,y,z)
  local anim = unit.anim 
  --声明一个带闭包的回调函数
  local function drawcall(face,rate,dx,dy,rotation,scaleX,scaleY)
    rotation = rotation or 0
    scaleX = scaleX or 1
    scaleY = scaleY or 1
    local animList = unit:getAnimList()
    
    local sacleface= (face<2 or face>5) and -1 or 1

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
  
    local scale = camera.zoom*animList.scalefactor
    local screenx,screeny = camera.modelToScreen(x*64 +32+dx,y*64+dy+0.5*animList.height*animList.scalefactor)
    if anim.scissor then
      local scissor_x,scissor_y = camera.modelToScreen(x*64+anim.scissor[1],y*64+anim.scissor[2])
      love.graphics.setScissor(scissor_x+rm.shiftX,scissor_y+rm.shiftY,anim.scissor[3],anim.scissor[4])
      
    end
    love.graphics.draw(image,screenx,screeny,rotation,scale*sacleface*scaleX,scale*scaleY,0.5*animList.width,0.5*animList.height)--绘制中心点
    if anim.scissor then
      love.graphics.setScissor()
    end
    
    
  end
  
  --寻找animation处理函数，
  if anim.method ==nil then
    anim.method = rm.animationMethod[anim.name]
  end
  anim.method(unit,anim,drawcall,x,y,z)--交给特定的函数处理
  
end

--在无animation时候画出第一帧固定图像
local function drawIdle(unit,x,y,z)
  local animList = unit:getAnimList()
  local todraw_img
  local sacleface= (unit.face<2 or unit.face>5) and -1 or 1
  if animList.type == "twoSide" and unit.face<=3 then --多重朝向
    todraw_img = animList[animList.num+1]
  else
    todraw_img = animList[1]
  end
  
  local scale = camera.zoom*animList.scalefactor
  local screenx,screeny = camera.modelToScreen(x*64 +32,y*64+0.5*animList.height*animList.scalefactor)
  love.graphics.draw(todraw_img,screenx,screeny,0,scale*sacleface,scale,0.5*animList.width,0.5*animList.height)--绘制，根据位置（左下点）和缩放
end



function rm.drawUnit(unit,x,y,z,screenx,screeny)
  if unit.anim then 
    drawAnimation(unit,x,y,z)
  else
    drawIdle(unit,x,y,z)
  end
  
end