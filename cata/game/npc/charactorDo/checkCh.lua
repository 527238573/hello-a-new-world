local charactorBase = g.creature.charactorBase 


function charactorBase:add_msg_if_npc(msgs,rate)
  if self ~=player then msg.addmsg(msgs,rate) end--
end

function charactorBase:cur_str()
  return math.max(self.base.str + self.bonus.str,1) --不能低于1
end
function charactorBase:cur_dex()
  return math.max(self.base.dex + self.bonus.dex,1)
end
function charactorBase:cur_int()
  return math.max(self.base.int + self.bonus.int,1)
end
function charactorBase:cur_per()
  return math.max(self.base.per + self.bonus.per,1)
end
function charactorBase:get_speed()
  return math.max((1+self.bonus.speed_percent/100)*(self.base.speed + self.bonus.speed),10) --角色速度不会低于10，
end


function charactorBase:get_max_hp(body_part)
  if body_part then
    return self.base[body_part] + self.bonus[body_part]
  else
    return 600
  end
  --暂无
end

function charactorBase:is_immune_effect(eff)
  return false
end

--是否睡觉或准备睡觉中
function charactorBase:in_sleep_state()
  return self:has_effect("sleep") or self:has_effect("lying_down")
end

--能否使用武器等，有力量属性限制等
function charactorBase:can_use(item,interact)
  
  return true
end



local bp_select_index = {"bp_eyes","bp_head","bp_torso","bp_arm_l","bp_arm_r","bp_leg_l","bp_leg_r"}
local default_hit_weights=
{
  smaller = {              0,       0,          20,         15,       15,         25,         25,},
  equal = {                0.33,    2.33,       33.33,      20,       20,         12,         12,},
  larger = {               0.57,    5.71,       36.57,      22.86,    22.86,      5.71,       5.71,},
}

function charactorBase:select_body_part(source,hit_roll)
  local szdif = source:get_size() - self:get_size()
  local difIndex = "equal"
  if szdif >0 then difIndex = "larger" elseif szdif<0 then difIndex = "smaller" end
  local hit_org = default_hit_weights[difIndex]
  local hit_weights = {}
  for i=1,#hit_org do hit_weights[i] = hit_org[i] end
  
  --todo跌倒 几率修正
  if hit_roll ~=0 then--hit几率修正
    hit_weights[1] = hit_weights[1] * math.pow(hit_roll, 1.15)
    hit_weights[2] = hit_weights[2] * math.pow(hit_roll, 1.35)
    hit_weights[3] = hit_weights[3] * math.pow(hit_roll, 1)
    hit_weights[4] = hit_weights[4] * math.pow(hit_roll, 0.95)
    hit_weights[5] = hit_weights[5] * math.pow(hit_roll, 0.95)
    hit_weights[6] = hit_weights[6] * math.pow(hit_roll, 0.975)
    hit_weights[7] = hit_weights[7] * math.pow(hit_roll, 0.975)
  end
  local totalWeight = 0
  for i=1,#hit_weights do totalWeight= totalWeight+hit_weights[i] end
  local roll = rnd() *totalWeight
  local add_weight = 0
  for i=1,#hit_weights do
    if roll<= hit_weights[i]+add_weight then
      return bp_select_index[i]
    end
    add_weight = add_weight+hit_weights[i]
  end
  debugmsg("error,select body part roll error,roll:"..roll.." totoalweight:"..totalWeight)
  return bp_select_index[3]
end

--


