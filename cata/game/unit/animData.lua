
local loaded = false
--只映射名字到数据
data.animation = {}


function data.loadAnimationData()
  if loaded then return else loaded = true end
  local tmp = dofile("data/unit/animList.lua")
  
  for _,v in ipairs(tmp) do
    data.animation[v.name] = v
  end
  
end
  
  