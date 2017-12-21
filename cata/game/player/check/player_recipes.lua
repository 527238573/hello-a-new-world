local player_mt = g.player_mt


--重设所有数据，根据
function player_mt:reset_recipes()
  self.recipes = {}
  for _,recipe in pairs(data.recipes) do
    self:canAutoLearnRecipe(recipe)--在检查时就学会了
  end
end




function player_mt:canAutoLearnRecipe(recipe)
  if not recipe.autolearn then return false end
  local skills = player.skills
  local mainlevel = skills:get_skill_level(recipe.main_skill)
  if mainlevel<recipe.main_level then return false end --仅主要技能满足即可
  debugmsg("auto learned recipe:"..recipe.id)
  self.recipes[recipe] = true --学会该配方
  return true
end

function player_mt:know_recipe(recipe)
  local know =  self.recipes[recipe]~=nil
  if not know then
    know = self:canAutoLearnRecipe(recipe)
  end
  return know
end


function player_mt:recipe_meet_skills(recipe)
  local skills = player.skills
  local mainlevel = skills:get_skill_level(recipe.main_skill)
  if mainlevel<recipe.main_level then return false end
  if recipe.required_skills then
    for k,v in pairs(recipe.required_skills) do
      local level = skills:get_skill_level(k)
      if level< v then return false end
    end
  end
  return true
end

function player_mt:recipe_meet_toolAndComponent(recipe)
  return self:recipe_meet_qualities(recipe) and self:recipe_meet_tools(recipe) and self:recipe_meet_components(recipe)
end


function player_mt:recipe_meet_one_quality(tool_id,tool_level)
  local weapon = self.weapon
  if weapon then
      if weapon:meet_quality(tool_id,tool_level) then return true end
  end
  for _,oneitem in ipairs(self.worn) do
    if oneitem:meet_quality(tool_id,tool_level) then return true end
  end
  for _,oneitem in ipairs(self.inventory.items) do
    if oneitem:meet_quality(tool_id,tool_level) then return true end
  end
  return false
end
  

function player_mt:recipe_meet_qualities(recipe,warning)
  for tool_id,tool_level in pairs(recipe.qualities) do
    local meet_this = self:recipe_meet_one_quality(tool_id,tool_level)
    if not meet_this then 
      if warning then
        local data = data.qualities[tool_id]
        addmsg(string.format( tl("你没有%s等级%d的工具！", "You don't have a tool with %s of level %d." ),data.name,tool_level),"warning")
      end
      return false
    end
  end
  return true
end

--待补上火焰或其他  ,返回的是寻找到的第一个符合条件的物品。
function player_mt:recipe_meet_one_tool_charges(tool_id,charges)
  local weapon = self.weapon
  if weapon then
    if weapon:meet_one_tool_charges(tool_id,charges) then return weapon end
  end
  for _,oneitem in ipairs(self.worn) do
    if oneitem:meet_one_tool_charges(tool_id,charges) then return oneitem end
  end
  for _,oneitem in ipairs(self.inventory.items) do
    if oneitem:meet_one_tool_charges(tool_id,charges) then return oneitem end
  end
  return nil
  
end


function player_mt:recipe_meet_tools(recipe)
  local weapon = self.weapon
  local wearlist= self.worn
  local inventorylist = self.inventory.items
  for _,tool_table in ipairs(recipe.tools) do
    local meet_this = false
    if weapon then
      meet_this = weapon:meet_tool_charges(tool_table)
    end
    if not meet_this then
      for _,oneitem in ipairs(wearlist) do
        meet_this = oneitem:meet_tool_charges(tool_table)
        if meet_this then break end
      end
    end
    if not meet_this then
      for _,oneitem in ipairs(inventorylist) do
        meet_this = oneitem:meet_tool_charges(tool_table)
        if meet_this then break end
      end
    end
    if not meet_this then 
      return false
    end
  end
  return true
end

--暂时方法。后续还要搜索地上等
function player_mt:recipe_meet_one_components(item_id,number)
  local inventory = self.inventory
  local meet_this = inventory:get_item_number(item_id)>=number
  return meet_this
end





function player_mt:recipe_meet_components(recipe)
  local inventory = self.inventory
  for _,com_table in ipairs(recipe.components) do
    local meet_this = false
    for _,one_require in ipairs(com_table) do
      meet_this = inventory:get_item_number(one_require[1])>=one_require[2]
      if meet_this then break end
    end
    if not meet_this then 
      return false
    end
  end
  return true
end

--取得物品装入list中。因为检查过了所以数量足够不可能出错的方法。
function player_mt:get_recipe_one_components(list,item_id,number)
  local inventory = self.inventory
  local remain_num = inventory:slice_n_item(list,item_id,number)
  if remain_num>0 then
    debugmsg("Error recipe components not enough!!! item_id:"..item_id) --一般不可能出现的错误。
  end
end


--获得一串列表的物品，如果有液体则询问容器。结束后调用conitnue_func（无参数）
function player_mt:acquire_item_list(list,conitnue_func)
  for i=1,#list do
    self.inventory:addItem(list[i])    
  end
  conitnue_func()
end



