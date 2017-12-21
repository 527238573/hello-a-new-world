local list = {}

list[#list+1] = {
  id = "cut",
  name = tl("切割","cutting"),
  quad = {0,1},
}

list[#list+1] = {
  id = "hammer",
  name = tl("捶打","hammering"),
  quad = {1,1},
}

list[#list+1] = {
  id = "screw",
  name = tl("拧动螺丝","screw driving"),
  quad = {2,0},
}

list[#list+1] = {
  id = "wrench",
  name = tl("扳动螺栓","bolt turning"),
  quad = {1,0},
}

list[#list+1] = {
  id = "saw_wood",
  name = tl("木材切锯","wood sawing"),
}

list[#list+1] = {
  id = "saw_metal",
  name = tl("钢材切锯","metal sawing"),
  
}
list[#list+1] = {
  id = "chisel",
  name = tl("雕凿","chiseling"),
  
}

list[#list+1] = {
  id = "axe",
  name = tl("伐木","tree cutting"),
  
}

list[#list+1] = {
  id = "dig",
  name = tl("挖掘","digging"),
  
}

list[#list+1] = {
  id = "pry",
  name = tl("撬动","prying"),
  
}

list[#list+1] = {
  id = "glare",
  name = tl("强光防护","glare protection"),
}

list[#list+1] = {
  id = "cook",
  name = tl("烹饪","cooking"),
}

list[#list+1] = {
  id = "butcher",
  name = tl("屠宰","butchering"),
}



return list