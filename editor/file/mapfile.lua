require "file/saveT"

local curFileName = nil
local curFilePath = nil
local mapfile = {}

function mapfile.newFile()
  curFileName = nil
  curFilePath = nil
  love.window.setTitle("MapEditor")
  editor.repalceMap({lowz = 1,highz = 2,subx = 1,suby = 1,building_name = "",weight = 100})
  editor.changeLayer(1)
  editor.changeDirection(1)
end

function mapfile.saveOld()
  if curFileName == nil then 
    eui.popwindow = eui.saveFileDialog
  else
    mapfile.internalSave(curFileName,curFilePath)
  end
end

--传递的name带后缀   path为目录+sep
function mapfile.openFile(name,path)
  curFilePath = path..name
  local result,err = table.load(curFilePath)
  print("load",result,err)
  io.flush()
  if result and type(result)=="table" and result.lowz then
    curFileName = name
    love.window.setTitle("MapEditor-"..name)
    editor.repalceMap(result)
    editor.changeLayer(1)
    editor.changeDirection(1)
  end
end

--可能不带后缀，也可能带  path为目录+sep
function mapfile.saveFile(name,path)
  
  if not(#name > 4 and name:sub(-4,-1) == ".lua") then
    name = name..".lua"
  end
  curFilePath = path..name
  mapfile.internalSave(name,curFilePath)
end

function mapfile.internalSave(name,fullpath)
  editor.cutUnuseSubmap()--除去没用的
  local result,err  = table.save(  editor.map,curFilePath )
  print("save",result,err)
  io.flush()
  if result ==1 then
    curFileName = name
    love.window.setTitle("MapEditor-"..name)
  end
end


return mapfile