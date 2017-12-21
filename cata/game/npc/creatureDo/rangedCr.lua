--远程攻击相关
local creatureBase = g.creature.creatureBase



--静态文字
local goodhit_message = {tl("爆头！","Headshot!"),tl("暴击！","Critical!"),tl("正中目标！","Good hit!"),tl("偏斜。","Grazing hit.")}

--会返回是否命中
function creatureBase:deal_projectile_attack(projectile,missed_by)
  if missed_by>=1 then return end --完全没命中，无信息显示，理论上，不会在此处运行
  local avoid_roll = self:dodge_roll()
  local diff_roll = dice(10,projectile.accurateness)
  local goodhit = missed_by+avoid_roll/diff_roll
  
  if goodhit >=1 then
    debugmsg("completely dodge goodhit:"..goodhit)
    --完全没命中
    if not self:is_monster() then
      if projectile.source_unit and player:seesUnit(projectile.source_unit) then
        self:add_msg_if_player(string.format(tl("你躲开了%s的远程攻击！","You avoid %s projectile!"),projectile.source_unit:getName()),"fight")
        self:add_msg_if_npc(string.format(tl("%s躲开了%s的远程攻击！","%s avoids %s projectile."),self:getName(),projectile.source_unit:getName()),"npc")
      else
        self:add_msg_if_player(tl("你躲开了飞来的远程攻击!","You avoid an incoming projectile!"),"fight")
        self:add_msg_if_npc(string.format(tl("%s躲开了飞来的远程攻击！","%s avoids an incoming projectile."),self:getName()),"npc")
      end
    end
    return
  end
  --命中，确定，命中部位
  local body_part = "bp_torso"
  if missed_by+rnd_float(-0.5, 0.5)<0.4 then
    body_part = "bp_torso"
  elseif one_in(4) then
    if one_in(2) then
      body_part = "bp_leg_l"
    else
      body_part = "bp_leg_r"
    end
  else
    if one_in(2) then
      body_part = "bp_arm_l"
    else
      body_part = "bp_arm_r"
    end
  end
  local message = ""
  local damage_mult = projectile.dam_mul --伤害修正
  if goodhit<0.1 then --爆头
    message = goodhit_message[1]
    damage_mult = damage_mult*rnd_float(2.45, 3.35)
    body_part = "bp_head"
  elseif  goodhit<0.2 then --暴击
    message = goodhit_message[2]
    damage_mult = damage_mult*rnd_float(1.75, 2.3)
  elseif  goodhit<0.4 then --正中
    message = goodhit_message[3]
    damage_mult = damage_mult*rnd_float(1, 1.5)
  elseif  goodhit<0.6 then --普通
    damage_mult = damage_mult*rnd_float(0.5, 1)
  elseif  goodhit<0.8 then --擦过
    message = goodhit_message[4]
    damage_mult = damage_mult*rnd_float(0, 0.3)
  else --无效
    damage_mult = 0
  end
  local dealt_dam
  --debugmsg("std2 dam:"..projectile.dam_ins:total_dam())
  debugmsg("dealt range attack missed_by"..missed_by.." dealt mul:"..damage_mult)
  if damage_mult>0 then --有伤害就deal
    dealt_dam = self:deal_damage(projectile.source_unit, body_part, projectile.dam_ins,damage_mult);
    --debugmsg("dealted!!!!!!!:")
    --子弹特效！！点火，击晕等等
  end
  --打印信息,
  local source = projectile.source_unit
  if player:seesUnit(self) then
    if damage_mult ==0 then
      if source then 
        if source ==player then
          addmsg(tl("你没打中！","You miss!"),"fight")
        elseif player:seesUnit(source) then
          addmsg(string.format(tl("%s的射击没有击中！","%s shot misses!"),source:getName()),"fight")
        end
      end
    elseif dealt_dam.total<=0 then
      if self:is_monster() then
        addmsg(string.format(tl("射击被%s%s弹开了！","The shot reflects off %s %s!"),self:getName(),self:skin_name()),"fight")
      elseif self:is_player() then
        addmsg(string.format(tl("射击被你的%s弹开了！","The shot reflects off your %s!"),self:body_part_name(body_part)),"fight")
      else
        addmsg(string.format(tl("射击被%s%s弹开了！","The shot reflects off %s %s!"),self:getName(),self:body_part_name(body_part)),"fight")
      end
    elseif self:is_player() then
      addmsg(string.format(tl("你的%s被射中了，受到%d点伤害。","You were hit in the %s for %d damage."),self:body_part_name(body_part),math.floor(dealt_dam.total+0.5)),"fight")
    elseif source==player then
      addmsg(message..string.format(tl("你击中%s，造成%d点伤害。","You hit %s for %d damage."),self:getName(),math.floor(dealt_dam.total+0.5)),"fight")
    elseif source~=nil and player:seesUnit(source) then
      addmsg(string.format(tl("%s射击%s。","%s shoots %s."),source:getName(),self:getName()),"fight")
    end
  end
  --todo 血液溅射
  return dealt_dam
end


function creatureBase:fire_change_face(tx,ty)
  local dx,dy = tx -self.x,ty-self.y
  if dx ==0 and dy==0 then return end
  if dx>=0 and dy>0 then
    self.face = 3
  elseif dx<0 and dy>=0 then
    self.face = 1
  elseif dx<=0 and dy<0 then
    self.face = 7
  elseif dx>0  and dy<=0 then
    self.face = 5 
  end
  
end

