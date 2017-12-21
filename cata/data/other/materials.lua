local list = {}

list[#list+1] = {
  id = "null",
  name = tl("未知","Unknow"),
  resist=  {bash = 0,cut=0,acid = 0,electric = 0,heat = 1, cold = 0,},
  density=1,
}

list[#list+1] = {
  id = "cotton",
  name = tl("棉质","Cotton"),
  resist=  {bash = 1,cut=1,acid = 3,electric =2,heat = 0, cold = 2,},
  density=3,
}

list[#list+1] = {
  id = "wood",
  name = tl("木头","Wood"),
  resist=  {bash = 3,cut=2,acid = 4,electric = 2,heat = 1, cold = 1,},
  density=8,
}

list[#list+1] = {
  id = "iron",
  name = tl("铁","Iron"),
  resist=  {bash = 4,cut=4,acid = 5,electric =0,heat = 3, cold = 1,},
  density=52,
}

list[#list+1] = {
  id = "steel",
  name = tl("钢","Steel"),
  resist=  {bash = 6,cut=6,acid = 7,electric =0,heat = 3, cold = 1,},
  density=30,
}

return list