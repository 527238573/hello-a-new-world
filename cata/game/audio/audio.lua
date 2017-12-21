
local soundList

function data.loadAudio()
  soundList = dofile("data/sound/sound.lua")
  
  
end



function g.playSound(name,rewind)
  local sound = soundList[name]
  if sound ==nil then 
    debugmsg("cant find sound:"..name)
    return;
  end
  if sound.random_group then
    sound = sound[rnd(1,#sound)]
  end
  local dataplay = sound.data
  dataplay:setVolume( sound.default_volume )
  
  if rewind then 
    dataplay:rewind()
  end
  dataplay:play()
end