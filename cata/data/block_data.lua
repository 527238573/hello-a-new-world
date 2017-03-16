local block_img = love.graphics.newImage("data/block.png")

local block_data = {block_img = block_img}


local function addBlock(name,x,y,w,h,typename,drawtype)
  drawtype = drawtype or 1
  
  local block ={name = name,img = block_img,width=w,height=h,typename = typename,drawtype = drawtype}
  block.scalefactor = 2
  if drawtype == 1 then -- normal 
    table.insert(block,love.graphics.newQuad(x,y,w,h,block_img:getDimensions()))
  elseif drawtype ==2 then --single  low wall  
    table.insert(block,love.graphics.newQuad(x,y,w,h+16,block_img:getDimensions()))--下方一半，加入
  elseif drawtype ==3 then --connected low wall
    table.insert(block,love.graphics.newQuad(x,y,w,h+16,block_img:getDimensions()))
    table.insert(block,love.graphics.newQuad(x+32,y,w,h+16,block_img:getDimensions()))
    table.insert(block,love.graphics.newQuad(x+32*2,y,w,h+16,block_img:getDimensions()))
    table.insert(block,love.graphics.newQuad(x+32*3,y,w,h+16,block_img:getDimensions()))
    
    table.insert(block,love.graphics.newQuad(x,y+64,w,h+16,block_img:getDimensions()))
    table.insert(block,love.graphics.newQuad(x+32,y+64,w,h+16,block_img:getDimensions()))
    table.insert(block,love.graphics.newQuad(x+32*2,y+64,w,h+16,block_img:getDimensions()))
    table.insert(block,love.graphics.newQuad(x+32*3,y+64,w,h+16,block_img:getDimensions()))
  end
  
  
  table.insert(block,love.graphics.newQuad(x,y,w,h,block_img:getDimensions()))
  table.insert(block_data,block)
end

addBlock("f_none",32*2,0,32,32,"none")

addBlock("f_tree",0,0,32,64,"plants")
addBlock("f_tree_young",32,0,32,64,"plants")
addBlock("f_underbush",64,32,32,32,"plants")
addBlock("f_shrub",32*3,32,32,32,"plants")

addBlock("f_door",32*0,32*9,32,32,"fitment",2)
addBlock("f_door_o",32*1,32*9,32,32,"fitment",2)
addBlock("f_door_b",32*1,32*11,32,32,"fitment",2)
addBlock("f_window",32*2,32*9,32,32,"fitment",1)
addBlock("f_window_open",32*3,32*9,32,32,"fitment",1)
addBlock("f_window_frame",32*3,32*10,32,32,"fitment",1)
addBlock("f_window_n",32*2,32*10,32,32,"fitment",1)
addBlock("f_window_empty",32*3,32*11,32,32,"fitment",1)
addBlock("f_stairs_up1",32*5,32*17,32,32,"fitment",1)
addBlock("f_stairs_up2",32*4,32*17,32,32,"fitment",1)
addBlock("f_stairs_up3",32*6,32*17,32,32,"fitment",1)
addBlock("f_stairs_up4",32*3,32*17,32,32,"fitment",1)
addBlock("f_stairs_down1",32*5,32*18,32,32,"fitment",2)
addBlock("f_stairs_down2",32*3,32*18,32,32,"fitment",2)
addBlock("f_stairs_down3",32*6,32*18,32,32,"fitment",2)
addBlock("f_stairs_down4",32*4,32*18,32,32,"fitment",2)



addBlock("f_sofa_pink1",0,32*3,32,32,"furnitrue",2)
addBlock("f_sofa_pink2",32,32*3,32,32,"furnitrue",2)
addBlock("f_sofa_pink3",32*2,32*3,32,32,"furnitrue",2)
addBlock("f_sofa_pink4",0,32*5,32,32,"furnitrue",2)
addBlock("f_sofa_pink5",32,32*5,32,32,"furnitrue",2)
addBlock("f_sofa_pink6",32*2,32*5,32,32,"furnitrue",2)
addBlock("f_sofa_pink7",0,32*7,32,32,"furnitrue",2)
addBlock("f_sofa_pink8",32,32*7,32,32,"furnitrue",2)
addBlock("f_sofa_pink9",32*2,32*7,32,32,"furnitrue",2)
addBlock("f_sofa_pink10",32*3,32*7,32,32,"furnitrue",1)
addBlock("f_bed",32*4,32*3,32,32,"furnitrue",3)
addBlock("f_table",32*4,32*7,32,32,"furnitrue",3)
addBlock("f_counter",32*4,32*11,32,32,"furnitrue",3)
addBlock("f_bench_v",32*9,32*11,32,32,"furnitrue",1)
addBlock("f_bench_h",32*9,32*12,32,32,"furnitrue",2)
addBlock("f_wood_chair1",32*8,32*9,32,32,"furnitrue",1)
addBlock("f_wood_chair2",32*9,32*9,32,32,"furnitrue",1)
addBlock("f_wood_chair3",32*8,32*10,32,32,"furnitrue",1)
addBlock("f_wood_chair4",32*9,32*10,32,32,"furnitrue",1)
addBlock("f_chair",32*9,32*8,32,32,"furnitrue",1)
addBlock("f_armchair",32*8,32*8,32,32,"furnitrue",1)
addBlock("f_dresser",32*0,32*13+16,32,48,"furnitrue",1)
addBlock("f_locker",32*1,32*13+16,32,48,"furnitrue",1)
addBlock("f_bookcase",32*2,32*13+16,32,48,"furnitrue",1)
addBlock("f_washer",32*0,32*15,32,32,"furnitrue",1)
addBlock("f_dryer",32*1,32*15,32,32,"furnitrue",1)
addBlock("f_nighttable",32*2,32*15,32,32,"furnitrue",1)
addBlock("f_cupboard",32*0,32*16,32,32,"furnitrue",1)
addBlock("f_sink",32*1,32*16,32,32,"furnitrue",1)
addBlock("f_oven",32*2,32*16,32,32,"furnitrue",1)
addBlock("f_fridge",32*3,32*16-16,32,48,"furnitrue",1)
addBlock("f_bathtub",32*4,32*16,32,32,"furnitrue",1)
addBlock("f_toilet",32*5,32*16,32,32,"furnitrue",1)
addBlock("f_computer",32*6,32*16-16,32,48,"furnitrue",1)
addBlock("f_computer_broken",32*7,32*16-16,32,48,"furnitrue",1)
addBlock("f_console_broken",32*4,32*15,32,32,"furnitrue",1)
addBlock("f_console",32*5,32*15,32,32,"furnitrue",1)
addBlock("f_fireplace",32*0,32*18,32,32,"furnitrue",1)
addBlock("f_fireplace_burning",32*1,32*18,32,32,"furnitrue",1)
addBlock("f_indoor_plant",32*0,32*19,32,32,"furnitrue",1)
addBlock("f_trashcan",32*1,32*19,32,32,"furnitrue",1)
addBlock("f_dumpster",32*2,32*19,32,32,"furnitrue",1)
return block_data