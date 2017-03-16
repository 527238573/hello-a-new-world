--building指的是连接的 N*M*l 的整块oter，能够 旋转

local img = data.Oter_BigImage--先读取overmapTer之后，使用同样的img
local imgw,imgh = img:getDimensions()
local otersize = 16

local overmapBuildings = {}


local function newBuilding(name,xlen,ylen,zmax,zmin,common)
  local rotate = true
  --rotate默认为true
  --zmax，zmin对应generate过程中对上下层影响的高度，起点z=1 
  --比如一座房子，zmin = -1, zmax = 2，表示地下2层，地上2层（包括房顶算一层）。如果在z=-5处生成这座房子，实际z范围就是 -7 到-4
  assert(zmax>=1 and zmax<=12,"zmax out range!")
  assert(zmin>=-10 and zmin<=1,"zmin out range!")
  assert(xlen>=1 and ylen>=1,"xlen or ylen out range!")
  local zlen  = zmax - zmin+1  --层数
  
  local newb = {name = name,xlen = xlen,ylen = ylen,zlen = zlen,zmax = zmax,zmin = zmin,rotate = true}
  newb.top = {}
  --创建各个oter数据
  for x = 0,xlen-1 do
    for y= 0,ylen-1 do
      for z = 0,zlen-1 do
        local building_oter = {name = name.."="..x.."="..y.."="..z}
        building_oter.tiletype = 4 --overmapbuilding
        building_oter.rotate = true
        building_oter.building = newb --直接连接table
        building_oter.rx = x
        building_oter.ry = y
        building_oter.rz = z
        if common then
          for k,v in pairs(common) do
            building_oter[k] = v --公共的同样属性
          end
        end
        newb[x*ylen*zlen+y*zlen+z+1] = building_oter
        
      end
    end
  end
  table.insert(overmapBuildings,newb)
  return newb
end

local function getOterInBuilding(building,sx,sy,sz)--相对坐标 x=1...n ,y= 1...n,z= zmin...zmax(取值范围)
  return building[(sx-1)*building.ylen*building.zlen+(sy-1)*building.zlen+(sz-building.zmin)+1]
end

--todo优化相同的quad
local function setBuildingLayerQuad(building,zlayer,startx,starty,endx,endy)--左上至右下 的quad 坐标  
  --检测数据合理性范围
  local xlen,ylen,zlen = building.xlen,building.ylen,building.zlen
  
  assert((endx-startx+1)==xlen,"layerX != xlen")
  assert((endy-starty+1)==ylen,"layerY != ylen")
  --assert(zlayer>=building.zmin and zlayer<=building.zmax,"zlayer out range")
  
  starty,endy = endy,starty
  
  for x = 0,xlen-1 do
    for y= 0,ylen-1 do
      local quad = love.graphics.newQuad((startx+x)*otersize,(starty-y)*otersize,otersize,otersize,imgw,imgh)
      if zlayer=="all" then
        for z = building.zmin,building.zmax do
          local index = x*ylen*zlen+y*zlen+z+1
          building[index][1] = quad
        end
      elseif type(zlayer)=="number" then
        local z = zlayer-building.zmin
        local index = x*ylen*zlen+y*zlen+z+1
        building[index][1] = quad
      end
        
      
    end
  end
end
local function setBuildingTop(building,zlayer,startx,starty,endx,endy)--左上至右下 的quad 坐标
  --检测数据合理性范围
  local top = building.top
  local xlen,ylen,zlen = building.xlen,building.ylen,building.zlen
  assert((endx-startx+1)==xlen,"layerX != xlen")
  assert((endy-starty+1)==ylen,"layerY != ylen")
  assert(zlayer>=building.zmin and zlayer<=building.zmax,"zlayer out range")
  starty,endy = endy,starty
  
  for x = 0,xlen-1 do
    for y= 0,ylen-1 do
      local quad = love.graphics.newQuad((startx+x)*otersize,(starty-y)*otersize,otersize,otersize,imgw,imgh)
      if zlayer=="all" then
        for z = building.zmin,building.zmax do
          local index = x*ylen*zlen+y*zlen+z+1
          top[index] = quad
        end
      elseif type(zlayer)=="number" then
        local z = zlayer-building.zmin
        local index = x*ylen*zlen+y*zlen+z+1
        top[index] = quad
      end
      
    end
  end
end


local shadow_x1 = love.graphics.newQuad(1*otersize,4*otersize,otersize,otersize,imgw,imgh)
local shadow_x2 = love.graphics.newQuad(2*otersize,4*otersize,otersize,otersize,imgw,imgh)
local shadow_y1 = love.graphics.newQuad(0*otersize,5*otersize,otersize,otersize,imgw,imgh)
local shadow_y2 = love.graphics.newQuad(0*otersize,6*otersize,otersize,otersize,imgw,imgh)
local shadow_cy = love.graphics.newQuad(3*otersize,4*otersize,otersize,otersize,imgw,imgh)
local shadow_cx = love.graphics.newQuad(4*otersize,4*otersize,otersize,otersize,imgw,imgh)
local shadow_cc = love.graphics.newQuad(5*otersize,4*otersize,otersize,otersize,imgw,imgh)
local shadow_c0 = love.graphics.newQuad(2*otersize,2*otersize,otersize,otersize,imgw,imgh)
local function setNormalTop(building,zlayer)
  local xlen,ylen,zlen = building.xlen,building.ylen,building.zlen
  local top = building.top
  for x = 0,xlen-1 do
    for y= 0,ylen-1 do
      local quad
      if x==xlen-1 then 
        if y==0 then --角落
          if xlen==1 then 
            if ylen==1 then
              quad = shadow_c0
            else
              quad = shadow_cx
            end
          else
            if ylen==1 then
              quad = shadow_cy
            else
              quad = shadow_cc
            end
          end
        else
          if y==ylen-1 then
            quad = shadow_y1
          else
            quad = shadow_y2
          end
        end
      elseif y==0 then
        if x==0 then
            quad = shadow_x1
          else
            quad = shadow_x2
        end
      end
      if zlayer=="all" then
        for z = building.zmin,building.zmax do
          local index = x*ylen*zlen+y*zlen+z+1
          top[index] = quad
        end
      elseif type(zlayer)=="number" then
        local z = zlayer-building.zmin
        local index = x*ylen*zlen+y*zlen+z+1
        top[index] = quad
      end
    end
  end
end
local tmp_building

tmp_building = newBuilding("house22",2,2,1,1)
setBuildingLayerQuad(tmp_building,1,1,5,2,6)
setNormalTop(tmp_building,1)


tmp_building = newBuilding("shelter",1,1,2,0)
setBuildingLayerQuad(tmp_building,"all",3,2,3,2)
setNormalTop(tmp_building,"all")



return overmapBuildings
