
local lovefs = require("file/lovefs")
local loaded = false
--只映射名字id到数据
data.itemTypes = {}
local itemTypes = data.itemTypes

local default_template = 
{
  common = { --所有物品类型共有的成员
    id = "null",
    name = "null item",
    description = "", --可能是富文本
    item_type = "generic", --功能分类
    category = "other",  --意义分类
    weight = 0, --重量，最小单位，也就是1= 10g，显示为0.01kg
    volume = 0, --体积，最小0，小单位按堆叠数量为一组 ，
    price = 0, --灾变前价格
    price_post = 0,--灾变后价格
    stack_size = 0, --堆叠数量
    canStack = false, --能否堆叠  stack_num 变量来标记，不用charges，
    integral_volume = nil,--集成体积，和其他物品组装后的体积，一般不用，使用原体积
    rigid = true,--是否刚体，作为容器使用时（非刚体不装东西体积较小）
    melee_dam = 0, --近战3属性，钝击 特殊（劈砍 穿刺 刺击） 命中修正
    melee_cut = 0, --不设这些属性是0，相当于拳头，但手持攻击仍会损毁物品（比如手持食物来攻击）
    m_to_hit = 0,


    container = nil,--default container 默认容器
    toolLevel = nil, -- 工具等级，等于cdda的qualities，用于配方需求检查
    --cdda 的properties属性 居然只有一个物品使用 ，废弃
    material = nil,--材质，一般实体物品必有此属性{"steel","cotton"} 
    use_action = nil, --使用物品， 数据是table，可能load后连接到method
    flags = nil, --flag 也即item_tag 
    techniques = nil, --近战武器特殊技巧table，格挡 残暴打击等等｛｝
    requireAttr = nil, --使用武器需要的力量敏捷等，cdda中也只有少数几个弓才有
    requireSkill = nil,--同上的skill限制，cdda 中是部分GUNMOD对gun等级机械学等级进行限制
    explosion = nil, --爆炸信息 power distance_factor causefire shrapnel：count mass recovery drop（itemtypeid）
    explosionInFire = nil,--nil即为false，是否在火中爆炸
    phase = nil, --默认nil为固体，其他为液体（没见到cdda此项为气体的，更别提等离子体） 为液体时需要容器，显然的
    light_emission = nil,--发光度，nil为不发光 cdda中是加个light300之类的flag，
    --cdda中的magazine 取消，只考虑用哪种类型的子弹
    count_by_charges = nil, --特殊类型会堆叠   此项转用canStack，本项废弃
    maximum_charges = nil, --考虑可充能物品
    charges_per_use =nil, --考虑可充能物品
    charges_default = nil,--考虑可充能物品

    --物品图标  在生成类型时会被替换为实际指向img 和quad
    img = "item1", --默认的无图标物品的图标，
    quad = {0,0}, --使用item1.png的第一个
  },

  tool={
    item_type = "tool",
    ammo_id = "null",--可以充能的燃料电池等
    revert_to = nil,--熄灭或关闭
    revert_msg = nil,--触发时信息
    subtype = nil,-- 特殊消耗charges 的同类型
    maximum_charges = 0,
    charges_default = 0,
    charges_per_use = 0,--每次消耗charge
    turns_per_charge = 0,--每回合消耗
  },

  comestible={--消耗品，不仅仅是food
    item_type = "comestible",
    comestible_type = "FOOD",--subtype, eg. FOOD, DRINK, MED
    tool = "null",--tool needed to consume (e.g. lighter for cigarettes) 
    quench= 0,--effect on character thirst (may be negative) */
    nutr = 0,--effect on character nutrition (may be negative)
    spoils = 0,--turns until becomes rotten, or zero if never spoils */
    addict = 0,--addiction potential */上瘾潜力
    add_type = nil,--上瘾种类 "ADD_CAFFEINE"
    fun= 0, --effect on morale when consuming */
    stim = nil, --stimulant effect */
    healthy = 0,--健康度修正，不健康食物可生病等
    
    canStack = true,--消耗品默认可堆叠
    stack_size = 1,--份量默认为1 --份量为一份单位体积，比如份量是10，那个数1-10都占用1体积，11个则算2组占用两个--一般为1，对于多次使用的堆簇物品，比如爆米花，设为多个
    
  },

  container = {
    item_type = "container",
    contains = 0,--Volume, scaled by the default-stack size of the item that is contained in this container.
    watertight= false,--水密容器
    preserves = false; --防止腐坏
    seals = false; -- Can be resealed. 能重封闭？
  },
  armor = {
    item_type = "armor",
    covers = 0,--二进制比特数据，不同位代表不同部位。。
    encumber = 0,--阻碍
    coverage = 0,--覆盖率
    thickness = 0,--厚度，一项防御属性
    env_resist = 0,--Resistance to environmental effects.
    warmth = 0,--保暖度
    storage = 0,--容纳空间
  },

  book = {
    item_type = "book",
    --暂不填
  },
  --后面几个远程武器，枪的先不填
}

local loaded_imgs ={}

local function getItemImage(img)
  if loaded_imgs[img]==nil then
    loaded_imgs[img] = love.graphics.newImage("data/item_img/"..img..".png")
  end
  return loaded_imgs[img]
end
local function getQuad(img,quad)
  local w = quad.w or 32 --默认当然是32*32，当然可以更大
  local h = quad.h or 32 
  return love.graphics.newQuad(quad[1]*32,quad[2]*32,w,h,img:getDimensions())

end

local function loadOneItemType(itype_table)
  local itype = {} --自建新table
  if itype_table.copy_from then
    --使用已有类型做模版，注意已有类型必须在此项之前被创建出来，
    --否则会报错。通常要保证写在同一文件中，并保证被copy类型在前面
    local copy_template = itemTypes[itype_table.copy_from]
    if copy_template==nil then error("not found copy_from itemtype:"..itype_table.copy_from..",create itemtype error:"..itype_table.id) end
    for k,v in pairs(copy_template) do --填入所有copy项的默认值
      itype[k] = v
    end
  else
    --创建新类型，填入各种默认值
    for k,v in pairs(default_template.common) do --填入所有物品都有的默认值
      itype[k] = v
    end
    if itype_table.item_type~= "generic" then
      local template = default_template[itype_table.item_type] --寻找特定类型默认值模版
      if template==nil then error("item_type wrong:"..itype_table.item_type) end
      for k,v in pairs(template) do  --填入特定类型的默认值
        itype[k] = v
      end
    end
  end
  for k,v in pairs(itype_table) do  --填入输入table的各种值 --copy_from各种值也被填入，不管
    itype[k] = v
  end
  --检查图标
  if type(itype.img)=="string" then itype.img = getItemImage(itype.img) end--寻找图标img
  if type(itype.quad)=="table" then itype.quad = getQuad(itype.img,itype.quad) end --创建图标quad
  --将itype填入列表
  if itemTypes[itype.id] ~=nil then
    debugmsg("create item type warnning: duplicate item type id:"..itype.id)
  end
  itemTypes[itype.id] = itype
end

function data.loadItemTypeData()
  if loaded then return else loaded = true end
  local fs = lovefs(love.filesystem.getSource().."/data/item")
  for _, v in ipairs(fs.files) do --
    local tmp = dofile("data/item/"..v) -- 执行文件夹内所有文件，载入所有itemtype列表
    debugmsg("itemtype file:"..v.." length:"..#tmp)
    for i=1,#tmp do
      loadOneItemType(tmp[i])--载入一项
    end
  end
end
