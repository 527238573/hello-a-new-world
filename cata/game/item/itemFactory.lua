
g.itemFactory = {}
local itemf = g.itemFactory
require "game/item/item"

function itemf.initItemFactory()
  itemf.fake_fists = itemf.createItem("fake_fists")
  
end
--物品name weight volume等如果需要特化（不同于type本身的属性），则在创建时，保存在实例中。
function itemf.createItem(idname)
  local itype = data.itemTypes[idname]
  if itype==nil then debugmsg("couldnt found itemtype to create item:"..idname);return nil end
  local newitem = {type = itype}
  setmetatable(newitem,itemf.item_mt)
  --初始化一些物品内容，或调用init
  newitem:init()

  return newitem
end



function itemf.make_mon_corpse(montype,name,turn)
  turn = turn or g.calendar.turn()
  if type(montype)=="string" then
    montype = data.monsterType[montype]
  end
  local itype = data.itemTypes["corpse"]
  if itype==nil then debugmsg("couldnt found itemtype corpse!");return nil end
  local newitem = {type = itype}
  setmetatable(newitem,itemf.item_mt)
  --初始化一些物品内容，或调用init
  newitem:init()

  newitem.corpse = montype --标记为corpse
  newitem.corpsename = name-- 特殊唯一名，可能为nil（非命名怪）
  --特化属性
  newitem.img =  itype.img
  newitem.quad =  itype.quads.green --暂定 都是绿色
  if name then
    newitem.name = string.format(tl("%s %s的尸体","%s corpse of%s"),montype.name,name)
  else
    newitem.name = string.format(tl("%s 尸体","%s corpse"),montype.name)
  end

  local size = montype.size
  local weight = 6000
  local volume = 140
  if     size ==1 then weight,volume= 100,3   --tiny  1kg  3dm3
  elseif size ==2 then weight,volume= 3575,80  -- SMALL 35kg
  elseif size ==3 then weight,volume= 7150,200  --MEDIUM 70kg
  elseif size ==4 then weight,volume= 15500,370 --large 155kg
  elseif size ==5 then weight,volume= 30000,920 --HUGE 300kg
  end
  --todo还要材质修正
  newitem.weight = weight 
  newitem.volume = volume
  return newitem
end

function itemf.get_material(id)
  local mat = data.materials[id]
  if mat~=nil then return mat end
  debugmsg("unknow material:"..id.." replaced by null material")
  return data.materials["null"]
end
