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
	map(0,0,0,0,16,16)
	spr(player.sprite,player.x,player.y)		
end
-->8
--player functions

function log(text,overwrite)
		printh(text, "log", overwrite)	
end

function make_player()
	player={}  --create empty table
	
	-- I believe this is all stored in a table as it's using a dot operator
	player.x = 8 --player's exact pixel
	player.y = 8 --position on screen	
	
	-- track how much player trying to move left/right and up/down
	player.direction_x = 0
	player.direction_y = 0	

	player.width = 7
	player.height = 7
	player.sprite = 5
	
	player.max_x_speed = 3
	player.max_y_speed = 3	
	player.acceleration = 1	
	player.drag = 0.85 -- 1 = no slow down, 0 = instant halt
end

function move_player()
	--when the user tries to move, only add the acceleration to the current speed.
	if (btn(⬅️)) player.direction_x -= player.acceleration 
	if (btn(➡️)) player.direction_x += player.acceleration
	if (btn(⬆️)) player.direction_y -= player.acceleration
	if (btn(⬇️)) player.direction_y += player.acceleration	
	
	-- max negative speed, player direction, max positive speed
	-- So if player.direction tries to exceed max, we refer to either - or + max instead
	-- essentially we ignore what player trying to do, until speed reduces
 	player.direction_x = mid(-player.max_x_speed,player.direction_x,player.max_x_speed)
 	player.direction_y = mid(-player.max_y_speed,player.direction_y,player.max_y_speed)

 -- call check_if_next_to_wall function for collision before letting player move
 check_if_next_to_wall(player)

 -- check player isn't trying to move into a solid object
 if (can_move(player, player.direction_x, player.direction_y)) then
  
  --actually move the player to the new location
  player.x += player.direction_x
  player.y += player.direction_y
  
 -- if player cannot move there, find out how close they can get and move them there instead.
 else 
  --create temporary variables to store how far the player is trying to move
  temp_direction_x = player.direction_x
  temp_direction_y = player.direction_y
  
  --make tempx,tempy shorter and shorter until we find a new position the player can move to
  while (not can_move(player,temp_direction_x,temp_direction_y)) do
  	
  	--if x movement has been shortened so much that it's practically 0, set it to 0
  	if (abs(temp_direction_x) <= 0.1) then
  	 temp_direction_x = 0  	
  	--but if it's not too small, make it 90% of what it was before. 
	-- this shortens the amount the player is trying to move in that direction.
  	else
  	 temp_direction_x *= 0.9
  	end
  	
  	--do the same thing for y movement
  	if (abs(temp_direction_y) <= 0.1) then
  	 temp_direction_y = 0
  	else
  	 temp_direction_y *= 0.9
  	end  	  	
  end

  --now we've found a distance the player can move, actually move them there
  player.x += temp_direction_x
  player.y += temp_direction_y
 end 
 
 -- if the player's still moving, then slow them down just a bit using the drag amount.
 -- Note: this actually takes effect whilst player trying to move, so I think it should only be
 -- used if player not pressing a button otherwise player cant reach top speed
 if (abs(player.direction_x) > 0) player.direction_x *= player.drag
 if (abs(player.direction_y) > 0) player.direction_y *= player.drag
 
 --if they are going slow enough in a particular direction, bring them to a halt.
 if (abs(player.direction_x)<0.02) player.direction_x = 0
 if (abs(player.direction_y)<0.02) player.direction_y = 0
	
end
-->8
--collision functions

--this function takes an object (only player currently) and it's x,y speed. Tt uses these
--to check the four corners of the object to see it can move into that spot. (a map tile
--marked as solid would prevent movement into that spot.)
function can_move(object,direction_x,direction_y)
	
	-- store left, right, top and bottom corner coordinates of location the player/object wants to move
	-- object.? is where they ARE, direction_? is where they want to move (based on key press)
	-- Note: Not performant as occurs 30 times per second even if the player not moving or near an object
	-- Note: Also this is missing bottom right coordinate but appears to be OK...?

	-- BUG: there is a bug where you get stuck on edge if moving diagonal down/left
	local next_left = object.x + direction_x	
	local next_right = object.x + direction_x + object.width
	local next_top = object.y + direction_y
	local next_bottom = object.y + direction_y + object.height

	-- now check each corner of where the object is trying to move and check if solid
	local top_left_solid = solid(next_left, next_top)
	local btm_left_solid = solid(next_left, next_bottom)
	local top_right_solid = solid(next_right, next_top)
	local btm_right_solid = solid(next_right, next_bottom)

	--if all of those locations are NOT solid, the object can move into that spot.
	-- this is why it's return NOT so we get (I think) a true returned as if all 4 are false we can move there
	return not (top_left_solid or btm_left_solid or	top_right_solid or btm_right_solid)
end

--checks x,y of player/object against the map to see if sprite marked as solid
function solid(x,y)

 -- divide x,y by 8 to get map coordinates.
 local map_x = flr(x/8)
 local map_y = flr(y/8)
 
 -- find what sprite is at that map x,y
 local map_sprite = mget(map_x,map_y)
 
 -- and get what flag it has set
 local flag = fget(map_sprite)

 --if the flag is 1 return true as it's solid
 return flag == 1
 
end

--if player next to a wall stop them moving in that direction
function check_if_next_to_wall(player)
 
 -- player moving left
 if (player.direction_x < 0) then
  --check both left corners for a wall
  local wall_top_left = solid(player.x -1, player.y)
  local wall_btm_left = solid(player.x -1, player.y + player.height)
  -- if wall in that direction, set x movement to 0
  if (wall_top_left or wall_btm_left) then
   player.direction_x = 0
  end
  
 -- player moving right
 elseif (player.direction_x > 0) then
  --check both right corners for a wall
  local wall_top_right = solid(player.x + player.width + 1, player.y)
  local wall_btm_right = solid(player.x + player.width + 1, player.y + player.height)
  --if there is a wall in that direction, set x movement to 0
  if (wall_top_right or wall_btm_right) then
   player.direction_x = 0
  end
 end

 -- player moving up
 if (player.direction_y < 0) then
  --check both top corners for a wall
  local wall_top_left = solid(player.x, player.y - 1)
  local wall_top_right = solid(player.x + player.width, player.y - 1)
  --if there is a wall in that direction, set y movement to 0
  if (wall_top_left or wall_top_right) then
   player.direction_y = 0
  end
  
 -- player moving down
 elseif (player.direction_y > 0) then
  --check both bottom corners for a wall
  local wall_btm_left = solid(player.x, player.y + player.height + 1)
  local wall_btm_right = solid(player.x, player.y + player.height + 1)
  --if there is a wall in that direction, set y movement to 0
  if (wall_btm_right or wall_btm_left) then
   player.direction_y = 0
  end
 end 
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
0401010101010201010203030201010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010202010201010203030201010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0402020202010201020203030201010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0402010101010201020203030201010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0402010202020201020202020201010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0402010101010101020101010101010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0402020202020202020101010101010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010101010101010101010101010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010101010101010101010101010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0006000007550095501d500205001b5001f5000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
