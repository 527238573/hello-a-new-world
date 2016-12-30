
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

--取得submap   x,y 1-10取值
function submap(x,y,z)
  assert(z<=map.highz and z>= map.lowz,"submap index z out of range")
  assert(x<=map.subx and x>= 1,"submap index x out of range")
  assert(y<=map.suby and y>= 1,"submap index y out of range")
  local zlayer = map[z]
  return zlayer[x][y]
end



function editor.createEmptySubmap(z)
  local subm = {}
  local default_ter
  if z>1 then default_ter = "air" elseif z==1 then default_ter = "dirt" else default_ter = "rock" end
  
  for i =1,c.submapSide do
    subm[i] = {}
    for j =1,c.submapSide do
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
  --循环所有submap，创建填充没有的
  
  for z = lz,hz do
    local zlayer = map[z]
    if(zlayer ==nil) then
      map[z] = {};
      zlayer =  map[z]
      for x = 1,w do
        if zlayer[x] == nil then zlayer[x] = {} end
        for y= 1,h do 
          if zlayer[x][y] == nil then
            zlayer[x][y] = editor.createEmptySubmap(z)
          end
        end
      end
    end
  end
end

