--动作入口
g.raction={}
local action=g.raction


function action.moveAction(x,y)
  local cost = g.player.plmove(x,y)
  g.takeTurn(cost) -- cost可能为0，动作无效的情况下
end

