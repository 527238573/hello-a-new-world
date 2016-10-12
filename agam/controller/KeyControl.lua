

keyControl = {}
keyControl.waiting = false;
keyControl.waitTimeLeft = 0;


keyControl.priority = {"up","down","right","left"}


function keyControl.keypressed(key)
  if(key =="t") then Vrotation =Vrotation +0.2 end
  if(key =="g") then Vrotation =Vrotation -0.2 end
  
  for i=1,4 do
    if(keyControl.priority[i]==key) then
        table.remove(keyControl.priority,i)
        table.insert(keyControl.priority,1,key)
      return
    end
  end
end




function keyControl.update(dt)
  if(keyControl.waiting) then
    keyControl.waitTimeLeft = keyControl.waitTimeLeft - dt
    if(keyControl.waitTimeLeft>0)  then return end
  end
  
  for i=1,4 do
    if(love.keyboard.isDown(keyControl.priority[i])) then
      
      if(keyControl.priority[i] == "up") then
        if(love.keyboard.isDown("left")) then
          g.raction.moveAction(-1,1)
        elseif(love.keyboard.isDown("right")) then
          g.raction.moveAction(1,1)
        else
          g.raction.moveAction(0,1)
        end
      elseif (keyControl.priority[i] =="down") then
        if(love.keyboard.isDown("left")) then
          g.raction.moveAction(-1,-1)
        elseif(love.keyboard.isDown("right")) then
          g.raction.moveAction(1,-1)
        else
          g.raction.moveAction(0,-1)
        end
      elseif (keyControl.priority[i] =="right") then
        if(love.keyboard.isDown("up")) then
          g.raction.moveAction(1,1)
        elseif(love.keyboard.isDown("down")) then
          g.raction.moveAction(1,-1)
        else
          g.raction.moveAction(1,0)
        end
      elseif (keyControl.priority[i] =="left") then
        if(love.keyboard.isDown("up")) then
          g.raction.moveAction(-1,1)
        elseif(love.keyboard.isDown("down")) then
          g.raction.moveAction(-1,-1)
        else
          g.raction.moveAction(-1,0)
        end
      end
        
      break
    end
  end
  keyControl.waiting = keyControl.waitTimeLeft>0
  if(keyControl.waiting == false)  then keyControl.waitTimeLeft = 0 end
end


function keyControl.lockTime(time)
  keyControl.waitTimeLeft = keyControl.waitTimeLeft + time
end
