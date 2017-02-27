local rm = render.main


local name_info
function rm.initDrawSter()
  name_info = data.ster
  
end


local getSquare --函数


local r0 = math.rad(0)
local r9 = math.rad(90)
local r18 = math.rad(180)
local r27 = math.rad(270)
-------------------1   2   3   4  5  6   7   8   9  A  B   C  D  E  F
local htileIndex= {4,  4,  3,  4, 5, 3,  6,  4,  3, 5, 6,  3, 6, 6, 2 }
local htileRad=   {r18,r9,r27,r0,r0,r18,r18,r27,r0,r9,r27,r9,r0,r9,r0}
--通过state code 确定使用哪个tile以及对应的rotation
--diretion: up =8 right=4 down =2 left =1
local function drawHierarchy(info,batch,x,y,z)
  local up  = getSquare(x,y+1,z)
  local right  = getSquare(x+1,y,z)
  local down  = getSquare(x,y-1,z)
  local left  = getSquare(x-1,y,z)
  local edgelist
  
  local function checkEdge(edge,direction)
    if edge==nil then return end
    local edge_ter_info = name_info[edge]
    if(edge_ter_info.type ==1) and (edge_ter_info.priority > info.priority) then
      --add edge
      if(edgelist==nil) then edgelist = {}end
      for i = 1,4 do 
        if(edgelist[i]==nil) then 
          edgelist[i] = {id =edge, val = direction,p =edge_ter_info.priority}
          break
        elseif edgelist[i].id == edge then
          edgelist[i].val = edgelist[i].val+direction
          break
        elseif edgelist[i].p>edge_ter_info.priority then
          table.insert(edgelist,i,{id =edge, val = direction,p =edge_ter_info.priority})
          break
        end
      end
    end
  end
  checkEdge(up,8);checkEdge(right,4);checkEdge(down,2);checkEdge(left,1)
  
  if edgelist==nil then return end
  for _,v in ipairs(edgelist) do
    local to_render_info = name_info[v.id]
    local rotation = htileRad[v.val]
    local quad = to_render_info[htileIndex[v.val]]
    local scale = info.scalefactor
    local ox = 32 / scale --一半
    local oy = 32 / scale
    batch:add(quad,(x+0.5)*64,(-y-0.5)*64,rotation,scale,scale,ox,oy) --直接使用常数
  end
end



local wallIndex= {[0]=1,2,6,7,3,4,8,9}

local function drawWall(info,batch,x,y,z)
  local up  = getSquare(x,y+1,z)
  local right  = getSquare(x+1,y,z)
  local down  = getSquare(x,y-1,z)
  local left  = getSquare(x-1,y,z)
  local state_code = 0
  
  local function checkEdge(edge,direction)
    if edge==nil then return end
    local edge_ter_info = name_info[edge]
    if(edge_ter_info.type ~=4) then
      state_code = state_code +direction
    end
  end
  checkEdge(right,4);checkEdge(down,2);checkEdge(left,1)--up单独计算
  local basequad = info[wallIndex[state_code]]
  local scale = info.scalefactor
  local dx,dy = x*64,(-y-1)*64
  batch:add(basequad,dx,dy,0,scale,scale)
  checkEdge(up,8);
  if state_code>=8 then
    batch:add(info[5],dx,dy,0,scale,scale)
  end
end


local function addTerrainToBatch(batch,x,y,z)
  local square = getSquare(x,y,z)
  local info = name_info[square]--取得图像--
  local scale = info.scalefactor
  
  
  if info.type ==1 then
    batch:add(info[1],x*64,(-y-1)*64,0,scale,scale)
    drawHierarchy(info,batch,x,y,z)
  elseif info.type ==4 then 
    drawWall(info,batch,x,y,z)
  else --默认单个draw
    batch:add(info[1],x*64,(-y-1)*64,0,scale,scale)
  end
  
end


local looksubmap = g.map.lookupSubmap
function rm.buildSubmapBatch(subm,batch,x,y,z)
  batch:clear()
  local up = looksubmap(x,y+1,z)
  local down = looksubmap(x,y-1,z)
  local left = looksubmap(x-1,y,z)
  local right = looksubmap(x+1,y,z)
  
  local function getSquareTmp(x,y,z)
    if x>15 then return right and right.raw:getTer(x-16,y) end
    if x<0 then return  left and left.raw:getTer(x+16,y) end
    if y>15 then return  up and up.raw:getTer(x,y-16) end
    if y<0 then return  down and down.raw:getTer(x,y+16) end
    return subm.raw:getTer(x,y)
  end
  getSquare = getSquareTmp
  for sx = 0,15 do
    for sy = 0,15 do
      addTerrainToBatch(batch,sx,sy,z)
    end
  end
  getSquare = nil
end



