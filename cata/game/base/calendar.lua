

local calendar = {}
g.calendar = calendar



--实际RL时间
local turnpast = 0

--游戏时间 ，6秒一个回合
local month = 9
local day = 5
local hour = 0
local minute = 0
local second  =0;

local month_table = {31,28,31,30,31,30,31,31,30,31,30,31}
local time_str 
local time_str_dirty = true

local function caculateTimeFromTurn()
  local total_sec = math.floor(turnpast*6)
  second = total_sec%60
  local total_minute = math.floor(total_sec/60)
  minute = total_minute%60
  local total_hour = math.floor(total_minute/60)
  hour = total_hour%24
  local total_day = math.floor(total_hour/24)
  if total_day >= 365 then total_day = total_day%365 end --不计闰年
  for mon = 0,11 do
    local realmon = (mon+8)%12+1 --从9月开始，9月1日0点为游戏turn = 0
    if total_day<month_table[realmon] then
      month = realmon
      day = total_day+1 --日期已得
      break;
    else
      total_day =total_day - month_table[realmon]
    end
  end
end

--因为不计年份所以turn会回到第一年，注意
local function caculateTurnFromTime()
  local monpast = month-9
  if monpast<0 then monpast = monpast+12 end
  local total_day = day-1
  for mon=0,11 do
    local realmon = (mon+8)%12+1--从9月开始
    if mon>=monpast then
      break;
    else
      total_day = total_day+month_table[realmon]
    end
  end
  turnpast = total_day*24*60*10 +hour*60*10 +minute*10+second/6
  debugmsg("turn set:"..turnpast)
end

--必须注意合法值
function calendar.setDate(mon,d,h,m,s)
  month = mon
  day = d
  hour =h or 8 
  minute = m or 0
  second = s or 0
  caculateTurnFromTime()
  time_str_dirty = true
end


function calendar.updateRL(dt)
  turnpast = turnpast+dt*c.timeSpeed
  caculateTimeFromTurn()
  time_str_dirty = true
end

local month_name = {
  tl("1月","Jan."),tl("2月","Feb."),tl("3月","Mar."),tl("4月","Apr."),
  tl("5月","May."),tl("6月","Jun."),tl("7月","Jul."),tl("8月","Aug."),
  tl("9月","Sep."),tl("10月","Oct."),tl("11月","Nov."),tl("12月","Dec."),
}
local dayname =  tl("日","")
function calendar.getTimeStr()
  if time_str_dirty then
    time_str_dirty = false
    time_str = string.format("%s%d%s %02d:%02d",month_name[month],day,dayname,hour,minute)
  end
  return time_str 
end


function calendar.turn()
  return turnpast
end


