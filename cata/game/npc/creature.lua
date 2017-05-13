--所有单位的根类， player继承 character 继承 creature  ,  npc 继承charactor，  monster继承creature


local creatureBase = {}
g.creature = {}
local cr = g.creature
--将子类型的metatable 加入函数
function cr.initCreatureMetaTable(mt)
  for k,v in pairs(creatureBase) do
    mt[k] =v
  end
end
--创建 实例的成员变量
function cr.initCreatureValue(t)
  t.delay = 0 --各自会有其他初始化
  t.animEffectList = g.createAnimEffectList()
end


--之后就是creature成员函数

--主要是统一动画的播放
function creatureBase:setAnimation(anim)
  anim.pastTime = -self.delay
  self.anim = anim
end

function creatureBase:setAnimation(anim)
  anim.pastTime = -self.delay
  self.anim = anim
end

--实际时间
function creatureBase:updateAnim(dt)
  local anim = self.anim
  if anim then
    anim.pastTime = anim.pastTime+dt
    if anim.pastTime> anim.totalTime then
      --anim.pastTime = anim.pastTime - anim.totalTime
      self.anim = nil --直接删除
    end
  end
  self.animEffectList:updateAnim(dt)
end

--简短的活动表现，使用小进度条，在单位身上可见.
function creatureBase:shortActivity(text,delayTime)
  if self.delay <=delayTime then
    self.delay = delayTime
    self.animEffectList:addEffect({name = "progress",text= text,pastTime=0,totalTime = delayTime})
  end
end


