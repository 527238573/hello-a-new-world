--所有单位的根类， player继承 character 继承 creature  ,  npc 继承charactor，  monster继承creature


local creatureBase = {}
g.creature = {creatureBase = creatureBase}
local cr = g.creature
--将子类型的metatable 加入函数
function cr.initCreatureMetaTable(mt)
  for k,v in pairs(creatureBase) do
    mt[k] =v
  end
end

--默认base值的table，需要一个table明确要重置的量
cr.default_base_table = {
    speed = 100,--会根据各种生物值实际变化
    speed_percent = 0,--百分比速度加成，10为10%加成，负数为减成。在固定加成之后
    dodge = 0,-- 基础闪避，一般为0，monster会重设此项  加成闪避会在百分比削减之后 
    dodge_reduce = 0,-- 闪避削减，最高50，也就是削减50%的闪避骰子数，陷阱等buff使用
    block = 0,
    hit = 0, --命中加成。base并无使用，只有bonus使用
    num_blocks = 0,
    num_dodges= 2,
    pain = 0,--似乎 应该是modpain
    bonus_hp=0,--额外hp，这样比较合理
    
    str = 8,--实际只有charactor使用的属性，如果有monster获得了增加这些属性的buff，这样不会出错（找不到atrname）
    dex = 8,--4大属性
    int = 8,
    per = 8,
  }
  
cr.default_charactor_base_table = { --只对charator有效的table
  bp_head = 100,
  bp_torso = 160,
  bp_arm_l = 90,
  bp_arm_r = 90,
  bp_leg_l = 90,
  bp_leg_r = 90,
}


--创建 实例的成员变量
function cr.initCreatureValue(t)
  t.dead = false
  
  t.delay = 0 --各自会有其他初始化
  t.animEffectList = {}--只作为一个 list，具体操作在creatureAnim里
  
  t.impact_dx = 0
  t.impact_dy = 0
  t.impactAnim_list = {} --冲击的动画，多个可叠加，播放完毕自动从list中删除，
  
  
  t.effects = {} --effect
  t.bonus_changed = false
  t.damage_queue ={} --储存时间延迟的damage 
  local base = {} --基础值
  local bonus = {} --奖励值等
  t.base = base -- 变化基础值 
  t.bonus = bonus --变化
  --数值组
  for k,v in pairs(cr.default_base_table) do
    base[k] = v
    bonus[k] = 0
  end
end


--之后就是creature成员函数
require "game/animation/creatureAnim"
require "game/npc/creatureDo/checkCr"
require "game/npc/creatureDo/effectCr"
require "game/npc/creatureDo/fightCr"
require "game/npc/creatureDo/rangedCr"
--下面几个函数需要移动到check中

--简短的活动表现，使用小进度条，在单位身上可见.
function creatureBase:shortActivity(text,delayTime)
  if self.delay <=delayTime then
    self.delay = delayTime
    self:addProgressAnimEffect(text,delayTime)
  end
end


function creatureBase:set_killer(killer)
  if killer~=nil and self.killer==nil then
    self.killer = killer
  end
end
--公共虚
--[[

get_speed()

is_dead_state()
check dead state 未加入 
--战斗相关，共通函数
melee_attack()

get_melee_skill()--取近战等级
get_dodge() --实时躲闪等级

hit_roll() --取命中
dodge_roll() --取闪避

on_dodge()进行闪避，对某目标实际闪避

deal_melee_hit () 传输damage_instance，返回 dealt_damage_instance

block_hit()格挡触发
on_hit() --击中身体部位触发
absorb_hit() 吸收伤害（部位护甲等） --现改为吸收一种类型的伤害，返回dam和pain

apply_damage()实施伤害，
on_hurt()受伤触发
select_body_part()-- 只有charactor有效，monster暂无身体部位
--]]

