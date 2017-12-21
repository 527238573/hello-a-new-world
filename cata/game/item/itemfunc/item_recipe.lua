
local item_mt = g.itemFactory.item_mt

function item_mt:meet_quality(tool_id,level)
  local tool_list = self.toolLevel
  if tool_list==nil then return false end
  for k,v in pairs(tool_list) do
    if k==tool_id and v>=level then return true end
  end
  return false
end

function item_mt:meet_tool_charges(tool_table)
  for _,one_require in ipairs(tool_table) do
    if self.type.id ==one_require[1] then
      if v>0  then
        if self:get_charges()>=one_require[2] then return true end
      else
        return true
      end
    end
  end
  return false
end



function item_mt:meet_one_tool_charges(tool_id,charges)
  if self.type.id ==tool_id then
    return charges<=0 or self:get_charges()>=charges 
  end
  return false
end
  