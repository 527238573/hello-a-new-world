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


local moveblock = -10000
local function setLast(display_name,move_cost,color,transparent,flag)
  local block = block_data[#block_data]
  block.displayname = display_name
  block.move_cost = move_cost --叠加movecost，除非设置了resetmovecost，可以把不能移动的地形变为能移动。把能移动的变为不能移动，取大负值
  block.color = color -- 
  block.transparent = transparent --是否可看穿
  
  if flag then 
    for k,v in pairs(flag) do
      block[k] = v
    end
  end
  
  --block.flag = flag
  
end




addBlock("f_none",32*2,0,32,32,"none");setLast(tl("无","none"),0,"black",true,nil)

addBlock("f_tree",0,0,32,64,"plants");setLast(tl("橡树","oak tree"),moveblock,"dark_green",false,nil)
addBlock("f_tree_young",32,0,32,64,"plants");setLast(tl("小树","young trere"),100,"dark_green",true,nil)
addBlock("f_underbrush",64,32,32,32,"plants");setLast(tl("灌木丛","underbrush"),160,"light_green",true,nil)
addBlock("f_shrub",32*3,32,32,32,"plants");setLast(tl("杂灌木","shrub"),90,"dark_green",true,nil)

addBlock("f_door_c",32*0,32*9,32,32,"fitment",2);setLast(tl("关闭的木门","close wood door"),moveblock,"brown",false,nil)
addBlock("f_door_o",32*1,32*9,32,32,"fitment",2);setLast(tl("打开的木门","open wood dooe"),0,"brown",true,nil)
addBlock("f_door_b",32*1,32*11,32,32,"fitment",2);setLast(tl("坏掉的木门","damaged wood door"),moveblock,"brown",true,nil)
addBlock("f_window",32*2,32*9,32,32,"fitment",1);setLast(tl("窗户","window"),moveblock,"light_blue",true,{resetTM = true})
addBlock("f_window_open",32*3,32*9,32,32,"fitment",1);setLast(tl("打开的窗户","open window"),250,"light_blue",true,{resetTM = true})
addBlock("f_window_frame",32*3,32*10,32,32,"fitment",1);setLast(tl("窗户框","window frame"),250,"light_blue",true,{resetTM = true})
addBlock("f_window_n",32*2,32*10,32,32,"fitment",1);setLast(tl("封闭窗户","sealed window"),moveblock,"light_blue",true,{resetTM = true})
addBlock("f_window_empty",32*3,32*11,32,32,"fitment",1);setLast(tl("空窗框","empty window"),250,"grey",true,{resetTM = true})
addBlock("f_stairs_up1",32*5,32*17+16,32,48,"fitment",1);
setLast(tl("上行楼梯","stairs up"),100,"dark_grey",false,{stairs = "up",stairs_dir = {0,1},rotate = {"f_stairs_up2","f_stairs_up3","f_stairs_up4"}})
addBlock("f_stairs_up2",32*4,32*17,32,32,"fitment",2);
setLast(tl("上行楼梯","stairs up"),100,"dark_grey",false,{stairs = "up",stairs_dir ={1,0},rotate = {"f_stairs_up3","f_stairs_up4","f_stairs_up1"}})
addBlock("f_stairs_up3",32*6,32*17,32,32,"fitment",2);
setLast(tl("上行楼梯","stairs up"),100,"dark_grey",false,{stairs = "up",stairs_dir ={0,-1},rotate = {"f_stairs_up4","f_stairs_up1","f_stairs_up2"}})
addBlock("f_stairs_up4",32*3,32*17,32,32,"fitment",2);
setLast(tl("上行楼梯","stairs up"),100,"dark_grey",false,{stairs = "up",stairs_dir ={-1,0},rotate = {"f_stairs_up1","f_stairs_up2","f_stairs_up3"}})
addBlock("f_stairs_down1",32*5,32*19,32,32,"fitment",2);
setLast(tl("下行楼梯","stairs down"),50,"dark_grey",true,{stairs = "down",stairs_dir ={0,1},rotate = {"f_stairs_down2","f_stairs_down3","f_stairs_down4"}})
addBlock("f_stairs_down2",32*3,32*19,32,32,"fitment",2);
setLast(tl("下行楼梯","stairs down"),50,"dark_grey",true,{stairs = "down",stairs_dir ={1,0},rotate = {"f_stairs_down3","f_stairs_down4","f_stairs_down1"}})
addBlock("f_stairs_down3",32*6,32*19,32,32,"fitment",2);
setLast(tl("下行楼梯","stairs down"),50,"dark_grey",true,{stairs = "down",stairs_dir ={0,-1},rotate = {"f_stairs_down4","f_stairs_down1","f_stairs_down2"}})
addBlock("f_stairs_down4",32*4,32*19,32,32,"fitment",2);
setLast(tl("下行楼梯","stairs down"),50,"dark_grey",true,{stairs = "down",stairs_dir ={-1,0},rotate = {"f_stairs_down1","f_stairs_down2","f_stairs_down3"}})



addBlock("f_sofa_pink1",0,32*3,32,32,"furnitrue",2);setLast(tl("沙发","sofa"),50,"dark_pink",true,{rotate = {"f_sofa_pink3","f_sofa_pink9","f_sofa_pink7"}})
addBlock("f_sofa_pink2",32,32*3,32,32,"furnitrue",2);setLast(tl("沙发","sofa"),50,"dark_pink",true,{rotate = {"f_sofa_pink6","f_sofa_pink8","f_sofa_pink4"}})
addBlock("f_sofa_pink3",32*2,32*3,32,32,"furnitrue",2);setLast(tl("沙发","sofa"),50,"dark_pink",true,{rotate = {"f_sofa_pink9","f_sofa_pink7","f_sofa_pink1"}})
addBlock("f_sofa_pink4",0,32*5,32,32,"furnitrue",2);setLast(tl("沙发","sofa"),50,"dark_pink",true,{rotate = {"f_sofa_pink2","f_sofa_pink6","f_sofa_pink8"}})
addBlock("f_sofa_pink5",32,32*5,32,32,"furnitrue",2);setLast(tl("沙发","sofa"),50,"dark_pink",true,nil)
addBlock("f_sofa_pink6",32*2,32*5,32,32,"furnitrue",2);setLast(tl("沙发","sofa"),50,"dark_pink",true,{rotate = {"f_sofa_pink8","f_sofa_pink4","f_sofa_pink2"}})
addBlock("f_sofa_pink7",0,32*7,32,32,"furnitrue",2);setLast(tl("沙发","sofa"),50,"dark_pink",true,{rotate = {"f_sofa_pink1","f_sofa_pink3","f_sofa_pink9"}})
addBlock("f_sofa_pink8",32,32*7,32,32,"furnitrue",2);setLast(tl("沙发","sofa"),50,"dark_pink",true,{rotate = {"f_sofa_pink4","f_sofa_pink2","f_sofa_pink6"}})
addBlock("f_sofa_pink9",32*2,32*7,32,32,"furnitrue",2);setLast(tl("沙发","sofa"),50,"dark_pink",true,{rotate = {"f_sofa_pink7","f_sofa_pink1","f_sofa_pink3"}})
addBlock("f_sofa_pink10",32*3,32*7,32,32,"furnitrue",1);setLast(tl("沙发","sofa"),50,"dark_pink",true,nil)
addBlock("f_bed",32*4,32*3,32,32,"furnitrue",3);setLast(tl("床","bed"),100,"light_grey",true,nil)
addBlock("f_table",32*4,32*7,32,32,"furnitrue",3);setLast(tl("桌子","table"),100,"light_brown",true,nil)
addBlock("f_counter",32*4,32*11,32,32,"furnitrue",3);setLast(tl("柜台","counter"),120,"light_brown",true,nil)
addBlock("f_bench_v",32*9,32*11,32,32,"furnitrue",1);setLast(tl("长椅-竖","bench"),50,"dark_brown",true,{rotate = {"f_bench_h","f_bench_v","f_bench_h"}})
addBlock("f_bench_h",32*9,32*12,32,32,"furnitrue",2);setLast(tl("长椅-横","bench"),50,"dark_brown",true,{rotate = {"f_bench_v","f_bench_h","f_bench_v"}})
addBlock("f_wood_chair2",32*8,32*9,32,32,"furnitrue",1);setLast(tl("木椅","wood chair"),50,"brown",true,{rotate = {"f_wood_chair3","f_wood_chair4","f_wood_chair1"}})
addBlock("f_wood_chair4",32*9,32*9,32,32,"furnitrue",1);setLast(tl("木椅","wood chair"),50,"brown",true,{rotate = {"f_wood_chair1","f_wood_chair2","f_wood_chair3"}})
addBlock("f_wood_chair1",32*8,32*10,32,32,"furnitrue",1);setLast(tl("木椅","wood chair"),50,"brown",true,{rotate = {"f_wood_chair2","f_wood_chair3","f_wood_chair4"}})
addBlock("f_wood_chair3",32*9,32*10,32,32,"furnitrue",1);setLast(tl("木椅","wood chair"),50,"brown",true,{rotate = {"f_wood_chair4","f_wood_chair1","f_wood_chair2"}})
addBlock("f_chair",32*9,32*8,32,32,"furnitrue",1);setLast(tl("椅子","chair"),50,"dark_brown",true,nil)
addBlock("f_armchair",32*8,32*8,32,32,"furnitrue",1);setLast(tl("扶手椅","arm chair"),50,"dark_red",true,nil)
addBlock("f_dresser",32*0,32*13+16,32,48,"furnitrue",1);setLast(tl("衣柜","dresser"),moveblock,"brown",false,nil)
addBlock("f_locker",32*1,32*13+16,32,48,"furnitrue",1);setLast(tl("锁柜","locker"),moveblock,"light_grey",false,nil)
addBlock("f_bookcase",32*2,32*13+16,32,48,"furnitrue",1);setLast(tl("书架","bookcase"),moveblock,"brown",false,nil)
addBlock("f_washer",32*0,32*15,32,32,"furnitrue",1);setLast(tl("洗衣机","washer machine"),250,"light_grey",true,nil)
addBlock("f_dryer",32*1,32*15,32,32,"furnitrue",1);setLast(tl("烘干机","dryer"),250,"light_grey",true,nil)
addBlock("f_nighttable",32*2,32*15,32,32,"furnitrue",1);setLast(tl("床头柜","bedside table"),100,"brown",true,nil)
addBlock("f_cupboard",32*0,32*16,32,32,"furnitrue",1);setLast(tl("碗柜","cupboard"),100,"dark_blue",true,nil)
addBlock("f_sink",32*1,32*16,32,32,"furnitrue",1);setLast(tl("水槽","sink"),150,"white",true,nil)
addBlock("f_oven",32*2,32*16,32,32,"furnitrue",1);setLast(tl("烤箱","oven"),100,"dark_grey",true,nil)
addBlock("f_fridge",32*3,32*16-16,32,48,"furnitrue",1);setLast(tl("冰箱","refrigerator"),moveblock,"dark_cyan",false,nil)
addBlock("f_bathtub",32*4,32*16,32,32,"furnitrue",1);setLast(tl("浴缸","bathtub"),100,"white",true,nil)
addBlock("f_toilet",32*5,32*16,32,32,"furnitrue",1);setLast(tl("马桶","toilet"),100,"white",true,nil)
addBlock("f_computer",32*6,32*16-16,32,48,"furnitrue",1);setLast(tl("电脑","computer"),moveblock,"light_grey",true,nil)
addBlock("f_computer_broken",32*7,32*16-16,32,48,"furnitrue",1);setLast(tl("损坏的电脑","broken computer"),moveblock,"light_grey",true,nil)
addBlock("f_console_broken",32*4,32*15,32,32,"furnitrue",1);setLast(tl("损坏的终端","broken console"),moveblock,"light_grey",true,nil)
addBlock("f_console",32*5,32*15,32,32,"furnitrue",1);setLast(tl("终端","console"),moveblock,"light_grey",true,nil)
addBlock("f_fireplace",32*0,32*18,32,32,"furnitrue",1);setLast(tl("壁炉","fireplace"),100,"dark_grey",true,nil)
addBlock("f_indoor_plant",32*0,32*19,32,32,"furnitrue",1);setLast(tl("室内植物","indoor plant"),50,"green",true,nil)
addBlock("f_trashcan",32*1,32*19,32,32,"furnitrue",1);setLast(tl("垃圾桶","trashcan"),150,"light_cyan",true,nil)
addBlock("f_dumpster",32*2,32*19,32,32,"furnitrue",1);setLast(tl("垃圾箱","dumpster"),150,"dark_green",true,nil)
return block_data