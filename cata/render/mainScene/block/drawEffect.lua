local rm = render.main






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

local function framesEffect(effect,screenx,screeny)
  if effect.pastTime<0 then return end --还在delay中的
  local zoom = ui.camera.zoom
  local effectData = effect.data
  local frameIndex = math.ceil(effect.pastTime/effectData.secPerFrame)
  local curFrame = effectData[frameIndex]
  local img = effectData.img
  
  if curFrame then --有帧存在时
        local scale = zoom*effectData.scaleFactor
        love.graphics.draw(img,curFrame,screenx+effect.offset_x*zoom,screeny-effect.offset_y*zoom,0,scale*effect.mirror,scale,effectData.ox,effectData.oy)
  end
end




--在unit背后effect，screenx,screeny是unit图像的中心点。 如果有anim，中心点也会动
function rm.drawUnitBackEffect(unit,x,y,z,screenx,screeny)
  
  
end




--前置的特效

function rm.drawUnitFrontEffect(unit,x,y,z,screenx,screeny)
  local list = unit.animEffectList
  for _,effect in ipairs(list) do
    if effect.name == "progress" then
      progressEffect(effect,screenx,screeny)
    elseif effect.name == "framesEffect" then
      framesEffect(effect,screenx,screeny)
    end
  end
end