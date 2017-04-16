--快速访问
local gmap= g.map



--[[player实例的metatable
player实例 本身只存状态数据
--]]
local player_mt = {}
g.player_mt = player_mt
player_mt.__index = player_mt
player = nil
require "game/player/action/basicAction"

--创建一个测试的 数值默认的player对象
function player_mt.createDefaultPlayer()
  player= {}
  local player = player
  
  setmetatable(player,player_mt)
  g.player = player
  
  player.delay  = 0  --延迟的行动点 （cdda中moves的 negative）
  player.x = 0
  player.y = 0
  player.z = 1 --当前坐标
  player.face = 4  --  face方向                  
  
  player_mt.animlist = data.animation["player_mc"]
  
  --animlist ，通常是要重创建的，现在用这个默认的代替
  player.anim = {name = "move",start_x = -64,start_y = 0,totalTime = 0.44,pastTime = 0}
  
end


function player_mt:getAnimList()
  return player_mt.animlist
end

--新增加delay行动点，通常是player 开始了新action，进入新的一个动画周期
function player_mt:addDelay(toadd)
  self.delay = self.delay+toadd
end

function player_mt:setAnimation(anim)
  anim.pastTime = -self.delay
  self.anim = anim
end

--roguelike时间
function player_mt:updateRL(dt)
  player.delay = player.delay -dt
  if player.delay <0 then player.delay  = 0 end
end

--实际时间
function player_mt:updateAnim(dt)
  local anim = self.anim
  if anim then
    anim.pastTime = anim.pastTime+dt
    if anim.pastTime> anim.totalTime then
      --anim.pastTime = anim.pastTime - anim.totalTime
      self.anim = nil --直接删除
    end
  end
end


function player_mt:save()
  local playerfile = g.profile_savedir.."/player"
  local tableToSave = {
      x = self.x,y = self.y,z=self.z,
      face = self.face,
    }
  table.save(tableToSave,playerfile)
  
end
function player_mt:load()
  local playerfile = g.profile_savedir.."/player"
  local tloaded = table.load(playerfile)
  self.face = tloaded.face
  g.player:setPosition(tloaded.x,tloaded.y,tloaded.z)
  ui.camera.resetToPlayerPosition()
end

