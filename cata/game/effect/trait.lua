local geffect = g.effect --和effect使用同目录


local trait_mt = {} --metatable
geffect.trait_mt = trait_mt
trait_mt.__index = trait_mt



function geffect.createTrait(idname,level)
  
  --bodypart在分布有效的effect中，默认躯干。
  local ttype = data.traitTypes[idname]
  if ttype ==nil then error("Error effect name:"..idname) end
  local newtrait= {type = ttype}
  setmetatable(newtrait,trait_mt)
  
  
  newtrait.level = c.clamp(level,ttype.min_level,ttype.max_level)
  --bodypart
  
  
  return newtrait
end

function trait_mt:getName()
  local name = self.type.name
  if self.type.names then
    --local mname = self.type.names[self.level]
    --debugmsg("show1:"..self.type.names[1])
    
    name = self.type.names[self.level] or name
  end
  return name
end

function trait_mt:getDescription()
  local description = self.type.description
  if self.type.descriptions then
    description = self.type.descriptions[self.level] or description
  end
  return description
end



function trait_mt:addSame(level)
  self.level = c.clamp(self.level+level,self.type.min_level,self.type.max_level)
  --注意 规范数值合法范围
end

function trait_mt:onAdd(unit)
  --播放消息，加上触发等
  if unit==player and self.type.apply_message then
    addmsg(self.type.apply_message,self.type.rating)
  end
  
  if self.type.change_bonus then unit:bonus_dirty() end
  if unit:is_player() and self.type.miss_reasons then unit.build_miss_reasons = false end
end
function trait_mt:onRemove(unit)
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

function trait_mt:is_good()
  return (self.type.rating =="good"  and self.level>=0) or (self.type.rating =="bad" and self.level<0)
end


--将此trait造成的属性改编 写入bonus
function trait_mt:calculate_bonus(bonus,unit)
  local mod_data =self.type.mod_data
  if mod_data then
    for atrname,mod_t in pairs(mod_data) do
      local base = mod_t[self.level] or 0 --
      bonus[atrname] = bonus[atrname]+base --修改
    end
  end
end


