local gmap = g.map

local vars

--初始化一些data的读取变量
function gmap.initBashInterface()
  vars={}
  vars.open_air_id =data.ster_name2id["t_air"] 
  vars.indoor_air_id =data.ster_name2id["t_air_indoor"] 
  vars.dirt_id =data.ster_name2id["t_dirt"] 
  vars.rockfloor_id =data.ster_name2id["t_rock"] 
end
--获得房顶  在ter_set = nil,时，会查找下方的支撑房顶
local function getRoof(x,y,z,allow_air)

  if z<c.Z_MIN then  return vars.rockfloor_id end
  local terThere = gmap.getTerIdAndBlockId(x,y,z)
  local terinfo = data.ster[terThere]
  if terinfo ==nil or terinfo.roof==nil then
    --return vars.open_air_id --不存在的地形信息，或坐标超出有效区,或无roof信息
    if not allow_air then return vars.dirt_id end
    if z<1 then return vars.indoor_air_id else return vars.open_air_id end --地下始终是
  end
  local newter = data.ster_name2id[terinfo.roof]
  if newter==nil then--找不到roof 对应的type
    debugmsg("Error:invalid roof type: ter_nameid:"..terinfo.name.." roof:"..newter)
    return vars.dirt_id
  end
  if z==0 and newter ==vars.rockfloor_id then-- A hack to work around not having a "solid earth" tile
    newter = vars.dirt_id --地表岩石自动变为泥土，特殊处理
  end
  return newter
end



local function bash_ter_block(x,y,z,bash_t)
  local tid,bid = gmap.getTerIdAndBlockId(x,y,z)
  if tid<1 then return end --超出有效范围
  local bash_info
  --local ter_info
  --local block_info 
  local smash_ter,smash_block = false,false
  if bid>1 then
    local block_info = data.block[bid]
    if block_info.bash then
      bash_info = block_info.bash
      smash_block = true
    end
  end
  if not smash_block then
    local ter_info = data.ster[tid]
    if ter_info.bash then
      bash_info = ter_info.bash
      smash_ter = true
    end
  end

  --确定了smash的对象

  --地板bash check，省略，
  --警报相关，省略

  if bash_info==nil or (bash_info.destory_only and not bash_t.destory) then
    if gmap.impassable(x,y,z) then
      --不可通行的地点，bash任然有效，不被当成空气，
      g.animManager.addEffectToSquareCenter("bash1",x,y,z)--默认bash失败效果
      bash_t.did_bash = true --表明已bash，不是打空气
      bash_t.cant_be_damaged = true --不可毁坏的
    end
    return--bash失败，没有可bash的东西或 普通bash无敌的东西
  end


  local resist_min = bash_info.str_min
  local resist_max = bash_info.str_max --省略 支撑物等加强数
  local resistance = resist_min + (resist_max-resist_min)*bash_t.roll
  local success = bash_t.destory or (resistance<=bash_t.str)--是否被打破
  bash_t.cant_be_damaged = resist_min>bash_t.str
  --声音
  if( not success )then --未成功，只有效果，实际无改变
    bash_t.did_bash = true
    if not bash_t.silent then
      g.animManager.addEffectToSquareCenter(bash_info.fail_effect,x,y,z)
      debugmsg("fail resist:"..resistance)
    end
    return
  end
  --之后就是成功后改变格子地形

  --plant，孢子 帐篷，等处理，省略
  if smash_block then
    local blockset = bash_info.block_set or 0
    gmap.setTerAndBlock(nil,blockset,x,y,z)--修改bash后的地形
  elseif not smash_ter then
    debugmsg("error bash air")
  elseif bash_info.ter_set then
    gmap.setTerAndBlock(bash_info.ter_set,nil,x,y,z)--修改bash后的地形
  else--没有bash后的地形，取空气或roof
    --supportroof bash下层省略
    gmap.setTerAndBlock(getRoof(x,y,z-1,true),nil,x,y,z)--修改bash后的地形,通常为空气了
  end
  --生成物品
  gmap.spawn_items1(x,y,z,bash_info.items)

  --帐篷，爆炸，垮塌，支柱垮塌省略
  bash_t.did_bash = true
  bash_t.success = success
  if not bash_t.silent then
    g.animManager.addEffectToSquareCenter(bash_info.effect,x,y,z)
  end
  --完毕
