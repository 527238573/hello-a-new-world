--跟踪保存所有活动的monster。作为monsterlist
g.monster = {} --该类代码簇总集
require "game/monster/monster"
require "game/monster/monsterData"


local gmon = g.monster
local monsterMap = {}


function gmon.addMonster(mon,x,y,z)
  monsterMap[mon] = true
  mon.x = x
  mon.y = y
  mon.z = z
  g.map.enterUnitCache(mon) --尝试进入单位grid
end

function gmon.spawnNewMonster(monid,x,y,z)
  local mon = gmon.createMonsterByid(monid)
  gmon.addMonster(mon,x,y,z)
end

function gmon.resetUnitCache()
  local enterUnitCache = g.map.enterUnitCache
  for mon,_ in pairs(monsterMap) do
    enterUnitCache(mon) --尝试进入单位grid
  end
end


function gmon.updateRL(dt)
  for mon,_ in pairs(monsterMap) do
    mon:updateRL(dt)
  end
end


function gmon.updateAnim(dt)
  for mon,_ in pairs(monsterMap) do
    mon:updateAnim(dt)
  end
  
end