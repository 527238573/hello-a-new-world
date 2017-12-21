local item_mt = g.itemFactory.item_mt
local itemf = g.itemFactory


function item_mt:is_armor()
  return self.type.item_type =="armor"
end


function item_mt:get_armor_layer()
  return self.type.armor_layer or 3 --默认3？
  
end

function item_mt:get_coverlist()
  return self.type.covers
end

--是否遮住该部位
function item_mt:covers_bodypart(bodypart)
  return self.type.covers[bodypart]
end

--合身不合身，基本累赘
function item_mt:get_encumber()
  return self.type.encumber --+ 额外
end

function item_mt:get_warmth()
  return self.type.warmth
end

function item_mt:get_storage()
  return self.type.storage
end

--随机是否cover击中这个部位的hit
function item_mt:hit_cover(body_part)
  if not self.type.covers[body_part] then return false end
  return self.type.coverage>=rnd(1,100) --0为必不中，100为必中
end

--作为装备时(或自身收到伤害时)提供的抵抗伤害类型的能力,to_self 是否是计算物品自身受伤害的抗性
function item_mt:get_damage_resist(dam_type,to_self)
  to_self = to_self or false
  local function get_material_resist(dam_type)--取得材质平均抗性的函数
    local resist = 0
    if self.type.material then
      for _,v in ipairs(self.type.material) do
        local mat = itemf.get_material(v)
        resist = resist+mat.resist[dam_type]
      end
      resist = resist/#self.type.material
    end
    return resist
  end
  
  if dam_type == "bash" then
    local resist = get_material_resist("bash")
    local thickness = 1
    if self:is_armor() then
      thickness=  math.max(1,self.type.thickness - (to_self and math.min(self.damage,0) or math.max(self.damage,0)))
    end
    return resist* 1.5 *thickness --乘上厚度
    
  elseif dam_type == "cut" then--和上一个一样，变成cut
    local resist = get_material_resist("cut")
    local thickness = 1
    if self:is_armor() then
      thickness=  math.max(1,self.type.thickness - (to_self and math.min(self.damage,0) or math.max(self.damage,0)))
    end
    return resist* 1.5 *thickness --乘上厚度
  elseif dam_type =="stab" then
    return 0.8* self:get_armor_resist("cut",to_self)--cut 的八成
  elseif dam_type =="acid" then
    if to_self then return 1000 end
    local resist = get_material_resist("acid")
    if self:is_armor() and self.type.env_resist<10 then --环境防护的修正
      resist = resist* self.type.env_resist/10
    end
    return resist
  elseif dam_type =="heat" then --fire
    local resist = get_material_resist("heat")
    if self:is_armor() and self.type.env_resist<10 then --环境防护的修正
      resist = resist* self.type.env_resist/10
    end
    return resist
  elseif dam_type =="electric" then 
    if to_self then return 1000 end --对自身不起效
    local resist = get_material_resist("electric")
    return resist
  elseif dam_type =="cold" then
    if to_self then return 1000 end --对自身不起效
    local resist = get_material_resist("cold")
    return resist
  end
  --其他视作真实伤害
  if to_self then return 1000 end --对物品自身其他伤害不起效
  return 0
end

--使物品收到击中伤害，返回是否destory，
function item_mt:take_hit_damage(amount,dam_type,showmsg)
  if self.damage>=5 then return true end--不能超量,已被摧毁
  local resist = self:get_damage_resist(dam_type,true)
  if resist>=1000 then return false end --不受伤害
  
  
  if self.type.covers then
    if not one_in(#self.type.covers) then return false end --覆盖部位越多的装备越难被摧毁
  end
  if amount>resist then
    debugmsg("attemp to damage item")
    if one_in(amount) or one_in(2) then
      return false --起码有一半以上几率不被摧毁
    end
  else
    if self:has_flag("STURDY") or not one_in(200) then --低伤害有0.5%几率对普通物品造成伤害
      return false
    end
  end
  
  if self:has_flag("FRAGILE") then
    self.damage = self.damage+ rnd(1,3)
  else
    self.damage = self.damage+ 1
  end
  --播放
  if showmsg then
    if self.damage>=5 then
      addmsg(string.format( tl("你的%s被彻底摧毁！","Your %s is completely destoryed!"),self:getNormalName()),"bad")
    else
      addmsg(string.format( tl("你的%s受到损伤！","Your %s is damaged!"),self:getNormalName()),"bad")
    end
  end
  return self.damage>=5
end






