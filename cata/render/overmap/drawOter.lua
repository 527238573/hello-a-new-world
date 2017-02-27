local rov = render.overmap
--快速局域变量
local get_ot = g.overmap.get_visible_oterid


local r00 = math.rad(0)
local r09 = math.rad(90)
local r18 = math.rad(180)
local r27 = math.rad(270)
-------------------0,         1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
local borderIndex= {[0] = 6,  5,  5,  4,  5,  3,  4,  2,  5,  4,  3,  2,  4,  2,  2,  1}
local borderRad=   {[0] =r00, r00,r27,r09,r18,r09,r00,r27,r09,r18,r00,r00,r27,r09,r18,r00}
local unseen_oid

function rov.initDrawOter()
  unseen_oid = data.oter_name2id["unseen"]
end


function rov.drawOter(batch,otx,oty,lx,ly,curz)
  local otid = get_ot(otx,oty,curz)
  local info = data.oter[otid]
  if info.name == "unseen" then return 0 end
  
  local up = get_ot(otx,oty+1,curz)
  local right = get_ot(otx+1,oty,curz)
  local down = get_ot(otx,oty-1,curz)
  local left = get_ot(otx-1,oty,curz)
  
  if info.tiletype ==1 then --single
    batch:add(info[1],lx*32,(-ly-1)*32,0,2,2)
  elseif info.tiletype ==2 then--border
    local statecode = 0
    local function checkBorder(direction,value)
      if direction == otid or direction==unseen_oid then 
        statecode = statecode+value 
      elseif info.border_share then 
        for _,v in ipairs(info.border_share) do
          if v==direction then statecode = statecode+value;break  end
        end
      end
    end
    checkBorder(up,8);checkBorder(right,4);checkBorder(down,2);checkBorder(left,1)
    local ox = 0.5*16
    local oy = 0.5*16
    if info.background then batch:add(info.background,(lx+0.5)*32,(-ly-0.5)*32,0,2,2,ox,oy)end
    
    batch:add(info[borderIndex[statecode]],(lx+0.5)*32,(-ly-0.5)*32,borderRad[statecode],2,2,ox,oy)
  elseif info.tiletype==3 then--building
    local rot = 0
    if info.rotate then
      --确定旋转, 0 入口朝下 1,2,3 分别顺时针旋转1，2，3*90度  背面顺序：上右下左
      rot = r09*(otid-info.base_id)
    end
    local ox = 0.5*16
    local oy = 0.5*16
    batch:add(info[1],(lx+0.5)*32,(-ly-0.5)*32,rot,2,2,ox,oy)
    batch:add(info[2],(lx+0.5)*32,(-ly-0.5)*32,0,2,2,ox,oy)--top 
  else
    return 0
  end
  
  
  return 1
end