local charactorBase = g.creature.charactorBase
local animManager = g.animManager



function charactorBase:get_melee_skill()
  return self.skills:get_skill_level("melee")
end
function charactorBase:get_defence_skill()
  return self.skills:get_skill_level("defence")
end

function charactorBase:get_dodge()
  if self:in_sleep_state() then return 0 end -- cdda跌倒不减闪避，奇
  
  local dodge = self.skills:get_skill_level("dodge") + self:cur_dex()/2+self.base.dodge +self.bonus.dodge    --敏捷+技能+0+bonus  
  local dodge_reduce = math.min(self.bonus.dodge_reduce,50) --最大50%闪避削减
  dodge  = dodge * (100-dodge_reduce)/100--百分比闪避削减
  return dodge 
end


function charactorBase:melee_attack(destunit)

  if destunit ==self  then
    --self:addDelay(0.5) 
    return
  end
  --ai 标记等
  local hit_roll = self:hit_roll()
  local target_dodge = destunit:dodge_roll()
  local hitspread = hit_roll - target_dodge
  local attack_cost_time = self:attack_speed(self.weapon,false)  --攻击耗时
  local seen_self = self ==player or player:seesUnit(self) --player能看见攻击发起者

  if hitspread<0 then 
    --未命中
    --todo stumble,以及missingreason
    
    if self ==player then  
      local miss_reason = self:get_miss_reason()
      if miss_reason then addmsg(miss_reason) end
      addmsg(tl("你没打中。","You miss."))
    elseif seen_self then
      addmsg(string.format(tl("%s未命中。","%s misses."),self:getName()),"npc")
    end
    destunit:on_dodge(self,self:get_melee_skill())--闪避动画在此函数里面
    
    --动画,未命中的
    self:miss_attack_animation(destunit,attack_cost_time)--delay在动画里附加
    
    --提升近战技能
    local self_weapon = self.weapon or g.itemFactory.fake_fists  --如果没有武器，用假的拳头物品代替
    self:melee_practice(false,self:unarmed_attack(),self_weapon:is_bashing_weapon(),self_weapon:is_cutting_weapon(),self_weapon:is_stabbing_weapon(),destunit:get_dodge(),destunit:get_defence_skill())
    
  else
    --只有命中后才计算暴击，不重新roll数值，这里暴击是比原来要高的
    local critical_hit = rnd()< self:crit_chance(hit_roll,target_dodge)
    
    local damage_ins = g.create_damage_instance()
    --roll all damage
    self:roll_all_damage(damage_ins,critical_hit,false,self.weapon)
    --damage_ins:add_damage("bash",5)--20伤害
    --technique
    --special_attacks 
    --攻击特效及其相关信息
    damage_ins.delay = 0.2 --延时
    local dealt_dam = destunit:deal_melee_hit(self,hitspread,critical_hit,damage_ins) --实际deal
    --攻击耗时
    --local costtime = 0.5
    --分析结果
    dealt_dam.bash=dealt_dam.bash or 0
    dealt_dam.cut =dealt_dam.cut or 0
    dealt_dam.stab = dealt_dam.stab or 0
    local practice_bashing = (dealt_dam.bash >= 10)
    local practice_cutting = (dealt_dam.cut >= 10)
    local practice_stabbing = (dealt_dam.stab >= 10)
    local practice_unarm = false
    if self:unarmed_attack() then
      practice_unarm = true
      practice_bashing = false
      --使用unarm动画！
      self:unarmed_attack_animation(destunit,attack_cost_time)--delay在动画里附加
    elseif dealt_dam.bash>dealt_dam.cut and dealt_dam.bash>dealt_dam.stab then
      practice_bashing = true
      --使用bash动画
      self:bashing_attack_animation(destunit,attack_cost_time)
    elseif dealt_dam.cut>=dealt_dam.stab then
      practice_cutting = true
      --使用cut动画，注意，全为0也使用cut动画
      self:cutting_attack_animation(destunit,attack_cost_time)
    else
      practice_stabbing = true
      --使用stab动画
      self:stabbing_attack_animation(destunit,attack_cost_time)
    end
    
    --gameworld 声音，打击声 与材质

    -- skill训练
    self:melee_practice(true,practice_unarm,practice_bashing,practice_cutting,practice_stabbing,destunit:get_dodge(),destunit:get_defence_skill())

    --文字信息播放
    if seen_self then--看见攻击发起者才能有信息
      if player:seesUnit(destunit) then
        self:hit_message(dealt_dam,critical_hit,destunit) --播放
      else
        if self == player then
          addmsg(tl("你打中了什么东西。","You hit something."),"info")
        else--npc
          addmsg(string.format(tl("%s打中了什么东西。","%s hits something."),self:getName()),"npc")
        end
      end
    end
  end
  --体力损耗
  --武术触发？

