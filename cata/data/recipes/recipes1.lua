local list = {}

list[#list+1] = {
  id = "nail",
  
  required_skills = {survival = 1,traps=1,mechanics=0},
  qualities = {cut = 1,cook = 1},
  tools = { {{"rock",-1},},
            {{"bat", -1},{"stick",10},{"cudgel",-1},{"pointy_stick",10},{"sharpened_rebar",10},{"wood_sword",-1},{"crude_sword",10}},
          },
  
  components = {{{"splinter",1},{"bone",1}},
                {{"l_pistol_JHP",1},{"h_rifle_M43",1}},
                },
  
  
  byproducts = {rock = 1,splinter=2},
  
  autolearn = true,
}


list[#list+1] = {
  id = "rock",
  
  
  result = "rock",
  components = {{{"splinter",4}}},
  autolearn = true,
}

return list