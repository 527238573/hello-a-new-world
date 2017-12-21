

local list = {}

list[#list+1] = {
  id = "fake_fists",
  name = "fake_fists",--拳头代替 物品，在weapon =nil时用这个假物品代替
  description = tl("如果你看到这个，是出了bug。","Its a bug if you see this"),--
  item_type = "generic",--一般类型
  weight = 0,--120, --增加攻击耗时
  flags = flagt{"UNARMED_WEAPON"},
  
  img = "item1",--无效的
  quad = {0,1},
}

list[#list+1] = {
  id = "corpse",
  name = "corpse",--尸体，名字会自动生成，根据怪物种类，所以此项无用
  description = tl("一具尸体。","A dead body."),--
  item_type = "generic",--一般类型
  
  --具体各种数值更具实际怪物种类绝对，重量 体积等
  img = "item1",--png name
  quad = {1,1},--quad,坐标0，开头，这两个变量创建类型时会替换掉
  quads={red = {1,1},green = {3,1},},--专门的多个quad
}

list[#list+1] = { --实际是ammo类型
  id = "nail",
  name = tl("钉子","nail"),
  description = tl("一盒钉子。","A box of nails, mainly useful with a hammer."),--
  item_type = "generic",--一般类型
  
  canStack = true,stack_size = 100,
  weight = 40,volume =1,price = 6000,
  material = {"iron"},
  img = "item1",--png name
  quad = {0,2},--quad,坐标0，开头，这两个变量创建类型时会替换掉
  
}


list[#list+1] = {
  id = "splinter",
  name = tl("碎木头","splintered wood"),
  description = tl("一根被劈成细条的木片，可以用来引火或串肉。","A splintered piece of wood, could be used as a skewer or for kindling."),--
  item_type = "generic",--一般类型
  
  
  canStack = true,stack_size = 1,
  weight = 45,volume =1,price = 0,
  melee_dam = 4,melee_cut = 0, m_to_hit = 1,
  material = {"wood"},
  qualities = {cook = 1},
  flags  ={NO_SALVAGE = true},
  img = "item1",--png name,
  quad = {1,2},--quad,坐标0，开头，这两个变量创建类型时会替换掉
  
}

list[#list+1] = {
  id = "rock",
  name = tl("石头","rock"),
  description = tl("一个棒球大小的石头，可以凑合当近战武器，也可以砸向敌人。","A rock the size of a baseball.  Makes a decent melee weapon, and is also good for throwing at enemies."),--
  item_type = "generic",--一般类型
  
  
  weight = 65,volume =1,price = 0,
  melee_dam = 7,melee_cut = 0, m_to_hit = -2,
  material = {"stone"},
  qualities = {HAMMER = 1},
  img = "item1",--png name,
  quad = {2,2},--quad,坐标0，开头，这两个变量创建类型时会替换掉
  
}




return list--所有内容都装在这，