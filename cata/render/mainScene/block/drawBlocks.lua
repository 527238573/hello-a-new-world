require "render/mainScene/block/drawUnit"
require "render/mainScene/block/drawEffect"
require "render/mainScene/block/drawItem"
local rm = render.main
local camera = ui.camera
local grid = g.map.grid

local bid_info
function rm.initDrawBlocks()
  bid_info = data.block
end

local conectedLowWall_index = {4,3,1,2,8,7,5,6}
local getblock = g.map.getBlockInGrid
local getblockAndItems = g.map.getBlockAndItemsInGrid
--screenx,screeny是square底部中心点
local function drawOneBlock(bid,screenx,screeny,x,y,z,itemlist)
  if bid==nil or bid<2 then return end
  local info  = bid_info[bid]
  
  if info.drawtype ==3 or  info.drawtype ==2 then return end
  local scale = camera.zoom*info.scalefactor
  love.graphics.draw(info.img,info[1],screenx,screeny,0,scale,scale,0.5*info.width,info.height)--绘制，根据位置（左下点）和缩放
  --item方面
  local drawItem = false
  if info.CONTAINER and info.SEALED==nil then--非封闭容器
    drawItem = math.abs(player.x - x)<=1 and math.abs(player.y - y)<=1 --必须近身才能看到内部
  end
  if info.ITEM_ON_TOP then drawItem = true end --默认在上方的在此draw
  if drawItem and itemlist and itemlist~=c.null_t and #itemlist>0 then rm.drawItem(itemlist,x,y,z,screenx,screeny) end
  
end

local getblockDataInGrid = g.map.getblockDataInGrid

local function drawOneSquare(x,y,z)
  local screenx,screeny = camera.modelToScreen(x*64 +32,y*64)
  local bid,unit,itemlist = getblockDataInGrid(x,y,z)
  --先drawfurniture或block，再draw物品 ，再draw单位
  drawOneBlock(bid,screenx,screeny,x,y,z,itemlist)
  --if itemlist~=c.null_t and #itemlist>0 then rm.drawItem(itemlist,x,y,z,screenx,screeny) end
  if unit then rm.drawUnit(unit,x,y,z,screenx,screeny)end
end

local function drawLowBlock(bid,info,x,y,z,screenx,screeny)
  if info.drawtype ~=3 and  info.drawtype ~=2 then return end --属于lowlayer的block
  local quad = info[1]
  local use_scc = false
  if info.drawtype ==3 then
    local up  = getblock(x,y+1,z)
    local right  = getblock(x+1,y,z)
    local left  = getblock(x-1,y,z)
    local statecode = 1
    if up~=nil and up == bid then statecode = statecode +4 end
    if right~=nil and right == bid then statecode = statecode +2 end
    if left~=nil and left == bid then statecode = statecode +1 end
    quad = info[conectedLowWall_index[statecode]]
  end
  local scale = camera.zoom*info.scalefactor
  if g.map.isWallTerInGrid(x,y-1,z) then
    use_scc = true
    love.graphics.setScissor(screenx-info.width*scale*0.5+rm.shiftX,screeny-info.height*scale+rm.shiftY,info.width*scale,info.height*scale)
  end
  love.graphics.draw(info.img,quad,screenx,screeny,0,scale,scale,0.5*info.width,info.height)--绘制，根据位置（左下点）和缩放
  if use_scc then love.graphics.setScissor() end--disable scissor
end

local function drawLowWallSquare(x,y,z,drawItem)
  local screenx,screeny = camera.modelToScreen(x*64 +32,y*64)
  local bid,itemlist= getblockAndItems(x,y,z)
  if bid and bid>1 then
    local info  = bid_info[bid]
    if info.drawtype ==3 or  info.drawtype ==2 then --属于lowlayer的block
      drawLowBlock(bid,info,x,y,z,screenx,screeny)
    end 
    if info.CONTAINER or info.ITEM_ON_TOP then
      drawItem = false--不在此层draw
    end
  end
  if drawItem and itemlist and itemlist~=c.null_t and #itemlist>0 then rm.drawItem(itemlist,x,y,z,screenx,screeny) end