end

--取得骰子信息
function charactorBase:hit_roll_dice()
  --基础命中
  local hit_dice = 3+(self:cur_dex()/4)+self:get_weapon_and_skill_hitbonus(self.weapon) --基础+属性命中+技能武器，这个值起始就起码有5点+武器补正，后续技能高了提升到10-20点以上，需要高累赘装备抵消
  hit_dice  = hit_dice+self.bonus.hit --effect带来的命中修正
  --醉拳
  if self:has_trait("DRUNKEN_MASTER") then
    local remain_time = self:get_effect_remain_time("drunk")
    if self:unarmed_attack() then
      hit_dice = hit_dice+ (remain_time/135) --从cdda回合换算为实际秒数
    else
      hit_dice = hit_dice+ (remain_time/180)
    end
  end
  --远视减成，可能移动到buff中去
  
  --躯干减成，手臂累赘减成呢？
  local sides = 10- self:get_bodypart_encumberance("bp_torso")
  
  hit_dice = math.max(hit_dice,1)
  sides = math.max(sides,2)
  
  return hit_dice,sides
end

function charactorBase:hit_roll()
  --//Unstable ground chance of failure
  --直接失败的特效effect_bouldering
  if self:has_effect("bouldering") and one_in(8) then
    self:add_msg_if_player(tl("你脚下的地面很颠簸！","The ground shifts beneath your feet!"),"bad")
    return 0
  end
  local hit_dice,sides = self:hit_roll_dice() --取得骰子信息
  return dice(hit_dice,sides)
end

--取得闪避骰子信息
function charactorBase:dodge_roll_dice()
  local sides =10--默认10个side
  local dodge_state= self:get_dodge();
  if self.dodge_left<=0 then --闪避次数用尽，力竭型闪避
    local dodge_dex = self.skills:get_skill_level("dodge") + self:cur_dex()
    if rnd(0,dodge_dex+15)<= dodge_dex then
      dodge_state = rnd(dodge_state/2,dodge_state)--保留一半以上的闪避dice
    else
      return 0,sides --力竭失效
    end
  end
  
  --理应收到腿部累赘减成（躯干可能有影响）
  return dodge_state,sides --起始属性起码有4点闪避dice，多可达 29，
end



function charactorBase:dodge_roll()
  --滑板鞋？！ 
  
  --effect_bouldering
  if self:has_effect("bouldering") and one_in(self:cur_dex()) then
    self:add_msg_if_player(tl("","You slip as the ground shifts beneath your feet!"),"bad")
    self:add_effect("downed", 0.9);
    return 0;
  end
  
  local dodge_dice,sides = self:dodge_roll_dice()
  local roll = dice(dodge_dice,sides) --起始属性起码有4点闪避dice，多可达 29，
  --local speed_stat = self:get_speed()  --速度减成，
  --if speed_stat<100 then
  --  roll= roll*speed_stat/100
  --end
  --debugmsg("player dodge:"..roll)
  return roll
end

function charactorBase:recoverDodgeAndBlock(dt)
  local max_dodge = self.base.num_dodges +self.bonus.num_dodges
  self.dodge_left = math.min(max_dodge,self.dodge_left+ dt*1.13)--2回合回复1次dodge
end


--进行实际闪避
function charactorBase:on_dodge(source_unit,level)
  --躲闪动画
  self.dodge_left = self.dodge_left-1--降低闪避次数
  --训练技能
  self.skills:train("dodge",2,level-4)--4级最多升到4级
  --todo 远程丢失瞄准
  --武术效果
  --闪避并反击的technique
  
end

function charactorBase:on_hit(source,deal_dam)

  --身体部位被击中的效果（致盲）， 酸性血液等触发转移到此处，cdda是在player::deal_damage里
end


function charactorBase:on_hurt(source,dam)
  --受伤触发

  --mod_pain dam/2
  --肾上腺素
  --打断睡觉，activity

end

