--远程武器
local list = {}

list[#list+1] = {
  id = "usp_9mm",
  name = tl("USP_9mm手枪","USP 9mm pistol"),
  description = tl("一款被执法机关广泛使用的手枪，其耐操性毋庸置疑，即使在被过度使用之后也能保持其精准性的稳定发挥。","A popular pistol, widely used among law enforcement.  Extensively tested for durability, it has been found to stay accurate even after being subjected to extreme abuse."),--
  item_type = "gun",--远程类型
  
  material = {"steel","plastic"} ,
  weight = 52,volume =2,price = 68000,
  melee_dam = 8,melee_cut = 0,melee_stab=0,m_to_hit = -2,
  --flags = flagt{"TRADER_AVOID"},
  img = "item1",--png name
  quad = {5,2},--
  --装备图
  weapon_appreance = {file = "gun_usp",always_back = false,start_cord={0,0}},--外观数据,start_cord 表示图片对齐位置，与人物正中心点，
  
  --gun专用属性
  skill_used = "pistol",--手枪技能
  ammotype = "l_pistol",--子弹口径
  pierce = 0, range = 0,damage = -1,   --穿甲，射程，伤害修正
  dispersion = 255,sight_dispersion = 90,recoil = 75, --基本散布，视野散布，后座
  durability= 9,magazine_size = 15,reload_time = 1.2, --耐用性，弹匣，重装时间 
  barrel_length =0,--枪管长度，和其他
  
  fire_sound = "fire_9mm",
  bullet_anim = "bullet1",
  reload_sound = "reload_pistol",
  semi_auto_shot = 0.3,
}


list[#list+1] = {
  id = "ak47m",
  name = tl("AKM步枪","AKM rifle"),
  description = tl("世界名枪之一，AKM 步枪以其耐用性而闻名，即使在最糟的环境下也能正常射击。","One of the most recognizable assault rifles ever made, the AKM is renowned for its durability even under the worst conditions."),--
  item_type = "gun",--远程类型
  
  material = {"steel","wood"} ,
  weight = 271,volume =7,price = 290000,
  melee_dam = 12,melee_cut = 0,melee_stab=0,m_to_hit = -1,
  flags = flagt{"NEVER_JAMS"},--从不卡壳
  img = "item1",--png name
  quad = {4,2},--
  --装备图
  weapon_appreance = {file = "gun_akm",always_back = false,start_cord={16,0}},--外观数据,start_cord 表示图片对齐位置，与人物正中心点，
  
  --gun专用属性
  skill_used = "rifle",--手枪技能
  ammotype = "h_rifle",--子弹口径
  pierce = 0, range = 0,damage = 1,   --穿甲，射程，伤害修正
  dispersion = 45,sight_dispersion = 60,recoil = 60, --基本散布，视野散布，后座
  durability= 9,magazine_size = 30,reload_time = 1.6, --耐用性，弹匣，重装时间 
  barrel_length =1,--枪管长度，和其他
  
  semi_auto_shot = 0.4, --半自动射击间隔
  burst = true,--允许自动射击
  burst_shot = 0.2,--射击间隔时间，burst模式下
  burst_size = 2,--burst size， burst一次最小发射数
  
  bullet_anim = "bullet1",
  fire_sound = "fire_762x39",
  reload_sound = "reload_rifle2",
}


list[#list+1] = {
  id = "shortbow",
  name = tl("短弓","short bow"),
  description = tl("比长弓更短，为了更容易被拉开而牺牲了威力。短弓射出的箭不易损坏，回收率高。","Shorter than the longbow and not as powerful, this bow is easier to draw and can be used effectively by average archers.  Arrows fired from this weapon have a good chance of remaining intact for re-use."),--
  item_type = "gun",--远程类型
  
  material = {"wood"} ,
  weight = 34,volume =6,price = 16000,
  melee_dam = 6,melee_cut = 0,melee_stab=0,m_to_hit = 0,
  flags = flagt{"RELOAD_AND_SHOOT"},--其他的flag等有功能时再加
  img = "item1",--png name
  quad = {6,2},--
  --装备图
  weapon_appreance = {file = "gun_woodbow",always_back = false,start_cord={0,16}},--外观数据,start_cord 表示图片对齐位置，与人物正中心点，
  
  --gun专用属性
  skill_used = "archery",--手枪技能
  ammotype = "arrow",--子弹口径
  pierce = 0, range = 6,damage = 3,   --穿甲，射程，伤害修正
  dispersion = 210,sight_dispersion = 150,recoil = 0, --基本散布，视野散布，后座
  durability= 6,magazine_size = 0,reload_time = 1, --耐用性，弹匣，重装时间 
  barrel_length =0,--枪管长度，和其他
  
  semi_auto_shot = 0.5,
  bullet_anim = "arrow_wood",
  fire_sound = "fire_arrow",
  --reload_sound = "reload_rifle2",
}



return list