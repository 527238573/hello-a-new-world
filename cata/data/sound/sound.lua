
local soundlist= {}


local function addSingleSound(idname,filename,default_volume,mode)
  mode = mode or "static"
  default_volume = default_volume or 1
  local one_sound = {}
  one_sound.data = love.audio.newSource("data/sound/"..filename,mode)
  one_sound.default_volume = default_volume
  soundlist[idname] = one_sound
end

local function addRandomGroup(idname,list,mode)
  mode = mode or "static"
  local one_sound = {random_group = true}
  for i=1,#list do
    local one_s = {}
    one_s.data = love.audio.newSource("data/sound/"..list[i][1],mode)
    one_s.default_volume = list[i][2] or 1
    one_sound[i] = one_s
  end
  soundlist[idname] = one_sound
end



addSingleSound("get","get1.wav")
addSingleSound("drop","drop1.wav")
addSingleSound("fail","fail1.wav")
addSingleSound("crush","crush1.wav")
addSingleSound("bash1","bash1.wav")
addSingleSound("dooropen1","dooropen1.ogg")
addSingleSound("doorclose1","doorclose1.ogg")
addSingleSound("windowopen1","windowopen1.ogg")
addSingleSound("windowclose1","windowclose1.ogg")

addSingleSound("miss","miss.wav")
addSingleSound("kill1","kill1.wav")
addSingleSound("kill2","kill2.wav")

addSingleSound("zombie_hit1","monster/bite_hit_1.wav",0.1)
addSingleSound("zombie_hit2","monster/bite_hit_2.wav",0.1)
addSingleSound("zombie_hit3","monster/bite_hit_3.wav",0.1)
addSingleSound("zombie_hit4","monster/bite_hit_4.wav",0.1)
addSingleSound("zombie_death1","monster/zombie_death_3.wav",0.2)
addSingleSound("zombie_death2","monster/zombie_death_4.wav",0.1)
addSingleSound("zombie_death3","monster/zombie_death_2.wav",0.1)
addSingleSound("zombie_death4","monster/zombie_death_1.wav",0.1)



addRandomGroup("bash_hit",{{"bash_hit1.wav",0.1},{"bash_hit2.wav",0.1}})

--addSingleSound("bash_hit1","bash_hit2.wav",0.1)
addSingleSound("cut_hit1","cut_hit1.wav",0.1)
addSingleSound("stab_hit1","stab_hit1.wav",0.1)

addSingleSound("fire_9mm","gun/weapon_fire_9mm.wav",0.2)
addSingleSound("fire_762x39","gun/weapon_fire_762x39.wav",0.2)
addSingleSound("fire_762x51","gun/weapon_fire_762x51.wav",0.2)
addSingleSound("fire_arrow","gun/weapon_fire_arrow.wav",0.2)
addSingleSound("reload_pistol","gun/pistol_reload.wav",0.1)
addSingleSound("reload_rifle1","gun/rifle_reload1.wav",0.1)
addSingleSound("reload_rifle2","gun/rifle_reload2.wav",0.1)
addRandomGroup("ranged_hit_flesh",{{"gun/hit_flesh_1.wav",0.05},{"gun/hit_flesh_2.wav",0.05},{"gun/hit_flesh_3.wav",0.05}})
return soundlist