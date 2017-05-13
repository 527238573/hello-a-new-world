local rm = render.main


--在unit背后effect，screenx,screeny是unit图像的中心点。 如果有anim，中心点也会动
function rm.drawUnitBackEffect(unit,x,y,z,screenx,screeny)
  
  
end




--前置的特效

function rm.drawUnitFrontEffect(unit,x,y,z,screenx,screeny)
  local list = unit.animEffectList
  for _,effect in ipairs(list) do
    local method = rm.animEffectMethod[effect.name]
    if method then
      method(effect,screenx,screeny)
    end
  end
end