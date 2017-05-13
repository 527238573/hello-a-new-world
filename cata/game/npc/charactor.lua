
local charactorBase = {}
local cr = g.creature


--将子类型的metatable 加入函数
function cr.initCharactorMetaTable(mt)
  cr.initCreatureMetaTable(mt)--父类
  for k,v in pairs(charactorBase) do
    mt[k] =v
  end
end
--创建 实例的成员变量
function cr.initCharatorValue(t)
  cr.initCreatureValue(t)
  t.str_org = 8;
  t.dex_org = 8;
  t.int_org = 8;
  t.per_org = 8;
  t.str_cur = 8;
  t.dex_cur = 8;
  t.int_cur = 8;
  t.per_cur = 8;
  t.speed_org = 100
  t.speed_cur = 100
  --[[
  bodypart:
  1= head
  2 = torso
  3 = arm_l
  4 = arm_r
  5 = leg_l
  6 = leg_r
  --]]
  
  t.hp_cur = {100,100,100,100,100,100}--1-6个位置
  t.hp_max = {100,100,100,100,100,100}
  
  t.inventory = g.createInventory()
end

--之后就是charactor类的成员函数了

