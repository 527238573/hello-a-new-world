g.skill = {}
local skill_data = {}
local skill_mt = {}
skill_mt.__index = skill_mt


function data.loadSkills()
  local tmp = dofile("data/other/skillData.lua")
  data.all_skills = tmp
  data.skill_data = skill_data
  for i=1,#tmp do
    skill_data[tmp[i].id] = tmp[i]
  end
end


function g.skill.createSkills(t)
  local skills = {unit = t} --本体记在unit
  setmetatable(skills,skill_mt)
  --默认必有的技能
  --力量
  skills:addNewSkill("melee")
  skills:addNewSkill("unarmed")
  skills:addNewSkill("bashing")
  skills:addNewSkill("cutting")
  skills:addNewSkill("stabbing")
  --感知
  skills:addNewSkill("gun")
  skills:addNewSkill("archery")
  skills:addNewSkill("launcher")
  skills:addNewSkill("pistol")
  skills:addNewSkill("rifle")
  skills:addNewSkill("shotgun")
  skills:addNewSkill("smg")
  skills:addNewSkill("throw")
  --敏捷
  skills:addNewSkill("dodge")
  skills:addNewSkill("defence")
  skills:addNewSkill("swimming")
  skills:addNewSkill("driving")
  --智力
  skills:addNewSkill("bartering")
  skills:addNewSkill("speaking")
  skills:addNewSkill("computer")
  skills:addNewSkill("construction")
  skills:addNewSkill("cooking")
  skills:addNewSkill("tailor")
  skills:addNewSkill("electronics")
  skills:addNewSkill("fabrication")
  skills:addNewSkill("firstaid")
  skills:addNewSkill("mechanics")
  skills:addNewSkill("survival")
  skills:addNewSkill("traps")
  
  return skills
end


function skill_mt:addNewSkill(id,level,maxlevel)
  if skill_data[id]==nil then 
    debugmsg("error skill id!:"..id)
    return 
  end
  level = level or 0--默认0级开始
  maxlevel = maxlevel or 20 --最大20级
  self[id] ={level = level,exp=0,maxlevel= maxlevel}
end

--未学会的skill返回0,计算以0为数值的技能加成
function skill_mt:get_skill_level(id)
  if self[id] == nil then return 0  
  else return self[id].level end
end

function skill_mt:get_skill_name(id)
  local data_s = skill_data[id]
  return data_s.name
end

--amount，代表经验值，level，代表这堆经验的等级
function skill_mt:train(id,amount,level)
  local skill= self[id]
  if skill ==nil then return end --未找到此项技能
  if skill.level>=skill.maxlevel then return end --已达到最大等级
  
  local data_s = skill_data[id]
  if skill.level> level+3 then --超过4级不得经验
    if self.unit:is_player() and one_in(8) then
      addmsg(string.format(tl("这个工作对你来说太简单了，你的%s技能无法超过%d级。","This task is too simple to train your %s beyond %d."),data_s.name,skill.level))
    end
    return 
  end
  
  --特性等加成
  
  if skill.level>=level then
    amount = amount/((skill.level-level+2)*(skill.level-level+2)-1)-- 1/3,1/8,1/15,1/24
  end
  if amount>0 then skill.exp = skill.exp+amount end
  if skill.exp>=100 then
    skill.exp = 0
    skill.level = skill.level+1
    --升级
    if self.unit:is_player() then
      addmsg(string.format(tl("你的%s技能升级至等级%d！","Your skill in %s has increased to %d!"),data_s.name,skill.level),"good")
      if skill.level> level+3 then
        addmsg(string.format(tl("你感到这个级别的%s工作实在是太简单了。","You feel that %s tasks of this level are becoming trivial."),data_s.name))--不能再提升经验提示
      end
    end
  end
  
  
  
end
