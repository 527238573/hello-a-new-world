


local default_component_val  ={
  id = "null",--唯一id
  name = "noname_component",
  --图形。
  --没有图标的组件会用相应物品图标（如果要用图标的话。）
  quads = nil,--   table，里面可以用N个quad或一个。N个时可以是多颜色或多种相邻。broken 或open 也占一个table，里面也是N种颜色？（这种可以没有。）
  --[[quads内部详解。 1-n键值表示N个quad，可以用来表示多颜色或 相邻变化模式，
        颜色超过一个时，ncolor = true.   表示相邻时nborder = true.不能同时启用。启用后broken和open也变成对应的n颜色table。未启用就没有table，相应值只是一个quad。
        rot = 旋转值，弧度顺时帧. sx= 1,sy=1, 翻转有缩放值正负,只需要设为-1。
        
        --veh_components1 全部使用这个img，使用batch加速。
  --]]--
  styles = nil,--当拥有多种样式时，可能变换quad，或者旋转。 里面是一个style的列表，每个style是table。 多个style时quads一般没有，自动设为styles第一项。  一个styletable里面可有N个quad可待表多种颜色。
  cover_all =false,--图像quad是否全覆盖。对anywhere不一定有用。
  
  
  --基本属性
  location = "anywhere",--占用槽位，相同槽位不能多个。同种不能多个。anywhere是任意槽位。槽位顺序也表示绘制顺序。
  --location会转化为Zorder，表示位置。
  
  
  difficulty = 0,--安装难度
  durability = 100,--最大血量？
  dmg_mod =100,--百分比的伤害修正。比如是10就是仅受到10%的伤害。
  flags={},--还是标准的flagt，xx=true这样。
  --[[已知的flag
    OBSTACLE 堵住移动，但不影响视觉
    OPENABLE 可开门，使OBSTACLE失效的。
    OPAQUE  挡住视觉
    TOOL_NONE--无需工具
    TOOL_WRENCH-- 扳手工具
    WELDING10 --正常焊接的2倍。不标明工具是默认1倍焊接
    PROTRUSION--突出物，非车架的车架层物体，如钉刺
    
    WINDOW --窗户
    CURTAIN--窗帘
    FUEL_TANK--邮箱
    ALTERNATOR -- 发电机
    ENGINE--引擎
    GASOLINE--使用汽油的engine
    ELECTRIC--使用电能的engine
    DIESEL--使用柴油的engine
    MUSCLE--肌肉engine
    CONTROLS --控制器。
    ON_CONTROLS--必须在控制器之上的物体。
  --]]
  
  --物品相关
  item_id = nil,--与之对应的物品id
  breaks_into = nil,--可以是string或table  string就是物品组id，table就描述一个当前的物品组。


  --其他引擎 储存，特殊功能等等，设额外的子table，数据存在子table里。
  cargo = nil,--数字，储存体积数量。有此项才能存。
  tank = nil,--tank = {gas = 60000} 60L汽油箱，里面数字按毫升算
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
local function loadOneQuads_t(q_t)
  local img = getItemImage(q_t.img)
  q_t.img=img
  for i=1,#q_t do
    q_t[i] = getQuad(img,q_t[i])
  end
  if q_t.nborder or q_t.ncolor then
    local broken = q_t.broken
    if broken then
      for i=1,#broken do
        broken[i] = getQuad(img,broken[i])
      end
    end
    local open = q_t.open
    if open then
      for i=1,#open do
        open[i] = getQuad(img,open[i])
      end
    end
  else --单一的quad
    if q_t.broken then q_t.broken = getQuad(img,q_t.broken) end
    if q_t.open then q_t.open = getQuad(img,q_t.open) end
  end
end

--位置排序信息。
local zorder = {
    
    armor = -2,--
    --对于未定义位置的部件，默认设为0，
    under = 1,--wheels
    tank = 2, --邮箱
    tank2 = 3, --电池盒？
    fuel_source = 4,
    engine_block = 5,
    structure =7,
    center =8,
    top = 9,
    roof =10,
    on_roof = 12,
    
    anywhere = 13,--基本是无显示的
}




data.veh_components = {}
local function loadOneComponent(component)
  for k,v in pairs(default_component_val) do
    if component[k]==nil then
      component[k] = v--填充默认内容。
    end
  end
  --可能要检查之后再放入。
  data.veh_components[component.id]=component
  --后续处理。
  if component.quads then loadOneQuads_t(component.quads) end
  if component.styles then
    for i=1,#component.styles do loadOneQuads_t(component.styles[i]) end
  end
  --通过location 设置zorder。不同location可以相同，但仍然可同时装备。
  component.zorder = zorder[component.location] or 0 --默认为0
end

local lovefs = require("file/lovefs")
local loaded = false
function data.load_vehicle_components()
  if loaded then return else loaded = true end
  local fs = lovefs(love.filesystem.getSource().."/data/vehicle/components")
  for _, v in ipairs(fs.files) do --
    local tmp = dofile("data/vehicle/components/"..v) -- 执行文件夹内所有文件，载入所有itemtype列表
    debugmsg("veh components file:"..v.." length:"..#tmp)
    for i=1,#tmp do
      loadOneComponent(tmp[i])--载入一项
    end
  end
  data.vehicleBatch_img = getItemImage("veh_components1")
  --清除缓存数据。
  loaded_imgs ={}
  loaded_quads = {}
  
end