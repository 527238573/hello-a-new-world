local player_mt = g.player_mt
local gmap= g.map
local animManager = g.animManager


--检测武器射击等等
--返回true 没问体，返回false中断调用的动作，  select_ammo 表示是否打开新窗口选择子弹
function player_mt:check_gun(select_ammo)
  local gun = self.weapon
  if gun==nil then
    addmsg(tl("你没有装备任何武器。", "You're not wielding anything." ))
    return false
  end
  if not gun:is_gun() then
    addmsg(string.format( tl("你不能用%s来射击！", "You can't shoot with a %s!." ),gun:getNormalName()),"info")
    return false
  end
  if not self:can_use(gun,true) then return end
  if gun:has_flag("RELOAD_AND_SHOOT") then
    --检测背包里的弹药，默认为1单发
    
    --检测默认弹药的数量
    if gun.default_ammo then
      local num_of_default_ammo = self.inventory:get_item_number(gun.default_ammo)
      if num_of_default_ammo>=1 then 
        return true 
      end
    end
    --所有可用弹药的数量
    local ammoList= {}
    local playeritemlist = self.inventory.items --直接操作items
    for i=1,#playeritemlist do
      if gun:can_use_ammo(playeritemlist[i]) then 
      table.insert(ammoList,playeritemlist[i])
      end
    end
    
    if #ammoList ==0 then
      addmsg(tl("没有可用的弹药！", "Out of ammo!" ),"warning");
      return false
    elseif #ammoList ==1 then --只可用一种
      gun.default_ammo = ammoList[1].type.id --默认弹药设为此种
      return true --没问题
    else--大于1种
      if select_ammo then
        --挑选弹药
        local function set_default_ammo(ammo) --挑选后的函数
          if ammo then gun.default_ammo = ammo.type.id end
        end
        ui.chooseItemWin:Open(tl("选择弹药","Select Ammo"),ammoList,set_default_ammo)
      else
        addmsg(tl("需要更换弹药种类。", "Need to replace ammunition types." ),"warning");
      end
      return false
    end
  else
    --枪里剩余弹药必须够
    if gun:get_ammo_number()< gun:get_ammo_required() then
      if gun:get_ammo_number()==0 then
        addmsg(tl("你需要重新装填！", "You need to reload!" ),"warning")
      else
        addmsg(string.format( tl("你的%s至少需要%i点能量才能射击。", "Your %s needs %d charges to fire!" ),gun:getNormalName(),gun:get_ammo_required()),"warning")
      end
      return false
    end
  end
  --一切妥当，随时射击
  return true
end




function player_mt:fastShotAction()
  
  --先检测手中武器
  if not self:check_gun(true) then return end
  
  local closestUnit,range = nil,15--15码内的目标
  local closetNeutrality,neu_range = nil,15 --中立的目标，次级优先目标
  
  local monsterList = g.monster.getList()
  for _,mon in ipairs(monsterList) do
    if not self:isFriendly(mon) then--非友好的都是可攻击目标
      local cur_range = c.dist_3d(self.x,self.y,self.z,mon.x,mon.y,mon.z) 
      
      if player:isHostile(mon) then
        if cur_range<range and self:seesUnit(mon) then --see最复杂，所以作为最后的条件
          closestUnit = mon;range= cur_range 
        end
      else
        if cur_range<neu_range and self:seesUnit(mon) then --see最复杂，所以作为最后的条件
          closetNeutrality = mon;neu_range= cur_range 
        end
      end
    end
  end
  closestUnit = closestUnit or closetNeutrality  --优先敌对目标，次级目标
  
  
  --待添加npc遍历
  
  if closestUnit then
    --快速射击该目标
    self:fire_gun(closestUnit,self.weapon)
    self.burst_shot = self.weapon:get_burst_size();--获得burst次数
    self.burst_shot = self.burst_shot-1;--已经射击过一次
    self.last_shot = {unit =closestUnit,x=closestUnit.x,y=closestUnit.y,z =closestUnit.z}--记录这次射击
    
  else
    addmsg(tl("你找不到目标。","You cant find a target."))
  end
  
end
--最小连射中
function player_mt:needBurst()
  local ret=  self.burst_shot>0
  if not ret then self.last_shot  = nil end --只要松开F键就会进入检查，不再连射时会清除目标
  return ret
end



--快速burst射击，只在持续射击时使用
function player_mt:fastBurstShotAction()
  self.burst_shot = self.burst_shot -1 --每次尝试都减少次数
  if self.last_shot ==nil then return end -- 没有上次射击
  
  --非burst武器不能使用此功能，不能显示任何信息
  local gun = self.weapon
  if gun==nil or not gun:is_gun() then return end
  if self.weapon:get_gun_mode()~= "burst"  and  self.burst_shot<0  then return end --非burst模式不能用按住F键连发
  if not self:check_gun(false) then return end --再检查基础发射
  
  local last_unit = self.last_shot.unit
  if last_unit and not last_unit:is_dead_state() and self:seesUnit(last_unit) then
    self.last_shot.x = last_unit.x
    self.last_shot.y = last_unit.y
    self.last_shot.z = last_unit.z
    self:fire_gun(last_unit,self.weapon) --继续射击上次的单位，并保存射击位置
  else
    self.last_shot.unit = nil  --没有单位可射击，射击地面
    self:fire_gun(nil,self.weapon,self.last_shot.x,self.last_shot.y,self.last_shot.z)--射击地面，上次射击的地面
  end
  
end


--打开瞄准模式
function player_mt:openAimWinAction()
  --先检测手中武器
  if not self:check_gun(true) then return end--与快速射击同理
  ui.aimWin:Open()
end
