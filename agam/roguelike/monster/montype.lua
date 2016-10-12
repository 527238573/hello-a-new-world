--[[怪物类型  需要在翻译文件之后]]--

montype = {}
                    --   Rodent      halfhuman      Human         Cow        TAAAANK
mon_size =creatEnumTable({"tiny",    "small",     "medium",     "large",    "huge" })

montype.std = {
    id = "std",
    name = tl("标准怪"),
    species = "none",
    size = mon_size.medium,
    mat  = "hflesh"
    
  }


montype.add = function (typetable)
    montype[ typetable.id] = typetable
    setmetatable(typetable,montype.std)
  end

--加载方法，需要在之后调用
function montype.load_standard()
  
  montype.add({ id = "testZ"})
end


