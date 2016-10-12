--roguelike game 总单例 




g = {} --roguelike世界

require "roguelike/scheduler"
require "roguelike/keyAction"
require "roguelike/player/player"
require "roguelike/map/map"




--当time大于0时才调用，使时间经过
local function player_nextTurn(time)
  g.scheduler.add(g.player,time)
  while(true) do
    local actor = g.scheduler.next()
    if(actor == g.player) then break end
  end
  
end

function g.takeTurn(time)
  --跟新 time 可能为0
  if(time>0)then 
    player_nextTurn(time) 
    --调用动画使其播放
    movie.play(time)
  end
  --为0的情况 朝向改变之类，在其它处更改状态
end
