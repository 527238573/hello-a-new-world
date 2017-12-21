local list = {}


list[#list+1] = {
  id = "crowbar",
  name = tl("撬棍","crowbar"),
  description = tl("正规工厂制作的标准撬棍，又名物理学圣剑，可以轻易进出别人的家里而不破坏门或者用来开启下水沟井盖，还可以潇洒的敲开丧尸的脑袋。实在是居家旅行的必备之物。","This is a hefty prying tool.  Use it to open locked doors without destroying them or to lift manhole covers.  You could also wield it to bash some heads in."),--
  item_type = "tool",--护甲类型
  
  material = "steel",
  weight = 50,volume =4,price = 1300,
  melee_dam = 14,melee_cut = 1,melee_stab=0,m_to_hit =2,
  --techniques = flagt{"WBLOCK_1"},--近战技能
  flags = flagt{"BELT_CLIP"},--可装皮带上？！
  toolLevel = {pry = 2},--撬动2级
  use_action = "crowbar",--主动使用：撬
  
  img = "item1",--png name
  quad = {6,0},--
  
  --装备图
  weapon_appreance = {file = "weapon_crowbar",always_back = true,start_cord={0,16}},
}


return list--所有内容都装在这，