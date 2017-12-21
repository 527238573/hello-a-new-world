--关于creature（unit） 动画的成员函数等，都在这里。
--
local creatureBase = g.creature.creatureBase


--主要是统一动画的播放  --一定要先setanimation 后addDelay
function creatureBase:setAnimation(anim)
  anim.pastTime = -self.delay
  self.anim = anim
end


function creatureBase:addImpactAnimation(impAnim)
  local list = self.impactAnim_list
  list[#list+1] = impAnim
end


--实际时间
function creatureBase:updateAnim(dt)
  local anim = self.anim
  if anim then
    anim.pastTime = anim.pastTime+dt
    
    
    if anim.pastTime> anim.totalTime then
      --anim.pastTime = anim.pastTime - anim.totalTime
      self.anim = nil --直接删除
      --if self ~= player then
      --  debugmsg("anim end:delay"..self.delay)
      --end
      
    end
  end
  --animEffectList 更新
  local effect_list = self.animEffectList
  local i=1
  while i<=#effect_list do
    local effect = effect_list[i]
    effect.pastTime = effect.pastTime+dt
    if effect.pastTime> effect.totalTime then
      table.remove(effect_list,i)
    else
      i = i+1
    end
  end
  
  --impact animation 更新
  local impactlist=  self.impactAnim_list
  local totalLen = #impactlist
  local cdx ,cdy = 0,0
  i=1
  while i<=totalLen do
    local impactAnim = impactlist[i]
    impactAnim.pastTime = impactAnim.pastTime+dt
    if impactAnim.pastTime> impactAnim.totalTime then
      table.remove(impactlist,i)
      totalLen = totalLen-1
    else
      i = i+1
      local dx,dy = impactAnim.method()--取得impact数据 --可能后面会加更多的变量？旋转等
      cdx = cdx+dx
      cdy = cdy+dy
    end
  end
  self.impact_dx = cdx--更新到成员变量
  self.impact_dy = cdy
end


function creatureBase:addProgressAnimEffect(text,delayTime)
  self.animEffectList[#self.animEffectList+1] = {name = "progress",text= text,pastTime=0,totalTime = delayTime}
end


function creatureBase:addFramesAnimEffect(effect_name,offset_x,offset_y,delay,mirror)
  delay = delay or 0
  local e_data = data.framesEffect[effect_name]
  if e_data ==nil then
    debugmsg("addFramesEffect cant find name:"..effect_name)
    return
  end
  local c_effect = {name = "framesEffect",data = e_data,pastTime=-delay,totalTime = e_data.secPerFrame * e_data.frameNum,offset_x=offset_x,offset_y=offset_y}
  c_effect.mirror = mirror or 1
  if e_data.random_mirror and not mirror then  c_effect.mirror = (one_in(2) and 1 or -1) end
  self.animEffectList[#self.animEffectList+1] = c_effect
end


function creatureBase:get_weapon_appearance()
  if self.weapon then return self.weapon:get_weapon_appearance() end
  return nil
end
