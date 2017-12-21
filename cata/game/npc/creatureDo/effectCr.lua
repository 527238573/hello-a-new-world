local creatureBase = g.creature.creatureBase



function creatureBase:resetBonus()
  local bonus = {}
  self.bonus = bonus
  for k,v in pairs(g.creature.default_base_table) do
    bonus[k] = 0
  end
  if not self:is_monster() then
    for k,v in pairs(g.creature.default_charactor_base_table) do--额外加成
      bonus[k] = 0
    end
  end
  
end

--添加effect--唯一入口
function creatureBase:add_effect(effect_id,dur,permanent,intensity,bodypart,force)
  permanent = permanent or false
  intensity = intensity or 1
  
  if not force and self:is_immune_effect(effect_id) then return end
  
  local eff_type = data.effectTypes[effect_id]
  if eff_type ==nil then 
    debugmsg("Invalid effect, ID:"..effect_id)
    return
  end
  
  local find_eff = self.effects[effect_id]
  if find_eff then
    find_eff:addSameEffect(dur,permanent,intensity,bodypart) --合并为一个
    return
  end
  --是否存在blockeffect --移动到is_immune_effect里了
  --移除（替换）的effect
  if eff_type.removes_effects then
    for _,v in ipairs(eff_type.removes_effects) do
      self:remove_effect(v)
    end
  end
  local new_eff = g.effect.createEffect(effect_id,dur,permanent,intensity,bodypart)
  self.effects[effect_id] = new_eff
  new_eff:onAddEffect(self)
  if self == player then self:reset_effect_list()end
end
--移除
function creatureBase:remove_effect(effect_id)
  local find_eff = self.effects[effect_id]
  if find_eff then
    find_eff:onRemoveEffect(self)
    self.effects[effect_id] = nil
    if self == player then self:reset_effect_list()end
  end
end
--全部清除，可能影响部分逻辑
function creatureBase:clear_effects()
  for _,eff in pairs(self.effects) do eff:onRemoveEffect(self) end
  self.effects = {}
end

function creatureBase:has_effect(effect_id)
  local find_eff = self.effects[effect_id]
  return find_eff~=nil
end
function creatureBase:get_effect(effect_id)
  return self.effects[effect_id]
end
function creatureBase:get_effect_remain_time(effect_id)
  local eff = self.effects[effect_id]
  if eff and not eff.permanent then
    return eff.duration - eff.pastTime
  end
  return 0
end


--占位，monster，charactor各自实现
function creatureBase:is_immune_effect(eff_id)
  --是否存在blockeffect
  for _,eff_ins in pairs(self.effects) do
    local blocks = eff_ins.type.blocks_effects
    if blocks then
      for _,v in ipairs(blocks) do
        if v==eff_id then return true end --被阻挡
      end
    end
  end
  return false
end

--更新effect时间，删除时间到的effects
function creatureBase:update_effects(dt)
  local to_delete 
  for eff_id,eff_ins in pairs(self.effects) do
    if eff_ins:update(dt) then
      if to_delete==nil then to_delete = {} end
      table.insert(to_delete,eff_id)
    end
  end
  --删除阶段
  if to_delete then
    for _,v in ipairs(to_delete) do
      self:remove_effect(v)
    end
  end
  --重计算buff
  if self.bonus_changed then
    self:recalculate_bonus()
  end
  
end

function creatureBase:resists_effect(eff_ins)
  for _,v in ipairs(eff_ins.type.resist_effects) do
    if self:has_effect(v) then return true end
  end 
  for _,v in ipairs(eff_ins.type.resist_traits) do
    if self:has_trait(v) then return true end
  end 
  return false
end
--charactor专用,
function creatureBase:has_trait(trait_id)
  return false
end

function creatureBase:bonus_dirty()
  self.bonus_changed = true
end

function creatureBase:recalculate_bonus()
  debugmsg("recalculate_bouns")
  self:resetBonus()
  for _,eff_ins in pairs(self.effects) do
    eff_ins:calculate_bonus(self.bonus,self)
  end
  if self.traits then
    for _,trait_ins in pairs(self.traits) do
      trait_ins:calculate_bonus(self.bonus,self)
    end
  end
  
  self.bonus_changed = false
end
--只有player会调用这个函数
function creatureBase:get_miss_reason()
  if not self.build_miss_reasons then --重建列表
    self.build_miss_reasons = true
    local weightT = c.weightT({})
    for _,eff in pairs(self.effects) do  --所有effect的miss reason
      if eff.type.miss_reasons then
        for _,v in ipairs(eff.type.miss_reasons) do
          c.pushWeightVal(weightT,v[1],v[2])
        end
      end
    end
    --所有trait
    for _,eff in pairs(self.trait) do  --所有effect的miss reason
      if eff.type.miss_reasons then
        for _,v in ipairs(eff.type.miss_reasons) do
          c.pushWeightVal(weightT,v[1],v[2])
        end
      end
    end
    
    
    --所有 累赘，保暖度
    self.miss_reason_list= weightT
  end
  if #self.miss_reason_list.weight>0 then
    return c.getWeightValue(self.miss_reason_list.weight)
  end
  return nil
end

--只有player才用
function creatureBase:reset_effect_list()
  local list = {}
  for _,eff_ins in pairs(self.effects) do
    list[#list+1] = eff_ins
  end
  self.effect_list  =list 
end

--[[在此记录出现的未被使用的traits
--DRUNKEN_MASTER --醉拳

--还有effect
--drunk 醉酒
bouldering  ??地面不稳？
sleep 睡觉
lying_down  躺倒
--]]