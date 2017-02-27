

local loaded = false
local oter_list = {}
local oter_name2info = {}
local oter_name2id = {}

data.oter = oter_list
data.oter_name2info = oter_name2info
data.oter_name2id = oter_name2id

--[[oter数据结构
一种oter可能会占用多个 oter_id来表示不同的状态
rotate=true 占用4个oterid表示不同方向
这些id仍指向同一个table,也就是一种oter 
--otertable 里 base_id 记录第一个oterid  ex_id为多出的oterid数量，默认为0(只有一个oterid) 
--]]


function data.loadOterTable(ot)
  
  for _,v in ipairs(ot) do
    table.insert(oter_list,v)
    oter_name2info[v.name] = v
    oter_name2id[v.name] = #oter_list
    v.base_id = #oter_list
    v.ex_id = 0
    --插入多余的oterid，旋转等
    if v.rotate then
      v.ex_id = 3
      table.insert(oter_list,v) --多余的，0，1，2，3
      table.insert(oter_list,v)
      table.insert(oter_list,v)
      
    end
    
    
  end
end

function data.loadOterData()
  if loaded then return else loaded = true end
  local tmp = dofile("data/overmapTer.lua")
  data.loadOterTable(tmp)
  data.Oter_BigImage = tmp.img
  
  
  --将一些字符name 连接为 数字id
  for k,v in ipairs(oter_list) do
    if v.border_share then 
      local newt = {}
      for index,name in ipairs(v.border_share)do
        local find_intid = oter_name2id[name]
        if find_intid ==nil then error("wrong name in border_share:"..v.name) end
        newt[index] = find_intid
      end
      v.border_share  = newt
    end
  end
  
end
  
