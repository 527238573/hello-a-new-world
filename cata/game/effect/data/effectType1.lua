local list = {}

list[#list+1] =
{
  id = "stunned",
  name = tl("眩晕!","Stunned !"),
  color = {22,50,120},
  description = tl("你晕头转向，随机运动。","Your movement is randomized."),
  apply_message = tl("你被击晕了！","You're stunned!"),
  rating = "bad",
}

list[#list+1] =
{
  id = "downed",
  name = tl("倒地","Downed"),
  description = tl("你倒在了地上，你必须爬起来才能继续移动。","You're knocked to the ground.  You have to get up before you can move."),
  apply_message = tl("你被击倒在地！","You're knocked to the floor!"),
  rating = "bad",
}


list[#list+1] =
{
  id = "on_fire",
  name = tl("着火!","On Fire !"),
  color = {150,20,20},
  description = tl("全身持续损伤\n你的衣服或装备可能被火焰吞噬。","Loss of health - Entire Body\nYour clothing and other equipment may be consumed by the flames."),
  apply_message = tl("你被烧着了！等在原地会尝试扑灭火焰。","You're on fire!  Wait in place to attempt to put out the fire."),
  rating = "bad",
}

list[#list+1] =
{
  id = "zapped",
  name = tl("电击","Zapped"),
  color = {150,150,0},
  description = tl("你被电击了，只能够勉强移动！","You've been zapped with electricity and are barely able to move!"),
  apply_message = tl("你被电击了！","You're zapped!"),
  rating = "bad",
}

list[#list+1] =
{
  id = "pushed",
  name = "pushed",
  description = "如果看到是一个bug，这个是ai用effect",
}



return list