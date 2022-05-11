pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--movement with inertia
--patreon.com/mboffin

--tab 0:basic game loop
--tab 1:player functions
--tab 2:collision functions

function _init()
	make_player()
end

function _update()
	move_player()
end

function _draw()
	cls()
	
	--draw the map from tile 0,0
	--at screen coordinate 0,0 and
	--draw 16 tiles wide and tall
	map(0,0,0,0,16,16)
	
	--draw the player's sprite at
	--p.x,p.y
	spr(player.sprite,player.x,player.y)
	
	-- print('player x-1 '..player.x, 10, 10, 8)
	-- print('player y '..player.y)
	-- print('mapx '..map_x)
	-- print('mapy '..map_y)
	-- print("hello owen")
end
-->8
--player functions

function make_player()
	player={}  --create empty table
	
	player.x = 24 --player's exact pixel
	player.y = 24 --position on screen
	
	-- track how much player trying to move left/right and up/down
	-- old variables: dx+dy
	player.direction_x = 0
	player.direction_y = 0    
	
	-- old variables: p.w, p.h
	player.width = 7
	player.height = 7

	player.sprite = 5
	
	-- old variables: p.xspd, p.yspd
	player.max_x_speed = 3
	player.max_y_speed = 3	
	
	-- old variables: p.a
	player.acceleration = 1	
	
	-- 1 = no slow down, 0 = instant halt
	-- old variables: p.drg
	player.drag = 0.85
end

function move_player()
	--when the user tries to move, only add the acceleration to the current speed.
	if (btn(⬅️)) player.direction_x -= player.acceleration
	if (btn(➡️)) player.direction_x += player.acceleration
	if (btn(⬆️)) player.direction_y -= player.acceleration
	if (btn(⬇️)) player.direction_y += player.acceleration	
	
	-- max negative speed, player direction, max positive speed
	-- quite clever. so if player.direction tries to exceed max, we refer to either - or + max instead
	-- essentially we ignore what player trying to do, until speed reduces
 	player.direction_x = mid(-player.max_x_speed,player.direction_x,player.max_x_speed)
 	player.direction_y = mid(-player.max_y_speed,player.direction_y,player.max_y_speed)


 --before doing any movement,
 --just check if they are next
 --to a wall, and if so, don't
 --let allow movement in that
 --direction.
 wall_check(player)

 -- check player isn't trying to move into a solid object
 if (can_move(player,player.direction_x,player.direction_y)) then
  
  --actually move the player to
  --the new location
  player.x += player.direction_x
  player.y += player.direction_y
  
 --but if the player cannot move
 --into that spot, find out how
 --close they can get and move
 --them there instead.
 else
 
  --create temporary variables
  --to store how far the player
  --is trying to move.
  -- old varibales tdx, tdy
  temp_direction_x = player.direction_x
  temp_direction_y = player.direction_y
  
  --now we're going to make
  --tdx,tdy shorter and shorter
  --until we find a new position
  --that the player can move to.
  while (not can_move(player,temp_direction_x,temp_direction_y)) do
  	
  	--if the amount of x movement
  	--has been shortened so much
  	--that it's practically 0,
  	--just set it to 0.
  	if (abs(temp_direction_x) <= 0.1) then
  	 temp_direction_x = 0
  	
  	--but if it's not too small,
  	--make it 90% of what it was
  	--before. (this shortens the
  	--amount the player is trying
  	--to move in that direction.)
  	else
  	 temp_direction_x *= 0.9
  	end
  	
  	--do the same thing for y
  	--movement.
  	if (abs(temp_direction_y) <= 0.1) then
  	 temp_direction_y = 0
  	else
  	 temp_direction_y *= 0.9
  	end
  	  	
  end

  --now that we've shorted the
  --distance the player is
  --trying to move to something
  --actually possible, actually
  --move the player to that new
  --shortened distance.
  player.x += temp_direction_x
  player.y += temp_direction_y

 end 
 
 --if the player's still moving,
 --then slow them down just a
 --bit using the drag amount.
 --this actually takes effect whilst player trying
 --to move, so i think it should only be
 --used if player not pressing a button otherwise
 --player cant reach top speed
 if (abs(player.direction_x) > 0) player.direction_x *= player.drag
 if (abs(player.direction_y) > 0) player.direction_y *= player.drag
 
 --if they are going slow enough
 --in a particular direction,
 --just bring them to a halt.
 if (abs(player.direction_x)<0.02) player.direction_x = 0
 if (abs(player.direction_y)<0.02) player.direction_y = 0
	
