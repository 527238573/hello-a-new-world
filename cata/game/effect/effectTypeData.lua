g.effect = {}
local geffect = g.effect
local loaded = false
data.effectTypes = {}
data.traitTypes = {}

local effect_default_value = {
  id = "null",
  name = "no_name",
  description = "on_description",
  max_duration = 30,--30秒
  max_intensity = 1,--[1,1]之间
  
  rating = "normal", --good，bad 等等，有益有害
  
  change_bonus = false,--表示会修改bonus，mod_data有值时必须为true，其他情况比如存在reduce可能时也要设为true，
  
  --颜色，名字颜色以示区分，默认黑
  color = {22,22,22},
  
  --apply_message
  --remove_message --可选
  
  --blocks_effects = {"xx","yy"} --阻挡的effect
  --removes_effects = {"xx","yy"} --替换 、消除的effect
  
  --resist_effects = {"xx","yy"} --  削减此项的effect-- 其他effect需要将change_bonus设为true才会在添加时执行削减效果
  --resist_traits = {"xx","yy"} --  削减此项的特性
  --[[mod_data =  --属性影响值
  {  xxxatr_id = {base_mod = xx, base_reduced =xx,scaling_mod = xx,scaling_reduced==xx}  --键值为属性名, reduced为缩减后的数值，scaling为intensity>1时的额外每个intensity增加值。默认不填都为0
  }             --其他如百分比变化，后续再添加
  --]]
  
  --miss_reasons = {{"reason1",weight1},{"reason2",weight2},....}--未命中原因，只对player有效
}

--特性、变异
local trait_default_value = {
  id = "null",
  name = "no_name",
  description = "on_description",
  --names = {xx,xx,xx..}
  --description = {xx,xx,xx..} --多等级的名称和描述，对应多个等级，没有就用基本的名字和描述
  min_level = 1,--最小等级，负面状态？
  max_level = 1,--最大等级，可以有多层变异
  
  rating = "good", --good，bad 等等，有益有害
  change_bonus = false,--表示会修改bonus，mod_data有值时必须为true，
  
  --blocks_effects = {"xx","yy"} --阻挡的effect，也会自动清除
  
  --[[mod_data =  --属性影响值
  {  xxxatr_id = {[1] = xx, [2] = xx,[-1] ==xx,..}  --键值为属性名,   只有等级对应值，[1] =xx就是1级变化的数值。 负值就是负等级。不填的默认都为0
  }             --其他如百分比变化，后续再添加
  --]]
  
  --miss_reasons = {{"reason1",weight1},{"reason2",weight2},....}--未命中原因，只对player有效
  
  --apply_message
  --remove_message --可选
  
}



local function loadOneEffect(eff)
  for k,v in pairs(effect_default_value) do
    if eff[k]==nil then
      eff[k] = v
    end
  end
  if eff.mod_data then eff.change_bonus = true end--mod_data有值时必须为true
  data.effectTypes[eff.id] = eff
end

local function loadOneTrait(trait)
  for k,v in pairs(trait_default_value) do
    if trait[k]==nil then
      trait[k] = v
    end
  end
  if trait.mod_data then trait.change_bonus = true end--mod_data有值时必须为true
  data.traitTypes[trait.id] = trait
end

function data.loadEffectTypes()
  if loaded then return else loaded = true end
  local tmp = dofile("game/effect/data/effectType1.lua")
  
  for _,v in ipairs(tmp) do
    loadOneEffect(v)
  end
  
  local tmp2 = dofile("game/effect/data/traitType1.lua")
  
  for _,v in ipairs(tmp2) do
    loadOneTrait(v)
  end
  
end