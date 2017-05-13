
g.itemFactory = {}
local itemf = g.itemFactory
require "game/item/item"

function itemf.createItem(idname)
  local itype = data.itemTypes[idname]
  if itype==nil then debugmsg("couldnt found itemtype to create item:"..idname);return nil end
  local newitem = {type = itype}
  setmetatable(newitem,itemf.item_mt)
  --初始化一些物品内容，或调用init
  newitem:init()
  
  return newitem
end


