



local priority = {"up","down","right","left"}
local priority_wasd = {"w","a","s","d"}
ui.key_g_delay = 0
function ui.mainKeypressed(key)
  for i=1,4 do
    if(priority[i]==key) then
        table.remove(priority,i)
        table.insert(priority,1,key)
      return
    end
    if(priority_wasd[i]==key) then
        table.remove(priority_wasd,i)
        table.insert(priority_wasd,1,key)
      return
    end
  end
  
  
  if g.checkControl() == false then return end
  if key=="space" then
    player:spaceAction()
    
  elseif key=="z" then
    ui.camera.setZ( ui.camera.cur_Z+1)
  elseif key=="x" then
    ui.camera.setZ( ui.camera.cur_Z-1)
  elseif key=="g" then
    player:pickOrDrop(0,0)--启动
  elseif key=="f" then
    player:fastShotAction()--快速射击
  elseif key=="v" then
    player:openAimWinAction()--瞄准模式，进入
  elseif key=="r" then
    player:reloadAction() --重装
  elseif key=="e" then
    --ui.pickupOrDropWin:Open(false)
  elseif key=="b" then
    if not love.mouse.isDown(1) then player:Bash() end
  elseif key=="c" then
    if not love.mouse.isDown(1) then player:close_door() end
  end
  
  
end



function ui.mainKeyCheck(dt)
  if ui.show_console then return end
  
  if g.checkControl() == false then return end
  if ui.keyOnWindow() then return end--焦点不在主界面
  
  --是否连射
  
  if love.keyboard.isDown("f") then
    player:fastBurstShotAction()
  elseif player:needBurst() then --最小burst没走完
    player:fastBurstShotAction()
  end
  
  for i=1,4 do
    if(love.keyboard.isDown(priority[i])) then
      if(priority[i] == "up") then
        if(love.keyboard.isDown("left")) then
          player:moveAction(-1,1)
        elseif(love.keyboard.isDown("right")) then
          player:moveAction(1,1)
        else
          player:moveAction(0,1)
        end
      elseif (priority[i] =="down") then
        if(love.keyboard.isDown("left")) then
          player:moveAction(-1,-1)
        elseif(love.keyboard.isDown("right")) then
          player:moveAction(1,-1)
        else
          player:moveAction(0,-1)
        end
      elseif (priority[i] =="right") then
        if(love.keyboard.isDown("up")) then
          player:moveAction(1,1)
        elseif(love.keyboard.isDown("down")) then
          player:moveAction(1,-1)
        else
          player:moveAction(1,0)
        end
      elseif (priority[i] =="left") then
        if(love.keyboard.isDown("up")) then
          player:moveAction(-1,1)
        elseif(love.keyboard.isDown("down")) then
          player:moveAction(-1,-1)
        else
          player:moveAction(-1,0)
        end
      end
      return
    end
    
    if(love.keyboard.isDown(priority_wasd[i])) then
      if(priority_wasd[i] == "w") then
        if(love.keyboard.isDown("a")) then
          player:moveAction(-1,1)
        elseif(love.keyboard.isDown("d")) then
          player:moveAction(1,1)
        else
          player:moveAction(0,1)
        end
      elseif (priority_wasd[i] =="s") then
        if(love.keyboard.isDown("a")) then
          player:moveAction(-1,-1)
        elseif(love.keyboard.isDown("d")) then
          player:moveAction(1,-1)
        else
          player:moveAction(0,-1)
        end
      elseif (priority_wasd[i] =="d") then
        if(love.keyboard.isDown("w")) then
          player:moveAction(1,1)
        elseif(love.keyboard.isDown("s")) then
          player:moveAction(1,-1)
        else
          player:moveAction(1,0)
        end
      elseif (priority_wasd[i] =="a") then
        if(love.keyboard.isDown("w")) then
          player:moveAction(-1,1)
        elseif(love.keyboard.isDown("s")) then
          player:moveAction(-1,-1)
        else
          player:moveAction(-1,0)
        end
      end
      return
    end
    
    
  end
  if not ui.keyOnWindow() then --更流畅的操作
    ui.key_g_delay =ui.key_g_delay -dt
    if ui.key_g_delay<=0 and love.keyboard.isDown("g") then
        player:pickOrDrop(0,0)--启动 
      return 
    end
  end
end