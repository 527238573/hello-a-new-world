g.vehicle = {}
local vehicle_mt = {}
vehicle_mt.__index = vehicle_mt
g.vehicle.vehicle_mt = vehicle_mt
local gveh = g.vehicle
require"game/vehicle/data/vehicleData"
require"game/vehicle/vehiclePart"
require"game/vehicle/component"
require"game/vehicle/vehicleFactory"


function gveh.create_vehicle()
  local new_v= {}
  setmetatable(new_v,vehicle_mt)
  --基本变量
  new_v.name = "Custom"-- 名字。
  --旋转，正向向右？
  new_v.rotation = 0
  new_v.x = 0 --绝对X，y  与suqare坐标对应。可小数。
  new_v.y = 0--绝对X,Y       对应与车辆中心点坐标
  new_v.z = 1--绝对X,Y

  new_v.center_x = 8--车辆中心点，在0-16的范围内。 
  new_v.center_y = 8

  new_v.relative_parts  ={} --车辆空间坐标对应parts。 x,y 应为0-15的整数，key为 x*16+y.
  new_v.parts ={}--非顺序存放的parts。 key就为parts .   值就为上面的key。

  --不同种类型的components列表。
  new_v.engines ={}



  --其他
  new_v.show_all = true --是否显示所有组件，不计cover_all 的覆盖
  new_v.batch_dirty = true 
  return new_v 
end






--世界square坐标，转换为车辆空间的坐标,注意格子中心应传X.5的坐标。
function vehicle_mt:coordinate_sqr_to_veh(x,y)
  local ox = x - self.x
  local oy = y - self.y
  local sina = math.sin(-self.roation)
  local cosa = math.cos(-self.roation) 
  return cosa*ox -sina*y+self.center_x,x*sina +y*cosa+self.center_y
end
--车辆空间的坐标（0-16的那个值）转换为sqr坐标。 还是小数，floor下才能变成具体sqr坐标。
function vehicle_mt:coordinate_veh_to_sqr(x,y)
  local ox =x-self.center_x
  local oy =y-self.center_y
  local sina = math.sin(self.roation)
  local cosa = math.cos(self.roation) 
  return cosa*ox -sina*y+self.x,x*sina +y*cosa+self.y
end

--增加x,y 车辆空间内坐标
function vehicle_mt:new_vehicle_part(x,y)
  assert(x>=0 and x<=15 and y>=0 and y<=15,"vehicle part coord error")
  x,y = math.floor(x),math.floor(y)--防止小数
  local key = x*16+y
  --警告并删除旧的。
  if self.relative_parts[key] then debugmsg("warning: new vehicle part overwirtes the old one.");self.parts[self.relative_parts[key]] = nil end
  local part = gveh.create_vehiclePart(self)
  self.relative_parts[key] = part
  self.parts[part] = key
  --part.veh = self
  part.key = key
  part.x = x
  part.y = y

  return part
end
--删除part
function vehicle_mt:remove_vehicle_part(x,y)
  assert(x>=0 and x<=15 and y>=0 and y<=15,"vehicle part coord error")
  local key = x*16+y
  local part = self.relative_parts[key]
  self.relative_parts[key] = nil
  if part then self.parts[part] = nil end
end


--可能返回nil
function vehicle_mt:get_part(x,y)
  if x>=0 and x<=15 and y>=0 and y<=15 then
    return self.relative_parts[x*16+y]
  else
    return nil
  end
end


--检测是否能安装components在这个位置。不考虑技能等玩家条件。
function vehicle_mt:can_mount(x,y,component_id)
  local comp_info = data.veh_components[component_id]
  if comp_info==nil then debugmsg("Error component_id:"..component_id);return false end

  local part = self:get_part(x,y)
  if part ==nil then--空的位置。
    if comp_info.location ~="structure" then --空位置必须第一个添加车架层。
      return false 
    else
      --添加structure，检查附近有无支撑组件
      if (not self:has_structural_part(x+1,y)) and (not self:has_structural_part(x,y+1)) and (not self:has_structural_part(x-1,y)) and (not self:has_structural_part(x,y-1)) then
        return false 
      end
      return true --可以，第一个添加structure。
    end
  end
--part有值的情况下，如果是structure会应为位置被占据而不能添加。
  for i=1,#part.components do
    local one_ctype = part.components[i].type
    if one_ctype.location == comp_info.location and comp_info.location~= "anywhere" then--只有anywhere才能重复，其他location只能占据一个
      return false --
    end
    if one_ctype.id == comp_info.id then return false end --同种类只能一个。
    if one_ctype.flags["PROTRUSION"] then return false end --以突出物为车架，不能添加其他组件了。
  end

  if comp_info.flags["MUSCLE"] then
    if self:has_engine_type("MUSCLE",false) then return false end --人力引擎只能一个。
  end
  if comp_info.flags["ALTERNATOR"] then
    local anchor_found = false
    for i=1,#part.components do
      local one_ctype = part.components[i].type
      if one_ctype.flags["ENGINE"] and (one_ctype.flags["GASOLINE"] or one_ctype.flags["DIESEL"] or one_ctype.flags["MUSCLE"]) then
        anchor_found = true
        break
      end
    end
    if not anchor_found then return false end --发电机必须放在引擎上，而且不能是电力引擎
  end
  
  if comp_info.flags["ON_CONTROLS"] then
    local anchor_found = false
    for i=1,#part.components do
      local one_ctype = part.components[i].type --需要在controls之上的物体，和控制器必须安在一起。
      if one_ctype.flags["CONTROLS"]  then
        anchor_found = true
        break
      end
    end
    if not anchor_found then return false end 
  end
  
  if comp_info.flags["CURTAIN"] then
    local anchor_found = false
    for i=1,#part.components do
      local one_ctype = part.components[i].type --需要在窗户上挂窗帘。
      if one_ctype.flags["WINDOW"]  then
        anchor_found = true
        break
      end
    end
    if not anchor_found then return false end 
  end
  --暂就这么多条件。
  
  --除了空part装structure外，全部满足通过此处返回true。
  return true
