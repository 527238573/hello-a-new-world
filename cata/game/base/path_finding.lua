
local base = g.base


local dir_dx = {[0]=0,1,0,-1}
local dir_dy = {[0]=1,0,-1,0}
function base.simple_find_path(startx,starty,endx,endy,maxX,maxY,estimator)
  
  local function inbounds(x,y)
    return x>=0 and x<maxX and y>=0 and y<maxY
  end
  
  local res = {}
  if (startx == endx and starty == endy) then return res end
  if not inbounds(startx,starty) or not inbounds(endx,endy) then return res end
  local nodes = {}
  
  local open_t = {}
  local closed_t = {}
  local dir_t = {}
  
  
  
  nodes[1] = {startx,starty,dir = 5,p = 1000}
  open_t[starty*maxX+startx] = 1000;
  
  local function insertNode(node)
    for i = #nodes,1,-1 do
      if nodes[i].p>node.p then
        table.insert(nodes,i+1,node)
        return
      end
    end
    table.insert(nodes,1,node)
  end
  
  
  while #nodes>0 do 
    --table.sort(nodes,function(s1,s2) return s1.p>s2.p end) --需排序
    local mn = nodes[#nodes]
    nodes[#nodes] = nil
     --// mark it visited
    closed_t[mn[2]*maxX+mn[1]] = true;
    if mn[1]==endx and mn[2]==endy then
      --已到终点，结束寻路
      local x,y = mn[1],mn[2]
      while(x ~= startx or y ~= starty) do
        local dir = dir_t[y*maxX+x]
        x =x+ dir_dx[dir];
        y =y+ dir_dy[dir];
        res[#res+1] = {x,y,dir}
      end
      return res-- res为倒序 ，需从后向前遍历
    end
    local startd = rnd(0,3)
    for drnd = startd,startd+3 do
      local d = drnd%4
      local x,y = mn[1]+dir_dx[d],mn[2]+dir_dy[d]
      local index = y*maxX+x
      if inbounds(x,y) and closed_t[index]~=true then
        local cn = {x,y,dir = d}
        cn.p = estimator(mn,cn)
        if cn.p>=0 then
          local open_p = open_t[index]
          if open_p==nil or open_p > cn.p then
            dir_t[index] = (d+2)%4;
            if open_p~=nil then
              for i = 1,#nodes do 
                if nodes[i][1] ==x and nodes[i][2] ==y then
                  table.remove(nodes,i)
                  break
                end
              end
            end
            open_t[index] = cn.p
            
            insertNode(cn)
            --nodes[#nodes+1] = cn
          end
        end
      end
    end
  end
  return res
end

