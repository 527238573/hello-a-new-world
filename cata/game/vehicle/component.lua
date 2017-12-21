--车辆元件。轮子，椅子等等

local gveh = g.vehicle
local component_mt = {}
component_mt.__index = component_mt
g.vehicle.component_mt = component_mt

--源cdda vehiclepart
function gveh.create_component(id,style,color)
  local ctype = data.veh_components[id]
  if ctype==nil then error("Wrong component id:"..id )end
  
  local new_c= {}
  setmetatable(new_c,component_mt)
  new_c.type = ctype
  --new_c.part = nil--在 part的 installComponent里设定
  new_c.hp = ctype.durability
  new_c.style = style or 1
  new_c.color = color or 1
  --基本变量。
  --[[
  img,quad,rot,sx,sy.
  --]]
  return new_c 
end



local r00 = math.rad(0)
local r09 = math.rad(90)
local r18 = math.rad(180)
local r27 = math.rad(270)
-------------------0,         1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
local borderIndex= {[0] = 1,  5,  5,  4,  5,  3,  4,  2,  5,  4,  3,  2,  4,  2,  2,  1}
local borderRad=   {[0] =r00, r09,r00,r18,r27,r09,r09,r09,r18,r27,r00,r18,r00,r27,r00,r00}
--需要手动调用，在全components创建完毕后再次调用这个，刷新Nborder的图像。
function component_mt:reset_quad()
  local quad_t = self.type.quads --可能为nil
  if self.type.styles then 
    quad_t = self.type.styles[self.style]
  end
  if quad_t ==nil then return end --没有图像的组件。
  
  self.rot = quad_t.rot or 0 --默认无旋转
  self.sx = quad_t.sx or 1 --默认无翻转
  self.sy = quad_t.sy or 1 --默认无翻转
  self.img = quad_t.img
  --确定使用的quad
  if quad_t.nborder then
    --相邻类型。
    local statecode  = 0
    if self.part:checkBorder(0,1,self.type) then statecode = statecode+8 end
    if self.part:checkBorder(1,0,self.type) then statecode = statecode+4 end
    if self.part:checkBorder(0,-1,self.type) then statecode = statecode+2 end
    if self.part:checkBorder(-1,0,self.type) then statecode = statecode+1 end
    self.quad = quad_t[borderIndex[statecode]]
    self.rot = borderRad[statecode]
  else
    local index = 1
    if quad_t.ncolor and self.color <=#quad_t and self.color>=1 then index = self.color end --有ncolor就使用color
    if quad_t.open and self.part.open then 
      self.quad =  quad_t.ncolor and quad_t.open[index] or quad_t.open
    elseif self.hp<=0 and quad_t.broken then
      self.quad = quad_t.ncolor and quad_t.broken[index] or quad_t.broken
    else
      self.quad = quad_t[index]
    end
  end
  
end

function component_mt:setCovered(covered)
  self.covered = covered
  return covered or self.type.cover_all
end


function component_mt:hasFlag(flag)
  return self.type.flags[flag]
end

function component_mt:drawToBatch(x,y,batch,show_all)
  --local scale = 1.01
  if self.quad and (not self.covered or show_all) then 
    batch:add(self.quad,x*32+16,(-y-1)*32+16,self.rot,self.sx,self.sy,16,16)
  end
end