end
--核心函数
--[[使用了大量声音系统的东西，需要以后添加修改
--]]   --silent-是否添加碎裂特效
function gmap.bashSquare(x,y,z,str,silent,destory,bash_floor)
  silent = silent or false
  destory = destory or false
  bash_floor = bash_floor or false

  local bash_t = {str = str,silent =silent,destory=destory,bash_floor=bash_floor,roll = rnd(),did_bash = false,succuess = false,cant_be_damaged = false}

  bash_ter_block(x,y,z,bash_t)--目前只bash地面和家具

  return bash_t
end

function gmap.is_bashable(x,y,z)
  local tid,bid = gmap.getTerIdAndBlockId(x,y,z)
  if tid<1 then return  false end --超出有效范围

  if bid>1 then
    local block_info = data.block[bid]
    if block_info.bash then return true end--可砸
  end
  local ter_info = data.ster[tid]
  if ter_info.bash then return true end
  return false

end


--返回数字评价等级，负为无效
function gmap.bash_rating(str,x,y,z)
  local tid,bid = gmap.getTerIdAndBlockId(x,y,z)
  if tid<1 then return  -1 end --超出有效范围
  local bash_min,bash_max
  if bid>1 then
    local block_info = data.block[bid]
    if block_info.bash then bash_min,bash_max =  block_info.bash.str_min,block_info.bash.str_max end
  end

  if bash_min==nil then
    local ter_info = data.ster[tid]
    if ter_info.bash then bash_min,bash_max =  ter_info.bash.str_min,ter_info.bash.str_max end
  end
  if bash_min==nil then return -1 end--没有可bash的
  if str<=bash_min then return 0
  elseif str>= bash_max then return 10 
  else
    return math.max(1,10*(str-bash_min)/(bash_max - bash_min))
  end
end


--射击穿过地格,返回true 停止
function gmap.shootThroughSquare(projectile,x,y,z)
  if projectile.dest_unit ==nil then--射击地面
    if x==projectile.dest_x and y==projectile.dest_y and z==projectile.dest_z then
      --射击地面
      gmap.shootSquare(projectile,x,y,z,true,true)
      return true,false--停止
    end
  end
  
  
  local tid,bid = gmap.getTerIdAndBlockId(x,y,z)
  if tid<1 then return  true end --超出有效范围
  local tinfo = data.ster[tid]
  local binfo = data.block[bid] --新加了0格子
  
  local trans = tinfo.transparent and binfo.transparent
  local moumtable = tinfo["MOUNTABLE"] or binfo["MOUNTABLE"]
  local move_cost = binfo.resetTM and binfo.move_cost or tinfo.move_cost +binfo.move_cost
  local block = move_cost<=0 --堵路
  local block_movecost = binfo.move_cost
  
  local blindage = false --掩体类型
  local shooted = false
  if not trans and block then
    --完全被挡住
    gmap.shootSquare(projectile,x,y,z,false,false)
    shooted = true
    blindage= true
  elseif trans and block then --可透过,但不可穿行
    --todo玻璃墙特殊处理？ 防弹玻璃等
    blindage= true
    if one_in(2) then --50%几率击中地形
      gmap.shootSquare(projectile,x,y,z,false,false)
      shooted = true
    end
  elseif  moumtable then --半高掩护体
    blindage= true
    if rnd()<0.15 then --15%几率击中地形
      gmap.shootSquare(projectile,x,y,z,false,false)
      shooted = true
    end
  else
    --击中家具等,movecost越大被打中几率越大， --最大200movecost封顶 10%击中几率
    if block_movecost>0 and rnd()< c.clamp(block_movecost/200*0.1,0,0.1) then 
      gmap.shootSquare(projectile,x,y,z,false,false)
      shooted = true
    end
  end
  
  --子弹拖拽的效果
  
  --子弹穿墙（如果可以）的衰减，考虑物体的硬度（bash难度），将shoot重设回来
  
  return shooted,blindage
end

function gmap.shootSquare(projectile,x,y,z,hitground,hitItems)
  local totaldam = projectile.dam_ins:total_dam()* projectile.dam_mul--没有系数修正的总伤害 * 总修正系数
  local delay = projectile:getFlyPostionDelay(x,y,z)
  g.insertDelayFunction(delay,function() 
      gmap.bashSquare(x,y,z,totaldam/rnd(1,3),false,false,hitground) --延迟，调用，保持和动画一致，子弹飞到该处才炸裂
      debugmsg("delay bashed!")
  end)
  --子弹特效，点火等
  --smash物品
end