local fall_to_main_bodypart = {
    bp_head = "bp_head",bp_eyes = "bp_head",bp_mouth = "bp_head",
    bp_torso = "bp_torso",
    bp_arm_l="bp_arm_l",bp_hand_l = "bp_arm_l",
    bp_arm_r="bp_arm_r",bp_hand_r = "bp_arm_r",
    bp_leg_l = "bp_leg_l",bp_foot_l = "bp_leg_l",
    bp_leg_r = "bp_leg_r",bp_foot_r = "bp_leg_r",
  }

--真的收到伤害
function charactorBase:take_damage(source,body_part,dam)
  if self:is_dead_state() then return end
  local main_body_part = fall_to_main_bodypart[body_part]
  debugmsg(string.format("recieve dam at %s: %f",body_part,dam))
  
  if main_body_part==nil then
    debugmsg("take_damage:Wacky body part hurt!:"..body_part)
    main_body_part = "bp_torso"
  end
  self.hp_part[main_body_part] = math.max(self.hp_part[main_body_part] - dam,0)
  if self:is_dead_state() then
    self:set_killer(source)
  end
end

function charactorBase:is_immune_damage(dam_type)
  return false
end


--装备吸收伤害，返回剩余的伤害amount，和 是否destoryed 装备 注意，这里的伤害amount还未经过倍乘过的伤害
function charactorBase:armor_absorb(witem,dam_amount,dam_type,body_part)
  if not witem:hit_cover(body_part) then return dam_amount end --未覆盖，不吸收
  local resist = witem:get_damage_resist(dam_type,false)
  dam_amount =math.max(0, dam_amount - resist)
  local destoryed = false
  if dam_amount>0 then destoryed = witem:take_hit_damage(dam_amount,dam_type,self == player) end
  if destoryed then self:destory_worn(witem) end
  return dam_amount,destoryed
end