end--can_mount

--是否能卸除。不检查component是否在xy上，
function vehicle_mt:can_unmount(x,y,component)
  local part = self:get_part(x,y)
  if part ==nil then return false end--空的位置。
  
  if component:hasFlag("ENGINE") and part:feature_count("ALTERNATOR")>0 then return false end --需要取下连接的组件。
  if component:hasFlag("CONTROLS") and part:feature_count("ON_CONTROLS")>0 then return false end 
  if component:hasFlag("WINDOW") and part:feature_count("CURTAIN")>0 then return false end 
  
  if component.type.location == "structure" then
    for i=1,#part.components do
      if part.components[i].type.location ~="structure" then return false end --取下structure之前，必须先取下其他类型的component
    end
    if #part.components==1 then --取下最后一个。。。需要检测不能把车辆劈成两半
      local connected ={}
      if self:get_part(x+1,y) then connected[#connected+1] = {x+1,y} end
      if self:get_part(x-1,y) then connected[#connected+1] = {x-1,y} end
      if self:get_part(x,y+1) then connected[#connected+1] = {x,y+1} end
      if self:get_part(x,y-1) then connected[#connected+1] = {x,y-1} end --四个方向上的连接part
      if #connected>1 then --
        for i=2,#connected do
          if not self:is_connected(connected[1][1],connected[1][2],connected[i][1],connected[i][2],x,y) then return false end --不能连接就返回false
        end
      end
    end
  end
  return true
end


function vehicle_mt:is_connected(x1,y1,x2,y2,ex,ey) --可以修改为不带递归的。
  local searched = {}
  local function search_point(sx,sy)
    if not(sx>=0 and sx<=15 and sy>=0 and sy<=15) then return false end --超出范围
    local skey = sx*16+sy
    if searched[skey] then return false end --已经查找过这个点
    searched[skey]= true --标记查找过
    if self:get_part(sx,sy)==nil then return false end --未找到，为空
    if sx==x1 and sy==y1 then return true end--找到，终结
    if sx==ex and sy==ey then return false end --与去除点相同，视为空
    if search_point(sx+1,sy) then return true end
    if search_point(sx-1,sy) then return true end
    if search_point(sx,sy+1) then return true end
    if search_point(sx,sy-1) then return true end
    return false
  end
  return search_point(x2,y2)--极限情况下有200多层递归？16*16
end



--有能支撑的组件。
function vehicle_mt:has_structural_part(x,y)
  local part = self:get_part(x,y)
  if part ==nil then return false end
  for i=1,#part.components do
    local one_ctype = part.components[i].type
    if one_ctype.location == "structure" then
      if one_ctype.flags["PROTRUSION"] then --突出物，非车架的车架层物体，如钉刺。不能算是车架支撑
        return false
      else
        return true
      end
    end
  end
  return false --不可能的，应为没有结构就不存在part了。
end


--查找有无该类型engine， enabled 为true则要检查可用性。
function vehicle_mt:has_engine_type(engine_type,enabled)
  for i=1,#self.engines do
    local engine = self.engines[i]
    if engine:hasFlag(engine_type) then
      return true
    end
  end
  return false
end



--component已经创建的情况下，强制安装。安装新组件的唯一入口。refresh设为false时需要手动刷新。通常为创建车辆时连续安装所有组件后再刷新。
function vehicle_mt:install_component(x,y,component,refresh)
  if not(x>=0 and x<=15 and y>=0 and y<=15) then return false end --超出范围，安装失败
  local part = self:get_part(x,y)
  if part==nil then part = self:new_vehicle_part(x,y) end
  part:installComponent(component)
  --安装新组件后刷新车辆信息！
  refresh = refresh or true --默认刷新。
  if refresh then  self:refresh() end
  return true
end

--从id创建，强制安装，不检查，不刷新。
function vehicle_mt:intstall_component_force(x,y,component_id,hp,style,color)
  hp = hp or -1
  local component=gveh.create_component(component_id,style,color)
  if hp>=0 then component.hp = hp end
  self:install_component(x,y,component,false)
end


--增删组件时会调用此方法。会改变车辆的整体信息，出力等。
function vehicle_mt:refresh()
  self.engines ={}
  for part,_ in pairs(self.parts) do
    local covered = false
    for i=#part.components,1,-1 do 
      local component = part.components[i]
      covered = component:setCovered(covered)
      if component:hasFlag("ENGINE") then table.insert(self.engines,component) end
    end
  end
  
  
  
  self:redraw_cache()--刷新图像
end



function vehicle_mt:getBatch()
  if self.batch ==nil then
    self.batch = love.graphics.newSpriteBatch(data.vehicleBatch_img)
  end
  return self.batch
end

function vehicle_mt:redraw_cache()
  local batch = self:getBatch()
  batch:clear()
  for part,_ in pairs(self.parts) do
    for _,component in ipairs(part.components) do
      component:reset_quad()--图像状态重置
      component:drawToBatch(part.x - self.center_x,part.y-self.center_y,batch,self.show_all)
    end
  end
  self.batch_dirty = false
end
