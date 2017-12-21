local gmap = g.map


--有效区域内
gmap.inbounds = gmap.isSquareInGrid -- 就用这个


--不检测有效区域
function gmap.hasFlag(flag,x,y,z)
  local sx= bit.arshift(x,4)
  local sy= bit.arshift(y,4)--取得submap坐标
  local sm = gmap.get_submap(sx,sy,z)
  if sm==nil then return false,false end --返回没有， valid也为无效
  local lx = bit.band(x,15)
  local ly = bit.band(y,15)
  local tid = sm.raw.ter[lx][ly]
  local bid = sm.raw.block[lx][ly]
  local ret = data.ster[tid][flag]==true
  if bid>1 then ret = ret or data.block[bid][flag]==true end
  return ret,true
end
--多个flag and 检测，不检测有效区域
function gmap.hasFlags(flagList,x,y,z)
  local sx= bit.arshift(x,4)
  local sy= bit.arshift(y,4)--取得submap坐标
  local sm = gmap.get_submap(sx,sy,z)
  if sm==nil then return false,false end --返回没有，注意有效区域
  local lx = bit.band(x,15)
  local ly = bit.band(y,15)
  local tid = sm.raw.ter[lx][ly]
  local bid = sm.raw.block[lx][ly]
  local ret = true
  local terinfo = data.ster[tid]
  local binfo
  if bid>1 then binfo  = data.block[bid] end
  for _,v in ipairs(flagList) do
    local fhas = terinfo[v]==true
    if bid>1 then 
      fhas = fhas or binfo[v]==true
    end
    ret = ret and fhas
  end
  return ret,true
end

--地形与家具的结合，目前只查询grid内的
function gmap.square_movecost(x,y,z)
  local sx= bit.arshift(x,4)
  local sy= bit.arshift(y,4)--取得submap坐标
  local sm = gmap.getSubmapInGrid(sx,sy,z)
  if sm==nil then return -1 end -- 不存在的地图标为-1
  local lx = bit.band(x,15)
  local ly = bit.band(y,15)
  
  local ter_info = data.ster[sm.raw:getTer(lx,ly)]
  local move_cost = ter_info.move_cost
  local bid = sm.raw:getBlock(lx,ly)
  if bid>1 then
    local blockinfo = data.block[bid]
    if blockinfo.resetTM then
      move_cost = blockinfo.move_cost
    else
      move_cost = move_cost +blockinfo.move_cost
    end
  end
  return move_cost
end

function gmap.impassable(x,y,z)
  local movecost =gmap.square_movecost(x,y,z)
  return movecost ==0 or movecost<-1 --注意-1时（地图无效时，默认仍是可pass）
end


--读取修改特定的ter，block
--同时读取
function gmap.getTerIdAndBlockId(x,y,z)
  local sx= bit.arshift(x,4)
  local sy= bit.arshift(y,4)--取得submap坐标
  local sm = gmap.get_submap(sx,sy,z)
  if sm==nil then return -1,-1 end -- 不存在的地图标为-1
  local lx = bit.band(x,15)
  local ly = bit.band(y,15)
  return sm.raw.ter[lx][ly],sm.raw.block[lx][ly]
end
--单一读取




--同时设置ter和block，如果为nil则为不修改，当只需修改一项时
function gmap.setTerAndBlock(new_ter,new_block,x,y,z)
  if type(new_ter)=="string" then new_ter=data.ster_name2id[new_ter] end --注意若为不存在的名字则没有报错，直接忽略了，可能将拼写错误隐含
  if type(new_block)=="string" then new_block=data.block_name2id[new_block] end --注意若为不存在的名字则没有报错，直接忽略了，可能将拼写错误隐含
  local sx= bit.arshift(x,4)
  local sy= bit.arshift(y,4)--取得submap坐标
  local sm = gmap.get_submap(sx,sy,z)
  if sm==nil then debugmsg("setTer on submap nonexistent");return end 
  local lx = bit.band(x,15)
  local ly = bit.band(y,15)
  if new_ter then 
    sm.raw:setTer(new_ter,lx,ly)
    sm.dirty = true--这个变量在绘制使用到，表示需要重建绘制
    if ly<=0 then 
      local sm2 = gmap.get_submap(sx,sy-1,z)
      if sm2~=nil then sm2.dirty = true end
    end
    if ly>=15 then 
      local sm2 = gmap.get_submap(sx,sy+1,z)
      if sm2~=nil then sm2.dirty = true end
    end
    if lx<=0 then 
      local sm2 = gmap.get_submap(sx-1,sy,z)
      if sm2~=nil then sm2.dirty = true end
    end
    if lx>=15 then 
      local sm2 = gmap.get_submap(sx+1,sy,z)
      if sm2~=nil then sm2.dirty = true end
    end
  end
  if new_block then 
    sm.raw:setBlock(new_block,lx,ly) 
  end
  if new_ter or new_block then
    gmap.zLevelCache.setOneLayerTransDirty(z)--改成全部
  end
