local lovefs = require("file/lovefs")
--roguelike game model
g = {}--主table
data={}--读取的数据table

require"game/base/base"
require"game/audio/audio"
require"game/animation/animManager"
require"game/map/omdata"--overmap terrain数据
require"game/map/mapdata"
require"game/map/map"
require"game/item/inventory"
require"game/effect/effectTypeData"
require"game/effect/effect"
require"game/effect/trait"
require"game/npc/creature"--顺序
require"game/npc/charactor"
require"game/player/player"
require"game/camera/cameraLock"
require"game/monster/critterTracker"
require"game/item/itemTypeData"
require"game/item/itemFactory"
require"game/item/recipes/recipesData"
require"game/other/projectile"
require"game/playerActivity/activity"
require"game/vehicle/vehicle"


function g.init()
  g.savehome = love.filesystem.getSourceBaseDirectory().."/save"
  data.loadAudio()
  data.loadOterData()--载入数据
  data.loadTerAndBlockData()
  data.loadSkills()
  data.loadItemTypeData()
  data.loadRecipeData()
  data.loadAnimationData()
  data.loadMonsterData()
  data.loadEffectTypes()
  data.loadVehicles()
  
  g.itemFactory.initItemFactory()
  g.newCreatedPorfile = true --提前设置好，
  g.map.init()
  
  g.player_mt.createDefaultPlayer() --先有默认的player，后面可以再替换
  g.canControl = false --ui能否发出控制命令
  
end

function g.createGame()
  debugmsg("create game")
  g.newCreatedPorfile = true
  g.map.createGame()
  g.calendar.setDate(9,7)
  g.player:setPosition(0,0,1)
end

function g.loadGame(profilename)
  if not love.filesystem.isDirectory(profilename) then
    debugmsg("doesn't have profile directory name:"..profilename)
    return false
  end
  g.newCreatedPorfile = false --已有的
  g.profileName = profilename
  g.profile_savedir = love.filesystem.getSaveDirectory().."/"..profilename --此变量必须在newCreatedPorfile = false时必须存在，读取之后要立即设定
  g.map.load()
  player:load()
  return true
end




function g.checkControl() -- 
  return g.curDt>g.player.delay  and player.activity==nil --处于activity中，不能控制
end

function g.preUpdate(dt)
  g.curDt = dt
  g.canControl = dt>g.player.delay
end

--update roguelike系统的时间（游戏模型的时间）
function g.updateRL(dt)
  g.calendar.updateRL(dt)
  g.player:updateRL(dt)
  g.monster.updateRL(dt)
end
--update 真实流逝的时间，用于驱动动画等
function g.updateAnim(dt)
  g.player:updateAnim(dt)
  g.cameraLock.updateAnim(dt)
  g.monster.updateAnim(dt)
  g.animManager.updateAnim(dt)
  g.updateAnimDelayFucntion(dt)
end

local function normalUpdate(dt)
  local rl_time_past  = c.clamp(g.player.delay,0,dt)
  if rl_time_past >0 then
    g.updateRL(rl_time_past)
  end
  g.updateAnim(dt)
  
end

local function fastForwardUpdate(dt)
  local activity = player.activity
  activity:updateRealTime(dt)
  local timeUnit = activity.calcuateInterval
  local drawInterval = activity.drawInterval or 22 --秒,5分钟  --也就是最大绘制间隔。
  local loopTimes = math.floor(drawInterval/timeUnit)
  for i=1,loopTimes do
    if player.activity ==nil or player.activity~=activity or player.activity.pause or (activity.timePast/activity.totalTime>activity.realTimePast/activity.minRealTime)then --pause状态，处于UI询问中？
      break;
    end
    g.updateRL(timeUnit)
    g.updateAnim(timeUnit)
  end
  if player.activity then
    --debugmsg("fastforward timeleft:"..(player.activity.totalTime-player.activity.timePast)..string.format("  %.05f",dt))
  end
end

function g.update(dt)
  if player.activity then
    fastForwardUpdate(dt)
  else
    normalUpdate(dt)
  end
end





function g.save()
  debugmsg("call save game")
  local profilename = g.profileName
  g.profile_savedir = love.filesystem.getSaveDirectory().."/"..profilename --此变量必须在newCreatedPorfile = false时必须存在，读取之后要立即设定
  --确保档案名称
  assert(type(profilename)=="string","saveError")
  if g.newCreatedPorfile then
    local function recursivelyDelete(item)--删除所有（居然不能一次删除）
        if love.filesystem.isDirectory(item) then
            for _, child in pairs(love.filesystem.getDirectoryItems(item)) do
                recursivelyDelete(item .. '/' .. child);
                love.filesystem.remove(item .. '/' .. child);
            end
        elseif love.filesystem.isFile(item) then
            love.filesystem.remove(item);
        end
        love.filesystem.remove(item)
    end
    if love.filesystem.isDirectory(profilename) then
      debugmsg("remove")
      recursivelyDelete(profilename)
    end
  end
    
  if not love.filesystem.isDirectory(profilename) then
    debugmsg("new createdir")
    assert(love.filesystem.createDirectory(profilename),"create profile error")
  end
  g.map.save()
  player:save()
  
  g.newCreatedPorfile = false
end



