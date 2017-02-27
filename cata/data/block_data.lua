local block_img = love.graphics.newImage("data/block.png")

local block_data = {block_img = block_img}


local function addBlock(name,x,y,w,h,typename)
  local block ={name = name,img = block_img,width=w,height=h,typename = typename}
  block.scalefactor = 2
  table.insert(block,love.graphics.newQuad(x,y,w,h,block_img:getDimensions()))
  table.insert(block_data,block)
end

addBlock("f_none",32*2,0,32,32,"none")

addBlock("f_tree",0,0,32,64,"plants")
addBlock("f_tree_young",32,0,32,64,"plants")
addBlock("f_underbush",64,32,32,32,"plants")
addBlock("f_shrub",32*3,32,32,32,"plants")

return block_data