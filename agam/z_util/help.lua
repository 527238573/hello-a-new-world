
--创建枚举table
function creatEnumTable(tbl, index) 
    assert(type(tbl)== "table") 
    local enumtbl = {} 
    local enumindex = index or 0 
    for i, v in ipairs(tbl) do 
        enumtbl[v] = enumindex + i 
    end 
    return enumtbl 
end 

function debugmsg(x)
  
  print(x)
end

--翻译函数 to local
function tl(dialouge)
  return dialouge
end
