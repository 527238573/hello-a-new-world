
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



