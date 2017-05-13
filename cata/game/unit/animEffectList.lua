
local ae_mt = {}
ae_mt.__index = ae_mt


function g.createAnimEffectList()
  local newlist = {}
  setmetatable(newlist,ae_mt)
  return newlist
end




function ae_mt:updateAnim(dt)
  local i=1
  while i<=#self do
    local effect = self[i]
    effect.pastTime = effect.pastTime+dt
    if effect.pastTime> effect.totalTime then
      --anim.pastTime = anim.pastTime - anim.totalTime
      table.remove(self,i)
      i= i-1
    end
    i = i+1
  end
end


function ae_mt:addEffect(effect)
  self[#self+1] = effect
end