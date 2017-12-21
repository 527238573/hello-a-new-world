local itemf = g.itemFactory

local item_mt = {} --metatable
g.itemFactory.item_mt = item_mt
item_mt.__index = item_mt

require"game/item/itemfunc/armor"
require"game/item/itemfunc/weapon"
require"game/item/itemfunc/gun"
require"game/item/itemfunc/item_recipe"
function item_mt:init()
  local thistype = self.type
  --物品初次被创建时通用调用
  self.stack_num = 1 --默认就叠一个,不可堆叠的物品也建一个此变量
  if thistype.canStack and thistype.stack_size>0 then self.stack_num = thistype.stack_size end --初始值
  self.charges = thistype.charges_default or 0 --没有charge的物品也建一个此变量
  
  self.damage = 0 --物品损坏程度，负值则为强化过的， 达到5会摧毁物品，所以4及以上都视为4，防出错
  
end

--绘图专用
function item_mt:getImgAndQuad()
  if self.corpse then return self.img,self.quad end
  if self.type.item_type=="ammo"  and self.type.plural_quad then --复数的图像
    if self.stack_num>=3 then return self.type.img,self.type.plural_quad end
  end
  return self.type.img,self.type.quad --默认
end

--信息显示名称，携带一定的信息
function item_mt:getName()
  local name = self.name or self.type.name
  if self:can_reload(false) then
    name = name.."("..self:get_ammo_number()..")"
  elseif self.stack_num>1 then --有堆叠
    name = name.."("..self.stack_num..")"
  end
  return name
end

--一般性名称，用于说明提示中  等等
function item_mt:getNormalName()
  local name = self.name or self.type.name
  return name
end

--总重量，包含堆叠
function item_mt:getWeight()
  local weight = self.weight or self.type.weight
  if self.type.stack_size>0 then
    return  math.ceil( self.stack_num/self.type.stack_size) *weight
  end
  return self.stack_num*weight
end
--总体积，包含堆叠
function item_mt:getVolume()
  local volume = self.volume or self.type.volume
  if self.type.stack_size>0 then
    return  math.ceil( self.stack_num/self.type.stack_size) *volume
  end
  return self.stack_num*volume
end

function item_mt:can_stack()
  return self.type.canStack
end

function item_mt:set_stack(num)
  self.stack_num = num
end

--获取充能数量
function item_mt:get_charges()
  return self.charges
end

function item_mt:cost_charges(num_charges)
  self.charges = math.max(0,self.charges - num_charges)--不能为负
end

--试着堆叠，成功销毁旧物品保留原物品。不成功返回false
function item_mt:try_to_stack_with(oitem)
  if self.type~= oitem.type then return false end
  if not self.type.canStack then return false end
  self.stack_num = self.stack_num +oitem.stack_num
  return true

end

--能否从地上捡起，液体不能直接捡起
function item_mt:can_pickup()
  return true
end


function item_mt:slice(num)
  if num>=0 and num<self.stack_num then
    local newitem = itemf.createItem(self.type.id)
    newitem.stack_num = num
    self.stack_num = self.stack_num -num
    return newitem
  end
  return nil
end


function item_mt:has_flag(flag_str)
  return self.type.flags[flag_str] --flag
end

