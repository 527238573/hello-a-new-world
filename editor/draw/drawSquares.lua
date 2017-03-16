
local tile_data = require "data/terrain_data"

local bit = require("bit")
local name_info = {}

for i=1,#tile_data do
  local info = tile_data[i]
  name_info[info.name] = info
end

function draw.isWall(ter)
  local edge_ter_info = name_info[ter]
  return edge_ter_info.type ==4
end




local function getSquare(x,y,z)
  if x>=0 and x< editor.square_x_num and y>=0 and y<editor.square_y_num then
    return editor.getSquareFormVirtualXY(x,y,z)
  else
    return nil
  end
end





local r0 = math.rad(0)
local r9 = math.rad(90)
local r18 = math.rad(180)
local r27 = math.rad(270)
-------------------1   2   3   4  5  6   7   8   9  A  B   C  D  E  F
local htileIndex= {4,  4,  3,  4, 5, 3,  6,  4,  3, 5, 6,  3, 6, 6, 2 }
local htileRad=   {r18,r9,r27,r0,r0,r18,r18,r27,r0,r9,r27,r9,r0,r9,r0}
--通过state code 确定使用哪个tile以及对应的rotation
--diretion: up =8 right=4 down =2 left =1
local function drawHierarchy(info,batch,x,y,z,lx,ly)
  local up  = getSquare(x,y+1,z)
  local right  = getSquare(x+1,y,z)
  local down  = getSquare(x,y-1,z)
  local left  = getSquare(x-1,y,z)
  local edgelist
  
  local function checkEdge(edge,direction)
    if edge==nil then return end
    local name = edge.ter
    local edge_ter_info = name_info[name]
    local edge_priority = edge_ter_info.priority
    
    if(edge_ter_info.type ==1) and (edge_priority > info.priority) then
      --add edge
      if(edgelist==nil) then edgelist = {}end
      for i = 1,4 do 
        if(edgelist[i]==nil) then 
          edgelist[i] = {name =name, val = direction,p =edge_priority}
          break
        elseif edgelist[i].name == name then
          edgelist[i].val = edgelist[i].val+direction
          break
        elseif edgelist[i].p>edge_priority then
          table.insert(edgelist,i,{name =name, val = direction,p =edge_priority})
          break
        end
      end
      --修正了排序问题
      --if(edgelist[name]==nil) then 
      --  edgelist[name] = direction 
      --else
      --  edgelist[name] = edgelist[name]+direction
      --end
    end
  end
  checkEdge(up,8);checkEdge(right,4);checkEdge(down,2);checkEdge(left,1)
  
  if edgelist==nil then return end
  for _,v in ipairs(edgelist) do
    local to_render_info = name_info[v.name]
    local rotation = htileRad[v.val]
    local quad = to_render_info[htileIndex[v.val]]
    local scale = info.scalefactor
    local ox = 0.5*c.squarePixels / scale
    local oy = 0.5*c.squarePixels / scale
    batch:add(quad,(lx+0.5)*c.squarePixels,(-ly-0.5)*c.squarePixels,rotation,scale,scale,ox,oy)
  end
end



local wallIndex= {[0]=1,2,6,7,3,4,8,9}

local function drawWall(info,batch,x,y,z,lx,ly)
  local up  = getSquare(x,y+1,z)
  local right  = getSquare(x+1,y,z)
  local down  = getSquare(x,y-1,z)
  local left  = getSquare(x-1,y,z)
  local state_code = 0
  
  local function checkEdge(edge,direction)
    if edge==nil then return end
    local name = edge.ter
    local edge_ter_info = name_info[name]
    if(edge_ter_info.type ~=4) then
      state_code = state_code +direction
    end
  end
  checkEdge(right,4);checkEdge(down,2);checkEdge(left,1)--up单独计算
  local basequad = info[wallIndex[state_code]]
  local scale = info.scalefactor
  local dx,dy = lx*c.squarePixels,(-ly-1)*c.squarePixels
  batch:add(basequad,dx,dy,0,scale,scale)
  checkEdge(up,8);
  if state_code>=8 then
    batch:add(info[5],dx,dy,0,scale,scale)
  end
end


function draw.addSquareToBatch(batch,x,y,z)
  local square = editor.getSquareFormVirtualXY(x,y,z)
  local info = name_info[square.ter]--取得图像--
  local scale = info.scalefactor
  local lx = bit.band(x,15)
  local ly = bit.band(y,15)
  
  
  if info.type ==1 then
    batch:add(info[1],lx*c.squarePixels,(-ly-1)*c.squarePixels,0,scale,scale)
    drawHierarchy(info,batch,x,y,z,lx,ly)
  elseif info.type ==4 then 
    drawWall(info,batch,x,y,z,lx,ly)
  else --默认单个draw
    batch:add(info[1],lx*c.squarePixels,(-ly-1)*c.squarePixels,0,scale,scale)
  end
  
end