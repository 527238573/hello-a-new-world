

local delayFunctionList= {}


function g.updateAnimDelayFucntion(dt)
  for i= #delayFunctionList,1,-1 do
    local onet = delayFunctionList[i]
    onet.delay = onet.delay-dt
    if onet.delay <=0 then
      onet.f(unpack(onet.args))
      table.remove(delayFunctionList,i)
    end
  end
  
  
end

--添加anim时间的delayfunc,  为了配合anim动画，里面也有执行逻辑，注意时间是按anim的
function g.insertDelayFunction(delay,func,...)
  local onet = {delay = delay, args = {...},f= func}
  delayFunctionList[#delayFunctionList+1] = onet
end


