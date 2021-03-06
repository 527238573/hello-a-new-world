--一些常数，常量，预定义等

c= {}

c.win_W = love.graphics.getWidth()
c.win_H = love.graphics.getHeight()

c.SQUARE_L= 64  --以下常数，基本不修改，位运算
c.SUBMAP_L = 16
c.BuffMap_L= 16
c.OMAP_L = 256--overmap的边长

c.Z_LAYERS = 23 -- z总层数  在overmap   editor中使用常数         使用处:mapbuffer overmap
c.Z_MAX = 12  -- 最高层     1楼= 地面 （z=1）,z<=0为地下
c.Z_MIN = -10 --最低 层

c.font_c20 = love.graphics.newFont("assets/fzh.ttf",20);
c.font_c18 = love.graphics.newFont("assets/fzh.ttf",18);
c.font_c16 = love.graphics.newFont("assets/fzh.ttf",16);
c.font_c14 = love.graphics.newFont("assets/fzh.ttf",14);
--c.font_c12 = love.graphics.newFont("assets/fzh.ttf",12);
c.font_x16 = love.graphics.newFont("assets/fzfs.ttf",16);
c.font_x14 = love.graphics.newFont("assets/fzfs.ttf",14);
--c.font_x12 = love.graphics.newFont("assets/fzfs.ttf",12);



c.null_t = {}
c.timeSpeed = 2.25 --行动点数，速度 和实际时间的换算  （行动点数/速度/tiemspeed = 实际时间）（回合数 = 实际时间秒*timeSpeed）1回合 = 0.444
c.face_table = {7,6,5,8,1,4,1,2,3}

function c.face(dx,dy)
  return c.face_table[(dy+1)*3 +dx+2]
end

function c.clamp(x,min,max)
  return x>max and max or x<min and min or x
end

function c.dist_2d(x1,y1,x2,y2)
  return math.sqrt((x1-x2)*(x1-x2)+ (y1-y2)*(y1-y2))
end
function c.dist_3d(x1,y1,z1,x2,y2,z2)
  return math.sqrt((x1-x2)*(x1-x2)+ (y1-y2)*(y1-y2)+(z1-z2)*(z1-z2))
end


function tl(str,str2)
  return str
end

local xid = 0
function newid()
  xid = xid+1
  return xid
end

local out = io.stdout
function debugmsg(msg)
  out:write(msg)
  out:write("\n")
  out:flush()
end

--全局变量 随机函数
rnd = love.math.random
function rnd_float(f1,f2)
  return f1+(f2-f1)*rnd()
end

function one_in(num)  return rnd(num)<=1 end

function x_in_y(x,y) return rnd()<=(x/y) end
--掷骰子
function dice(number,side)
  local ret =0
  for i=1,number do
    ret = ret+rnd(1,side)
  end
  return ret
end


function c.random_shuffle(t)
  local length  = #t
  for i=length,1,-1 do
    local rnd_index = rnd(i)
    local tmp = t[rnd_index]
    t[rnd_index] = t[i]
    t[i] = tmp
  end
end



--查找在权重table t 中随机值v的index
local function search_weight(t,v)
    local left = 1;
    local right = #t
    local min = 0
    local max = t[right]
    while left < right do
      local mid = math.floor((left + right)/2)
      if t[mid] == v then
        return mid;
      elseif v<= t[mid]  then
        right = mid 
      else 
        left = mid +1
      end
    end
    return right
end
c.search_weight = search_weight

--[[从权重表中随机值：
权重表结构:
{ val = {v1,v2,v3...}
  weight = {w1,w2,w3...}
}

--]]
function c.getWeightValue(weightTable)
  --local rn  =rnd(weightTable.weight[#weightTable.weight])
  --for k,v in ipairs(weightTable.weight) do
  --  print(k,v)
  --end
  --io.flush()
  --debugmsg(rn)
  return weightTable.val[search_weight(weightTable.weight,rnd(weightTable.weight[#weightTable.weight]))]
end
--全局名称
pick = c.getWeightValue


--从一般表创建权重表
function c.weightT(wt)
  local r = {val = {},weight={}}
  local w = 0
  for k,v in pairs(wt) do
    w= w+v
    table.insert(r.val,k)
    table.insert(r.weight,w)
  end
  return r
end
function c.pushWeightVal(wt,val,weight)
  local lastwight = 0
  if( wt) then lastwight = wt.weight[#wt.weight] end
  wt= wt or {val = {},weight={}}
  table.insert(wt.val,val)
  table.insert(wt.weight,weight+lastwight)
  return wt
end



--全局常量
--stringid转换数字id
function oid(name)
  local id = data.oter_name2id[name]
  if id ==nil then error("wrong oter name:"..name) end
  return id
end

function tid(name)
  local id = data.ster_name2id[name]
  if id ==nil then error("wrong ster name:"..name) end
  return id
end
function fid(name)
  local id = data.block_name2id[name]
  if id ==nil then error("wrong block name:"..name) end
  return id
end



function flagt(ftable)
  local nt = {}
  for k,v in ipairs(ftable) do
    nt[v] = true
  end
  return nt
end

