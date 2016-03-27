require"world/camera"
require"world/MapLayer"
require"core/Unit"
require"player/KeyControl"

gameWorld = {}
gameWorld.allActor = {}
gameWorld.renderList = {}
gameWorld.renderList.maxlayer = 10 -- 最大10层（1-10）



--添加到世界
function gameWorld.addToWorld(renderable) -- 必须是
  local layer = renderable.layer
  if( gameWorld.renderList[layer] == nil) then
    gameWorld.renderList[layer] = {}
  end
  gameWorld.renderList[layer][renderable] = true;
  gameWorld.allActor[renderable] = true;
  
end
--从世界删除
function gameWorld.removeFormWorld(renderable)
  gameWorld.allActor[renderable] = nil
  local layer = renderable.layer
  if(layer ~= nil)then
    gameWorld.renderList[layer][renderable] = nil   --删除相应的绘制
  end
end



function gameWorld.update(dt) -- 跟新所有对象
  keyControl.update(dt) -- 更新操作
  for key,_ in pairs(gameWorld.allActor) do
    key:update(dt)
  end
  
  camera.update(dt)
end

function gameWorld.draw()       --绘制所有可绘制对象
  mapLayer.draw() --绘制地图
  for i= 1,gameWorld.renderList.maxlayer do
    local list= gameWorld.renderList[i]
    if list then
      for key,_ in pairs(list) do
        key:draw()
      end
    end
  end
end