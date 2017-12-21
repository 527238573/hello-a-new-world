local item_mt = g.itemFactory.item_mt
--gun -default_ammo 变量为默认弹药类型，也就是装载过弹药后，会将此项设置，下次不用从多种弹药中选择而是直接选择此种弹药 

--输入物品进行reload，reload到最大值， ammo的数量会变化，减少或变为0需要托管方进行处理   返回true为ammo 整个被拿走了，返回false仍然可能变为0
function item_mt:reload_ammo(ammo)
  if self.magazine~=nil then
    if self.magazine.type ==ammo.type then
      local max = self:get_magazine_size()- self.magazine.stack_num --能装载的数量
      if max <=0 then return false end --不能装更多，满了
      local load_num = math.min(max,ammo.stack_num)
      self.magazine.stack_num = self.magazine.stack_num+load_num --可能还没达到最大
      ammo.stack_num = ammo.stack_num-load_num --可能降为0
    else
      debugmsg("error:different reload ammo item type") --当前子弹类型不一致，需要清空弹匣才能更换新的
    end
  else
    local max = self:get_magazine_size() ----能装载的数量
    if ammo.stack_num> max then
      self.magazine = ammo:slice(max)--切割数量
      self.default_ammo = ammo.type.id --装载后默认弹药设为此项
    else
      self.default_ammo = ammo.type.id --装载后默认弹药设为此项 
      self.magazine = ammo
      return true --ammo 整个被拿走
    end
  end
  return false
end

--检测物品是否是能装载的ammo
function item_mt:can_use_ammo(ammo)
  if self.magazine~=nil then --已经装载时，只能用相同类型的ammo
   return self.magazine.type ==ammo.type 
  else
    if ammo.type.item_type == "ammo" and ammo.type.ammotype == self.type.ammotype and ammo.type.ammotype ~=nil then --子弹类型，且口径一致,不能为空，防出错
      return true
    end
    return false 
  end
end

--todo:根据人物技能可变的时间
function item_mt:reload_time(owner)
  return self.type.reload_time
  
end

function item_mt:reload_sound()
  return self.type.reload_sound 
  
end

function item_mt:get_gun_skill()
  return self.type.skill_used
  
end


--当前子弹数量
function item_mt:get_ammo_number()
  if self.magazine~=nil then
    return self.magazine.stack_num  --一组物品的数量
  else
    return 0
  end
  
end

--单次发射需要的弹药，大部分是1，少量比如能量耗电的
function item_mt:get_ammo_required()
  return 1 --等以后种类多了再改
end
function item_mt:slice_oneShot_ammo()
  local oneShot_num = self:get_ammo_required()
  if self.magazine.stack_num> oneShot_num then
    return self.magazine:slice(oneShot_num)
  elseif self.magazine.stack_num==oneShot_num then
    local ret = self.magazine
    self.magazine = nil
    return ret
  end
  --一般不会出现返回nil的情况
end


--弹匣总量，可能后续会有改造变化
function item_mt:get_magazine_size()
  return self.type.magazine_size
  
end

function item_mt:is_gun()
  return self.type.item_type =="gun"
end

function item_mt:can_reload(interact)
  if self.type.item_type ~="gun" then
    if interact then addmsg(string.format( tl("你不能重新装填%s！", "You can't reload a %s!." ),self:getNormalName()),"info") end
    return false
  end
  
  if self:has_flag("RELOAD_AND_SHOOT") or self.type.magazine_size<=0 then
    if interact then addmsg(string.format( tl("%s不需要手动装填，装填和开火一步到位。","The %s does not need to be reloaded, it reloads and fires in a single motion." ),self:getNormalName()),"info") end
    return false
  end
  return true
end


function item_mt:get_projectile_anim_name(ammo)
  if ammo and ammo.type.bullet_anim then return ammo.type.bullet_anim end--子弹有动画用子弹的
  return self.type.bullet_anim
end


function item_mt:gun_dispersion(ammo)
  local dispersion_sum = 0
  dispersion_sum  = dispersion_sum+ self.type.dispersion
  dispersion_sum = dispersion_sum+ self.damage*60 --武器损坏的影响
  if ammo then
    dispersion_sum = dispersion_sum + ammo.type.dispersion --子弹散布
  end
  return math.max(dispersion_sum,0)--最小值：0
end

function item_mt:get_gun_damage(ammo)
  local damage = self.type.damage
  local pierce = self.type.pierce
  if ammo then 
    damage = damage + ammo.type.damage 
    pierce = pierce + ammo.type.pierce 
  end
  damage = damage - self.damage*2 --损伤减成
  local dam_ins = g.create_damage_instance()
  --debugmsg("std damage:"..damage)
  dam_ins:add_damage("cut",math.max(0,damage),math.max(0,pierce))
  return dam_ins
end

function item_mt:get_gun_range(ammo)
  local ret = self.type.range
  if ammo then 
    ret = ret + ammo.type.range
  elseif self.magazine then
    ret = ret + self.magazine.type.range --默认使用弹匣内的弹药
  elseif self.default_ammo then
    ret = ret +data.itemTypes[self.default_ammo].range --RELOAD_AND_SHOOT 要加上默认弹药的射程
  end
  
  return math.max(1,ret) --射程总不能小于1吧
end
function item_mt:get_fire_sound()
  --射击音效
  return self.type.fire_sound
end

function item_mt:get_shot_inverval()
  --射击间隔
  local mode = self:get_gun_mode()
  if mode == "semi_auto" then
    return self.type.semi_auto_shot
  else
    return self.type.burst_shot--其他采用连射时间
  end
end


--返回burst_size，最小连射弹数,只有连射模式下才有效
function item_mt:get_burst_size()
  if self:get_gun_mode() == "burst" then
    return self.type.burst_size
  end
  return 0
end

--单发 or 连射 or 其他（3点射？）
function item_mt:get_gun_mode()
  if self.type.burst  then return "burst" end
  
  
  if self.gun_mode ==nil then
    --初始化
    if not self:has_flag("BURST_ONLY") then 
      self.gun_mode = "semi_auto"
    elseif self.type.burst  then
      self.gun_mode = "burst" --自动射击
    end
    --其他情况为nil，出错
  end
  return self.gun_mode --nil就为单发半自动的标准模式
end
--是否拥有多个gun mode
function item_mt:can_change_gun_mode()
  local num = 0
  if not self:has_flag("BURST_ONLY") then num=num+1 end --自动模式
  if self.type.burst then num=num+1 end --
  return num>1 --多种模式
end
function item_mt:change_gun_mode()
  local modes={}
  if not self:has_flag("BURST_ONLY") then modes[#modes+1] = "semi_auto" end --半自动
  if self.type.burst then modes[#modes+1] = "burst" end --自动
  --还有其他等
  for i=1,#modes do
    if self.gun_mode==modes[i] then
      self.gun_mode =modes[i+1]
      break
    end
  end
  if self.gun_mode==nil then self.gun_mode=modes[1] end
  --注意出错的设定仍然可能为nil
end
--获取射击模式的文字描述
function item_mt:get_gun_mode_text(mode)
  if mode == "semi_auto" then
    if self:has_flag("RELOAD_AND_SHOOT") then
      return tl("手动","manual")
    else
      return tl("半自动","semi-auto")
    end
  elseif mode =="burst" then
    return tl("自动","auto")
  end
  return "未知bug_gun_mode"
end



