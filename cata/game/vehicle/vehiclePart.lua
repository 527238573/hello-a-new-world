
local gveh = g.vehicle
local vehiclePart_mt = {}
vehiclePart_mt.__index = vehiclePart_mt
g.vehicle.vehiclePart_mt = vehiclePart_mt


--和cdda中的vehicle part不同，这里一个part表示车辆空间内占的一个方格，而不是方格上的多个配件。


--只有vehicle能创建，基本变量的填写在vehicle里 ，
function gveh.create_vehiclePart(veh)
  local new_vp= {}
  setmetatable(new_vp,vehiclePart_mt)
  new_vp.veh = veh
  new_vp.open = false --对能open的才有效。
  new_vp.gas_amount =0 --油量等。
  
  new_vp.components = {} --数组，储存该part上的components。 按zorder排序。同zorder不计顺序。只有veh本体管理components的拆卸。因为要管理特殊种类的components
  return new_vp 
end


--安装。-不检测。 通过插入排序。
function vehiclePart_mt:installComponent(component)
  local zorder = component.type.zorder
  for i=1,#self.components do 
    if zorder< self.components[i].type.zorder then
      table.insert(self.components,i,component)
      return
    end
  end
  table.insert(self.components,component)
  component.part = self
end

--此部位含有feature flag 的component数量
function vehiclePart_mt:feature_count(feature)
  local count =0
  for i=1,#self.components do 
    if self.components[i]:hasFlag(feature) then count = count+1 end
  end
  return count
end

--寻找临近的相似类型，选择nborder图像时使用
function vehiclePart_mt:checkBorder(dx,dy,component_type)
  local part = self.veh:get_part(self.x+dx,self.y+dy)
  if part==nil then return false end
  for _,component in ipairs(part.components) do
    if component.type == component_type then return true end --找到
  end
  return false
end
