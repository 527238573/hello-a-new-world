--快速访问
local gmap= g.map



--[[player实例的metatable
player实例 本身只存状态数据
--]]
local player_mt = {}
g.player_mt = player_mt
g.creature.initCharactorMetaTable(player_mt)--初始化mt——table 。将charactor函数先加入
player_mt.__index = player_mt
player = nil
require "game/player/check/player_recipes"
require"game/player/action/playerState"
require "game/player/action/basicAction"
require "game/player/action/fightAction"
require "game/playerActivity/player_activity"
--require"game/player/action/melee"--在某些之后的 --移到charator中了
--创建一个测试的 数值默认的player对象
function player_mt.createDefaultPlayer()
  player= {}
  local player = player
  g.creature.initCharatorValue(player)
  
  setmetatable(player,player_mt)
  g.player = player
  
  
  player:set_full_hp()
  player.delay  = 0  --延迟的行动点 （cdda中moves的 negative）
  player.x = 0
  player.y = 0
  player.z = 1 --当前坐标
  player.face = 4  --  face方向 
  player.inventory:setMaxCarry(3000,40)
  player.effect_list = {}--只有player才有，方便显示
  player_mt.animlist = data.animation["player_mc"]
  --animlist ，通常是要重创建的，现在用这个默认的代替
  player.anim = g.animManager.createMoveAnim(player,-64,0,0.44)
  --必做出基本数据
  player:on_wear_change()
  --初始化配方，在技能等级设定之后再设定
  player:reset_recipes()
  --其他实验
  
  player:add_trait("fleet",-1)
  player:add_effect("on_fire",1)
  player:add_effect("zapped",5)
  player:add_effect("stunned",3)
end


function player_mt:getAnimList()
  return self.eq_animlist or player_mt.animlist
end

--新增加delay行动点，通常是player 开始了新action，进入新的一个动画周期
function player_mt:addDelay(toadd)
  self.delay = self.delay+toadd
end

--roguelike时间
function player_mt:updateRL(dt)
  self:recoverDodgeAndBlock(dt)
  self:update_effects(dt)
  self:update_damage(dt)
  if self.activity then self:update_activity(dt) end --更新活动
  player.delay = player.delay -dt
  if player.delay <0 then player.delay  = 0 end
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

