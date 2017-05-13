

local list = {}



list[#list+1] = {
  id = "corpse",
  name = "corpse",--尸体，名字会自动生成，根据怪物种类，所以此项无用
  description = tl("一具尸体。","A dead body."),--
  item_type = "generic",--一般类型
  
  --具体各种数值更具实际怪物种类绝对，重量 体积等
  img = "item1",--png name
  quad = {1,1},--quad,坐标0，开头，这两个变量创建类型时会替换掉
  
}


return list--所有内容都装在这，