local itemf = g.itemFactory

local item_mt = {} --metatable
g.itemFactory.item_mt = item_mt
item_mt.__index = item_mt


function item_mt:init()
  local thistype = self.type
  --物品初次被创建时通用调用
  self.stack_num = 1 --默认就叠一个,不可堆叠的物品也建一个此变量
  if thistype.canStack and thistype.stack_size>0 then self.stack_num = thistype.stack_size end --初始值
  self.charges = thistype.charges_default or 0 --没有charge的物品也建一个此变量
end

function item_mt:getName()
  local name = self.type.name
  if self.stack_num>1 then --有堆叠
    name = name.."("..self.stack_num..")"
  end
  return name
end

--总重量，包含堆叠
function item_mt:getWeight()
  if self.type.stack_size>0 then
    return  math.ceil( self.stack_num/self.type.stack_size) *self.type.weight
  end
  return self.stack_num*self.type.weight
end
--总体积，包含堆叠
function item_mt:getVolume()
  if self.type.stack_size>0 then
    return  math.ceil( self.stack_num/self.type.stack_size) *self.type.volume
  end
  return self.stack_num*self.type.volume
end

function item_mt:can_stack()
  return self.type.canStack
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