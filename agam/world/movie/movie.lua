



local player_clips = {}


movie = {}

function movie.init()
  movie.plu = createUnit("player")--创建标准
  gameWorld.addToWorld(movie.plu)
end



function movie.pushPlayerWalkAction(fromX,fromY,toX,toY)
  local clip = Clip()
  clip.id = "move"
  clip.from_x,clip.from_y = fromX,fromY
  clip.to_x,clip.to_y  = toX,toY
  clip.host = g.player
  table.insert(player_clips,clip)
end

function movie.playerFaceDirection(x)
  if(x~=0)then 
    local face_right = x>0
    if(movie.plu.faceRight~= face_right) then movie.plu.faceRight = face_right end
  end
end



function movie.play(gtime)
  gtime = gtime/3
  for i= 1,#player_clips do 
    local pclip = player_clips[i]
    pclip:applyToUnit(gtime,movie.plu)
  end
  
  player_clips = {}
  keyControl.lockTime(gtime)
  
end







