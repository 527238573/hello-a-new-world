
local function flagt(ftable)
  local nt = {}
  for k,v in ipairs(ftable) do
    nt[v] = true
  end
  return nt
end



local list = {}

list[#list+1] = {
  id = "zombie_debug",
  name = tl("测试丧尸","debug zombie"),
  description="This monster exists only for testing purposes.",
  anim_id = "zombie1",
  species="ZOMBIE",
  default_faction="zombie",
  size = 3, --1，TINY 2 SMALL，3 MEDIUM，4 LARGE，5 HUGE
  material = "flesh",
  diff=3,
  aggression=100,
  morale=100,
  speed=70,
  hp=80,
  melee_skill=4,
  melee_dice=2,
  melee_dice_sides=3,
  melee_cut=0,
  dodge=0,
  defence = 0,--防御挨打等级
  armor_bash=0,
  armor_cut=0,
  armor_stab=0,
  armor_acid=0,
  armor_fire=0,
  vision_day=40,
  vision_night=3,
  flags=flagt{"SEES", "HEARS", "SMELLS", "STUMBLES", "WARM", "BASHES", "GROUP_BASH", "POISON", "BLEED", "NO_BREATHE", "REVIVES", "BONES", "PUSH_MON"},
  death_drops="default_zombie_death_drops",
  death_sound = {"zombie_death1","zombie_death2","zombie_death3","zombie_death4"},
  attack_sound = {"zombie_hit1","zombie_hit2","zombie_hit3","zombie_hit4",chance = 0.4},
};


return list