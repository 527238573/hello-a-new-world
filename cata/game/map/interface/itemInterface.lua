local gmap = g.map


local maxItem_per_square = 500

--读取itemlist 可能返回null_t
function gmap.getSquareItemList(x,y,z)
  local sx= bit.arshift(x,4)
  local sy= bit.arshift(y,4)--取得submap坐标
  local sm = gmap.get_submap(sx,sy,z)
  if sm==nil then return nil end --摧毁物品，发现了没有的地图
  local lx = bit.band(x,15)
  local ly = bit.band(y,15)
  return sm.item[lx*16+ly+1]
end


--同上，但为null_t,则自动创建新的，以保证可以向其中加入物品
function gmap.getOrCreateItemList(x,y,z)
  local sx= bit.arshift(x,4)
  local sy= bit.arshift(y,4)--取得submap坐标
  local sm = gmap.get_submap(sx,sy,z)
  if sm==nil then return nil end --摧毁物品，发现了没有的地图
  local lx = bit.band(x,15)
  local ly = bit.band(y,15)
  local index = lx*16+ly+1
  if sm.item[index] == c.null_t then sm.item[index] = {} end
  return sm.item[index]
end
function gmap.setSquareItemList(itemlist,x,y,z)
  local sx= bit.arshift(x,4)
  local sy= bit.arshift(y,4)--取得submap坐标
  local sm = gmap.get_submap(sx,sy,z)
  if sm==nil then return nil end --没有的地图
  local lx = bit.band(x,15)
  local ly = bit.band(y,15)
  sm.item[lx*16+ly+1] = itemlist
end



--很慢速的函数，基本要各种检测和已有物品合并,多个物品直接多次调用，因为检查太复杂保持单一个函数就好
function gmap.addItemToSqaure(item,x,y,z)
  local res,valid = gmap.hasFlag("DESTROY_ITEM",x,y,z)
  if res then
    return nil --被摧毁，被丢在可毁灭的地形上。
  elseif not valid then
    return nil --没有submap，也被摧毁
  end
  local try_stack = item:can_stack()
  for nx,ny,nz in gmap.closest_xypoint_first(x,y,z,2) do--默认为2
    if not(gmap.hasFlag("DESTROY_ITEM",nx,ny,nz) or gmap.hasFlag("NOITEM",nx,ny,nz) )then
      --可以放置物品
      local list = gmap.getOrCreateItemList(nx,ny,nz) -- 这里效率确实不快，三次bit取运算
      if list==nil then return nil end--遇到未加载的地图，销毁物品
      if try_stack then
        for i=1,#list do
          if list[i]:try_to_stack_with(item) then return list[i] end--已变成新
        end
      end
      if #list<maxItem_per_square then
        list[#list+1] = item
        return item
      end
    end
  end
end

--选取平面中接近的点，返回迭代器
function gmap.closest_xypoint_first(x,y,z,radius)
  local mx,my = 0,0
  local dx,dy = 0,-1
  local rrr = radius*2+1
  return function()
    local rx,ry,rz
    if mx>=-0.5*rrr and mx<=0.5*rrr and my>=-0.5*rrr and my<=0.5*rrr then
      rx,ry,rz =  x+mx,y+my,z
    end
    if mx==my or (mx<0 and mx == -my) or( mx>0 and mx ==1-my) then
      dx,dy =dy,dx
      dx = -dx
    end
    mx = mx+dx
    my = my+dy
    return rx,ry,rz
  end
end