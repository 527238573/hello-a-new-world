-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local NONE = {}
local BASE = (...):match('(.-)[^%.]+$')
local default_theme = require(BASE..'theme')

local suit = {}
suit.__index = suit

function suit.new(theme)
  return setmetatable({
      -- TODO: deep copy/copy on write? better to let user handle => documentation?
      theme = theme or default_theme,
      mouse_x = 0, mouse_y = 0,
      mouse_button_down = false,

      draw_queue = {n = 0},

      Button = require(BASE.."button"),
      Label = require(BASE.."label"),
      Checkbox = require(BASE.."checkbox"),
      Input = require(BASE.."input"),
      Slider = require(BASE.."slider"),
      S9Button = require(BASE.."s9button"),
      Dialog = require(BASE.."dialog"),
      DragArea = require(BASE.."dragArea"),
      Image = require(BASE.."image"),
      ImageButton = require(BASE.."imagebutton"),
      ScrollBar = require(BASE.."scrollBar"),
      ScrollRect = require(BASE.."scrollRect"),

      layout = require(BASE.."layout").new(),
      }, suit)
end

-- helper
function suit.getOptionsAndSize(opt, ...)
  if type(opt) == "table" then
    return opt, ...
  end
  return {}, opt, ...
end

--id的 局限性，button 和 label使用 text做ID 可能 出现混乱。没有可靠ID的情况下 避免操作相关返回值

-- gui state
function suit:anyHovered()
  return self.hovered ~= nil
end

function suit:isHovered(id)
  return id == self.hovered
end

function suit:wasHovered(id)
  return id == self.hovered_last
end

function suit:anyActive()
  return self.active ~= nil
end

function suit:isActive(id)
  return id == self.active
end

function suit:anyHit()
  return self.hit ~= nil
end

function suit:isHit(id)
  return id == self.hit
end

function suit:getStateName(id)
  if self:isActive(id) then
    return "active"
  elseif self:isHovered(id) then
    return "hovered"
  end
  return "normal"
end

-- mouse handling
function suit:mouseInRect(x,y,w,h)
  return self.mouse_x >= x and self.mouse_y >= y and
  self.mouse_x <= x+w and self.mouse_y <= y+h
end

function suit:checkScissor()
  if self.cur_scissor then 
    return self:mouseInRect(self.cur_scissor.x,self.cur_scissor.y,self.cur_scissor.w,self.cur_scissor.h)
  else
    return true
  end
end

function suit:registerMouseHit(opt,id, ul_x, ul_y, hit)
  if hit(self.mouse_x - ul_x, self.mouse_y - ul_y) and self:checkScissor() then -- 同时check
    if(self.hovered ~= nil and self.hoverOpt ~= nil) then
      if(self.hoverOpt.state == "hovered") then self.hoverOpt.state = "normal" end
    end
    self.hovered = id
    self.hoverOpt = opt
    if self.active == nil and self.mouse_button_down and self:wasHovered(id) then
      self.active = id
    end
  end
  return self:getStateName(id)
end

function suit:registerHitbox(opt,id, x,y,w,h)
  return self:registerMouseHit(opt,id, x,y, function(x,y)
      return x >= 0 and x <= w and y >= 0 and y <= h
    end)
end

function suit:mouseReleasedOn(id)
  if not self.mouse_button_down and self:isActive(id) and self:isHovered(id)and self:wasHovered(id) then
    self.hit = id

    return true
  end
  return false
end

function suit:updateMouse(x, y, button_down)
  self.mouse_x, self.mouse_y = x,y
  if button_down ~= nil then
    self.mouse_button_down = button_down
  end
end

function suit:getMousePosition()
  return self.mouse_x, self.mouse_y
end

-- keyboard handling
function suit:getPressedKey()
  return self.key_down, self.textchar
end

function suit:keypressed(key)
  self.key_down = key
end

function suit:textinput(char)
  self.textchar = char
end

function suit:grabKeyboardFocus(id)
  if self:isActive(id) then
    if love.system.getOS() == "Android" or love.system.getOS() == "iOS" then
      if id == NONE then
        love.keyboard.setTextInput( false )
      else
        love.keyboard.setTextInput( true )
      end
    end
    self.keyboardFocus = id
  end
  return self:hasKeyboardFocus(id)
end

function suit:hasKeyboardFocus(id)
  return self.keyboardFocus == id
end

function suit:keyPressedOn(id, key)
  return self:hasKeyboardFocus(id) and self.key_down == key
end

-- state update
function suit:enterFrame()
  if not self.mouse_button_down then
    self.active = nil
  elseif self.active == nil then
    self.active = NONE
  elseif self.keyboardFocus ~= self.active then
    self.keyboardFocus =  NONE
  end

  self.hovered_last, self.hovered = self.hovered, nil
  self.hoverOpt = nil
  self:updateMouse(love.mouse.getX(), love.mouse.getY(), love.mouse.isDown(1))
  self.key_down, self.textchar = nil, ""
  self:grabKeyboardFocus(NONE)
  self.hit = nil
  assert(self.cur_scissor==nil,"scissor not end porperly")
end

function suit:exitFrame()
end

-- draw
function suit:registerDraw(f, ...)
  local args = {...}
  local nargs = select('#', ...)
  self.draw_queue.n = self.draw_queue.n + 1
  self.draw_queue[self.draw_queue.n] = function()
    f(unpack(args, 1, nargs))
  end
end

function suit:draw()
  self:exitFrame()
  love.graphics.push('all')
  for i = 1,self.draw_queue.n do
    self.draw_queue[i]()
  end
  love.graphics.pop()
  self.draw_queue.n = 0
  self:enterFrame()
end


function suit:combineState(parentid,...)
  local list = {...}
  local state ={id = parentid,hit = false, active = false, hovered = false, wasHovered = false}
  for i=1,#list do 
    state.hit = state.hit or list[i].hit 
    state.active = state.active or list[i].active 
    state.hovered = state.hovered or list[i].hovered 
    state.wasHovered = state.wasHovered or list[i].wasHovered 
  end
  return state
end

local function calculateNewScissor(old,x,y,w,h)
  local nx = math.max(old.x,x)
  local ny = math.max(old.y,y)
  local nw = math:max(math.min(old.x+old.w,x+w)-nx,0)
  local nh = math:max(math.min(old.y+old.h,y+h)-ny,0)
  return {x = nx,y=ny,w = nw, h= nh,next = old}
end

function suit:pushScissor(x,y,w,h)
  if self.cur_scissor then 
    self.cur_scissor = calculateNewScissor(self.cur_scissor,x,y,w,h)
  else
    self.cur_scissor = {x = x,y=y,w = w, h= h}
  end
  self:registerDraw(function(sc)
      love.graphics.setScissor(sc.x,sc.y,sc.w,sc.h)
    end,self.cur_scissor)
end

function suit:endScissor()
  assert(self.cur_scissor,"must have Scissor to pop out")
  self.cur_scissor = self.cur_scissor.next
  if self.cur_scissor then 
    self:registerDraw(function(sc)
        love.graphics.setScissor(sc.x,sc.y,sc.w,sc.h)
      end,self.cur_scissor)
  else
    self:registerDraw(function()
        love.graphics.setScissor()--disable scissor
      end)
  end
end


return suit
