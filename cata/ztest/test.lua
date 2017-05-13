





test={}



function test.testAdd1()
  if not ui.showMainMenu then
    --g.save()
    --g.monster.spawnNewMonster("zombie_debug",player.x,player.y+3,player.z)
    
    --测试加地物品
    
    --local oneitem = g.itemFactory.createItem("meat")
    --player.inventory:addItem(oneitem)
    --g.message.addmsg("加肉*1入背包！","good")
    g.map.setTerAndBlock("t_rock",nil,player.x,player.y+4,player.z)
  end
  
end

function test.testAdd2()
  if not ui.showMainMenu then
    --g.save()
    --g.monster.spawnNewMonster("zombie_debug",player.x,player.y+3,player.z)
    --player.animEffectList:addEffect({name = "progress",pastTime=0,totalTime = 1})
    --测试加地物品
    local oneitem = g.itemFactory.createItem("bone")
    player.inventory:addItem(oneitem)
    g.message.addmsg("加骨*1入背包！")
    
  end
  
end


function test.testnew()
  --debugmsg("curZ:"..ui.camera.cur_Z)
  if not ui.showMainMenu then
    --g.save()
    --g.monster.spawnNewMonster("zombie_debug",player.x,player.y+3,player.z)
    
    --测试加地物品
    local oneitem = g.itemFactory.createItem("meat")
    g.map.addItemToSqaure(oneitem,player.x,player.y+3,player.z)
    
    
  end
end

function test.testnew2()
  --debugmsg("curZ:"..ui.camera.cur_Z)
  if not ui.showMainMenu then
    --g.save()
    --g.monster.spawnNewMonster("zombie_debug",player.x,player.y+3,player.z)
    
    --测试加地物品
    local oneitem = g.itemFactory.createItem("bone")
    g.map.addItemToSqaure(oneitem,player.x,player.y+3,player.z)
    
    
  end
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