end
-->8
--collision functions

--this function takes an object and a speed in the x and y directions. it uses those
--to check the four corners of the object to see it can move into that spot. (a map tile
--marked as solid would prevent movement into that spot.)
function can_move(object,direction_x,direction_y)
	
	--create variables for the
	--left, right, top, and bottom
	--coordinates of where the
	--object is trying to be.
	local nx_l = object.x + direction_x       --lft
	local nx_r = object.x + direction_x + object.width   --rgt
	local ny_t = object.y + direction_y       --top
	local ny_b = object.y + direction_y + object.height   --btm

	--now check each corner of
	--where the object is trying to
	--be and see if that spot is
	--solid or not.
	local top_left_solid=solid(nx_l,ny_t)
	local btm_left_solid=solid(nx_l,ny_b)
	local top_right_solid=solid(nx_r,ny_t)
	local btm_right_solid=solid(nx_r,ny_b)

	--if all of those locations are
	--not solid, the object can
	--move into that spot.
	return not (top_left_solid or
													btm_left_solid or
													top_right_solid or
													btm_right_solid)
end

--checks an x,y pixel coordinate
--against the map to see if it 
--can be walked on or not
function solid(x,y)

 --pixel coords -> map coords
 -- ***** add local back to these ******
 map_x = flr(x/8)
 map_y = flr(y/8)
 
 --what sprite is at that spot?
 local map_sprite=mget(map_x,map_y)
 
 --what flag does it have?
 local flag=fget(map_sprite)

 --if the flag is 1, it's solid
 return flag==1
end

--this checks to see if the
--player is next to a wall. if
--so, don't let them try to move
--in that direction.
function wall_check(player)
 
 --going left?
 if (player.direction_x < 0) then
  --check both left corners for
  --a wall.
  local wall_top_left=solid(player.x-1,player.y)
  local wall_btm_left=solid(player.x-1,player.y + player.height)

  --if there is a wall in that
  --direction, set x movement
  --to 0.
  if (wall_top_left or wall_btm_left) then
   player.direction_x = 0
  end
  
 --going right?
 elseif (player.direction_x > 0) then
  --check both right corners for
  --a wall.
  local wall_top_right=solid(player.x+player.width+1,player.y)
  local wall_btm_right=solid(player.x+player.width+1,player.y+player.height)

  --if there is a wall in that
  --direction, set x movement
  --to 0.
  if (wall_top_right or wall_btm_right) then
   player.direction_x = 0
  end
 end

 --going up?
 if (player.direction_y < 0) then
  --check both top corners for
  --a wall.
  local wall_top_left=solid(player.x,player.y-1)
  local wall_top_right=solid(player.x+player.width,player.y-1)

  --if there is a wall in that
  --direction, set y movement
  --to 0.
  if (wall_top_left or wall_top_right) then
   player.direction_y = 0
  end
  
 --going down?
 elseif (player.direction_y > 0) then
  --check both bottom corners 
  --for a wall.
  local wall_btm_left=solid(player.x,player.y+player.height+1)
  local wall_btm_right=solid(player.x,player.y+player.height+1)

  --if there is a wall in that
  --direction, set y movement
  --to 0.
  if (wall_btm_right or wall_btm_left) then
   player.direction_y = 0
  end
 end

 --the two commented lines of 
 --code below do the same thing
 --as all the lines of code 
 --above, but are just condensed
	
	--if ((a.dx<0 and (solid(a.x-1,a.y) or solid(a.x-1,a.y+a.h-1))) or (a.dx>0 and (solid(a.x+a.w,a.y) or solid(a.x+a.w,a.y+a.h-1)))) p.dx=0
	--if ((a.dy<0 and (solid(a.x,a.y-1) or solid(a.x+a.h-1,a.y-1))) or (a.dy>0 and (solid(a.x,a.y+a.h) or solid(a.x+a.w-1,a.y+a.h)))) p.dy=0
