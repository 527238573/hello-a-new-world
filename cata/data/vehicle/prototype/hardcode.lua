--手工编写的车模型。

local list = {}


--[[
 
 
  6 7 8 9
10
9
8
7
6
5
--]]



list[#list+1] = {
  id = "car",
  name = tl("汽车","Car"),
  {x= 6,y=10,
    [1] = {id = "frame"},
    [2] = {id = "bonnet",style =3},
    [3] = {id = "headlight",style =2},
    [4] = {id = "wheel_steerable"},
  },
  {x= 7,y=10,
    [1] = {id = "frame"},
    [2] = {id = "bonnet"},
    [3] = {id = "engine_v4"},
    [4] = {id = "car_battery"},
    [5] = {id = "car_alternator"},
  },
  {x= 8,y=10,
    [1] = {id = "frame"},
    [2] = {id = "bonnet"},
  },
  {x= 9,y=10,
    [1] = {id = "frame"},
    [2] = {id = "bonnet",style =2},
    [3] = {id = "headlight",style =1},
    [4] = {id = "wheel_steerable"},
  },


  {x= 6,y=9,
    [1] = {id = "frame"},
    [2] = {id = "windshield"},
  },
  {x= 7,y=9,
    [1] = {id = "frame"},
    [2] = {id = "windshield"},
  },
  {x= 8,y=9,
    [1] = {id = "frame"},
    [2] = {id = "windshield"},
  },
  {x= 9,y=9,
    [1] = {id = "frame"},
    [2] = {id = "windshield"},
  },

  {x= 6,y=8,
    [1] = {id = "frame"},
    [2] = {id = "door"},
  },
  {x= 7,y=8,
    [1] = {id = "frame"},
    [2] = {id = "reclining_seat"},
    [3] = {id = "controls"},
    [4] = {id = "roof"},
  },
  {x= 8,y=8,
    [1] = {id = "frame"},
    [2] = {id = "reclining_seat"},
    [3] = {id = "roof"},
  },
  {x= 9,y=8,
    [1] = {id = "frame"},
    [2] = {id = "door"},
  },
  
  {x= 6,y=7,
    [1] = {id = "frame"},
    [2] = {id = "door"},
  },
  {x= 7,y=7,
    [1] = {id = "frame"},
    [2] = {id = "seat"},
    [3] = {id = "roof"},
  },
  {x= 8,y=7,
    [1] = {id = "frame"},
    [2] = {id = "seat"},
    [3] = {id = "roof"},
  },
  {x= 9,y=7,
    [1] = {id = "frame"},
    [2] = {id = "door"},
  },
  
  {x= 6,y=6,
    [1] = {id = "frame"},
    [2] = {id = "quarterpanel",style =1},
    [3] = {id = "gas_tank_60"},
  },
  {x= 7,y=6,
    [1] = {id = "frame"},
    [2] = {id = "trunk"},
    [3] = {id = "roof"},
  },
  {x= 8,y=6,
    [1] = {id = "frame"},
    [2] = {id = "trunk"},
    [3] = {id = "roof"},
  },
  {x= 9,y=6,
    [1] = {id = "frame"},
    [2] = {id = "quarterpanel",style =1},
  },
  
  {x= 6,y=5,
    [1] = {id = "frame"},
    [2] = {id = "quarterpanel",style =3},
    [3] = {id = "wheel"},
  },
  {x= 7,y=5,
    [1] = {id = "frame"},
    [2] = {id = "door_trunk",},
  },
  {x= 8,y=5,
    [1] = {id = "frame"},
    [2] = {id = "door_trunk",},
  },
  {x= 9,y=5,
    [1] = {id = "frame"},
    [2] = {id = "quarterpanel",style =4},
    [3] = {id = "wheel"},
  },
}







