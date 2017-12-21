

local gmon = g.monster

local mondeath = {}
gmon.mondeath = mondeath




local function make_mon_corpse(mon,damageLvl)
  local corpse = g.itemFactory.make_mon_corpse(mon.type)
  g.map.addItemToSqaure(corpse,mon.x,mon.y,mon.z)
  
  --todo damage level
end




function mondeath.normal(mon)
  
  if player:seesUnit(mon)  and not mon.type.no_corpse_quiet then
    
    g.message.addmsg(string.format(tl("%s 死了!","The %s dies!"),mon:getName()))
    make_mon_corpse(mon,0) --需要确定damagelevel
    if mon.type.death_sound then
      if type(mon.type.death_sound)=="table" then
        g.playSound(mon.type.death_sound[rnd(1,#mon.type.death_sound)])
      else
        g.playSound(mon.type.death_sound)
      end
    end
  end
  
end