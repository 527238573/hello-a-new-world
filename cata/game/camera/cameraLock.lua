
local lock = {}
g.cameraLock  = lock


lock.locked = false



function lock.cameraMove(fx,fy,tx,ty,time,curTime)

  lock.fx = fx*64
  lock.fy = fy*64
  lock.tx = tx*64
  lock.ty = ty*64

  lock.cur = curTime
  lock.total = time
  lock.locked = true
end


function lock.updateAnim(dt)
  if lock.locked then
    if lock.cur>=lock.total then
      lock.locked = false
    end
    lock.cur =lock.cur+dt
    if lock.cur>lock.total then
      lock.cur = lock.total
    end
  end
end