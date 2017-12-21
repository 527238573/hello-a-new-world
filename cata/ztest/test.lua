





test={}

function test.testF()
  if not ui.showMainMenu then
    
    local projectile = g.create_projectile()
    local dam_ins = g.create_damage_instance()
    dam_ins:add_damage("bash",20)
    projectile.dam_ins = dam_ins
    --projectile:attack(nil,player.x,player.y,player.z,nil,player.x+rnd(-4,4),player.y+rnd(-4,4),player.z)
     projectile:attack(player,player.x,player.y,player.z,nil,player.x,player.y+3,player.z)
    
  end
  
end

function test.testAdd1()
  if not ui.showMainMenu then
    --g.save()
    --g.monster.spawnNewMonster("zombie_debug",player.x,player.y+3,player.z)
    
    --测试加地物品
    
    --local oneitem = g.itemFactory.createItem("meat")
    --player.inventory:addItem(oneitem)
    --g.message.addmsg("加肉*1入背包！","good")
    --g.map.setTerAndBlock("t_wall_rock",nil,player.x,player.y+4,player.z)
    g.map.bashSquare(player.x,player.y+5,player.z,44)
  end
  
end

function test.testAdd2()
  if not ui.showMainMenu then
    test.testInterrupt()
    --g.save()
    --g.monster.spawnNewMonster("zombie_debug",player.x,player.y+3,player.z)
    --player.animEffectList:addEffect({name = "progress",pastTime=0,totalTime = 1})
    --测试加地物品
    local oneitem = g.itemFactory.createItem("hoodie")
    player:wear_item(oneitem,true)
    oneitem = g.itemFactory.createItem("cargo_pants")
    player:wear_item(oneitem,true)
    oneitem = g.itemFactory.createItem("wood_sword")
    player:wield_item(oneitem,true)
    oneitem = g.itemFactory.createItem("cudgel")
    player.inventory:addItem(oneitem)
    
    
    oneitem = g.itemFactory.createItem("usp_9mm")
    player.inventory:addItem(oneitem)
    oneitem = g.itemFactory.createItem("ak47m")
    player.inventory:addItem(oneitem)
    oneitem = g.itemFactory.createItem("shortbow")
    player.inventory:addItem(oneitem)
    oneitem = g.itemFactory.createItem("l_pistol_JHP")
    player.inventory:addItem(oneitem)
    oneitem = g.itemFactory.createItem("h_rifle_M43")
     oneitem.stack_num = 120
    player.inventory:addItem(oneitem)
    oneitem = g.itemFactory.createItem("arrow_wood")
    oneitem.stack_num = 100
    player.inventory:addItem(oneitem)
    
    
    oneitem = g.itemFactory.createItem("bone")
    player.inventory:addItem(oneitem)
    
    oneitem = g.itemFactory.createItem("splinter")
    oneitem:set_stack(10)
    player.inventory:addItem(oneitem)
    --player.inventory:addItem(oneitem)
    --g.message.addmsg("捡起 肉块 。")
    g.animManager.addSquareEffect("green_dead",player.x,player.y+3,player.z)
    --debugmsg("rnd:"..rnd())
  end
  
end


function test.testnew()
  --debugmsg("curZ:"..ui.camera.cur_Z)
  if not ui.showMainMenu then
    --g.save()
    g.monster.spawnNewMonster("zombie_debug",player.x,player.y+3,player.z)
    
    --测试加地物品
    --local oneitem = g.itemFactory.createItem("meat")
    --g.map.addItemToSqaure(oneitem,player.x,player.y+3,player.z)
    
    
  end
end

function test.spawn_v()
  if not ui.showMainMenu then
    g.vehicle.spawnNewVehicle("car3",player.x,player.y+3)
    
    
    
    
  end
end


function test.testnew2()
  --debugmsg("curZ:"..ui.camera.cur_Z)
  if not ui.showMainMenu then
    --g.save()
    --g.monster.spawnNewMonster("zombie_debug",player.x,player.y+3,player.z)
    
    --测试加地物品
    --local oneitem = g.itemFactory.createItem("bone")
    local oneitem = g.itemFactory.make_mon_corpse("zombie_debug")
    g.map.addItemToSqaure(oneitem,player.x,player.y+3,player.z)
    
    for i=1,0.5 do
      debugmsg("do:"..i)
    end
  end
end
function test.testfastForward()
  player.activity = g.activity.create_activity()
  player.activity:setTotalTime(600)
end

function test.testInterrupt()
  player:cancel_activity_query("很长的一段话，描述了中断的原因。你真的要中断吗",true)
end


function test.testadd()
  
  local submapLength = 64*16
  local startx = math.floor(ui.camera.seen_minX/submapLength)
  local starty = math.floor(ui.camera.seen_minY/submapLength)
  local endx = math.floor((ui.camera.seen_maxX)/submapLength) 
  local endy = math.floor((ui.camera.seen_maxY+32)/submapLength)--额外多画的部分
  
  print(startx,endx,starty,endy)
  io.flush()
  
  g.cameraLock.cameraMove(0,0,10,0,5,0)
  --[[
  if getsubmap == g.map.getSubmapInGrid then
    getsubmap = g.map.lookupSubmap
  else
    getsubmap = g.map.getSubmapInGrid
  end
  --]]
  --[[
  --g.map.setGridCenterSquare(100,100,1)
  local time1  = love.timer.getTime()
  
  for trun = 1,1000 do
    --local sm = g.map.shift(0,0,0)
    --local sm = g.map.reloadGrid(0,0,0)
  end
  
  
  local time2 = love.timer.getTime() 
  print(time2 - time1)
  io.flush()
  --]]
end