local function complete_make_craft(activity)
  local recipe = activity.command.recipe
  --消耗能量。
  for i=1,#activity.cost_charges do
    activity.cost_charges[i].item:cost_charges(activity.cost_charges[i].charges)
  end
  
  --提升技能。
  
  --获得物品。
  local result_list= {}
  local result =g.itemFactory.createItem(recipe.result)
  result_list[#result_list+1] = result --push back
  if recipe.result_mult then --复数产出
    if result:can_stack() then --可堆叠直接设置堆叠数量。
      result:set_stack(recipe.result_mult)
    else  --不可堆叠。直接多造
      for i=2,recipe.result_mult do
        result_list[#result_list+1] = g.itemFactory.createItem(recipe.result) --多造
      end
    end
  end
  if recipe.byproducts then--生成副产物
    for item_id,number in pairs(recipe.byproducts) do
      local result =g.itemFactory.createItem(item_id)
      result_list[#result_list+1] = result --push back
      if result:can_stack() then
        result:set_stack(number)
      elseif number>1 then
        for i=2,number do
          result_list[#result_list+1] = g.itemFactory.createItem(item_id) --多造
        end
      end
    end
  end
  
  --
  local function continue_makecraft()
    if recipe.byproducts==nil then
      addmsg(string.format( tl("你制作了%s。", "You craft %s."),result:getName()),"info")
    else
      addmsg(string.format( tl("你制作了%s以及一些副产物。", "You craft %s and some other byproducts."),result:getName()),"info")
    end
    
    if activity.command.left_num>0 then
      player:make_craft(activity.command)
    elseif activity.command.return_craftwin then
      ui.craftingWin:Open()--重打开
    end
  end
  player:acquire_item_list(result_list,continue_makecraft)
end
local function cancel_make_craft(activity)
  --取消制作，原材料返还 
  --液体不返还！从容器里取出后停止制作即浪费了。
  --根据技能提高返还。
  local recipe = activity.command.recipe
  
  addmsg(string.format( tl("你停止制作%s并返还了部分原料。", "You stop crafting %s and retrieve some material."),recipe.result_itype.name),"warning")
  for i=1,#activity.cost_material do
    
    --还要检测
    player.inventory:addItem(activity.cost_material[i])    
  end
  
end



--通过命令进行制作。当然还要检查一遍条件（和配方条件不同，这个是已经），
function player_mt:make_craft(command)
  --检查，当然还要检查光线对速度的加成等。目前无速度修正，也没考虑光线是否可做。
  local recipe = command.recipe
  
  --再次检查quality。可能在多次制造时满足quality的物品被当材料用掉了，所以每次都要检查。
  if not self:recipe_meet_qualities(recipe,true) then return end--
  --检查工具并找出扣除充能的物品，储存着。
  local cost_charges= {}
  for i=1,#command.toollist do
    debugmsg("toollen:"..#command.toollist)
    local tool_id = command.toollist[i].tool_id
    local charges = command.toollist[i].charges
    local finditem = self:recipe_meet_one_tool_charges(tool_id,charges)
    if finditem then
      if charges>0 then
        table.insert(cost_charges,{item = finditem,charges = charges})--记录下工具耗能，将来消耗掉。注意能够耗能的都是不可堆叠的物品。万一出现在材料中被取走了也能正确消耗。
      end
    else
      --没有合适的工具，可能是充能耗尽？
      local itype = data.itemTypes[tool_id]
      local warning_str = string.format( tl("你找不到工具:%s!", "You can't find a tool: %s!" ),itype.name)
      if charges>0 then warning_str=warning_str..tl("可能是充能耗尽了。","It may be running out of charges.") end
      addmsg(warning_str,"warning")
      return 
    end
  end
  --检查材料
  for i=1,#command.components do
    local item_id = command.components[i].item_id
    local number = command.components[i].number
    if not self:recipe_meet_one_components(item_id,number) then
      local itype = data.itemTypes[item_id]
      addmsg(string.format( tl("制作材料:%s 数量不足!", number>1 and "You don't have enough %s to craft!" or "You don't have a %s to craft!"),itype.name),"warning")
      return
    end
  end
  --扣除材料。保存在list中。如果活动中断，会返还材料。成功则扣除。
  local cost_material ={}
  for i=1,#command.components do
    self:get_recipe_one_components(cost_material,command.components[i].item_id,command.components[i].number)
  end
  --检查完毕。开始执行。
  command.left_num = command.left_num-1
  --创建activity
  local activity = g.activity.create_activity()
  local recipe_time = recipe.costtime/13.5 --使用了常数，实际对应2.25的timespeed。 换算为实际秒数
  --还需要经过时间加成等。
  debugmsg("set time:"..recipe_time)
  activity:setTotalTime(recipe_time)
  
  --详细微调实际时间表现效果
  if command.total_num>1 then
    activity.minRealTime = math.max(0.75,recipe.costtime/1800)
  else
    activity.minRealTime = math.max(1.5,recipe.costtime/900)
  end
  if command.total_num >1 then
    activity.name = string.format(tl("制作: %s (%d/%d)","Crafting: %s (%d/%d)"),recipe.result_itype.name,command.total_num-command.left_num,command.total_num)
  else
    activity.name = string.format(tl("制作: %s","Crafting: %s"),recipe.result_itype.name)
  end
  activity.manuallyCancel =true
  activity.complete_func = complete_make_craft --注册中断和完成的方法。
  activity.cancel_func = cancel_make_craft
  --输入craft自己需要的变量
  activity.command = command
  activity.cost_charges =cost_charges
  activity.cost_material =cost_material
  self:assign_activity(activity)--开始activity。
  debugmsg("past time:"..activity.timePast.."totalTime:"..activity.totalTime)
end