end






local squareLength = 64

function rm.drawLowBlocksLayer(zcache)
  love.graphics.setColor(255,255,255)
  local startx = math.floor(camera.seen_minX/squareLength)-1
  local starty = math.floor(camera.seen_maxY/squareLength)+1
  local endx = math.floor((camera.seen_maxX)/squareLength)+1
  local endy = math.floor((camera.seen_minY-64)/squareLength)
  local z = camera.cur_Z
  for y= starty,endy,-1 do -- 从上至下
    for x= startx,endx do
      local rx = x-grid.minXsquare
      local ry = y-grid.minYsquare
      local drawItem = false
      if rx>=0 and rx<144 and ry>=0 and ry<144 then
        drawItem = zcache.seen[rx][ry]>0
      end
      drawLowWallSquare(x,y,z,drawItem)
    end
  end
end

function rm.drawLowBlocksLayerUnder(zcache)
  love.graphics.setColor(255,255,255)
  local startx = math.floor(camera.seen_minX/squareLength)-1
  local starty = math.floor((camera.seen_maxY+20)/squareLength)+1
  local endx = math.floor((camera.seen_maxX)/squareLength)+1
  local endy = math.floor((camera.seen_minY-44)/squareLength)
  local z = camera.cur_Z-1
  for y= starty,endy,-1 do -- 从上至下
    for x= startx,endx do
      local rx = x-grid.minXsquare
      local ry = y-grid.minYsquare
      if rx>=0 and rx<144 and ry>=0 and ry<144 then
        local drawItem = zcache.seen[rx][ry]>0
        if zcache.floor[rx][ry]==false then
          drawLowWallSquare(x,y,z,drawItem)
        elseif ry>=1 and zcache.floor[rx][ry-1]==false then--多看一格
          drawLowWallSquare(x,y,z,drawItem)
        end
      end
    end
  end
end


function rm.drawBlocksLayer(zcache)
  love.graphics.setColor(255,255,255)
  local startx = math.floor(camera.seen_minX/squareLength)-1
  local starty = math.floor((camera.seen_maxY)/squareLength)+1
  local endx = math.floor((camera.seen_maxX)/squareLength)+1
  local endy = math.floor((camera.seen_minY-64)/squareLength)
  
  local z = camera.cur_Z
  for y= starty,endy,-1 do -- 从上至下
    for x= startx,endx do
      local rx = x-grid.minXsquare
      local ry = y-grid.minYsquare
      if rx>=0 and rx<=143 and ry>=0 and ry<=143 then
        --确定在grid的范围内 
        if(zcache.seen[rx][ry]>0) then--可见的
            drawOneSquare(x,y,z)
        end
      end
    end
  end
end

function rm.drawBlocksLayerUnder(zcache)
  love.graphics.setColor(255,255,255)
  local startx = math.floor(camera.seen_minX/squareLength)-1
  local starty = math.floor((camera.seen_maxY+20)/squareLength)+1
  local endx = math.floor((camera.seen_maxX)/squareLength)+1
  local endy = math.floor((camera.seen_minY-44)/squareLength)
  
  local z = camera.cur_Z-1
  for y= starty,endy,-1 do -- 从上至下
    for x= startx,endx do
      local rx = x-grid.minXsquare
      local ry = y-grid.minYsquare
      if rx>=0 and rx<=143 and ry>=0 and ry<=143 then
        --确定在grid的范围内 
        if(zcache.seen[rx][ry]>0) then--可见的
          if zcache.floor[rx][ry]==false  then
            drawOneSquare(x,y,z)
          elseif ry>=1 and zcache.floor[rx][ry-1]==false then--多看一格
            drawOneSquare(x,y,z)
          end
        end
      end
    end
  end
end


