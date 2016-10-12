
--地图总功能，向其他部分掩藏具体分割等功能


--[[
地图 坐标用x y 表示，外部始终使用统一标准全局坐标系，整数
Y轴朝上 x轴朝右
]]
map = {}
--[[返回花费移动点数 100点为标准点数
    不存在combine movecost
]]
function map.move_cost(x,y)
  if(x>=1 and x<=mapLayer.width and y>=1 and y<=mapLayer.height)then
    return 100
  end
    return 0 -- 不可通行
  --测试版本的方法
end




