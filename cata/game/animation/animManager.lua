
--预load
local datalist
function data.loadAnimationData()
  data.animation = {}
  local tmp = dofile("data/unit/animList.lua")
  for _,v in ipairs(tmp) do
    data.animation[v.name] = v
  end
  
  data.framesEffect = dofile("data/animation/framesEffect.lua")
  datalist = data.framesEffect
  
  --读取projectile
  data.projectile = dofile("data/animation/projectile.lua")
  
  
end


g.animManager = {methodlist = {}}
local animManager = g.animManager
require"game/animation/mapEffect"--一部分函数代码
--动画
require"game/animation/method/animMethod"
