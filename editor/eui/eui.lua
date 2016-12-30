
eui= {}
eui.PicButton = require "eui/component/picButton"
eui.Panel = require "eui/component/panel"
eui.closeBtn = require "eui/component/closeBtn"
eui.numberStepper = require "eui/component/numberStepper"
eui.topbar = require "eui/topbar"
eui.painterPanel = require "eui/painterPanel"

-- suit up
local suit = require 'suit'
eui.testcall = require "eui/testcall"

eui.popwindow = nil--弹出窗口


function eui.uiLayer()
  editor.touch()
  eui.topbar()
  eui.painterPanel()
  --eui.testcall()
  
  if eui.popwindow then eui.popwindow() end--弹出窗口，最上层
end

