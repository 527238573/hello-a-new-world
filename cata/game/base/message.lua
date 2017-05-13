
msg = {}
local msg = msg
g.message = msg


local message_list = {}
local max_length = 100
g.message.message_list = message_list

function msg.addmsg(msg,msgtype)
  msgtype = msgtype or "info"
  if message_list[1] then
    if msg == message_list[1].msg and msgtype == message_list[1].msgtype then
      message_list[1].count = (message_list[1].count or 1)+1 --增加count
      message_list[1].warpped_mwin = nil--清除缓存
      return
    end
  end
  
  local msg_t = {msg = msg, msgtype = msgtype}
  --还有时间戳
  table.insert(message_list,1,msg_t)
  if #message_list>max_length then message_list[max_length+1] = nil end --清除末尾
end
  
  


