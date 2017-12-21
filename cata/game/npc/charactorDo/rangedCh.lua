local charactorBase = g.creature.charactorBase
local animManager = g.animManager





function charactorBase:fire_gun(destunit,weapon,dest_x,dest_y,dest_z)
  if destunit then dest_x,dest_y,dest_z = destunit.x,destunit.y,destunit.z end --当destunit存在时，后面的参数无意义，当为nil时才有意义
  
  --所有检查都做过了，现在不再检查
  
  --取得子弹,可能有更多种情况
  local ammo
  if weapon:has_flag("RELOAD_AND_SHOOT") then
    --从背包里取得
    debugmsg("isplayer?".. ((self==player)and "yes" or "no"))
    ammo = self.inventory:slice_one_ammo(weapon.default_ammo) -- 
  else
    ammo = weapon:slice_oneShot_ammo() --这里ammo作为类型参考值，不是切割出来的新物品。仅共读取信息用。
  end
  if ammo==nil then debugmsg("internal error: fire_gun cant find ammo");return end --没有无限子弹的枪
  
  
  --计算散布，根据技能
  local skill_weapon_id = weapon:get_gun_skill()--武器技能的id
  local skill_weapon = self.skills:get_skill_level(skill_weapon_id) --武器技能等级
  local skill_gun = self.skills:get_skill_level("gun") --射击技能等级
  local player_dispersion = 0
  if skill_weapon<10 then player_dispersion = player_dispersion+ 45*(10-skill_weapon) end --weapon技能等级的减成
  if skill_gun<10 then player_dispersion = player_dispersion+ 15*(10-skill_gun) end --gun技能的减成
  if skill_weapon_id == "archery" then player_dispersion = player_dispersion+135 end
  if skill_weapon_id == "throw" then player_dispersion = player_dispersion+195 end  --武器种类的先天散布减成
  
  local weapon_dispersion =  weapon:gun_dispersion(ammo)
  --训练技能的门槛
  local train_skill = weapon_dispersion <player_dispersion+15*rnd(0,self:cur_per()) --为true则训练技能
  if train_skill then
    self.skills:train(skill_weapon_id,rnd(1,8),skill_weapon-3) 
    self.skills:train("gun",rnd(1,3),skill_gun-3) 
  elseif one_in(30) then
    self:add_msg_if_player(tl("你的远程武器所能提供的枪法等级已达上限，你需要一把更精准的远程武器来继续提高你的枪法。","You'll need a more accurate gun to keep improving your aim."));
  end
  
  --计算散布，后可能移动到其他地方
  local dispersion = self:get_weapon_dispersion(weapon,ammo,true)
  debugmsg("random dispersion:"..dispersion)
  
  --枪本身的损伤：卡壳等
  
  
  --单发的子弹
  local projectile = g.create_projectile()
  --设置子弹的各项属性
  projectile:set_animation(weapon:get_projectile_anim_name(ammo))--子弹飞行动画
  
  local defalut_speed = weapon:has_flag("RELOAD_AND_SHOOT") and 600 or 1000
  projectile.speed = ammo.type.ammo_speed or defalut_speed
  projectile.accurateness = ammo.type.ammo_accurateness or defalut_speed  
  projectile.shot_dispersion = dispersion
  projectile.dam_ins = weapon:get_gun_damage(ammo)
  projectile.max_range = weapon:get_gun_range(ammo)
  projectile.ammo = ammo--记录弹药？仅在shotend处播放声音？待修改
  projectile:set_drop(ammo) --可能的掉落
  
  --设置子弹的 特效，掉落，爆炸等等
  projectile:attack(self,self.x,self.y,self.z,destunit,dest_x,dest_y,dest_z)
  
  --弹射弹壳，本作取消了这种物品所以没有
  
  --后坐力
  --声音
  g.playSound(weapon:get_fire_sound(),true)--reload声音
  
  --射击间隔，需考虑技能--todo
  self:addDelay(weapon:get_shot_inverval())
  self:fire_change_face(dest_x,dest_y)
end
--random是否随机还是取 均值
function charactorBase:get_weapon_dispersion(weapon,ammo,random)
  --使用这个而不是总随机是为了改进随机分布
  local function random_or_max(val)
    if random then return val*rnd() else return val end
  end
  
  local dispersion  = 0
  local skill_weapon_id = weapon:get_gun_skill()--武器技能的id
  local skill_weapon = self.skills:get_skill_level(skill_weapon_id) --武器技能等级
  local skill_gun = self.skills:get_skill_level("gun") --射击技能等级
  local player_dispersion = 0
  if skill_weapon<10 then player_dispersion = player_dispersion+ 45*(10-skill_weapon) end --weapon技能等级的减成
  if skill_gun<10 then player_dispersion = player_dispersion+ 15*(10-skill_gun) end --gun技能的减成
  if skill_weapon_id == "archery" then player_dispersion = player_dispersion+135 end
  if skill_weapon_id == "throw" then player_dispersion = player_dispersion+195 end  --武器种类的先天散布减成
  
  dispersion = dispersion + random_or_max( player_dispersion)
  --todo 驾驶的影响
  dispersion =   dispersion +random_or_max(math.max((12 - self:cur_dex())*15,0))--属性的影响
  dispersion =   dispersion +random_or_max(math.max((12 - self:cur_per())*15,0))
  dispersion = dispersion + random_or_max(self:get_bodypart_encumberance("bp_eyes")*6) --累赘的影响
  dispersion = dispersion + random_or_max(self:get_bodypart_encumberance("bp_arm_l")*3 +self:get_bodypart_encumberance("bp_arm_r")*3)
  
  dispersion  = dispersion+ random_or_max(weapon.type.dispersion+weapon.damage*60)
  if ammo then
    dispersion = dispersion + random_or_max(ammo.type.dispersion) --子弹散布
  end
  --todo 后坐力 recoil +driving_recoil
  
  
  --倍数增减，bionic 和水下妨碍?
  return dispersion
end
  
