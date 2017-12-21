local list = {}

list[#list+1] =
{
  id = "fleet",
  name = "动作快慢",
  description = tl("你可以比别人跑得更快，速度增加15%。","You can move more quickly than most, resulting in a 15% speed bonus."),
  
  names = {
    [-3]=tl("全身僵化","Systemic rigid"),
    [-2]=tl("肌肉僵硬","Muscle stiffness"),
    [-1]=tl("行动迟缓","Slow action"),
    [1]=tl("动作敏捷","Quick"),
    [2]=tl("行动如风","Action like wind"),
    },
  descriptions= {
    [-3]=tl("你的全身肌肉非常不适合运动，你的速度下降30%。","Your systemic muscles are very slow to act.  Your speed 30% slower."),
    [-2]=tl("你的肌肉十分僵硬，你的速度下降20%。","Your muscles are very stiff.  Your speed 20% slower."),
    [-1]=tl("你的反应速度很慢，你的速度下降10%。","Your reaction is slow.  Your speed 10% slower."),
    [1]=tl("你的动作比多数人更快，你的速度增加10%。","You can act more quickly than most, resulting in a 10% speed bonus."),
    [2]=tl("你的行动速度飞快，看其他人都像慢动作。速度提高20%。","Your moves are fast and everyone else looks like slow motion. +20% speed."),
    },
  
  rating = "good",
  min_level = -3,--最小等级，负面状态？
  max_level = 2,--最大等级，可以有多层变异
  mod_data = {speed_percent = {[-3]=-30,[-2]=-20,[-1]=-10,[1]=10,[2]=20,}},
}




return list