end


function gmap.has_floor_or_support(x,y,z)
  local tid,bid = gmap.getTerIdAndBlockId(x,y,z)
  if tid ==-1 then return z<=1 end --不存在的地图空中无support
  --现在无support的地形暂为空气，室内空气
  local ter_info = data.ster[tid]
  return ter_info.nosupport --
end



function gmap.open_door(x,y,z,inside,checkOnly)
  inside = inside or true
  checkOnly = checkOnly or false
  
  local tid,bid = gmap.getTerIdAndBlockId(x,y,z)
  local ter_info = data.ster[tid]
  local block_info = data.block[bid]
  if ter_info.open_door then
    local newinfo = data.ster_name2info[ter_info.open_door]
    if newinfo == nil then
      debugmsg(string.format("wrong open_door name :%s ,at terrain:%s",ter_info.open_door,ter_info.name))
      return false
    end
    if ter_info["OPENCLOSE_INSIDE"] and inside==false then
      return false --只能在内部打开
    end
    
    if not checkOnly then
      gmap.setTerAndBlock(ter_info.open_door,nil,x,y,z)
      local sound_id = ter_info.open_door_sound or "dooropen1"--默认值
      g.playSound(sound_id,true,x,y,z)
    end
    return true
  elseif bid>1 and block_info.open_door then
    local newinfo = data.block_name2info[block_info.open_door]
    if newinfo == nil then
      debugmsg(string.format("wrong open_door name :%s ,at block:%s",block_info.open_door,block_info.name))
      return false
    end
    if block_info["OPENCLOSE_INSIDE"] and inside==false then
      return false --只能在内部打开
    end
    if not checkOnly then
      gmap.setTerAndBlock(nil,block_info.open_door,x,y,z)
      local sound_id = block_info.open_door_sound or "dooropen1"
      g.playSound(sound_id,true,x,y,z)
    end
    return true
  end
  return false
  --省略开车门
end


function gmap.close_door(x,y,z,inside,checkOnly)
  inside = inside or true
  checkOnly = checkOnly or false
  
  local tid,bid = gmap.getTerIdAndBlockId(x,y,z)
  local ter_info = data.ster[tid]
  local block_info = data.block[bid]
  if ter_info.close_door then
    local newinfo = data.ster_name2info[ter_info.close_door]
    if newinfo == nil then
      debugmsg(string.format("wrong close_door name :%s ,at terrain:%s",ter_info.close_door,ter_info.name))
      return false
    end
    if ter_info["OPENCLOSE_INSIDE"] and inside==false then
      return false --只能在内部打开
    end
    
    if not checkOnly then
      gmap.setTerAndBlock(ter_info.close_door,nil,x,y,z)
      local sound_id = ter_info.close_door_sound or "doorclose1"--默认值
      g.playSound(sound_id,true,x,y,z)
    end
    return true
  elseif bid>1 and block_info.close_door then
    local newinfo = data.block_name2info[block_info.close_door]
    if newinfo == nil then
      debugmsg(string.format("wrong close_door name :%s ,at block:%s",block_info.close_door,block_info.name))
      return false
    end
    if block_info["OPENCLOSE_INSIDE"] and inside==false then
      return false --只能在内部打开
    end
    if not checkOnly then
      gmap.setTerAndBlock(nil,block_info.close_door,x,y,z)
      local sound_id = block_info.close_door_sound or "doorclose1"
      g.playSound(sound_id,true,x,y,z)
    end
    return true
  end
  return false
end








