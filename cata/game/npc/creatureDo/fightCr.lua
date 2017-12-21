local creatureBase = g.creature.creatureBase



function creatureBase:deal_melee_hit(source,hit_spread, critical_hit,dam_ins)
  
  local body_part = self:select_body_part(source,hit_spread)
  --格挡触发
  if self:block_hit(source,body_part,dam_ins) then return end--伤害被格挡，dam_ins在另一路线处理
  --// Bashing crit
  if critical_hit and not self:is_immune_effect("stunned") then
    for i=1,#dam_ins do 
      if dam_ins[i].type =="bash" then
        if dam_ins[i].amount *hit_spread >self:get_max_hp() then 
          self:add_effect("stunned",0.5)--击晕0.5
        end
        break;
      end
    end
    
  end
  -- // Stabbing effects
  for i=1,#dam_ins do 
      if dam_ins[i].type =="stab" then
        local stab_move = (rnd()+0.5) *dam_ins[i].amount
        if critical_hit then stab_move = stab_move*1.5 end
        self:delay_moves(stab_move/2)--行动击退
        if stab_move>150 and not self:is_immune_effect("downed") then
          self:add_effect("downed",0.6)----击倒
          --todo，击倒message
        end
        break;
      end
    end
  
  local deal_dam = self:deal_damage(source,body_part,dam_ins)
  --onhit击中触发
  self:on_hit(source,deal_dam)
  return deal_dam
end

function creatureBase:block_hit(source,body_part,dam_ins)--虚
  return false
end



function creatureBase:deal_damage(source,body_part,dam_ins,final_mul) --并不修改dam_ins
  final_mul = final_mul or 1
  local deal_dam = {total = 0,body_part = body_part} --
  if self:is_dead_state() then return deal_dam end --死亡后无伤害
  local total_dam,total_pain =0,0
  
  for _,dam_t in ipairs(dam_ins) do
    local cur_dam,cur_pain = self:absorb_hit(dam_t,final_mul,body_part)
    deal_dam[dam_t.type] = cur_dam
    total_dam = total_dam+cur_dam
    total_pain = total_pain+cur_pain
  end
  deal_dam.total = total_dam
  
  self:mod_pain(total_pain)--调整pain
  --NoGIB 调整伤害
  self:apply_damage(source,body_part,total_dam,dam_ins.delay)
  return deal_dam
end


--实施伤害，有延迟的。真的实施伤害在take_damage中
function creatureBase:apply_damage(source,body_part,dam,delay)
  delay = delay or 0 
  if dam<=0 then return end
  
  if delay==0 then 
    self:take_damage(source,body_part,dam)
  else
    table.insert(self.damage_queue,{source = source,body_part =body_part,dam=dam,delay = delay})--延迟伤害
  end
  self:on_hurt(source,dam)
end

function creatureBase:update_damage(dt)
  --计算延时伤害
  local i=1
  while i<=#self.damage_queue do
    local dam_t = self.damage_queue[i]
    dam_t.delay = dam_t.delay  - dt
    if dam_t.delay<=0 then
      self:take_damage(dam_t.source,dam_t.body_part,dam_t.dam)
      table.remove(self.damage_queue,i)
    else
      i= i+1
    end
  end
end



function creatureBase:select_body_part(source,hit_roll)
  return "bp_torso"
end