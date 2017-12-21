local gmon = g.monster
local monster_mt = gmon.monster_mt
local animManager = g.animManager



function monster_mt:melee_attack(destunit)

  if destunit ==self or self.type.melee_dice <= 0 then
    self:addDelay(0.5) --算作行动过了
    return
  end
  local atack_cost_time = self.type.attack_cost/self:get_speed()/c.timeSpeed
  
  local dx,dy =  destunit.x -self.x ,destunit.y - self.y
  self:setAnimation(animManager.createMoveAndBackAnim(self,28*dx,28*dy,atack_cost_time*0.8,math.min(0.15,atack_cost_time*0.2)))
  self:addDelay(atack_cost_time)
  self.face =  c.face(dx,dy)
  
  
  if self.type.attack_sound then
    if type(self.type.attack_sound)=="table" then
      if  not (self.type.attack_sound.chance and rnd() >self.type.attack_sound.chance)  then
          g.playSound(self.type.attack_sound[rnd(1,#self.type.attack_sound)])
      end
    else
        g.playSound(self.type.attack_sound)
    end
  end
  
  
  
  --部分AI effect标记

  local hitspread = self:hit_roll() - destunit:dodge_roll()
  local u_see_me = player:seesUnit(self)
  if hitspread<0 then --miss
    --闪避信息
    if u_see_me then
      if destunit ==player then
        addmsg(string.format(tl("你躲开了%s.","You dodge %s."),self:getName()))
      elseif destunit:is_npc() then
        addmsg(string.format(tl("%s闪避了%s的攻击.","%s dodges %s attack."),destunit:getName(),self:getName()),"npc")
      else
        addmsg(string.format(tl("%s没击中%s!","The %s misses %s!"),self:getName(),destunit:getName()))
      end
    elseif destunit ==player then
      addmsg(tl("你躲避了不知来路的攻击。","You dodge an attack from an unseen source."))
    end
    destunit:on_dodge(self,self:get_melee_skill())
    
  else  --命中
    destunit:addFramesAnimEffect("clawhit",(rnd()-0.5)*(8+12*math.abs(dy))-12*dx,(rnd()-0.5)*(8+12*math.abs(dx))-12*dy) --详细约束特效起始位置，更好的效果
    local impact_xishu = 1
    if dx~=0 and dy~=0 then impact_xishu = 0.8 end
    local impact_rnd = (rnd()-0.5)*4 *impact_xishu
    destunit:addImpactAnimation(animManager.createImpactAnim(destunit,6*dx*impact_xishu+3*impact_rnd*dy,4*dy*impact_xishu+3*impact_rnd*dx,0.12,0.05,0.15))
    
    
    
    local damage_ins = g.create_damage_instance()
    damage_ins:add_damage("bash",dice( self.type.melee_dice, self.type.melee_dice_sides))
    local dealt_dam = destunit:deal_melee_hit(self,hitspread,false,damage_ins)
    local total_dealt = dealt_dam.total
    local hit_bp_name = destunit:body_part_name(dealt_dam.body_part)
    if total_dealt<=0 then
      --命中后无伤害
      if u_see_me then
        if destunit ==player then
          addmsg(string.format(tl("%s击中了你的%s，但你的%s保护了你。","The %s hits your %s, but your %s protects you."),self:getName(),hit_bp_name,destunit:skin_name()))
        elseif destunit:is_npc() then
          addmsg(string.format(tl("%s击中了%s的%s，但是被%s阻挡了。","The %s hits %s %s but is stopped by %s."),self:getName(),destunit:getName(),hit_bp_name,destunit:skin_name()))
        else
          addmsg(string.format(tl("%s击中了%s，但是被它的%s阻挡了。","The %s hits %s but is stopped by its %s."),self:getName(),destunit:getName(),destunit:skin_name()))
        end
      elseif destunit ==player then
        addmsg(string.format(tl("某个东西击中了你的%s，但你的%s保护了你。","Something hits your %s, but your %s protects you."),hit_bp_name,destunit:skin_name()))
      end
    else
      --命中并造成伤害
      if u_see_me then
        if destunit ==player then
          addmsg(string.format(tl("%s击中了你的%s。","The %s hits your %s."),self:getName(),hit_bp_name),"bad")
        elseif destunit:is_npc() then
          addmsg(string.format(tl("%s击中了%s的%s。","The %s hits %s %s."),self:getName(),destunit:getName(),hit_bp_name))
        else
          addmsg(string.format(tl("%s击中了%s!","The %s hits %s!"),self:getName(),destunit:getName()))
        end
      elseif destunit ==player then
        addmsg(string.format(tl("有东西击中了你的%s!","Something hits your %s!"),hit_bp_name),"bad")
      end
      --攻击附加特殊效果，毒，流血等
      
    end--命中伤害结束
  end--命中结束
  
end



--近战等级
function monster_mt:get_melee_skill()
  return self.type.melee_skill
end
function monster_mt:get_defence_skill()
  return self.type.defence
end

--躲闪等级
function monster_mt:get_dodge()
  --跌倒时return 0
  if self:has_effect("downed")  then return 0 end
  
  local ret = self.base.dodge
  --todo陷阱异常时减半 --后续再添加 可以变成百分比bouns加入到effect中去，跌倒也可以，不过
  local dodge_reduce = math.min(self.bonus.dodge_reduce,50) --最大50%闪避削减
  ret  = ret * (100-dodge_reduce)/100--百分比闪避削减
  
  
  --delay过长时衰弱的闪避
  if self.delay >= (1+100/self:get_speed())/c.timeSpeed then --
    ret = rnd(0,ret)
  end
  
  return math.max(ret + self.bonus.dodge,0)--最小0级？
end


--命中率

function monster_mt:hit_roll()
  --影响命中率的效果。。。effect_bouldering
  if self:has_effect("bouldering") and one_in(self:get_melee_skill()) then
    return 0
  end
  --一般丧失初始4级击中
  return dice(self:get_melee_skill()+ self.bonus.hit,10) --cdda怪物没有buff加成？

end

function monster_mt:dodge_roll()
  --影响闪避率的效果。。。effect_bouldering
  if self:has_effect("bouldering") and one_in(self.type.dodge) then
    return 0
  end
  
  local numberdice  = self:get_dodge()
  local size = self.type.size
  numberdice = numberdice+6-size*2 --体积修正（暂定）
  if size<3 then numberdice  = numberdice +(3-size) end
  numberdice = numberdice + self:get_speed()/80
  debugmsg("mon ndice:"..numberdice)
  --numberdice = numberdice+4    -- 一般丧尸初始0级闪避，即使加上速度70加成，只有0.875dice，不能闪避任何攻击
  return dice(numberdice,10)
end



--进行实际闪避
function monster_mt:on_dodge(source_unit,level)
  --躲闪动画
end

function monster_mt:on_hit(source,deal_dam)
  
end

function monster_mt:on_hurt(source,dam)
  --
end
--处理伤害,是延迟过后的
function monster_mt:take_damage(source,body_part,dam)
  if self:is_dead_state() then return end
  self.hp = self.hp - dam
  if self.hp<=0 then 
    self:set_killer(source)
  end
end

function monster_mt:is_immune_damage(dam_type)
  if dam_type == "acid" then return self:has_flag("ACIDPROOF")
  elseif dam_type == "acid" then return (self:made_of("steel") or self:made_of("stone"))
  elseif dam_type == "electric" then return self:has_flag("ELECTRIC") 
  elseif dam_type == "cold" then return self:has_flag("WARM") end
  return false
end


--返回，实际dam,pain
function monster_mt:absorb_hit(dam_t,final_mul,body_part)
  local dam_type = dam_t.type
  local dam_mul = dam_t.dam_mul * final_mul
  
  if self:is_immune_damage(dam_type) then return 0,0 end
  local adjusted_damage,pain = 0,0
  if dam_type =="bash" then
    if self:has_flag("PLASTIC") then
      adjusted_damage = dam_t.amount/rnd(2,4)
      pain = dam_t.amount/4
    else
      adjusted_damage = math.max(0,dam_t.amount - math.max(0,self.type.armor_bash-dam_t.res_pen)*dam_t.res_mult)*dam_mul
      pain = adjusted_damage/4     
      self:delay_moves(rnd(0,adjusted_damage*2))--击退行动条
    end
  elseif dam_type =="cut" then
    adjusted_damage = math.max(0,dam_t.amount - math.max(0,self.type.armor_cut-dam_t.res_pen)*dam_t.res_mult)*dam_mul
    pain = (adjusted_damage +math.sqrt(adjusted_damage))/4
  elseif dam_type == "stab" then
    adjusted_damage = math.max(0,dam_t.amount - math.max(0,self.type.armor_stab-dam_t.res_pen)*dam_t.res_mult)*dam_mul
    pain = (adjusted_damage +math.sqrt(adjusted_damage))/4
  elseif dam_type == "acid" then
    adjusted_damage = math.max(0,dam_t.amount - math.max(0,self.type.armor_acid-dam_t.res_pen)*dam_t.res_mult)*dam_mul
    pain = adjusted_damage/3
  elseif dam_type == "heat" then
    adjusted_damage = math.max(0,dam_t.amount - math.max(0,self.type.armor_fire-dam_t.res_pen)*dam_t.res_mult)*dam_mul
    pain = adjusted_damage/4
    if rnd(5,100)<adjusted_damage then self:add_effect("on_fire",rnd()+0.5)end
  elseif dam_type == "cold" then  
    adjusted_damage = dam_t.amount*dam_mul
    pain = adjusted_damage/6   ---减速
    self:delay_moves(adjusted_damage*80)--击退行动条--似乎过长？
  elseif dam_type == "electric" then
    adjusted_damage = dam_t.amount*dam_mul
    pain = adjusted_damage/4
    self:add_effect("zapped",math.max(0.8,rnd(0,adjusted_damage/3)))
  else--其他都当真实伤害
    adjusted_damage = dam_t.amount*dam_mul
    pain = adjusted_damage/4
  end
  return adjusted_damage,pain
end
