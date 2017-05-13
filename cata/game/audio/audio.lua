
local soundList

function data.loadAudio()
  soundList = dofile("data/sound/sound.lua")
  
  
end



function g.playSound(name)
  local sound = soundList[name]
  if sound ==nil then 
    debugmsg("cant find sound:"..name)
    return;
  end
  sound:play()
end