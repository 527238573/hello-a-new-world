
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
    weight = 0, --重量，最小单位，也就是1= 10g，显示为0.01kg  100 = 1kg ，cdda为1g 也就是1000= 1kg
    volume = 0, --体积，最小0，小单位按堆叠数量为一组 ，
    price = 0, --灾变前价格
    price_post = 0,--灾变后价格
    stack_size = 0, --堆叠数量，也就是一组的数量，按整组算重量体积
    canStack = false, --能否堆叠  stack_num 变量来标记，不用charges，
    integral_volume = nil,--集成体积，和其他物品组装后的体积，一般不用，使用原体积
    rigid = true,--是否刚体，作为容器使用时（非刚体不装东西体积较小）
    melee_dam = 0, --近战3属性，钝击 特殊（劈砍 穿刺 刺击） 命中修正
    melee_cut = 0, --不设这些属性是0，相当于拳头，但手持攻击仍会损毁物品（比如手持食物来攻击）
    melee_stab= 0, --清楚的标注stab，不再奇怪的flag变化
    m_to_hit = 0,--To-hit bonus for melee combat; -5 to 5 is reasonable 命中加成
    weapon_appreance = nil,--作为weapon时的外观，table，数据模式看melee文件

    container = nil,--default container 默认容器
    toolLevel = nil, -- 工具等级，等于cdda的qualities，用于配方需求检查 ｛COOK =1,｝--这样
    --cdda 的properties属性 居然只有一个物品使用 ，废弃
    material = nil,--材质，一般实体物品必有此属性{"steel","cotton"}   --可能为 单字符串，不是table，可能要兼容处理
    use_action = nil, --使用物品， 数据是table，或string，可能load后连接到method 
    flags = {}, --flag 也即item_tag  默认空table，模式为 ｛xx = true｝，
    techniques = nil, --近战武器特殊技巧table，格挡 残暴打击等等｛｝  使用flagt变换
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
    quad = {0,0}, --使用item1.png的第一个 --需要有值来默认图标。
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

  comestible={--消耗品，不仅仅是food,可能是药之类
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
    covers = {},--table，部位名称=true为覆盖该位置            cdda是二进制比特数据，不同位代表不同部位。。
    encumber = 0,--阻碍
    coverage = 0,--覆盖率
    thickness = 0,--厚度，一项防御属性
    env_resist = 0,--Resistance to environmental effects.
    warmth = 0,--保暖度
    storage = 0,--容纳空间
    armor_layer = 2,  --层次，1为内衣 2为中层衣物 3为外衣， 4为包等， 5 挂最外层的，比包还外的
    
    guise = nil,-- 字符串：upper（上衣）,lower（下装）,whole(全身装),head（头）,其他等 ,装备动画覆盖位置
    guise_data = nil, --table  ,file = 文件名，不带后缀，都为png，在equipment文件夹里找  其他参数
    
    category = "armor",
  },

  book = {
    item_type = "book",
    --暂不填
  },
  
  gun = { --远程武器
    item_type = "gun",
    skill_used = "pistol",--射击武器的类型（影响技能）
    ammotype = "l_pistol", --子弹类型， 目前有 轻型手枪子弹l_pistol，重型手枪子弹h_pistol，轻型步枪子弹l_rifle，重型步枪子弹h_rifle，霰弹shotgun，（狙击sniper，训练等）
    
    pierce = 0, --穿甲加成，要和子弹一起算
    range = 0, --射程加成
    damage = 0,--伤害加成
    dispersion = 0,--散布加成
    sight_dispersion = 0,--视野散布，后面再看作用
    recoil = 0,--后坐力加成
    
    loudness = 0,--射击声响，可能还有reload声响
    aim_speed = 0,--瞄准速度，后面再看作用
    
    durability= 0,--Gun durability, affects gun being damaged during shooting.
    magazine_size = 0,--弹匣容量，cdda中弹匣和枪是分开的，这里不分开
    reload_time = 0.8, --单位秒，受到技能减成
    barrel_length = 0,--枪管长度，暂和cdda一致，作用后面再发掘
    --子弹附加特效和 枪械模组 省略，后面再说
    bullet_anim = "bullet1",--子弹动画
    fire_sound = "fire_9mm",--子弹发射时音效
    reload_sound = "reload_pistol", --reload时音效
    semi_auto_shot = 0.4, --射击间隔时间，自动射击模式下
    
    burst = false,--能否全自动射击
    burst_shot = 0.2,--射击间隔时间，burst模式下
    burst_size = 2,--burst size， burst一次最小发射数
  },
  
  ammo = {
    item_type = "ammo",
    ammotype = "l_pistol",--口径类型，和之前的一样
    canStack = true,--必须能堆叠
    pierce = 0, --穿甲加成，要和枪一起算
    range = 0, --射程加成
    damage = 1,--伤害加成
    dispersion = 0,--散布加成
    recoil = 0,--后坐力加成
    
    recover_rate = 0,--回收率,通常弓箭类有几率捡回，几率0.8 = 80%这样
    --
    ammo_speed = 1000,--动画飞行速度
    ammo_accurateness = 1000, --闪避度，越低越容易闪避
    bullet_anim = nil,--子弹动画，弓箭等专用，不同的箭外观不同，子弹有动画就优先用子弹的
    --击中声音。。。
  },
  
  --后面几个远程武器，枪的先不填
}

