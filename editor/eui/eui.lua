
eui= {}
eui.home = love.filesystem.getSourceBaseDirectory().."/data/mapgen"

eui.PicButton = require "eui/component/picButton"
eui.Panel = require "eui/component/panel"
eui.closeBtn = require "eui/component/closeBtn"
eui.numberStepper = require "eui/component/numberStepper"
eui.fileButton = require "eui/component/fileButton"
eui.topbar = require "eui/topbar"
eui.painterPanel = require "eui/painterPanel"
eui.touch = require "eui/touch"
require "eui/fileDialog"
-- suit up
local suit = require 'suit'
eui.testcall = require "eui/testcall"


function eui.init()
  eui.popwindow = nil--弹出窗口
  eui.terrainList_init()
  eui.blockList_init()
end


function eui.uiLayer()
  eui.touch()
  eui.topbar()
  eui.painterPanel()
  --eui.testcall()
  
  if eui.popwindow then eui.popwindow() end--弹出窗口，最上层
end


function eui.handleKeyPressed(key)
  if(key == 'w') then 
    editor.changeLayer(editor.curZ +1)
  elseif (key == 's') then 
    editor.changeLayer(editor.curZ -1)
  elseif (key == 'a') then 
    editor.changeDirection(editor.curDirection -1)
  elseif (key == 'd') then 
    editor.changeDirection(editor.curDirection +1)
  end
end