end
__gfx__
00000000333333437777777711111111656665660cccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000033333333766666651111111155555555cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
007007003343333376666665111cc11166656665cc77c77c00000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700033333333766666651111111155555555cc71c71c00000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000333333437666666511cc1cc165666566cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700333333337666666511111111555555551cccccc100000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000334333337666666511111111666566651111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333335555555511111111555555550540054000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
65666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
66656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
65666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
66656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
65666566333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334365666566
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
66656665334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333366656665
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
65666566333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334365666566
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
66656665334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333366656665
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
65666566333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334365666566
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
66656665334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333366656665
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
65666566333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334365666566
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
66656665334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333366656665
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
65666566333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334365666566
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
66656665334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333366656665
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
65666566333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334365666566
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
66656665334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333366656665
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
65666566333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334365666566
5555555533333cccccc3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
666566653343cccccccc333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333366656665
555555553333cc77c77c333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
656665663333cc71c71c334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334365666566
555555553333cccccccc333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
6665666533431cccccc1333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333366656665
55555555333311111111333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
65666566333335433543334377777777777777777777777777777777333333433333334377777777777777777777777777777777333333433333334365666566
55555555333333333333333376666665766666657666666576666665333333333333333376666665766666657666666576666665333333333333333355555555
66656665334333333343333376666665766666657666666576666665334333333343333376666665766666657666666576666665334333333343333366656665
55555555333333333333333376666665766666657666666576666665333333333333333376666665766666657666666576666665333333333333333355555555
65666566333333433333334376666665766666657666666576666665333333433333334376666665766666657666666576666665333333433333334365666566
55555555333333333333333376666665766666657666666576666665333333333333333376666665766666657666666576666665333333333333333355555555
66656665334333333343333376666665766666657666666576666665334333333343333376666665766666657666666576666665334333333343333366656665
55555555333333333333333355555555555555555555555555555555333333333333333355555555555555555555555555555555333333333333333355555555
65666566333333433333334377777777111111111111111177777777333333433333334377777777111111111111111177777777333333433333334365666566
55555555333333333333333376666665111111111111111176666665333333333333333376666665111111111111111176666665333333333333333355555555
66656665334333333343333376666665111cc111111cc11176666665334333333343333376666665111cc111111cc11176666665334333333343333366656665
55555555333333333333333376666665111111111111111176666665333333333333333376666665111111111111111176666665333333333333333355555555
6566656633333343333333437666666511cc1cc111cc1cc17666666533333343333333437666666511cc1cc111cc1cc176666665333333433333334365666566
55555555333333333333333376666665111111111111111176666665333333333333333376666665111111111111111176666665333333333333333355555555
66656665334333333343333376666665111111111111111176666665334333333343333376666665111111111111111176666665334333333343333366656665
55555555333333333333333355555555111111111111111155555555333333333333333355555555111111111111111155555555333333333333333355555555
65666566333333433333334377777777111111111111111177777777333333433333334377777777111111111111111177777777333333433333334365666566
55555555333333333333333376666665111111111111111176666665333333333333333376666665111111111111111176666665333333333333333355555555
66656665334333333343333376666665111cc111111cc11176666665334333333343333376666665111cc111111cc11176666665334333333343333366656665
55555555333333333333333376666665111111111111111176666665333333333333333376666665111111111111111176666665333333333333333355555555
6566656633333343333333437666666511cc1cc111cc1cc17666666533333343333333437666666511cc1cc111cc1cc176666665333333433333334365666566
55555555333333333333333376666665111111111111111176666665333333333333333376666665111111111111111176666665333333333333333355555555
66656665334333333343333376666665111111111111111176666665334333333343333376666665111111111111111176666665334333333343333366656665
55555555333333333333333355555555111111111111111155555555333333333333333355555555111111111111111155555555333333333333333355555555
65666566333333433333334377777777111111111111111177777777333333433333334377777777111111111111111177777777333333433333334365666566
55555555333333333333333376666665111111111111111176666665333333333333333376666665111111111111111176666665333333333333333355555555
66656665334333333343333376666665111cc111111cc11176666665334333333343333376666665111cc111111cc11176666665334333333343333366656665
55555555333333333333333376666665111111111111111176666665333333333333333376666665111111111111111176666665333333333333333355555555
6566656633333343333333437666666511cc1cc111cc1cc17666666533333343333333437666666511cc1cc111cc1cc176666665333333433333334365666566
55555555333333333333333376666665111111111111111176666665333333333333333376666665111111111111111176666665333333333333333355555555
66656665334333333343333376666665111111111111111176666665334333333343333376666665111111111111111176666665334333333343333366656665
55555555333333333333333355555555111111111111111155555555333333333333333355555555111111111111111155555555333333333333333355555555
65666566333333433333334377777777111111111111111177777777333333433333334377777777111111111111111177777777333333433333334365666566
55555555333333333333333376666665111111111111111176666665333333333333333376666665111111111111111176666665333333333333333355555555
66656665334333333343333376666665111cc111111cc11176666665334333333343333376666665111cc111111cc11176666665334333333343333366656665
55555555333333333333333376666665111111111111111176666665333333333333333376666665111111111111111176666665333333333333333355555555
6566656633333343333333437666666511cc1cc111cc1cc17666666533333343333333437666666511cc1cc111cc1cc176666665333333433333334365666566
55555555333333333333333376666665111111111111111176666665333333333333333376666665111111111111111176666665333333333333333355555555
66656665334333333343333376666665111111111111111176666665334333333343333376666665111111111111111176666665334333333343333366656665
55555555333333333333333355555555111111111111111155555555333333333333333355555555111111111111111155555555333333333333333355555555
65666566333333433333334377777777777777777777777777777777333333433333334377777777777777777777777777777777333333433333334365666566
55555555333333333333333376666665766666657666666576666665333333333333333376666665766666657666666576666665333333333333333355555555
66656665334333333343333376666665766666657666666576666665334333333343333376666665766666657666666576666665334333333343333366656665
55555555333333333333333376666665766666657666666576666665333333333333333376666665766666657666666576666665333333333333333355555555
65666566333333433333334376666665766666657666666576666665333333433333334376666665766666657666666576666665333333433333334365666566
55555555333333333333333376666665766666657666666576666665333333333333333376666665766666657666666576666665333333333333333355555555
66656665334333333343333376666665766666657666666576666665334333333343333376666665766666657666666576666665334333333343333366656665
55555555333333333333333355555555555555555555555555555555333333333333333355555555555555555555555555555555333333333333333355555555
65666566333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334365666566
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
66656665334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333366656665
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
65666566333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334365666566
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
66656665334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333366656665
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
65666566333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334365666566
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
66656665334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333366656665
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
65666566333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334365666566
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
66656665334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333366656665
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
65666566333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334365666566
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
66656665334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333366656665
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
65666566333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334365666566
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
66656665334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333366656665
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
65666566333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334365666566
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
66656665334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333366656665
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
65666566333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334365666566
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
66656665334333333343333333433333334333333343333333433333334333333343333333433333334333333343333333433333334333333343333366656665
55555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555555
65666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
66656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
65666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
66656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555

__gff__
0000010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010101010101010101010101010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010101010101010101010101010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010101010101010101010101010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010101010101010101010101010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010202020201010202020201010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010203030201010203030201010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010203030201010203030201010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010203030201010203030201010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010203030201010203030201010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010202020201010202020201010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010101010101010101010101010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010101010101010101010101010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010101010101010101010101010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010101010101010101010101010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0006000007550095501d500205001b5001f5000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
