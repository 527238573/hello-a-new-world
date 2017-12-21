g.activity = {}

local activity_mt = {} 
 activity_mt.__index = activity_mt

function g.activity.create_activity()
  local newc = {}
  --默认15秒钟？
  newc.timePast= 0 --从0开始即时，模拟中的现实时间 
  newc.totalTime = 50 --都是以现实世界秒为单位，600秒现实世界10分钟，游戏时间 = 600*13.5 = 8100秒.25个小时游戏时间135分钟。
  newc.drawInterval  =22 --最大的会绘制时间间隔，也是现实时间为单位，22、0.5 也就是44个frame计算画一次。游戏内部时间约等于5分钟。
  newc.calcuateInterval = 0.5--秒计算一次.--可以更小，但浪费计算力？
  newc.minRealTime = 1--最短完成的现实时间。也就说如果计算速度太快，（计算速度如上，1帧跑游戏时间5分钟。60帧跑5小时游戏时间，不到5小时的不到1秒就跑完了，所以要延长），就按最短时间跑完。
  newc.realTimePast = 0 --真正现实经过的时间。
  newc.name = "unknown activity未知活动"
  newc.manuallyCancel = true --默认能手动取消。在过程读条中会有取消按钮。设为false 则是不能取消的活动，例如睡觉。
  newc.cancel_func=nil --取消函数。参数为activity自己。非正常结束调用这个
  newc.complete_func=nil --结束函数。参数为activity自己。 时间到了会调用这个。
  newc.stopstr = tl("停止进行？","Stop the process?") --停止询问的提示。不同的activity可能不同
  
  
  setmetatable(newc,activity_mt)
  return newc --更多的信息需要创建者填写，在craft ui里。
end


function activity_mt:updateRealTime(dt)
  self.realTimePast = self.realTimePast+dt
  
end

--将现实时间秒数转化为游戏小时和分钟数
local function getTimeStr(time)
  local game_minites = math.floor(time*13.5/60)
  local hours = math.floor(game_minites/60)
  local min = game_minites - hours*60
  if hours>0 then
    return string.format(tl("%d小时%d分钟","%d hour %d minites"),hours,min)
  else
    return string.format(tl("%d分钟","%d minites"),min)
  end
end



function activity_mt:setTotalTime(time)
  self.timePast = 0
  self.totalTime=time
  self.totalTime_str = tl("总时间: ","Total time: ")..getTimeStr(time)
end

function activity_mt:getPastTimeStr()
  return tl("经过时间: ","Elapsed time: ")..getTimeStr(self.timePast)
end






