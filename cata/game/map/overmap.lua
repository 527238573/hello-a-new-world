
local overmapBase = g.overmap
local ffi = require("ffi")
ffi.cdef[[
typedef struct { uint16_t ter[256][256][23];   bool seen[256][256][23];  } overmap;
]]
-- ffi 数据结构缺乏保护，需要严格检查index范围！
local mt = {
  __index = {
    getOter = function(om,x,y,z) 
      assert(x>=0 and x<256,"oter X out of index!")
      assert(y>=0 and y<256,"oter Y out of index!")
      assert(z>=-10 and z<=12,"oter Z out of index!")
      return om.ter[x][y][z+10]
    end,
    getSeen = function(om,x,y,z) 
      assert(x>=0 and x<256,"oter X out of index!")
      assert(y>=0 and y<256,"oter Y out of index!")
      assert(z>=-10 and z<=12,"oter Z out of index!")
      return om.seen[x][y][z+10]
    end,
    setOter = function(om,value,x,y,z) 
      assert(x>=0 and x<256,"oter X out of index!")
      assert(y>=0 and y<256,"oter Y out of index!")
      assert(z>=-10 and z<=12,"oter Z out of index!")
      om.ter[x][y][z+10] = value
    end,
    setSeen = function(om,value,x,y,z) 
      assert(x>=0 and x<256,"oter X out of index!")
      assert(y>=0 and y<256,"oter Y out of index!")
      assert(z>=-10 and z<=12,"oter Z out of index!")
      om.seen[x][y][z+10] = value
    end,
    inbounds = function(om,x,y,z)
      return x>=0 and x<256 and y>=0 and y<256 and z>=-10 and z<=12
    end,
    getOterOrNil = function(om,x,y,z)
      if x>=0 and x<256 and y>=0 and y<256 and z>=-10 and z<=12 then return om.ter[x][y][z+10] else return nil end
    end
    
  },
}
overmapBase.create_overmap = ffi.metatype("overmap", mt)


--将overmap数据丢到一个table中
local function dumpToTable(om)
  local ret = {}
  ret.oter={}
  for layer=-10,12 do
    local layer_t = {}
    ret.oter[layer] = layer_t
    local cur_tid  = -1
    local cur_num = 0
    for sx = 0,255 do
      for sy =0,255 do
        local new_oterid = om.ter[sx][sy][layer+10]
        if new_oterid~=cur_tid then
          if cur_num>0 then
            local info = data.oter[cur_tid]
            local ts = {info.name,cur_num}
            if info.base_id<cur_tid then ts[3] = cur_tid-info.base_id end
            layer_t[#layer_t+1] =ts  --插入
          end
          cur_tid = new_oterid
          cur_num = 1
        else
          cur_num = cur_num+1
        end
      end
    end
    if cur_num>0 then
      local info = data.oter[cur_tid]
      local ts = {info.name,cur_num}
      if info.base_id<cur_tid then ts[3] = cur_tid-info.base_id end
      layer_t[#layer_t+1] =ts  --插入
    end
  end
  ret.seen = {}
  for layer=-10,12 do
    local layer_t = {}
    ret.seen[layer] = layer_t
    local cur_seen  = false
    local cur_num = 0
    for sx = 0,255 do
      for sy =0,255 do
        local new_seen = om.seen[sx][sy][layer+10]
        if new_seen~=cur_seen then
          if cur_num>0 then
            layer_t[#layer_t+1] ={cur_seen,cur_num}  --插入
          end
          cur_seen = new_seen
          cur_num = 1
        else
          cur_num = cur_num+1
        end
      end
    end
    if cur_num>0 then
      layer_t[#layer_t+1] ={cur_seen,cur_num}  --插入
    end
  end
  return ret
end


function overmapBase.saveOneOvermap(om,x,y,dirname)
  local filename = dirname.."/o."..x.."."..y
  --debugmsg("attemp to save om:"..x..","..y)
  
  --local time1  = love.timer.getTime()
  local tableToSave = dumpToTable(om)
  --local time2 = love.timer.getTime() 
  --print("dumptable time:"..time2 - time1)
  
  table.save(tableToSave,filename)
  --local time3 = love.timer.getTime() 
  --print("writefile time:"..time3 - time2)
end

function overmapBase.load_overmap_from_table(omtable)
  local om = overmapBase.create_overmap()
  for layer=-10,12 do
    local oterlayer = omtable.oter[layer]
    local sx,sy=0,0
    local function setOter(oterid)
      if sx>=256 then error("outRange")end
      om.ter[sx][sy][layer+10] = oterid
      --下一个oter
      sy = sy+1
      if sy>=256 then sy = 0;sx =sx+1 end
    end
    for i=1,#oterlayer do
      local chuan = oterlayer[i]
      local oid = data.oter_name2id[chuan[1]]
      local num = chuan[2]
      if chuan[3] then oid = oid + chuan[3] end
      for j = 1,num do setOter(oid) end
    end
  end
  for layer=-10,12 do
    local seenlayer = omtable.seen[layer]
    local sx,sy=0,0
    local function setSeen(oseen)
      if sx>=256 then error("outRange")end
      om.seen[sx][sy][layer+10] = oseen
      --下一个oter
      sy = sy+1
      if sy>=256 then sy = 0;sx =sx+1 end
    end
    for i=1,#seenlayer do
      local chuan = seenlayer[i]
      local val = chuan[1]
      for j = 1,chuan[2] do setSeen(val) end
    end
  end
  return om
end

