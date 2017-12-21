local animManager = g.animManager
local mapEffect_list = {}
local squareEffect_list = {}
local porjectile_list = {}

function animManager.getMapEffectList()
  return mapEffect_list
end
function animManager.getProjectileList()
  return porjectile_list
end

function animManager.updateAnim(dt)
  local i=1
  while i<=#mapEffect_list do
    local effect = mapEffect_list[i]
    effect.pastTime = effect.pastTime+dt
    if effect.pastTime> effect.totalTime then --移除已经结束的effect
      table.remove(mapEffect_list,i)
    else
      i = i+1
    end
  end
  i=1 --同样的
  while i<=#squareEffect_list do
    local effect = squareEffect_list[i]
    effect.pastTime = effect.pastTime+dt
    if effect.pastTime> effect.totalTime then 
      table.remove(squareEffect_list,i)
      g.map.leaveEffectCache(effect) --移除出cache
    else
      i = i+1
    end
  end
  --投射物
  i=1
  while i<=#porjectile_list do
    local projectile = porjectile_list[i]
    projectile.pastTime = projectile.pastTime+dt
    if projectile.pastTime> projectile.totalTime then 
      table.remove(porjectile_list,i)
    else
      i = i+1
    end
  end
  
end

function animManager.addSquareEffect(effectname,x,y,z)
  local effectData =  data.framesEffect[effectname] 
  if effectData==nil then
    debugmsg("cant find mapeffect data :"..effectname)
    return
  end
  local effect = {pastTime = 0,totalTime = effectData.secPerFrame * effectData.frameNum}
  effect.data = effectData
  effect.x = x
  effect.y = y
  effect.z = z
  squareEffect_list[#squareEffect_list+1] = effect
  g.map.enterEffectCache(effect) --进入cache
  if effectData.sound_id then
    g.playSound(effectData.sound_id,true) --未考虑声音的远近等
  end
end
function animManager.resetEffectCache()
  
  for i=1,#squareEffect_list do
    g.map.enterEffectCache(squareEffect_list[i]) --进入cache
  end
end

function animManager.addEffectToSquareCenter(effectname,x,y,z)
  local effectData =  data.framesEffect[effectname] 
  if effectData==nil then
    debugmsg("cant find mapeffect data :"..effectname)
    return
  end
  local effect = {pastTime = 0,totalTime = effectData.secPerFrame * effectData.frameNum}
  effect.data = effectData
  effect.x = x*64+32
  effect.y = y*64+32
  effect.z = z
  effect.minX = effect.x  - effectData.w--(*2 /2 )
  effect.maxX = effect.x  + effectData.w--(*2 /2 )
  effect.minY = effect.y  - effectData.h--(*2 /2 )
  effect.maxY = effect.y  + effectData.h--(*2 /2 )
  mapEffect_list[#mapEffect_list+1] = effect
  if effectData.sound_id then
    g.playSound(effectData.sound_id,true)
  end
end



function animManager.addProjectile(porjectile)
  porjectile_list[#porjectile_list+1] = porjectile
  porjectile.pastTime = 0
  porjectile.totalTime = porjectile.totalTime  or 1
end
