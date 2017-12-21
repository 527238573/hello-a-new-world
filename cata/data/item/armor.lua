local list = {}

list[#list+1] = {
  id = "trenchcoat",
  name = tl("风衣","trenchcoat"),
  description = tl("一件薄薄的棉质风衣，缝着不少口袋，看上去挺能装。穿起来就像雷锋侠！","A thin cotton trenchcoat, lined with pockets.  Great for storage."),--
  item_type = "armor",--护甲类型
  material = "cotton",
  weight = 83,volume =17,price = 11500,
  m_to_hit = -1,--战斗属性减成
  img = "item1",--png name
  quad = {8,3},--
  --armor属性
  guise= "upper", --外观数据
  guise_data = {file = "c_trenchcoat"},--外观数据
  flags = flagt{"VARSIZE","POCKETS"},
  covers = flagt{"bp_arm_l","bp_arm_r","bp_torso"},
  coverage = 90,
  encumber = 0,
  thickness = 2,
  env_resist = 1,
  warmth = 15,
  storage = 24,
  armor_layer = 3, --外衣
}


list[#list+1] = {
  id = "cargo_pants",
  name = tl("工装长裤","cargo pants"),
  description = tl("一条衬有口袋的裤子，可以放很多东西。","A pair of pants lined with pockets, offering lots of storage."),--
  item_type = "armor",--护甲类型
  material = "cotton",
  weight = 67,volume =9,price = 2500,
  img = "item1",--png name
  quad = {9,3},--
  --armor属性
  guise= "lower", --外观数据
  guise_data = {file = "p_cargo_pants"},--外观数据
  flags = flagt{"VARSIZE","POCKETS"},
  covers = flagt{"bp_leg_l","bp_leg_r"},
  coverage = 95,
  encumber = 0,
  thickness = 2,
  env_resist = 0,
  warmth = 15,
  storage = 12,
  armor_layer = 3, --外衣
}

list[#list+1] = {
  id = "hoodie",
  name = tl("连帽衫","hoodie"),
  description = tl("一件带有兜帽的卫衣。小哥，你的黑金古刀呢？","A sweatshirt with a hood and a \"kangaroo pocket\" in front for storage."),--
  item_type = "armor",--护甲类型
  material = "cotton",
  weight = 42,volume =12,price = 3800,
  img = "item1",--png name
  quad = {8,2},--
  --armor属性
  guise= "upper", --外观数据
  guise_data = {file = "c_hoodie"},--外观数据
  flags = flagt{"VARSIZE","POCKETS","HOOD"},
  covers = flagt{"bp_arm_l","bp_arm_r","bp_torso"},
  coverage = 95,
  encumber = 0,
  thickness = 3,
  env_resist = 0,
  warmth = 30,
  storage = 12,
  armor_layer = 2, --中层衣物
}

list[#list+1] = {
  id = "jeans",
  name = tl("牛仔裤","jeans"),
  description = tl("有着两个大口袋的蓝色牛仔裤。","A pair of blue jeans with two deep pockets."),--
  item_type = "armor",--护甲类型
  material = "cotton",
  weight = 60,volume =8,price = 4000,
  m_to_hit = 1,--战斗属性减成
  img = "item1",--png name
  quad = {9,2},--
  --armor属性
  guise= "lower", --外观数据
  guise_data = {file = "p_jeans"},--外观数据
  flags = flagt{"VARSIZE","POCKETS"},
  covers = flagt{"bp_leg_l","bp_leg_r"},
  coverage = 95,
  encumber = 0,
  thickness = 3,
  env_resist = 0,
  warmth = 10,
  storage = 4,
  armor_layer = 3, --外衣
}

list[#list+1] = {
  id = "sweatshirt",
  name = tl("运动衫","sweatshirt"),
  description = tl("一件厚棉衫，除了保暖，还填充了些厚度。","A thick cotton shirt.  Provides warmth and a bit of padding."),--
  item_type = "armor",--护甲类型
  material = "cotton",
  weight = 34,volume =14,price = 3000,
  img = "item1",--png name
  quad = {8,1},--
  --armor属性
  guise= "upper", --外观数据
  guise_data = {file = "c_orange"},--外观数据
  flags = flagt{"VARSIZE"},
  covers = flagt{"bp_arm_l","bp_arm_r","bp_torso"},
  coverage = 95,
  encumber = 0,
  thickness = 3,
  env_resist = 0,
  warmth = 30,
  storage = 6,
  armor_layer = 2, --中层
}


list[#list+1] = {
  id = "pants",
  name = tl("长裤","pants"),
  description = tl("这是卡其裤，比牛仔裤要保暖些。","A pair of khaki pants.  Slightly warmer than jeans."),--
  item_type = "armor",--护甲类型
  material = "cotton",
  weight = 40,volume =7,price = 3500,
  img = "item1",--png name
  quad = {9,1},--
  --armor属性
  guise= "lower", --外观数据
  guise_data = {file = "p_grey"},--外观数据
  flags = flagt{"VARSIZE","POCKETS"},
  covers = flagt{"bp_leg_l","bp_leg_r"},
  coverage = 95,
  encumber = 0,
  thickness = 1,
  env_resist = 0,
  warmth = 15,
  storage = 4,
  armor_layer = 2, --中层
}



return list--所有内容都装在这，