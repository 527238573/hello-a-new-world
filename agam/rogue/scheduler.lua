

scheduler = {}

local _time =0;
local _events={}
local _eventTimes={}
local _repeat = {}
local _current = nil;
local _defaultDuration =1
local _duration = _defaultDuration

function scheduler.getTime()
  return _time
end



local function addToEvents(event,time)
  local index =1
  for i=1,#_eventTimes do
    if _eventTimes[i]>time then index = i break end
    index = index +1
  end
  table.insert(_events, index, event)
	table.insert(_eventTimes, index, event)
end


function scheduler.add(item,repeating,time)
  time = time or _defaultDuration
  addToEvents(item,time)
  if(repeating) then table.insert(_repeat, item) end
end

local function indexOf(list,item)
  for i=1,#list do
    if list[i] ==item then return i end
  end
  return 0
end

--返回true或false
function scheduler.remove(item)
  if item==_current then 
    _current =nil
    _duration=_defaultDuration
  end
  local index = indexOf(_repeat,item)
  if index~=0 then table.remove(_repeat, index) end
  index=indexOf(_events, item)
  if index ==0 then return false end
  table.remove(_events, index)
	table.remove(_eventTimes, index)
  return true
end


function scheduler.clear()
  _events={}
  _eventTimes={}
  _repeat={}
  _current = nil
  _duration = _defaultDuration
end

--返回该item
function scheduler.next()
  if(_current) and indexOf(_repeat, _current)~=0 then--重插入
    addToEvents(_current,_duration or _defaultDuration)
    _duration=_defaultDuration
  end
  if #_events>0 then 
      local time = table.remove(_eventTimes, 1)
    if time>0 then
      _time=_time+time
      for i=1,#_eventTimes do
        _eventTimes[i]=_eventTimes[i]-time
      end
    end
    _current = table.remove(_events, 1)
  else
    _current = nil
  end
  return _current
end


function scheduler.setDuration(time)
  if _current then _duration=time end
end




