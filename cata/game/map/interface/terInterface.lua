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

--读取修改特定的ter，block
--同时读取
function gmap.getTerIdAndBlockId(x,y,z)
  local sx= bit.arshift(x,4)
  local sy= bit.arshift(y,4)--取得submap坐标
  local sm = gmap.get_submap(sx,sy,z)
  if sm==nil then return -1,-1 end -- 不存在的地图标为-1
  local lx = bit.band(x,15)
  local ly = bit.band(y,15)
  return sm.raw:getTer(lx,ly),sm.raw:getBlock(lx,ly)
end





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
end


