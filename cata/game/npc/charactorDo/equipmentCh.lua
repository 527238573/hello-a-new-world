local charactorBase = g.creature.charactorBase


--先用can_wear测试能否穿上，然后取消指针托管，将无托管状态的物品传给wear_item,是正确穿物品的顺序
function charactorBase:can_wear(to_wear,interactive)
  if not to_wear:is_armor() then
    if interactive then self:add_msg_if_player(string.format(tl("想要穿%s是不可能的。","Putting on a %s would be tricky."),to_wear:getNormalName()),"info") end
    return false
  end
  for i=1,#self.worn do
    if to_wear == self.worn[i] then
      if interactive then self:add_msg_if_player(tl("你已经穿着它了。","You are already wearing that."),"info") end
      return false
    end
  end
  --动力甲
  --同种 穿着数量限制
  --头，鞋穿着限制
  --WOOLALLERGY，oversize
  return true
end

function charactorBase:wear_item(to_wear,interactive)
  if not self:can_wear(to_wear,interactive) then return false end
  self:add_to_worn(to_wear)
  self:add_msg_if_player(string.format(tl("你穿上你的%s。","You put on your %s."),to_wear:getNormalName()),"info") 
  --装备改变
  self:on_wear_change()
  return true
  --提示信息发送
end
--传递target item，返回是否成功，不成功会出错误信息
function charactorBase:take_off(target,interactive)
  if target == self.weapon then return self:unwield(interactive) end
  
  local found = false
  for i=1,#self.worn do
    if target == self.worn[i] then
      table.remove(self.worn,i)
      found = true
    end
  end
  if not found and interactive then self:add_msg_if_player(tl("你没有穿着该物品。","You are not wearing that item."),"info"); return false end
  self.inventory:addItem(target)
  if interactive then self:add_msg_if_player(string.format(tl("你脱下你的%s。","You take off your %s."),target:getNormalName()),"info")  end
  self:on_wear_change()
  return true
end

--如果物体是容器什么的，内容物掉到地上（或装包里，不能再添加身上因为可能在一个worn的遍历中）
function charactorBase:destory_worn(target)
  for i=1,#self.worn do
    if target == self.worn[i] then
      table.remove(self.worn,i)
      self:on_wear_change()
      return
    end
  end
  debugmsg("error: not found the equipment to be destory")
end


--下面三个同上
--考虑能否替换现手中的物品
function charactorBase:can_wield(to_weild,interactive)
  return true
end
function charactorBase:can_unwield(interactive)
  return true
end 


local wield_info = tl("手持","wield")
--返回成功与否，调用此方法前必须先调用检查，然后取消原物品指针，传入此
function charactorBase:wield_item(to_weild,interactive)
  if not self:can_wield(to_weild,interactive) then return false end
  self:unwield(false) --必成，上面已经检查了
  if to_weild == nil then return true end --为空则返回
  self.weapon = to_weild
  --todo 手持触发 weapon.on_wield
  --动作耗时，msg
  --暂时使用固定时间 todo：修改为多种因素的
  self:add_msg_if_player(string.format(tl("你手持了%s。","You wield your %s."),to_weild:getNormalName()),"info") 
  self:shortActivity(wield_info,0.7) --固定时间
  
  return true
end
--自动放入背包，
--返回成功与否
function charactorBase:unwield(interactive)
  if not self:can_unwield(interactive) then return false end
  local weapon = self.weapon
  self.weapon = nil
  if weapon~=nil then self.inventory:addItem(weapon) end
  
  return true
end

--仅插入数据
function charactorBase:add_to_worn(to_wear)
  local insert_pos = nil
  local curlayer = to_wear:get_armor_layer() 
  for i=1,#self.worn do
    local witem = self.worn[i]
    if witem:get_armor_layer()> curlayer then
      insert_pos = i
    end
  end
  insert_pos = insert_pos or #self.worn+1
  table.insert(self.worn,insert_pos,to_wear) --插入装备列表
end

