local creatureBase = g.creature.creatureBase
local gmap = g.map
--传入creature单位
function creatureBase:seesUnit(unit)
  if self == unit then return true end
  --player 感应 地听 等
  
  
  --local wanted_range= c.dist_3d(self.x,self.y,self.z,unit.x,unit.y,unit.z)
  --if wanted_range<2 then return true end --眼前可移动的就可见
  
  -- 其他特殊的不可见，入地 夜盲 潜水等
  
  --if unit ==player then --只有眼尖的怪能这么观察
  --  local wanted_range= c.dist_3d(self.x,self.y,self.z,unit.x,unit.y,unit.z)
  --  return wanted_range <60 and gmap.zLevelCache.canPlayerSees(self.x,self.y,self.z)
  --end
  
  return self:seesXYZ(unit.x,unit.y,unit.z)
end

--检测某地能否看见
function creatureBase:seesXYZ(x,y,z)
  
  --todo  需要计算环境光和视野等，现在为默认，等光照系统做出后在加
  local range = 60
  local wanted_range= c.dist_3d(self.x,self.y,self.z,x,y,z)
  
  if wanted_range>range then return false end
  if self ==player then
    return gmap.zLevelCache.canPlayerSees(x,y,z)
  else
    return gmap.canSee(self.x,self.y,self.z,x,y,z,range)
    --return true
  end
  
end


function creatureBase:getName()
  return "CreatureBaseName"
end
function creatureBase:get_size()
  return 3 --MEDIUM默认
end

function creatureBase:mod_pain(npain)
  self.base.pain = math.max(0,self.base.pain +npain)
end

--推迟行动条
function creatureBase:delay_moves(move_points)
  self.delay = self.delay + move_points/100/c.timeSpeed
end

--信息
function creatureBase:add_msg_if_player(msgs,rate)
  if self ==player then msg.addmsg(msgs,rate) end--
end

function creatureBase:add_msg_if_npc(msgs,rate)
end

function creatureBase:is_player()
  return self == player
end

function creatureBase:is_npc()
  return false
end
function creatureBase:is_monster()
  return false
end

function creatureBase:skin_name()
  return tl("护甲","armor")
end

function creatureBase:made_of(material)
  return "flesh" == material --npc player都是flesh
end

local body_part_list = 
{
  bp_eyes = tl("眼睛","eyes"),
  bp_mouth = tl("嘴巴","mouth"),
  bp_head = tl("头部","head"),
  bp_torso = tl("躯干","torso"),
  bp_arm_l = tl("左臂","left arm"),
  bp_arm_r = tl("右臂","right arm"),
  bp_leg_l = tl("左腿","left leg"),
  bp_leg_r = tl("右腿","right leg"),
  bp_hand_l = tl("左手","left hand"),
  bp_hand_r = tl("右手","right hand"),
  bp_foot_l = tl("左脚","left foot"),
  bp_foot_r = tl("右脚","right foot"),
}


function creatureBase:body_part_name(body_part)
  return body_part_list[body_part] or tl("附加部位","appendix")
end

local common_bodypart = {"bp_eyes","bp_mouth","bp_head","bp_torso","bp_arm_l","bp_arm_r","bp_hand_l","bp_hand_r","bp_leg_l","bp_leg_r","bp_foot_l","bp_foot_r"}
function creatureBase:get_bodypart_list() --取得当前的bodypart，可能会有新增的部位，现在还没有这功能
  return common_bodypart
end


--是否友好的  ,友好的单位 不能攻击
function creatureBase:isFriendly(unit)
  unit = unit or player -- 默认为玩家自己
  if unit == self then return true end --自己对自己是true
  --以下关系暂定，需要更多的机制补全。
  if self ==player then return false end --主角对其他人是敌对
  if unit ==player then return false end --其他怪对主角是敌对
  return true --怪之间是友善，
end
--需要去攻击的对象,(会主动攻击，既不是Friendly 也不是Hostile是中立可攻击对象)
function creatureBase:isHostile(unit)
  unit = unit or player -- 默认为玩家自己
  if unit == self then return false end --自己对自己是true
  --以下关系暂定，需要更多的机制补全。
  if self ==player then return true end --主角对其他人是敌对
  if unit ==player then return true end --其他怪对主角是敌对
  return false --怪之间是友善，
end

--能交换位置（对友方来说）--交换位置会有额外动态
function creatureBase:canReplace()
  if self ==player then return false end --主角不能被交换位置
  return true
end
