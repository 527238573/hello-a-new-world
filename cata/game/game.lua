--roguelike game model
g = {}--主table
data={}--读取的数据table

require"game/base/base"
require"game/map/omdata"--overmap terrain数据
require"game/map/mapdata"
require"game/unit/animData"
require"game/map/map"
require"game/player/player"
require"game/camera/cameraLock"

function g.init()
  data.loadOterData()--载入数据
  data.loadTerAndBlockData()
  data.loadAnimationData()
  
  g.map.init()
  
  g.player_mt.createDefaultPlayer() --先有默认的player，后面可以再替换
  g.canControl = false --ui能否发出控制命令
  g.player:setPosition(0,0,1)
  
end


function g.checkControl() -- 
  return g.curDt>g.player.delay
end

function g.preUpdate(dt)
  g.curDt = dt
  g.canControl = dt>g.player.delay
end

--update roguelike系统的时间（游戏模型的时间）
function g.updateRL(dt)
  g.player:updateRL(dt)
end
--update 真实流逝的时间，用于驱动动画等
function g.updateAnim(dt)
  g.player:updateAnim(dt)
  g.cameraLock.updateAnim(dt)
end

function g.update(dt)
  local rl_time_past  = c.clamp(g.player.delay,0,dt)
  if rl_time_past >0 then
    g.updateRL(rl_time_past)
  end
  g.updateAnim(dt)
end