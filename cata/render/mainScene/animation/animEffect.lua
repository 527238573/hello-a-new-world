local rm = render.main
--动画名称和function的映射
rm.animEffectMethod  ={}



local function progressEffect(effect,screenx,screeny)
  local zoom = ui.camera.zoom
  local precent  = effect.pastTime/effect.totalTime
  
  
  
  love.graphics.setColor(168,168,255)
  love.graphics.rectangle("fill",screenx-32*zoom,screeny+4*zoom,64*zoom,14*zoom)
  love.graphics.setColor(100,100,255)
  love.graphics.rectangle("fill",screenx-30*zoom,screeny+6*zoom,60*precent*zoom,10*zoom)
  love.graphics.setColor(255,255,255)
  if zoom==1 and effect.text then
    love.graphics.setFont(c.font_c14)
    love.graphics.printf(effect.text,screenx-32,screeny+4,64,"center")
  end
  
end




function rm.initAnimationEffect()
  
  
  rm.animEffectMethod["progress"] = progressEffect
end