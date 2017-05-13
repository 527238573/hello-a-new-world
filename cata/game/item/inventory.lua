
local inv_mt = {}
inv_mt.__index = inv_mt
g.inventory_mt = inv_mt

--只有player和npc有inventory
function g.createInventory()
  local inv ={}
  setmetatable(inv,inv_mt)
  inv:init()
  return inv
  
end

--初始化
function inv_mt:init()
  --默认变量
  self.items= {}--储存所有物品
  self.maxVolume = 2000 --缺省值 20kg
  self.maxWeight = 20 --缺省值，一般要重设
  self.cur_volume = 0 --当前值
  self.cur_weight = 0
  self.itemDirty = false--重量等有变化重计算当前值
  
  self.unsorted = false--标记重排序
  
end

function inv_mt:setMaxCarry(weight,volume)
  self.maxVolume = volume
  self.maxWeight = weight
end

--必须成功，成功后返回item，可能是堆叠后的（会改变）
function inv_mt:addItem(item)
  --不考虑重量体积等，直接加入。
  for i=1,#self.items do --尝试堆叠
    if self.items[i]:try_to_stack_with(item) then
      self.itemDirty = true --不改变排序
      return self.items[i]
    end
  end
  self.items[#self.items+1] = item ---直接加入
  self.itemDirty = true
  self.unsorted  = true
  return item
end
--整个物品移除，不考虑部分stack
function inv_mt:removeItem(item)
  for i=1,#self.items do --尝试堆叠
    if self.items[i] ==item then
      table.remove(self.items,i)
      self.itemDirty = true --排序不变，只有重量变
      return item
    end
  end
  debugmsg("error:remove item cant find in inventory")
  return nil
end

--切割物品，如果是最大值就从背包中删除
function inv_mt:sliceItem(item,num)
  if num<=0 then return nil end
  if not item:can_stack() and num>1 then  debugmsg("error:cant slice unstackable Item!");return nil end
  if num >= item.stack_num then return self:removeItem(item) end --冗余，有大于
  self.itemDirty = true -- 只有数量重量变
  return item:slice(num)
end




function inv_mt:recalculateWeightAndVolume()
  self.itemDirty = false
  local volume = 0
  local weight = 0
  for i=1,#self.items do
    volume = volume +self.items[i]:getVolume()
    weight = weight +self.items[i]:getWeight()
  end
  self.cur_volume = volume
  self.cur_weight = weight
end
--重量
function inv_mt:getWeight()
  if  self.itemDirty then self:recalculateWeightAndVolume() end
  return self.cur_weight
end
function inv_mt:getVolume()--体积
  if  self.itemDirty then self:recalculateWeightAndVolume() end
  return self.cur_volume
end



local function itemcompare(item1,item2)
  --先比较categories  后面再定
  
  return item1.type.id<item2.type.id --最终比较type id
end
function inv_mt:sort()
  if not self.unsorted then return end
  self:restack()
  table.sort(self.items,itemcompare)
end

--重新堆叠，比较繁琐
function inv_mt:restack()
  local olditems = self.items
  local newitems = {}
  local haschange = false
  for i=1,#olditems do
    local toadd = olditems[i]
    local stacked = false
    for j=1,#newitems do
      if newitems[j]:try_to_stack_with(toadd) then
        stacked = true
        haschange = true
        break;
      end
    end
    if not stacked then
      newitems[#newitems+1] = toadd
    end
  end 
  if haschange then --有变化时才改
    self.items = newitems
    self.itemDirty = true--堆叠可能导致小物件重量变化
    self.unsorted  = true
  end
end




