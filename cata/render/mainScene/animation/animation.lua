require "render/mainScene/animation/animEffect"
local rm = render.main

--动画名称和function的映射
rm.animationMethod  ={}




local function moveAnim(unit,anim,drawcall,x,y,z)
  local rate = anim.pastTime/anim.totalTime
  rate = c.clamp(rate,0,1)
  local dx = anim.start_x*(1-rate)
  local dy =  anim.start_y*(1-rate)
  dx,dy = ui.camera.clampXY(dx,dy)--防抖动，移动与镜头一致
  --face
  drawcall(unit.face,rate,dx,dy)
end


function rm.initAnimation()
  rm.animationMethod["move"] = moveAnim
  
  rm.initAnimationEffect()
end




