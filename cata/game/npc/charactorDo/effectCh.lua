--一些triat，effect，只有对charactor才起效的放在这里
local charactorBase = g.creature.charactorBase 


function charactorBase:add_trait(trait_id,level)
  level =level or 1
  local trait_type = data.traitTypes[trait_id]
  if trait_type ==nil then 
    debugmsg("Invalid trait, ID:"..trait_id)
    return
  end
  local find_trait = self.traits[trait_id]
  if find_trait then
    find_trait:addSame(level) --合并为一个
    if find_trait.level ==0 then --降为无变化，中等？
      self:remove_trait(trait_id)
    end
    return
  end
  if trait_type.blocks_effects then --阻止效果，包括移除
    for _,v in ipairs(trait_type.blocks_effects) do
      self:remove_effect(v)
    end
  end
  local new_trait = g.effect.createTrait(trait_id,level)
  self.traits[trait_id] = new_trait
  new_trait:onAdd(self)
end

function charactorBase:remove_trait(trait_id)
  local find_trait = self.traits[trait_id]
  if find_trait then
    find_trait:onRemove(self)
    self.traits[trait_id] = nil
  end
end

function charactorBase:has_trait(trait_id)
  return self.traits[trait_id]~=nil
end

--重载
function charactorBase:is_immune_effect(eff_id)
  --是否存在blockeffect
  for _,eff_ins in pairs(self.effects) do
    local blocks = eff_ins.type.blocks_effects
    if blocks then
      for _,v in ipairs(blocks) do
        if v==eff_id then return true end --被阻挡
      end
    end
  end
  --traits 的阻挡效果
  for _,trait_ins in pairs(self.traits) do
    local blocks = trait_ins.type.blocks_effects
    if blocks then
      for _,v in ipairs(blocks) do
        if v==eff_id then return true end --被阻挡
      end
    end
  end
  
  return false
end