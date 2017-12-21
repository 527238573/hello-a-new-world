local player_mt = g.player_mt






--reload特定的物品  parentWin 表示在什么ui下展开可能的子窗口
function player_mt:reload_ammo(item_gun,parentWin)
  if not item_gun:can_reload(true) then return end --检测能否装载并显示信息
  local max = item_gun:get_magazine_size()
  local cur = item_gun:get_ammo_number()
  --已经装满
  if cur>= max then addmsg(string.format( tl("%s已经装满了。", "The %s is already fully loaded!" ),item_gun:getNormalName()),"info"); return end
  --确定可以load，开始寻找子弹
  local ammoList= {}
  self.inventory:sort()
  local playeritemlist = self.inventory.items --直接操作items
  for i=1,#playeritemlist do
    if item_gun:can_use_ammo(playeritemlist[i]) then  --选择可用的子弹 后来可改，也许非背包内的
      table.insert(ammoList,playeritemlist[i])
    end
  end
  --
  if #ammoList==0 then
    addmsg(tl("没有可用的弹药！", "Out of ammo!" ),"info");--可能改成多种的名称
    return
  end
  
  local function load_ammo(ammo) --找到ammo后的函数
    if ammo ==nil then return end --未选择退出
    local orgnum = ammo.stack_num
    local remove = item_gun:reload_ammo(ammo)
    remove = remove or (ammo.stack_num<=0)
    local dirty = (orgnum~= ammo.stack_num)
    if remove then
      self.inventory:removeItem(ammo)
    elseif dirty then
      self.inventory.itemDirty = true
    end
    --信息
    addmsg(string.format( tl("你重新装填了%s。", "You reload the %s." ),item_gun:getNormalName()),"info");
    --行动条
    self:shortActivity(tl("装载","reload"),item_gun:reload_time(self)) --时间
    --还有音效
     g.playSound(item_gun:reload_sound(),true)--reload声音
    --todo
  end
  
  if #ammoList==1 then
    load_ammo(ammoList[1]) --只有一种时，自动选择
  else
    if parentWin then
      parentWin:OpenChild(ui.chooseItemWin,tl("选择弹药","Select Ammo"),ammoList,load_ammo)
    else
      ui.chooseItemWin:Open(tl("选择弹药","Select Ammo"),ammoList,load_ammo)
    end
  end
end




--按R键进行的当前武器的reload
function player_mt:reloadAction()
  local weapon = self.weapon
  if weapon then
    self:reload_ammo(weapon)
  else
    addmsg(tl("你没有装备任何武器。", "You're not wielding anything." ))
  end
end