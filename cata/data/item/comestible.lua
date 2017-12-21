local list = {}

list[#list+1] = {
  id = "meat",
  name = tl("肉块","chunk of meat"),
  description = tl("一块生肉。可以生吃，但烹饪更佳。","Freshly butchered meat.  You could eat it raw, but cooking it is better."),--
  item_type = "comestible",--消耗品类型
  material = "flesh",
  comestible_type = "FOOD",
  weight = 20,volume =1,price = 500,
  spoils = 24,nutr  =28,healthy = -1,fun = -10,
  img = "item1",--png name
  quad = {2,0},--
  
}

list[#list+1] = {
  id = "bone",
  name = tl("骨头","bone"),
  description = tl("一根某种生物的骨头。可以用来吃或做东西。","A bone from some creature or other.  Could be eaten or used to make some stuff, like needles."),--
  item_type = "comestible",--消耗品类型
  material = "bone",
  comestible_type = "FOOD",
  weight = 22,volume =1,price = 0,
  nutr  =4,healthy = -1,fun = -1,
  img = "item1",--png name
  quad = {3,0},--
  
}

return list--所有内容都装在这，