local loaded_imgs ={}
local loaded_quads = {}
local function getItemImage(img)
  if loaded_imgs[img]==nil then
    loaded_imgs[img] = love.graphics.newImage("data/item_img/"..img..".png")
  end
  return loaded_imgs[img]
end
local function getQuad(img,quad) --加入缓存。
  local key = quad[1]*100+quad[2]
  local table = loaded_quads[img]
  if table ==nil then table={};loaded_quads[img] =table end
  if table[key] then return table[key] end
  local w = quad.w or 32 --默认当然是32*32，当然可以更大
  local h = quad.h or 32 
  local newquad= love.graphics.newQuad(quad[1]*32,quad[2]*32,w,h,img:getDimensions())
  table[key] = newquad
  return newquad
end

local function getGuiseData(guise,guise_data)
  local gd = {}
  gd.always_front = guise_data.always_front --总在最前
  local img = love.graphics.newImage("data/equipment/"..guise_data.file..".png")
  gd.img = img
  local w = guise_data.w or 32 --默认当然是32*32一个格子
  local h = guise_data.w or 32 
  
  if guise =="lower" then
    for i=1,8 do
      gd[i] = love.graphics.newQuad((i-1)*w,0,w,h,img:getDimensions())--8格动画
    end
  else
    gd[1] = love.graphics.newQuad(0,0,w,h,img:getDimensions())--只用2个
    gd[2] = love.graphics.newQuad(1*w,0,w,h,img:getDimensions())
  end
  return gd
end

local function getWeaponAppreance(weapon_appreance)
  weapon_appreance.img = love.graphics.newImage("data/equipment/"..weapon_appreance.file..".png")
  weapon_appreance.scaleFactor = weapon_appreance.scaleFactor or 2
  --都是单张的图
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
  if itype.quads then --连续的多个quad
    for k,v in pairs(itype.quads) do
      itype.quads[k] = getQuad(itype.img,v)
    end
  end
  if itype.plural_quad then --复数 图像，
    itype.plural_quad = getQuad(itype.img,itype.plural_quad)
  end
  
  
  --guise装备外观
  if itype.guise then
    itype.guise_data = getGuiseData(itype.guise,itype.guise_data)
  end
  if itype.weapon_appreance then
    getWeaponAppreance(itype.weapon_appreance)--输入至table内
  end
  --兼容 material
  if type(itype.material)=="string" then--单材质
    itype.material = {[1] = itype.material}
  end
  
  --将itype填入列表
  if itemTypes[itype.id] ~=nil then
    debugmsg("create item type warnning: duplicate item type id:"..itype.id)
  end
  itemTypes[itype.id] = itype
end


local function load_materials()
  local list = dofile("data/other/materials.lua")
  local materials = {}
  for _,v in ipairs(list) do
    materials[v.id] = v
  end
  data.materials = materials
end

--在物品之后
local function load_toolQualities()
  local list = dofile("data/other/toolQualities.lua")
  local img = love.graphics.newImage("data/item_img/toolquality.png")
  local default_quad = love.graphics.newQuad(0,0,32,32,img:getDimensions())
  debugmsg("tool quality length:"..#list)
  
  data.qualities = {}
  for i=1,#list do
    local onequality = list[i]
    data.qualities[onequality.id]=onequality
    onequality.img = img
    if onequality.quad then
      onequality.quad = love.graphics.newQuad(32*onequality.quad[1],32*onequality.quad[2],32,32,img:getDimensions())
    else
      onequality.quad = default_quad
    end
    onequality.typelist= {}
  end
  for typeid,v in pairs(data.itemTypes) do
    if v.toolLevel then
      for toolid,_ in pairs(v.toolLevel) do
        local quality =data.qualities[toolid]
        if quality==nil then 
          debugmsg(string.format("Error tool quality id: %s in itemtype:%s",toolid,typeid))
        else
          table.insert(quality.typelist,v)
        end
      end
    end
  end
end


function data.loadItemTypeData()
  if loaded then return else loaded = true end
  load_materials()--读取
  
  local fs = lovefs(love.filesystem.getSource().."/data/item")
  for _, v in ipairs(fs.files) do --
    local tmp = dofile("data/item/"..v) -- 执行文件夹内所有文件，载入所有itemtype列表
    debugmsg("itemtype file:"..v.." length:"..#tmp)
    for i=1,#tmp do
      loadOneItemType(tmp[i])--载入一项
    end
  end
  --几个默认数据
  data.default_eq = {}
  data.default_eq.head = getGuiseData("head",{file = "default_head"})
  data.default_eq.upper = getGuiseData("upper",{file = "c_default"})
  data.default_eq.lower = getGuiseData("lower",{file = "p_default"})
  
  --载入tool数据
  load_toolQualities()
  
  --清除缓存数据。
  loaded_imgs ={}
  loaded_quads = {}
end
