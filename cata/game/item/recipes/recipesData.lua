local lovefs = require("file/lovefs")
local loaded = false
--载入recipesData
local  recipe_categories = {
  {id = "weapon",name = tl("武器","WEAPON"),
    sub_cats = {
      {id = "bashing",name = tl("钝击","Bashing")},
      {id = "cutting",name = tl("劈砍","Cutting")},
      {id = "stabbing",name = tl("穿刺","Piercing")},
      {id = "ranged",name = tl("远程","Ranged")},
      {id = "firearms",name = tl("枪械","Firearms")},
      {id = "explosive",name = tl("爆炸","Explosive")},
      {id = "other",name = tl("其他","Other")},
    },
  },
  {id = "ammo",name = tl("弹药","AMMO"),
    sub_cats = {
      {id = "arrows",name = tl("钝击","Arrows")},
      {id = "bullets",name = tl("子弹","Bullets")},
      {id = "grenades",name = tl("榴弹","Grenades")},
      {id = "components",name = tl("组件","Component")},
      {id = "other",name = tl("其他","Other")},
    },
  },
  {id = "food",name = tl("食物","FOOD"),
    sub_cats = {
      {id = "meat",name = tl("肉食","Meat")},
      {id = "veggies",name = tl("蔬菜","Veggies")},
      {id = "drinks",name = tl("饮品","Drinks")},
      {id = "bread",name = tl("主食","Bread")},
      {id = "pasta",name = tl("面食","Pasta")},
      {id = "snack",name = tl("小吃","Snack")},
      {id = "dry",name = tl("风干","Dry")},
      {id = "brew",name = tl("酿造","Brew")},
      {id = "other",name = tl("其他","Other")},
    },
  },
  {id = "chem",name = tl("化学","CHEM"),
    sub_cats = {
      {id = "drugs",name = tl("药剂","Drugs")},
      {id = "fuel",name = tl("燃料","Fuel")},
      {id = "mutagen",name = tl("变异","Mutagen")},
      {id = "chemicals",name = tl("化学品","Chemicals")},
      {id = "other",name = tl("其他","Other")},
    },
  },
  {id = "electronic",name = tl("电子","ELEC"),
    sub_cats = {
      {id = "cbm",name = tl("CBM","CBMs")},
      {id = "tools",name = tl("工具","Tools")},
      {id = "parts",name = tl("载具","Parts")},
      {id = "lighting",name = tl("照明","Lighting")},
      {id = "components",name = tl("组件","Component")},
      {id = "other",name = tl("其他","Other")},
    },
  },
  {id = "armor",name = tl("装备","ARMOR"),
    sub_cats = {
      {id = "storage",name = tl("储存","Storage")},
      {id = "suit",name = tl("套装","Suit")},
      {id = "head",name = tl("头部","Head")},
      {id = "torso",name = tl("躯干","Torso")},
      {id = "arms",name = tl("手臂","Arms")},
      {id = "hands",name = tl("手掌","Hands")},
      {id = "legs",name = tl("腿部","Legs")},
      {id = "feet",name = tl("脚部","Feet")},
      {id = "other",name = tl("其他","Other")},
    },
  },
  
  {id = "other",name = tl("其他","OTHER"),
    sub_cats = {
      {id = "tools",name = tl("工具","Tools")},
      {id = "medical",name = tl("医药","Medical")},
      {id = "containers",name = tl("容器","Containers")},
      {id = "materials",name = tl("材料","Materials")},
      {id = "parts",name = tl("载具","Parts")},
      {id = "traps",name = tl("陷阱","Traps")},
      {id = "other",name = tl("其他","Other")},
    },
  },
  
}
data.recipe_categories = recipe_categories--输入data中

local default_recipe_val  ={
  id = "null",--一般为出产主物品的id，当有多个差不多配方的时候才以id区分
  category = "other", --配方所在分类
  sub_cat = "other",--默认other大类other小类
  
  
  main_skill = "fabrication",--主技能，默认制造
  main_level = 0, --需要的主技能等级。默认0
  required_skills = nil, --需要的副技能及其等级，格式为 = ｛xxskill_id = required_level,...｝ 可以多个技能，但不能太多
  
  qualities = {},--工具等级-- 列出所有需要的等级｛xxxtoolskill = level,xxx2= level2,...｝ 
  tools = {},--   工具列表，单一个工具或 多个可选工具 tools = {{{"xxx",-1},{"xxx2",-1}},      
  --   {{"xxx",2}}}--三层table结构，哪怕只有一个也要包三层。最里面的字符串是id，数字表示消耗能量数量。-1为不消耗。 可以为火源。 第二层table里是 或关系，排序表示优先级。靠前的优先消耗。
  components = {}, --材料，和tool一样3层table，不过物品id后的数字是 消耗数量（绝对数量。无论是否可堆叠。）
  
  result = "nail",--主产物id ，默认钉子？
  result_mult = nil, -- 主产物数量。不设此项就是默认1个。或一组（可堆叠物品。）设置就是绝对数量。
  byproducts = nil,--副产物，table 里xx=number 为各种副产物的数量。
  container =nil,--当产物为液体且配方里规定了容器时，出产的产物会装到此容器里。
  
  costtime = 600,--耗时 按秒计算，600秒为10分钟。 
  --批量时间减成暂时没有。
  flags = {},
  
  reversible = nil, -- 是否能反向分解。如果能，会被登记到物品处。分解无需技能等级？
  autolearn = nil,--自动学习。如果有，会被登记。技能提升满足后会检查并学习。 只要主技能满足，就能够被学习。 
  
}


