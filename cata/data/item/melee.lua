local list = {}

list[#list+1] = {
  id = "stick",
  name = tl("重木棍","heavy stick"),
  description = tl("一根坚实而沉重的棍子，既能做武器，也能被切割成2x4制式木料作为制作材料。","A sturdy, heavy stick.  Makes a decent melee weapon, and can be cut into two by fours for crafting."),--
  item_type = "generic",--护甲类型
  
  material = "wood",
  weight = 170,volume =5,price = 0,
  melee_dam = 14,melee_cut = 0,melee_stab=0,m_to_hit = -2,
  flags = flagt{"TRADER_AVOID"},
  img = "item1",--png name
  quad = {4,0},--
  
  --装备图
  weapon_appreance = {file = "weapon_stick",always_back = false,start_cord={0,16}},--外观数据,start_cord 表示图片对齐位置，与人物正中心点，
}

list[#list+1] = {
  id = "bat",
  name = tl("棒球棍","baseball bat"),
  description = tl("一根牢固的木制棒球棍，揍起人来既顺手又给力。","A sturdy wood bat.  Makes a great melee weapon."),--
  item_type = "generic",--护甲类型
  
  material = "wood",
  weight = 113,volume =7,price = 16000,
  melee_dam = 19,melee_cut = 0,melee_stab=0,m_to_hit = 3,
  techniques = flagt{"WBLOCK_1"},--近战技能
  flags = flagt{"DURABLE_MELEE"},
  img = "item1",--png name
  quad = {5,0},--
  
  --装备图
  weapon_appreance = {file = "weapon_bat",always_back = true,start_cord={0,16}},--外观数据,start_cord 表示武器起始格子，16，0为人物正中下面的点
}

--撬棍在tools里

list[#list+1] = {
  id = "cudgel",
  name = tl("长棍","cudgel"),
  description = tl("这就是一根长杆子，一般也就在训练的时候用用。不过在关键时刻也算凑合。","A slender long rod of wood, while traditionally intended as a training tool for many dueling moves, it still makes a good melee weapon in a pinch."),--
  item_type = "generic",--护甲类型
  
  material = "wood",
  weight = 88,volume =8,price = 1000,
  melee_dam = 8,melee_cut = 0,melee_stab=0,m_to_hit = 2,
  techniques = flagt{"WBLOCK_1","RAPID","PRECISE"},--近战技能
  flags = flagt{"DURABLE_MELEE"},
  img = "item1",--png name
  quad = {7,0},--
  
  --装备图
  weapon_appreance = {file = "weapon_cudgel",always_back = false,start_cord={32,16}},
}

list[#list+1] = {
  id = "pointy_stick",
  name = tl("尖木棍","pointy stick"),
  description = tl("一头削的尖尖的木棍，可以用来演杂技，当然也可以用来扎人。一朵菊花先到，随后枪出如龙。","A simple wood pole with one end sharpened."),--
  item_type = "generic",--护甲类型
  
  material = "wood",
  weight = 90,volume =5,price = 0,
  melee_dam = 4,melee_cut = 0,melee_stab=8,m_to_hit = 1,
  techniques = flagt{"WBLOCK_1"},--近战技能
  --flags = flagt{"SPEAR"},--可隔一个格远程--无用
  toolLevel = {cook = 1},--烹饪1级
  img = "item1",--png name
  quad = {8,0},--
  
  --装备图
  weapon_appreance = {file = "weapon_pointystick",always_back = false,start_cord={16,16}},
}

list[#list+1] = {
  id = "sharpened_rebar",
  name = tl("磨尖钢筋","sharpened rebar"),
  description = tl("前端稍微磨尖了的钢筋，不过还是适合敲击而非戳击，好在多点选择灵活性还不错。","A somewhat sharpened piece of rebar, it is still better at bashing than stabbing but the added flexibility is nice."),--
  item_type = "generic",--护甲类型
  
  material = "iron",
  weight = 110,volume =6,price = 500,price_post = 2000,
  melee_dam = 14,melee_cut = 0,melee_stab=8,m_to_hit =0,
  --techniques = flagt{"WBLOCK_1"},--近战技能
  flags = flagt{"REACH_ATTACK"},--可隔一个格远程
  toolLevel = {cook = 1},--烹饪1级
  img = "item1",--png name
  quad = {9,0},--
  
  --装备图
  weapon_appreance = {file = "weapon_spear_rebar",always_back = false,start_cord={16,16}},
}

list[#list+1] = {
  id = "wood_sword",
  name = tl("木剑","wood sword"),
  description = tl("一个2x4制式木料装上十字护手后削尖了头的木剑；虽然并不适合拿来挥砍，但总是比赤手空拳要好。","A two by four with a cross guard and whittled down point; not much for slashing, but much better than your bare hands."),--
  item_type = "generic",--护甲类型
  
  material = "wood",
  weight = 60,volume =5,price = 0,
  melee_dam = 12,melee_cut = 1,melee_stab=0,m_to_hit =1,
  techniques = flagt{"WBLOCK_1"},--近战技能
  flags = flagt{"SHEATH_SWORD"},
  img = "item1",--png name
  quad = {4,1},--
  
  --装备图
  weapon_appreance = {file = "weapon_sword_wood",always_back = true,start_cord={0,16}},
}

list[#list+1] = {
  id = "crude_sword",
  name = tl("粗制剑","crude sword"),
  description = tl("一些废铁条被简陋的敲打进一把木剑的边缘。新加上去的重量导致整把武器重心不平衡，不过锯齿的边缘增加了不错的劈砍强度。","Several bits of thin scrap metal crudely beat into the semblance of an edge over a wooden sword.  The added weight is unbalanced, but the jagged edge offers a good bit of slashing power."),--
  item_type = "generic",--护甲类型
  
  material = "wood",
  weight = 110,volume =6,price = 0,
  melee_dam = 6,melee_cut = 14,melee_stab=0,m_to_hit =-1,
  techniques = flagt{"WBLOCK_1"},--近战技能
  flags = flagt{"SHEATH_SWORD"},
  img = "item1",--png name
  quad = {5,1},--
  
  --装备图
  weapon_appreance = {file = "weapon_sword_crude",always_back = true,start_cord={0,16}},
}



return list--所有内容都装在这，