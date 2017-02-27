
local editor = editor
local map = {}
editor.map = map


function editor.initMap()
  --submap x,y 从1开始
  --z轴 1为楼，0为地下1楼
  map.lowz = 1
  map.highz = 2 --floor2
  map.subx = 1
  map.suby = 1
  editor.changeMapSize(1,2,1,1)
  
end

--取得submap   x,y 从0开始
function submap(x,y,z)
  assert(z<=map.highz and z>= map.lowz,"submap index z out of range")
  assert(x<map.subx and x>= 0,"submap index x out of range")
  assert(y<map.suby and y>= 0,"submap index y out of range")
  local zlayer = map[z]
  return zlayer[x][y]
end




local function createEmptySubmap(z)
  local subm = {}
  local default_ter
  if z>1 then default_ter = "t_air" elseif z==1 then default_ter = "t_dirt" else default_ter = "t_rock" end
  
  for i =0,c.submapSide-1 do
    subm[i] = {}
    for j =0,c.submapSide-1 do
      subm[i][j] = { ter = default_ter}
    end
  end
  return subm
end

function editor.changeMapSize(lz,hz,w,h)
  assert(hz>=lz,"submap lowz must less than highz")
  map.lowz = lz
  map.highz = hz 
  map.subx = w
  map.suby = h
  editor.size_str = "长宽:"..w.."×"..h.." layers:"..lz.."f~"..hz.."f"
  editor.updateMapRect();
  
  --循环所有submap，创建填充没有的
  
  for z = lz,hz do
    local zlayer = map[z]
    if(zlayer ==nil) then
      map[z] = {};
      zlayer =  map[z]
    end
    
    for x = 0,w-1 do
      if zlayer[x] == nil then zlayer[x] = {} end
      for y= 0,h-1 do 
        if zlayer[x][y] == nil then
          zlayer[x][y] = createEmptySubmap(z)
        end
      end
    end
  end
end


local function brushTerrain(x,y)
  if editor.selctTileInfo ==nil then return end
  if( x>=0 and x<editor.square_x_num and y>=0 and y<editor.square_y_num) then
    local sx = bit.rshift(x,4)
    local sy = bit.rshift(y,4)
    local submap = editor.getSubmapFormVirtualXY(sx,sy,editor.curZ)
    local square = editor.getSquareFormVirtualXY(x,y,editor.curZ)
    square.ter = editor.selctTileInfo.name
    draw.setDirty(submap)
    
  end
end
local function brushBlock(x,y)
  if editor.selctBlockInfo ==nil then return end
  if( x>=0 and x<editor.square_x_num and y>=0 and y<editor.square_y_num) then
    local sx = bit.rshift(x,4)
    local sy = bit.rshift(y,4)
    local submap = editor.getSubmapFormVirtualXY(sx,sy,editor.curZ)
    local square = editor.getSquareFormVirtualXY(x,y,editor.curZ)
    square.block = editor.selctBlockInfo.name
    if square.block=="none" then square.block = nil end--清除
    --draw.setDirty(submap)--无需dirty，block实时绘制
  end
end
function editor.brushSquare(x,y)
  if editor.curPainterSelct ==1 then
    brushTerrain(x,y)
  elseif editor.curPainterSelct ==2 then
    brushBlock(x,y)
  end
end

function editor.repalceMap(newmap)
  map = newmap
  editor.map = map
  editor.changeMapSize(map.lowz,map.highz,map.subx,map.suby)
  draw.dirtyAll()
end