--吸收伤害
function charactorBase:absorb_hit(dam_t,final_mul,body_part)
  local dam_type = dam_t.type
  if self:is_immune_damage(dam_type) then return 0,0 end
  
  local amount = dam_t.amount
  if amount<=0 then return 0,0 end --0伤害返回
  
  --吸收伤害的护盾cbm，ads？在装备之前减伤
  
  --装备减伤
  local index =1
  local destoryed =false
  while (index <= #self.worn) do
    amount,destoryed = self:armor_absorb(self.worn[index],amount,dam_type,body_part)
    if amount<=0 then break end
    if not destoryed then index = index+1 end --
  end
  
  --肉体的cbm，强化各个部位等的减伤
  --trait 的减增伤
  --武术护甲的减伤
  if amount<=0 then return 0,0 end --0伤害返回
  
  local adjusted_damage = dam_t.amount*dam_t.dam_mul*final_mul
  local pain = adjusted_damage/4 --标准
  --特殊变化
  if dam_type =="bash" then
      self:delay_moves(rnd(0,adjusted_damage/2))--击退行动条，player被击退只有怪物的1/4
  elseif dam_type =="cut" then
    pain = (adjusted_damage +math.sqrt(adjusted_damage))/4
  elseif dam_type == "stab" then
    pain = (adjusted_damage +math.sqrt(adjusted_damage))/4
  elseif dam_type == "acid" then
    pain = adjusted_damage/3
  elseif dam_type == "heat" then
    if rnd(5,100)<adjusted_damage then self:add_effect("on_fire",rnd()+0.5)end
  elseif dam_type == "cold" then  
    pain = adjusted_damage/6   ---减速
    self:delay_moves(adjusted_damage*30)--击退行动条 player比怪物的短
  elseif dam_type == "electric" then
    self:add_effect("zapped",math.max(0.8,rnd(0,adjusted_damage/3)))
  end
  return adjusted_damage,pain
end

--如果不传weapon 表示使用手中的weap
function charactorBase:crit_chance(roll_hit,target_dodge,weapon)
  weapon = weapon or g.itemFactory.fake_fists  --如果没有武器，用假的拳头物品代替
  local unarmed_skill = self.skills:get_skill_level("unarmed")
  local bashing_skill = self.skills:get_skill_level("bashing")
  local cutting_skill = self.skills:get_skill_level("cutting")
  local stabbing_skill = self.skills:get_skill_level("stabbing")
  local melee_skill = self.skills:get_skill_level("melee")
  
  --可能有 cqb生化插件对技能修改
  
  local weapon_crit_chance = 0.5
  if weapon:has_flag("UNARMED_WEAPON") then
    weapon_crit_chance = 0.5 + 0.05 * unarmed_skill
  end
  local weapon_hit = weapon:get_weapon_hit_bonus()
  if weapon_hit>0 then 
    weapon_crit_chance = math.max(weapon_crit_chance,0.5 + 0.1 * weapon_hit)
  else
    weapon_crit_chance = weapon_crit_chance + 0.1 *weapon_hit --减成
  end
  --属性提升暴击
  local stat_crit_chance = 0.25 +0.01*self:cur_dex() +0.02*self:cur_per() 
  
  local best_skill = 0
  if weapon:is_bashing_weapon() and bashing_skill>best_skill then
    best_skill = bashing_skill
  end
  if weapon:is_cutting_weapon() and cutting_skill>best_skill then
    best_skill = cutting_skill
  end
  if weapon:is_stabbing_weapon() and stabbing_skill>best_skill then
    best_skill = stabbing_skill
  end
  if weapon:has_flag("UNARMED_WEAPON") and unarmed_skill > best_skill then
    best_skill = unarmed_skill
  end
  --///\EFFECT_MELEE slightly increases crit chance with any melee weapon
  best_skill = best_skill+ melee_skill/2.5
  local skill_crit_chance = 0.25 + best_skill * 0.025
  
  --以下复制cdda的说明
  --[[
  // Examples (survivor stats/chances of each crit):
    // Fresh (skill-less) 8/8/8/8, unarmed:
    //  50%, 49%, 25%; ~1/16 guaranteed crit + ~1/8 if roll>dodge*1.5
    // Expert (skills 10) 10/10/10/10, unarmed:
    //  100%, 55%, 60%; ~1/3 guaranteed crit + ~4/10 if roll>dodge*1.5
    // Godlike with combat CBM 20/20/20/20, pipe (+1 accuracy):
    //  60%, 100%, 42%; ~1/4 guaranteed crit + ~3/8 if roll>dodge*1.5

    // Note: the formulas below are only valid if none of the 3 crit chance values go above 1.0
    // But that would require >10 skills/+6 to-hit/75 dex, so it's OK to have minor weirdness there
    // Things like crit values dropping a bit instead of rising

    // Chance to get all 3 crits (a guaranteed crit regardless of hit/dodge)
  --]]
  local chance_triple = weapon_crit_chance * stat_crit_chance * skill_crit_chance
  --Only check double crit (one that requries hit/dodge comparison) if we have good hit vs dodge
  if roll_hit > (target_dodge * 1.5) then
    --两相暴击 只算一半的成功率
    local chance_double = (weapon_crit_chance * stat_crit_chance +stat_crit_chance * skill_crit_chance +weapon_crit_chance * skill_crit_chance -3*chance_triple)*0.5-- 
    return chance_triple+chance_double --cdda这里额外减少，怀疑出错
  end
  
  return chance_triple  --
end

--是否正用unarm attack
function charactorBase:unarmed_attack()
  return self.weapon==nil or self.weapon:has_flag("UNARMED_WEAPON")
end

--武器与技能结合提供的hit加成，
function charactorBase:get_weapon_and_skill_hitbonus(weapon)
  weapon = weapon or g.itemFactory.fake_fists  --如果没有武器，用假的拳头物品代替
  local unarmed_skill = self.skills:get_skill_level("unarmed")
  local bashing_skill = self.skills:get_skill_level("bashing")
  local cutting_skill = self.skills:get_skill_level("cutting")
  local stabbing_skill = self.skills:get_skill_level("stabbing")
  local melee_skill = self.skills:get_skill_level("melee")
  --可能有 cqb生化插件对技能修改
  local best_bonus = 0
  if weapon:has_flag("UNARMED_WEAPON")then
    best_bonus = unarmed_skill/2
  end
  if weapon:is_bashing_weapon()then
    best_bonus = math.max(best_bonus,bashing_skill/3)
  end
  if weapon:is_cutting_weapon() then
    best_bonus = math.max(best_bonus,cutting_skill/3)
  end
  if weapon:is_stabbing_weapon()then
    best_bonus = math.max(best_bonus,stabbing_skill/3)
  end
  return melee_skill/2+best_bonus +weapon:get_weapon_hit_bonus()--近战技+类型技+武器自身补正--cdda居然没有武器补正，出错了吗
end


--roll 所有近战伤害
function charactorBase:roll_all_damage(dam_ins,critical,is_average,weapon)
  weapon = weapon or g.itemFactory.fake_fists --不能为空
  self:roll_bash_damage(dam_ins,critical,is_average,weapon)
  self:roll_cut_damage(dam_ins,critical,is_average,weapon)
  self:roll_stab_damage(dam_ins,critical,is_average,weapon)
  
end

--weapon必须有值
function charactorBase:roll_bash_damage(dam_ins,critical,is_average,weapon)
  local unarmed =weapon:has_flag("UNARMED_WEAPON")
  local skill = unarmed and self.skills:get_skill_level("unarmed") or self.skills:get_skill_level("bashing")
  --可能有 cqb生化插件对技能修改
  local stat  = self:cur_str()--力量
  local stat_bonus = (is_average and (rnd()*0.5+0.5) or 0.75) *stat 
  -- 还要加上武术buff的加成
  --醉拳
  
  local bash_dam = weapon:damage_bash() +stat_bonus +(unarmed and skill or 0) --unarm武器受到技能加伤害
  -- // 80%, 88%, 96%, 104%, 112%, 116%, 120%, 124%, 128%, 132% --按此增长的倍乘系数
  local bash_mul = (skill>5) and (0.8 + 0.08 * skill) or (0.96 + 0.04 * skill)
  
  local bash_cap = 2 * stat + 2 * skill --伤害限制
  if bash_dam>bash_cap then 
    bash_mul = bash_mul*(1+bash_cap/bash_dam)/2 --多余伤害减半
  end
  local bash_min = bash_dam *math.min(1,stat/20) --最小伤害 力量为8 则为40%
  bash_dam = is_average and 0.5*(bash_dam+bash_min) or rnd() *(bash_dam-bash_min) +bash_min --随机
  local armor_mult = 1
  --武术buff系数倍率
  if critical then 
    bash_mul = bash_mul*1.5 --暴击1.5倍伤害
    armor_mult = 0.5 --暴击50%穿甲
  end
  dam_ins:add_damage("bash",bash_dam,0,armor_mult,bash_mul)
  --debugmsg("bashdam:"..bash_dam)
end


function charactorBase:roll_cut_damage(dam_ins,critical,is_average,weapon)
  local unarmed =weapon:has_flag("UNARMED_WEAPON")
  local unarmed_skill = self.skills:get_skill_level("unarmed")
  local cutting_skill = self.skills:get_skill_level("cutting")
  --可能有 cqb生化插件对技能修改
  local cut_dam = weapon:damage_cut() 
  if unarmed then
    --各种变异，利爪 ，bio
  end
  
  if cut_dam<=0 then return end
  --这之后加武术buff 固定加成，
  
  local arpen = 0
  local armor_mult = 1
  --// 80%, 88%, 96%, 104%, 112%, 116%, 120%, 124%, 128%, 132%
  local cut_mul = (cutting_skill>5) and (0.8 + 0.08 * cutting_skill) or (0.96 + 0.04 * cutting_skill)
  --武术buff系数加成
  if critical then
    cut_mul = cut_mul*1.25
    arpen = arpen+5
    armor_mult = 0.75    --25%百分比+5固穿，倍率1.25
  end
  dam_ins:add_damage("cut",cut_dam,arpen,armor_mult,cut_mul)--基本没随机，固定的输出
  --debugmsg("cutdam:"..cut_dam)
end

function charactorBase:roll_stab_damage(dam_ins,critical,is_average,weapon)
  local unarmed =weapon:has_flag("UNARMED_WEAPON")
  local unarmed_skill = self.skills:get_skill_level("unarmed")
  local stabbing_skill = self.skills:get_skill_level("stabbing")
  
  local stab_dam = weapon:damage_stab() 
  if unarmed then
    --各种变异，利爪，尖刺 ，bio
  end
  if stab_dam<=0 then return end
  --这之后加武术buff 固定加成，
  local arpen = 0
  local armor_mult = 1
  --// // 66%, 76%, 86%, 96%, 106%, 116%, 122%, 128%, 134%, 140% --起始更低，增长更快
  local stab_mul = (stabbing_skill>5) and (0.66 + 0.1 * stabbing_skill) or (0.86 + 0.06 * stabbing_skill)
  --武术buff系数加成
  if critical then
    stab_mul = stab_mul*(1+0.1*stabbing_skill) --增长恐怖，后期太高惹
    --arpen = arpen+0
    armor_mult = 0.66    --34%破甲
  end
  dam_ins:add_damage("stab",stab_dam,arpen,armor_mult,stab_mul)--基本没随机，固定的输出
end



function charactorBase:miss_attack_animation(destunit,costtime)
  costtime = math.max(0.2,costtime)--不能小于0.2秒，
  local interval_time = 0.2*((math.min(costtime,0.5)-0.2)/0.3)
  local anim_time = math.min(0.6,costtime-interval_time)--动画时常不能超过0.6秒，暂定，太长为完全慢动作？
  local time1 = anim_time*0.33 --一阶段时长
  
  g.playSound("miss",true)--未命中声音
  local dx,dy =  destunit.x -self.x ,destunit.y - self.y
  --来回动画
  self:setAnimation(animManager.createMoveAndBackAnim(self,28*dx,28*dy,anim_time,time1))--setanimation必在addDelay之前，才不会出错
  self:addDelay(costtime)
end

--攻击动画及音效 ,costtime,表示计算出来的参考costtime，返回值是修正后的costtime
--徒手攻击动画,destunit一般一格范围远
function charactorBase:unarmed_attack_animation(destunit,costtime)--hit表示是否命中
  costtime = math.max(0.2,costtime)--不能小于0.2秒，因为伤害生效时间为0.2秒，时间太短动画也没有意义
  local interval_time = 0.2*((math.min(costtime,0.5)-0.2)/0.3)
  local anim_time = math.min(0.6,costtime-interval_time)--动画时常不能超过0.6秒，暂定，太长为完全慢动作？
  local time1 = anim_time*0.33 --一阶段时长
  local delay1 = math.min(0,time1-0.1)--小于0.1无delay
  
  g.playSound("bash1",true) --拳击音效，暂定
  local dx,dy =  destunit.x -self.x ,destunit.y - self.y
  --来回动画
  self:setAnimation(animManager.createMoveAndBackAnim(self,28*dx,28*dy,anim_time,time1))--setanimation必在addDelay之前，才不会出错
  destunit:addFramesAnimEffect("quan_hit",(rnd()-0.5)*(8+12*math.abs(dy))-12*dx,(rnd()-0.5)*(8+12*math.abs(dx))-12*dy,delay1) --详细约束特效起始位置，更好的效果

  --受击动画
  local impact_xishu = 1
  if dx~=0 and dy~=0 then impact_xishu = 0.8 end
  local impact_rnd = (rnd()-0.5)*4 *impact_xishu                             
  destunit:addImpactAnimation(animManager.createImpactAnim(destunit,8*dx*impact_xishu+impact_rnd*dy,8*dy*impact_xishu+4*impact_rnd*dx,time1,0.05,0.15))--delay =time1 ,1阶段=0.05，2阶段=0.15
  self:addDelay(costtime)
end

--目前先搞成一样的
function charactorBase:bashing_attack_animation(destunit,costtime)
  costtime = math.max(0.2,costtime)--不能小于0.2秒，因为伤害生效时间为0.2秒，时间太短动画也没有意义
  local interval_time = 0.2*((math.min(costtime,0.5)-0.2)/0.3)
  local anim_time = math.min(0.6,costtime-interval_time)--动画时常不能超过0.6秒，暂定，太长为完全慢动作？
  local time1 = anim_time*0.33 --一阶段时长
  local delay1 = math.min(0,time1-0.1)--小于0.1无delay
  
  g.playSound("bash_hit",true) --拳击音效，暂定
  local dx,dy =  destunit.x -self.x ,destunit.y - self.y
  --来回动画
  self:setAnimation(animManager.createMoveAndBackAnim(self,28*dx,28*dy,anim_time,time1))--setanimation必在addDelay之前，才不会出错
  destunit:addFramesAnimEffect("bash_hit",(rnd()-0.5)*(8+12*math.abs(dy))-12*dx,(rnd()-0.5)*(8+12*math.abs(dx))-12*dy,delay1) --详细约束特效起始位置，更好的效果

  --受击动画
  local impact_xishu = 1
  if dx~=0 and dy~=0 then impact_xishu = 0.8 end
  local impact_rnd = (rnd()-0.5)*4 *impact_xishu                             
  destunit:addImpactAnimation(animManager.createImpactAnim(destunit,8*dx*impact_xishu+impact_rnd*dy,8*dy*impact_xishu+4*impact_rnd*dx,time1,0.05,0.15))--delay =time1 ,1阶段=0.05，2阶段=0.15
  self:addDelay(costtime)
end


function charactorBase:cutting_attack_animation(destunit,costtime)
  costtime = math.max(0.2,costtime)--不能小于0.2秒，因为伤害生效时间为0.2秒，时间太短动画也没有意义
  local interval_time = 0.2*((math.min(costtime,0.5)-0.2)/0.3)
  local anim_time = math.min(0.6,costtime-interval_time)--动画时常不能超过0.6秒，暂定，太长为完全慢动作？
  local time1 = anim_time*0.33 --一阶段时长
  local delay1 = math.min(0,time1-0.1)--小于0.1无delay
  
  g.playSound("cut_hit1",true) --拳击音效，暂定
  local dx,dy =  destunit.x -self.x ,destunit.y - self.y
  --来回动画
  self:setAnimation(animManager.createMoveAndBackAnim(self,28*dx,28*dy,anim_time,time1))--setanimation必在addDelay之前，才不会出错
  destunit:addFramesAnimEffect("cut_hit",(rnd()-0.5)*(8+12*math.abs(dy))-12*dx,(rnd()-0.5)*(8+12*math.abs(dx))-12*dy,delay1) --详细约束特效起始位置，更好的效果

  --受击动画
  local impact_xishu = 1
  if dx~=0 and dy~=0 then impact_xishu = 0.8 end
  local impact_rnd = (rnd()-0.5)*4 *impact_xishu                             
  destunit:addImpactAnimation(animManager.createImpactAnim(destunit,8*dx*impact_xishu+impact_rnd*dy,8*dy*impact_xishu+4*impact_rnd*dx,time1,0.05,0.15))--delay =time1 ,1阶段=0.05，2阶段=0.15
  self:addDelay(costtime)
end


function charactorBase:stabbing_attack_animation(destunit,costtime)
  costtime = math.max(0.2,costtime)--不能小于0.2秒，因为伤害生效时间为0.2秒，时间太短动画也没有意义
  local interval_time = 0.2*((math.min(costtime,0.5)-0.2)/0.3)
  local anim_time = math.min(0.6,costtime-interval_time)--动画时常不能超过0.6秒，暂定，太长为完全慢动作？
  local time1 = anim_time*0.33 --一阶段时长
  local delay1 = math.min(0,time1-0.1)--小于0.1无delay
  
  g.playSound("stab_hit1",true) --拳击音效，暂定
  local dx,dy =  destunit.x -self.x ,destunit.y - self.y
  --来回动画
  self:setAnimation(animManager.createMoveAndBackAnim(self,28*dx,28*dy,anim_time,time1))--setanimation必在addDelay之前，才不会出错
  destunit:addFramesAnimEffect("stab_hit",(rnd()-0.5)*(8+12*math.abs(dy))-12*dx,(rnd()-0.5)*(8+12*math.abs(dx))-12*dy,delay1) --详细约束特效起始位置，更好的效果

  --受击动画
  local impact_xishu = 1
  if dx~=0 and dy~=0 then impact_xishu = 0.8 end
  local impact_rnd = (rnd()-0.5)*4 *impact_xishu                             
  destunit:addImpactAnimation(animManager.createImpactAnim(destunit,8*dx*impact_xishu+impact_rnd*dy,8*dy*impact_xishu+4*impact_rnd*dx,time1,0.05,0.15))--delay =time1 ,1阶段=0.05，2阶段=0.15
  self:addDelay(costtime)
end


function charactorBase:attack_speed(weapon,is_average)
  weapon =weapon or g.itemFactory.fake_fists --不能为空
  local base_move_cost = weapon:attack_movepoint()/2
  local melee_skill = self.skills:get_skill_level("melee")
  local skill_cost = base_move_cost/(1+math.pow(melee_skill,3)/400)
  local stat_cost = is_average and self:cur_dex()/2 or rnd(0,self:cur_dex())
  local encumbrance_penalty = 10* self:get_bodypart_encumberance("bp_torso") +5* self:get_bodypart_encumberance("bp_arm_l")+5* self:get_bodypart_encumberance("bp_arm_r")
  
  local movecost = math.max(base_move_cost +skill_cost - stat_cost +encumbrance_penalty,20)
  --其他trait的影响
  local realTime = 1.8*movecost/self:get_speed() /c.timeSpeed --0体积0重量 无加成 average时间为 0.5左右
  debugmsg("player attack costtime:"..realTime.." basetime:"..base_move_cost*2)
  return realTime
end


function charactorBase:melee_practice(is_hit,unarmed,bashing,cutting,stabbing,dodgelevel,denfence_level)
  
  local min,max = 2,3
  if (is_hit)  then
    max,min = 5,10
    self.skills:train("melee",rnd(5,10),dodgelevel-2)--0级最多升到2级
  else
    self.skills:train("melee",rnd(2,5),dodgelevel-2)--0级最多升到2级
  end
  --cdda居然有技能循序 
  if unarmed then self.skills:train("unarmed",rnd(min,max),denfence_level-2) end
  if bashing then self.skills:train("bashing",rnd(min,max),denfence_level-2) end
  if cutting then self.skills:train("cutting",rnd(min,max),denfence_level-2) end
  if stabbing then self.skills:train("stabbing",rnd(min,max),denfence_level-2) end
  
end

--输出伤害信息（基本）
local player_stab = {tl("你刺穿%s","You impale %s"),tl("你剜%s","You gouge %s"),tl("你贯穿%s","You run %s through"),
                     tl("你捅刺%s","You puncture %s"),tl("你刺击%s","You pierce %s"),tl("你戳中%s","You poke %s"), }
local npc_stab = {tl("%s刺穿%s","%s impales %s"),tl("%s剜%s","%s gouges %s"),tl("%s贯穿%s","%s runs %s through"),
                     tl("%s捅刺%s","%s punctures %s"),tl("%s刺击%s","%s pierces %s"),tl("%s戳中%s","%s pokes %s"), }
                   
local player_cut = {tl("你剖戮%s","You gut %s"),tl("你狠狠削中%s","You chop %s"),tl("你猛斩%s","You slash %s"),
                    tl("你横段斩%s","You mutilate %s"),tl("你重砍%s","You maim %s"),tl("你刺砍%s","You stab %s"),
                    tl("你切击%s","You slice %s"),tl("你砍中%s","You cut %s"),tl("你凿中%s","You nick %s"), }
local npc_cut = {tl("%s剖戮%s","%s guts %s"),tl("%s狠狠削中%s","%s chops %s"),tl("%s猛斩%s","%s slashes %s"),
                    tl("%s横段斩%s","%s mutilates %s"),tl("%s重砍%s","%s maims %s"),tl("%s刺砍%s","%s stabs %s"),
                    tl("%s切击%s","%s slices %s"),tl("%s砍中%s","%s cuts %s"),tl("%s凿中%s","%s nicks %s"), }
                  
local player_bash = {tl("你狠揍%s","You clobber %s"),tl("你一记重击%s","You smash %s"),tl("你痛击%s","You thrash %s"),
                     tl("你猛击%s","You batter %s"),tl("你敲打%s","You whack %s"),tl("你击中%s","You hit %s"), }
local npc_bash = {tl("%s狠揍%s","%s clobbers %s"),tl("%s一记重击%s","%s smashes %s"),tl("%s痛击%s","%s thrashes %s"),
                     tl("%s猛击%s","%s batters %s"),tl("%s敲打%s","%s whacks %s"),tl("%s击中%s","%s hits %s"), }

function charactorBase:hit_message(dealt_dam,critical,target)
  local is_player = self:is_player()
  local message_array
  local cut_message = false
  if dealt_dam.bash>(dealt_dam.cut+dealt_dam.stab) then
    message_array = is_player and player_bash or npc_bash
  elseif dealt_dam.cut>=dealt_dam.stab then
    message_array = is_player and player_cut or npc_cut
    cut_message = true
  else
    message_array = is_player and player_stab or npc_stab
  end
  local index=0
  if dealt_dam.total>30 then
    index = cut_message and rnd(1,5) or rnd(1,3)
  elseif dealt_dam.total>20 then
    index = cut_message and rnd(6,7) or 4
  elseif dealt_dam.total>10 then
    index = cut_message and 8 or 5
  else
    index = cut_message and 9 or 6
  end
  local message = message_array[index]
  if is_player then
    message = string.format(message,target:getName())
  else
    message = string.format(message,self:getName(),target:getName())--npc
  end
  local int_dam=math.floor(dealt_dam.total+0.5)--四舍五入
  if int_dam<=0 then
    if is_player then
      message = message..tl("但是没有造成什么伤害。"," but do no damage.")
    else
      message = message..tl("但是没有造成什么伤害。"," but does no damage.")
    end
  elseif critical then
    message = message..string.format(tl("造成%d点伤害。暴击！"," for %d damage. Critical!"),int_dam)
  else
    message = message..string.format(tl("造成%d点伤害。"," for %d damage."),int_dam)
  end
  addmsg(message,is_player and "info" or "npc")
end