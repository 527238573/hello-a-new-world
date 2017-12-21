local animManager = g.animManager
--method 需要返回值的顺序。 
--face,rate,dx,dy,rotation,scaleX,scaleY



function animManager.createMoveAnim(unit,start_x,start_y,totalTime)
  local anim = {name = "move",pastTime = 0,totalTime = totalTime}
  anim.method = 
  function() --使用，闭包，减少传递的变量
    local rate = anim.pastTime/anim.totalTime
    rate = c.clamp(rate,0,1)
    local dx = start_x*(1-rate)
    local dy =  start_y*(1-rate)
    dx,dy = ui.camera.clampXY(dx,dy)--防抖动，移动与镜头一致
    --face
    return unit.face,rate,dx,dy
  end
  
  return anim
end

function animManager.createMoveAndBackAnim(unit,target_x,target_y,totalTime,midTime)
  local anim = {name = "moveAndBack",pastTime = 0,totalTime = totalTime}
  anim.method = function () --使用，闭包，减少传递的变量
    local crate ; 
    if anim.pastTime<midTime then
      crate = anim.pastTime/midTime--中间值
    else
      crate =1- (anim.pastTime-midTime)/(anim.totalTime - midTime)
    end
    local rate = anim.pastTime/anim.totalTime
    rate = c.clamp(rate,0,1)
    local dx = target_x*(crate)
    local dy =  target_y*(crate)
    --dx,dy = ui.camera.clampXY(dx,dy)--防抖动，移动与镜头一致--不需防抖，因为镜头不动
    --face
    return unit.face,rate,dx,dy
  end
  return anim
end

--标准撞击，只取得最终撞击冲击点，算出需要时间
function animManager.createImpactAnim(unit,tdx,tdy,delay,midTime,backTime)
  local totalTime = delay+midTime+backTime
  local anim = {name = "impactAnim",pastTime = 0,totalTime = totalTime}
  anim.method = function () --使用，闭包，减少传递的变量
    local crate ; 
    local cpast = anim.pastTime - delay
    if cpast<0 then 
      return 0,0
    elseif cpast<midTime then
      crate = cpast/midTime--中间值
    elseif cpast<=midTime+backTime then
      crate =1- (cpast-midTime)/(backTime)
    else
      return 0,0
    end
    return  tdx*(crate),tdy*(crate)
  end
  return anim
end


