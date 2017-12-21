local geffect = g.effect

local effect_mt = {} --metatable
geffect.effect_mt = effect_mt
effect_mt.__index = effect_mt



function geffect.createEffect(idname,duration,permanent,intensity,bodypart)
  permanent = permanent or false
  intensity = intensity or 1
  --bodypart在分布有效的effect中，默认躯干。
  local etype = data.effectTypes[idname]
  if etype ==nil then error("Error effect name:"..idname) end
  local neweffect= {type = etype}
  setmetatable(neweffect,effect_mt)
  
  
  neweffect.pastTime = 0
  neweffect.duration = c.clamp(duration,0,etype.max_duration) --规范数值合法范围
  neweffect.permanent = permanent
  neweffect.intensity = c.clamp(intensity,1,etype.max_intensity)
  --bodypart
  
  
  return neweffect
end


function effect_mt:getName()
  return self.type.name
end

function effect_mt:getDescription()
  return self.type.description
end

local str_dur= tl("持续:%.1fs","duration:%.1fs")
local str_permanent = tl("持续时间：永久","duration:permanent")
function effect_mt:getTimeStr()
  if self.permanent then return str_permanent 
  else
    return string.format(str_dur,self.duration - self.pastTime)
  end
end

--返回need remove
function effect_mt:update(dt)
  self.pastTime = self.pastTime+dt
  --相关触发
  return (not self.permanent) and self.pastTime >self.duration
end

--已有这个effect时，想添加同样的effect，与这个合并
function effect_mt:addSameEffect(duration,permanent,intensity,bodypart)
  --注意 规范数值合法范围
end


function effect_mt:onAddEffect(unit)
  --播放消息，加上触发等
  if unit==player and self.type.apply_message then
    addmsg(self.type.apply_message,self.type.rating)
  end
  
  if self.type.change_bonus then unit:bonus_dirty() end
  if unit:is_player() and self.type.miss_reasons then unit.build_miss_reasons = false end
end
function effect_mt:onRemoveEffect(unit)
  --播放消息
  if unit==player and self.type.remove_message then
    local rate = "normal"
    if self.type.rating=="good" then
      rate = "bad"
    elseif self.type.rating=="bad" then
      rate = "good"
    end
    addmsg(self.type.remove_message,rate)
  end
  
  if self.type.change_bonus then unit:bonus_dirty() end
  if unit:is_player() and self.type.miss_reasons then unit.build_miss_reasons = false end
end


--太不详细，需要大量注释
--将此effect造成的属性改编 写入bonus
function effect_mt:calculate_bonus(bonus,unit)
  local mod_data =self.type.mod_data
  if mod_data then
    for atrname,mod_t in pairs(mod_data) do
      local reduced = unit:resists_effect(self)
      
      local base = mod_t.base_mod or 0
      if reduced then base =(mod_t.base_reduced or 0) end
      if self.intensity>1 then --存在scaling
        
        local scaling = mod_t.scaling_mod or 0
        if reduced then scaling =(mod_t.scaling_reduced or 0) end
        base = base+ (self.intensity-1)*scaling
      end
      --if bonus[atrname] ==nil then bonus[atrname] = 0 end  打错名字，或未初始化的属性会报错
      bonus[atrname] = bonus[atrname]+base --修改
    end
  end
end

function effect_mt:get_color()
  return self.type.color
end