data.recipes = {}


local function loadOneRecipe(recipe)
  for k,v in pairs(default_recipe_val) do
    if recipe[k]==nil then
      recipe[k] = v--填充默认内容。
    end
  end
  --可能需要检查各种物品id
  --检查skill 
  if data.skill_data[recipe.main_skill] ==nil then debugmsg("WrongSkill id:"..recipe.main_skill) end
  if recipe.required_skills then 
    for skill_id,_ in pairs(recipe.required_skills) do
      if data.skill_data[skill_id] ==nil then debugmsg("WrongSkill id:"..skill_id) end
    end
  end
  
  --检查qualities
  for qid,_ in pairs(recipe.qualities) do
    if data.qualities[qid]  ==nil then error("Error quality id :"..qid.." recipe:"..recipe.id) end
  end
  --检查tools
  for _,t2 in ipairs(recipe.tools) do
    if #t2<1 then error("Empty tools entry recipe:"..recipe.id)end
    for _,t3 in ipairs(t2) do
      if data.itemTypes[t3[1]] ==nil then error("Error itemtype id :"..t3[1].." recipe:"..recipe.id) end
      if type(t3[2])~="number" then error("Error number :"..t3[2].." recipe:"..recipe.id) end
    end
  end
  --检查components
  for _,t2 in ipairs(recipe.components) do
    if #t2<1 then error("Empty components entry recipe:"..recipe.id)end
    for _,t3 in ipairs(t2) do
      if data.itemTypes[t3[1]] ==nil then error("Error itemtype id :"..t3[1].." recipe:"..recipe.id) end
      if t3[2]<1 then error("Error itemNumber :"..t3[2].." recipe:"..recipe.id) end
    end
  end
  --检查result的id
  local result_itype = data.itemTypes[recipe.result]
  if result_itype==nil then debugmsg("Error!!!!!!!!!: recipe result id:"..recipe.result);return end
  recipe.result_itype = result_itype
  --检查副产物
  if recipe.byproducts then
    for tid,number in pairs(recipe.byproducts) do
      if data.itemTypes[tid] ==nil then error("Error itemtype id :"..t3[1].." recipe:"..recipe.id) end
      if number<1 then error("Error itemNumber :"..number.." recipe:"..recipe.id) end
    end
  end
  
  data.recipes[recipe.id]=recipe
  --注册到分类列表中
  local cat1
  for i=1,#recipe_categories do 
    if recipe_categories[i].id == recipe.category then
      cat1 = recipe_categories[i]
      break;
    end
  end
  if cat1 ==nil then cat1 =recipe_categories[#recipe_categories];debugmsg("error recipe category:"..recipe.category) end--在出错的最后一个other
  local cat2 
  for i=1,#(cat1.sub_cats) do 
    if cat1.sub_cats[i].id == recipe.sub_cat then
      cat2 = cat1.sub_cats[i]
      break;
    end
  end
  if cat2 ==nil then cat2 = cat1.sub_cats[#(cat1.sub_cats)];debugmsg("error recipe sub_cat:"..recipe.sub_cat) end--在出错的最后一个other
  table.insert(cat2,recipe)--插入子类型中
  
  
  
  
  
  --注册解体配方
  if recipe.reversible then
    (result_itype).reverse_recipe = recipe --在itemtype上注册 解体recipe
  end
  
  
end

function data.loadRecipeData()
  if loaded then return else loaded = true end
  local fs = lovefs(love.filesystem.getSource().."/data/recipes")
  for _, v in ipairs(fs.files) do --
    local tmp = dofile("data/recipes/"..v) -- 执行文件夹内所有文件，载入所有itemtype列表
    debugmsg("recipes file:"..v.." length:"..#tmp)
    for i=1,#tmp do
      loadOneRecipe(tmp[i])--载入一项
    end
  end
end