--装备改变触发，装备穿脱，被打爆等  基本创建实例时要调用一次此函数，生成基本数据结构
function charactorBase:on_wear_change()
  --recalc_sight_limits
  --calc_encumbrance
  --创建装备数据表格
  local wearing_data = {}
  self.wearing_data = wearing_data
  
  local total_weight = 0 --统计重量，存储空间
  local total_storage = 0
  local bodypart_list = self:get_bodypart_list()--取得当前部位
  local encumber = {};wearing_data.encumber = encumber
  local cover = {};wearing_data.cover = cover
  local warmth = {};wearing_data.warmth = warmth
  for i=1,#bodypart_list do
    encumber[bodypart_list[i]] = {base = 0,add = 0,all = 0}
    cover[bodypart_list[i]] = {}
    warmth[bodypart_list[i]]  = 0
  end
  local display = {head = {},torso = {},arms = {},hands = {},legs = {},feet = {}}
  wearing_data.display = display
  local function bodypart_to_displaypart(bodypart)
    if bodypart=="bp_head" or bodypart=="bp_eyes" or bodypart=="bp_eyes" then
      return "head"
    elseif bodypart=="bp_torso" then
      return "torso"
    elseif bodypart=="bp_arm_l" or bodypart=="bp_arm_r" then
      return "arms"
    elseif bodypart=="bp_hand_l" or bodypart=="bp_hand_r" then
      return "hands"
    elseif bodypart=="bp_leg_l" or bodypart=="bp_leg_r" then
      return "legs"
    elseif bodypart=="bp_foot_l" or bodypart=="bp_foot_r" then
      return "feet"
    else
      return "torso"--默认
    end
  end
  
  --创建数据结构
  for i=1,#self.worn do
    local witem = self.worn[i]
    total_weight = total_weight+ witem:getWeight()
    total_storage = total_storage + witem:get_storage()
    local covers = witem:get_coverlist()
    local add_display = false
    for bodypart,_ in pairs(covers) do
      if cover[bodypart] then
        table.insert(cover[bodypart],witem) --插入装备位置表，没有的部位忽略，不覆盖的装备忽略
        warmth[bodypart] = warmth[bodypart]+witem:get_warmth()--累加保暖度
      end
      local disname = bodypart_to_displaypart(bodypart)
      local target_list = display[bodypart_to_displaypart(bodypart)]
      if target_list[#target_list] ~= witem then --不能重复插入
        table.insert(target_list,witem)--插入 display list
      end
      add_display = true
      --debugmsg("add bodypart:"..disname)
    end
    if add_display==false then table.insert(display.torso,witem) end --无cover的装备，也显示出来，显示在躯干上。。。
  end
  --计算累赘值
  --数目累加的共通方法
  local function calc_layer_encumbrance(layer,num,target_encumber)
    if num<=1 then return end --一件不加累赘
    --1层每三件加1累赘
    --2层，每两件加一累赘
    --3层以上 每件 多的加一累赘
    if layer==1 then
      target_encumber.add =target_encumber.add+ math.floor(num/3)
    elseif layer ==2 then
      target_encumber.add =target_encumber.add+ math.floor(num/2)
    else
      target_encumber.add =target_encumber.add+ (num-1)
    end
  end
  --遍历部位
  for i=1,#bodypart_list do
    local bodypart = bodypart_list[i]
    local target_list = cover[bodypart]
    local target_encumber = encumber[bodypart]
    local cur_layer = 1 --从1层开始
    local cur_layer_num = 0
    for j= 1,#target_list do
      local witem = target_list[j]
      --累加基本累赘度
      target_encumber.base = target_encumber.base + witem:get_encumber()
      if witem:get_armor_layer()>cur_layer then
        --计算层累赘度
        calc_layer_encumbrance(cur_layer,cur_layer_num,target_encumber)
        cur_layer = witem:get_armor_layer()
        cur_layer_num = 0
      end
      cur_layer_num = cur_layer_num+1
    end
    calc_layer_encumbrance(cur_layer,cur_layer_num,target_encumber)
    target_encumber.all = target_encumber.base +target_encumber.add
  end
  --
  wearing_data.total_weight = total_weight
  wearing_data.total_storage = total_storage
  self:on_weight_and_storage_change()--背负最大体积和重量改变
  self:equipment_animation_change()
end

function charactorBase:get_equipment_animList()
  if self.eq_animlist==nil then
    local animlist = {}
    animlist.img = love.graphics.newCanvas(256, 32)
    animlist.use_quad = true
    animlist.use_canvas = true
    animlist.num = 4
    animlist.width = 32
    animlist.height = 32
    animlist.scalefactor = 2
    animlist.type = "twoSide" -- single oneSide twoSide
    animlist.pingpong  = true
    for i=1,8 do
      animlist[i] = love.graphics.newQuad(32*(i-1),0,32,32,256,32)
    end
    self.eq_animlist = animlist
  end
  return self.eq_animlist
end


--重建/新建 装备组成的动画
function charactorBase:equipment_animation_change()
  local head =data.default_eq.head
  local cloth = data.default_eq.upper
  local pants = data.default_eq.lower
  local find_upper,find_lower = false,false
  local whole_upper,whole_lower =false,false
  --寻找上装，下装
  for i=#self.worn,1,-1 do
    local witem = self.worn[i]
    if find_upper==false then
      if witem.type.guise =="upper" or witem.type.guise =="whole" then
        find_upper = true
        cloth = witem.type.guise_data
        whole_upper = witem.type.guise =="whole"
      end
    end
    if find_lower==false then
      if witem.type.guise =="lower" or witem.type.guise =="whole" then
        find_lower = true
        pants = witem.type.guise_data
        whole_lower = witem.type.guise =="whole"
      end
    end
    if find_upper and find_lower then break end
  end
  local draw_upper = true
  if whole_upper then
    draw_upper = false
    pants = cloth
  end
  if whole_lower then draw_upper = false end --全身装相当于下装的位置，并取消上装
  
  --开工绘制
  local animlist = self:get_equipment_animList()
  local canvas = animlist.img
  --正面，下装，上装，头
  --反面，头，下装，上装
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha")
  for i=1,4 do --正面4帧
    love.graphics.draw(pants.img,pants[i],(i-1)*32,0)
    if draw_upper then love.graphics.draw(cloth.img,cloth[1],(i-1)*32,0) end
    love.graphics.draw(head.img,head[1],(i-1)*32,0)
  end
  for i=5,8 do --反面四针
    love.graphics.draw(head.img,head[2],(i-1)*32,0)
    love.graphics.draw(pants.img,pants[i],(i-1)*32,0)
    if draw_upper then love.graphics.draw(cloth.img,cloth[2],(i-1)*32,0) end
  end
  love.graphics.setCanvas()--其他没啥了吧？
end

function charactorBase:on_weight_and_storage_change()
  
  
end


--返回 all，base，add  
function charactorBase:get_bodypart_encumberance(bodypart)  --todo需要计算除装备外，组件和变异的累赘度
  local target  =self.wearing_data.encumber[bodypart]
  if target then
    return target.all,target.base,target.add
  else
    return 0,0,0
  end
end
--经过环境增减的数值
function charactorBase:get_bodypart_warmth(bodypart)
  local target  =self.wearing_data.warmth[bodypart]
  return target or 0
end