list[#list+1] = {
  id = "car2",
  name = tl("汽车","Car"),
  {x= 6,y=10,
    [1] = {id = "frame"},
    [2] = {id = "bonnet",style =6},
    [3] = {id = "headlight",style =4},
    [4] = {id = "wheel_steerable"},
  },
  {x= 7,y=10,
    [1] = {id = "frame"},
    [2] = {id = "bonnet",style =4},
    [3] = {id = "engine_v4"},
    [4] = {id = "car_battery"},
    [5] = {id = "car_alternator"},
  },
  {x= 8,y=10,
    [1] = {id = "frame"},
    [2] = {id = "bonnet",style =4},
  },
  {x= 9,y=10,
    [1] = {id = "frame"},
    [2] = {id = "bonnet",style =5},
    [3] = {id = "headlight",style =3},
    [4] = {id = "wheel_steerable"},
  },


  {x= 6,y=9,
    [1] = {id = "frame"},
    [2] = {id = "windshield",style=2},
  },
  {x= 7,y=9,
    [1] = {id = "frame"},
    [2] = {id = "windshield"},
  },
  {x= 8,y=9,
    [1] = {id = "frame"},
    [2] = {id = "windshield"},
  },
  {x= 9,y=9,
    [1] = {id = "frame"},
    [2] = {id = "windshield",style=3},
  },

  {x= 6,y=8,
    [1] = {id = "frame"},
    [2] = {id = "door",style=3},
  },
  {x= 7,y=8,
    [1] = {id = "frame"},
    [2] = {id = "reclining_seat"},
    [3] = {id = "controls"},
    [4] = {id = "roof"},
  },
  {x= 8,y=8,
    [1] = {id = "frame"},
    [2] = {id = "reclining_seat"},
    [3] = {id = "roof"},
  },
  {x= 9,y=8,
    [1] = {id = "frame"},
    [2] = {id = "door",style=4},
  },
  
  {x= 6,y=7,
    [1] = {id = "frame"},
    [2] = {id = "door",style=3},
  },
  {x= 7,y=7,
    [1] = {id = "frame"},
    [2] = {id = "seat"},
    [3] = {id = "roof"},
  },
  {x= 8,y=7,
    [1] = {id = "frame"},
    [2] = {id = "seat"},
    [3] = {id = "roof"},
  },
  {x= 9,y=7,
    [1] = {id = "frame"},
    [2] = {id = "door",style=4},
  },
  
  {x= 6,y=6,
    [1] = {id = "frame"},
    [2] = {id = "quarterpanel",style =8},
    [3] = {id = "gas_tank_60"},
  },
  {x= 7,y=6,
    [1] = {id = "frame"},
    [2] = {id = "trunk"},
    [3] = {id = "roof"},
  },
  {x= 8,y=6,
    [1] = {id = "frame"},
    [2] = {id = "trunk"},
    [3] = {id = "roof"},
  },
  {x= 9,y=6,
    [1] = {id = "frame"},
    [2] = {id = "quarterpanel",style =9},
  },
  
  {x= 6,y=5,
    [1] = {id = "frame"},
    [2] = {id = "quarterpanel",style =10},
    [3] = {id = "wheel"},
  },
  {x= 7,y=5,
    [1] = {id = "frame"},
    [2] = {id = "door_trunk",},
  },
  {x= 8,y=5,
    [1] = {id = "frame"},
    [2] = {id = "door_trunk",},
  },
  {x= 9,y=5,
    [1] = {id = "frame"},
    [2] = {id = "quarterpanel",style =11},
    [3] = {id = "wheel"},
  },
}




list[#list+1] = {
  id = "car3",
  name = tl("汽车","Car"),
  {x= 6,y=10,
    [1] = {id = "frame"},
    [2] = {id = "bonnet",style =6},
    [3] = {id = "headlight",style =4},
  },
  {x= 7,y=10,
    [1] = {id = "frame"},
    [2] = {id = "bonnet",style =4},
    [3] = {id = "engine_v4"},
    [4] = {id = "car_battery"},
    [5] = {id = "car_alternator"},
  },
  {x= 8,y=10,
    [1] = {id = "frame"},
    [2] = {id = "bonnet",style =4},
  },
  {x= 9,y=10,
    [1] = {id = "frame"},
    [2] = {id = "bonnet",style =5},
    [3] = {id = "headlight",style =3},
  },


  {x= 6,y=9,
    [1] = {id = "frame"},
    [2] = {id = "windshield",style=2},
    [3] = {id = "wheel_steerable"},
  },
  {x= 7,y=9,
    [1] = {id = "frame"},
    [2] = {id = "windshield"},
  },
  {x= 8,y=9,
    [1] = {id = "frame"},
    [2] = {id = "windshield"},
  },
  {x= 9,y=9,
    [1] = {id = "frame"},
    [2] = {id = "windshield",style=3},
    [3] = {id = "wheel_steerable"},
  },

  {x= 6,y=8,
    [1] = {id = "frame"},
    [2] = {id = "door",style=3},
  },
  {x= 7,y=8,
    [1] = {id = "frame"},
    [2] = {id = "reclining_seat"},
    [3] = {id = "controls"},
    [4] = {id = "roof"},
  },
  {x= 8,y=8,
    [1] = {id = "frame"},
    [2] = {id = "reclining_seat"},
    [3] = {id = "roof"},
  },
  {x= 9,y=8,
    [1] = {id = "frame"},
    [2] = {id = "door",style=4},
  },
  
  {x= 6,y=7,
    [1] = {id = "frame"},
    [2] = {id = "door",style=3},
    [3] = {id = "gas_tank_60"},
  },
  {x= 7,y=7,
    [1] = {id = "frame"},
    [2] = {id = "seat"},
    [3] = {id = "roof"},
  },
  {x= 8,y=7,
    [1] = {id = "frame"},
    [2] = {id = "seat"},
    [3] = {id = "roof"},
  },
  {x= 9,y=7,
    [1] = {id = "frame"},
    [2] = {id = "door",style=4},
  },
  
  
  
  {x= 6,y=6,
    [1] = {id = "frame"},
    [2] = {id = "quarterpanel",style =10},
    [3] = {id = "wheel"},
    
  },
  {x= 7,y=6,
    [1] = {id = "frame"},
    [2] = {id = "door_trunk",},
  },
  {x= 8,y=6,
    [1] = {id = "frame"},
    [2] = {id = "door_trunk",},
  },
  {x= 9,y=6,
    [1] = {id = "frame"},
    [2] = {id = "quarterpanel",style =11},
    [3] = {id = "wheel"},
  },
}



return list