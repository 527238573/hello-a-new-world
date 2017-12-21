local list = {}

list[#list+1] = {
  id = "l_pistol_JHP",
  name = tl("轻型手枪子弹 JHP","light pistol bullet JHP"),
  description = tl("9x19mm 的手枪子弹。JHP（被甲空尖弹）的穿甲力比FMJ（全金属被甲弹）差一些，但是它们在遇到没有穿着护甲的目标时能迅速分散开，在敌人体内留下空腔，子弹也更容易留在目标体内。","9x19mm ammunition with a 116gr jacketed hollow point bullet.  JHP rounds have inferior penetration to FMJ rounds but their expansion slightly increases stopping power against unarmored targets and reduces overpenetration."),--
  item_type = "ammo",--消耗品类型
  material = {"steel","powder"},
  weight = 35,volume =1,price = 2400,stack_size = 50,
  img = "item1",--png name
  quad = {4,3},--
  
  ammotype = "l_pistol",--子弹口径
  pierce = 0, range = 14,damage = 26,   --穿甲，射程，伤害修正
  dispersion = 140,recoil = 195, --基本散布，后座
}



list[#list+1] = {
  id = "h_rifle_M43",
  name = tl("重型步枪子弹M43","heavy rifle bullet M43"),
  description = tl("123格令的7.62x39mm M43 全金属被甲钢芯弹。由二战时期的苏联研发，7.62x39mm规格弹药迅速地流行全世界。M43型号Z子弹由于其过好的弹道稳定性，其终端弹道性能很差。据实验，该型号子弹在射入目标内26厘米后才开始明显翻滚。","7.62x39mm M43 ammunition with 123gr steel core FMJ bullets.  Developed in WW2 by the Soviet Union the 7.62x39mm round rapidly became extremely popular all over the world.  The bullet has poor wounding potential due to its stability, only begining to yaw after 26cm."),--
  item_type = "ammo",--消耗品类型
  material = {"steel","powder"},
  weight = 39,volume =1,price = 5200,stack_size = 30,
  img = "item1",--png name
  quad = {5,3},--
  
  ammotype = "h_rifle",--子弹口径
  pierce = 8, range = 30,damage = 36,   --穿甲，射程，伤害修正
  dispersion = 180,recoil = 420, --基本散布，后座
}


list[#list+1] = {
  id = "arrow_wood",
  name = tl("木箭","wooden arrow"),
  description = tl("一支带有金属箭头和箭羽的木制箭矢。它有点轻，造成的伤害还不错，精准度也还凑合，射击后只有小概率可以保持完好。","A basic wooden arrow, it has a metal arrowhead and fletching.  It's light-weight, does some damage, and is so-so on accuracy.  Stands a below average chance of remaining intact once fired."),--
  item_type = "ammo",--消耗品类型
  material = {"wood"},
  weight = 51,volume =1,price = 1000,stack_size = 10,
  melee_dam = 2,melee_cut = 1,melee_stab=0,m_to_hit = 0,
  img = "item1",--png name
  quad = {6,3},--
  plural_quad = {6,4},--
  
  
  ammotype = "arrow",--子弹口径
  pierce = 3, range = 7,damage = 10,   --穿甲，射程，伤害修正
  dispersion = 135,recoil = 0, --基本散布，后座
  recover_rate = 0.8, --捡回率
  ammo_speed = 600,--动画飞行速度
  ammo_accurateness = 500, --闪避度，越低越容易闪避
  bullet_anim = "arrow_wood",--子弹动画
  
}



return list