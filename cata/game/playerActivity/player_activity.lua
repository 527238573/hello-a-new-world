local player_mt = g.player_mt




function player_mt:update_activity(dt)
  local activity = player.activity
  
  activity.timePast = activity.timePast + dt
  
  if activity.timePast>= activity.totalTime then
    --finish
    debugmsg("activity finished")
    self:complete_activity()
  end
end


function player_mt:assign_activity(activity)
  self.activity  = activity
end

--完成
function player_mt:complete_activity()
  local activity = self.activity
  if activity==nil then return end
  self.activity = nil--先删除
  if activity.complete_func then
    activity.complete_func(activity) -- 调用结束函数。数据都存在activity本身里面
  end
end

function player_mt:cancel_activity()
  local activity = self.activity
  if activity==nil then return end
  if activity.timePast>= activity.totalTime then
    self:complete_activity()
    return--满足时间条件，正常结束activity。
  end
  self.activity = nil--先删除
  if activity.cancel_func then --按理说所有activity都有完成和取消函数的。
    activity.cancel_func(activity) -- 非正常结束包括意外取消或主动取消，经过时间等信息都存在activity，比如睡觉经过X个小时回复相应点数的精力。
  end
end


--提示询问


function player_mt:cancel_activity_query(msg,canIgnore)
  local activity = self.activity
  if activity==nil then return end
  if activity.manuallyCancel== false then return end --必须自动停止？如果睡眠需要用其他
  if activity.ignore and canIgnore then return end --已经被ignore，后面能够被ignore的信息自动无视
  activity.pause = {msg = msg,canIgnore = canIgnore}
  activity.pause_msg = string.format("%s,%s",msg,activity.stopstr)
end





