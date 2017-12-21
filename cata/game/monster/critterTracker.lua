--跟踪保存所有活动的monster。作为monsterlist
g.monster = {} --该类代码簇总集
require "game/monster/monster"
require "game/monster/monsterData"
require "game/monster/monsterDo/deathMon"

local gmon = g.monster
local monsterList = {}


function gmon.addMonster(mon,x,y,z)
  monsterList[#monsterList+1] = mon
  mon.x = x
  mon.y = y
  mon.z = z
  g.map.enterUnitCache(mon) --尝试进入单位grid
end

function gmon.spawnNewMonster(monid,x,y,z)
  local mon = gmon.createMonsterByid(monid)
  gmon.addMonster(mon,x,y,z)
end

function gmon.getList()
  return monsterList
end

function gmon.resetUnitCache()
  local enterUnitCache = g.map.enterUnitCache
  for i,mon in ipairs(monsterList) do
    enterUnitCache(mon) --尝试进入单位grid
  end
end


function gmon.updateRL(dt)
  for i,mon in ipairs(monsterList) do
    mon:updateRL(dt)
  end
  --清除死体
  local i =1
  local length = #monsterList
  while i<= length do
    local mon = monsterList[i]
    if mon.dead then
      table.remove(monsterList,i)
      debugmsg(string.format("remove monster:%d,%d,%d",mon.x,mon.y,mon.z))
      
      length = length-1
    else
      i = i+1
    end
  end
end


function gmon.updateAnim(dt)
  for i,mon in ipairs(monsterList) do
    mon:updateAnim(dt)
  end
  
end