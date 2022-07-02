pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--[[  
** REMINDERS **
CONTROL +K +J = unfold all
CONTROL +K +1 = fold at level 1 
U, D, L, R, O, and X are the buttons (up, down, left, right, o-button, x-button) 
CTRL + X deletes a line of code!
--]]

-- Furlock Bones: Consulting Dogtective --

--init, update and draw functions
function _init()
	-- debug_mode = false
	camera_x = 0
	camera_y = 0
	activeGame = false
	anim_time = 0
	anim_wait = 0.1	
	owl_time = 0
	owl_wait = 1
	map_swapper()
	create_player()
	create_brian()
	create_owl()
	create_signs()
	init_conversation_text()		
	poke(0x5f5c, 255) -- this means a held button (btnp) only registers once
	readingSign = false	
	notNowBrian = false
	current_map_maximum_x = 624
	current_map_maximum_y = 248	
	track_1start = 0 -- this indicates the point in the music the track starts
	track_2start = 11
	musicState = 'start' -- used for music, seems bizarely complex!
	show_inventory = false
end

-- map compress related, try to add to function or init
_n = nil _={}
_[0] = false 
_[1] = true

function _update60()
	musicControl()
	if activeGame == true  then 
		animate_player()
		animate_owl()
		if show_inventory == false then
			move_player() -- MUST be before camera_follow_player
		end
		camera_follow_player() -- MUST be after move_player
		conversation_system()
		move_brian()
		doMapStuff()
		view_inventory()
	else -- if on menu then start game
		if (btnp(❎)) then activeGame = true end
	end	
end

function _draw()
	cls()	
	if activeGame == false then draw_menu() end
	if activeGame == true then draw_game() end	
			
	--print("y: "..player.y,player.x,player.y-10,8)
	--print("camy: "..camera_y)
	--print("convo: "..conversation_state)
	--print(camera_x,50,0)
	--print(camera_y)
	
end

function draw_menu()	
	format_text_centered(text_array, 7) -- display menu text	
end

function draw_game()
	if show_inventory == false then
		camera(camera_x,camera_y) -- run before map to avoid inventory stutter
		map(0,0,0,0,128,32) -- draw game level
		spr(player.sprite,player.x,player.y,1,1,player.direction==-1)		
		spr(brian.sprite,brian.x,brian.y,1,1,brian.direction==-1)
		spr(owl.sprite,owl.x,owl.y,1,1,1)
		spr(sign1.sprite,sign1.x,sign1.y,1,1,1)
		spr(sign2.sprite,sign2.x,sign2.y,1,1,1)
		if text.active == true then draw_conversation()	end
	end
	if show_inventory == true then
		rectfill(0, 0, 127, 127, 6) -- fill screen
		rect(0, 0, 127, 127, 3) -- screen border 
		rect(0, 0, 127, 6, 3) -- top heading
		string = "inventory"
		print(string,64 - (#string * 2),1,7) -- heading text
		--[[]
			x0, y0, x1, y1
			x0 = x upper left
			y0 = y upper left
			x1 = x lower right
			y1 = x lower right
			so to visualise this you are ONLY placing those 2 corners, after which the 
			rectangle is drawn between them. Also the x1 and y1 start from the x0,y0 position
			whereas x0,y0 start from 0,0
		]]
		rect(5, 50, 50, 70, 11) -- sentence start
	end 	
end

function display_book_sentences()	
	-- determine longest line of text
	local maxTextWidth = 0
	for i=1, #text.string do 
		if #text.string[i] > maxTextWidth then -- loop through array and find longest text element
			maxTextWidth = #text.string[i] -- set max width to longest element so box wide enough
		end
	end

	-- define textbox with border
	local textbox_x = camera_x + 64 - maxTextWidth *2 -1 -- -1 for border and centred

	-- if player close to screen bottom, draw text box at top, else draw at bottom
	if (player.y < 200) then
		textbox_y = camera_y + 100 -- controls vertical location of text box (0 top, 127 bottom)
	else
		textbox_y = camera_y + 5 -- controls vertical location of text box (0 top, 127 bottom)
	end	
	
	local textbox_width = textbox_x+(maxTextWidth*4)  -- *4 to account for character width
	local textbox_height = textbox_y + #text.string * 6 -- *6 for character height

	-- draw outer border text box
	rectfill(textbox_x-2, textbox_y-2, textbox_width+2, textbox_height+2, 0)
	rectfill(textbox_x, textbox_y, textbox_width, textbox_height, 12)

	-- write text
	for i=1, #text.string do  -- the # gets the legnth of the array 'text'
		local txt = text.string[i]
		-- local tx = textbox_x +1 -- add 1 pixel of outside of box and text
		local tx = camera_x + 64 - #txt * 2 -- centre text based on length of string txt
		local ty = textbox_y -5+(i*6) -- padding for top of box but because for loop starts at 1 we need to subtract 5		
		if (conversation_state == "start") and i == 1 
		 or (conversation_state == "sign") and i == 1 
		 then 
			print(txt, tx, ty, 7) -- print first text line white
		else
			print(txt, tx, ty, 1)
		end
	end
end

function character_arrays()
	-- characters = {} -- create empty object/array to store all characters

	-- frodo = {} -- create empty object/array for a specific character
	-- frodo.name = "frodo baggins" -- populate the object with various parameters
	-- frodo.age =  46
	-- frodo.hp = 10
	-- frodo.str = 7
	-- frodo.x = 100
	-- frodo.y = 50

	-- gandalf = {} -- create empty object/array/table for a specific character
	-- gandalf.name = "gandalf the grey" -- populate the object with various parameters
	-- gandalf.age =  46
	-- gandalf.hp = 10
	-- gandalf.str = 7
	-- gandalf.x = 200
	-- gandalf.y = 99

	-- characters[1] = frodo	-- add frodo to the character 
	-- characters[2] = gandalf

	-- for i=1, #characters do		
	-- 	print(characters[i].name)
	-- end

	-- t = {}
	-- print(t)
end

function view_inventory()
	if (btnp(🅾️)) and show_inventory == false then
		show_inventory = true
		camera(0,0) -- move camera to 0,0 as we always display inventory here
	elseif (btnp(🅾️)) and show_inventory == true then
		show_inventory = false
	end
end


-->8
--player functions
function create_player() 
	player={}  --create empty table -- this means we're creating the player as an object!
	player.x = 40 -- 40 = house, 432 = owl (map location x8 for exact pixel location)
	player.y = 40
	player.direction = 1
	player.velocity_x = 0
	player.velocity_y = 0	
	player.max_x_speed = 1
	player.max_y_speed = 1	
	player.acceleration = 0.2
	player.drag = 0.7 -- 1 = no slow down, 0 = instant halt
	player.width = 7
	player.height = 7
	player.sprite = 1
end

function animate_player()
	if player.velocity_x != 0 or player.velocity_y != 0 then
		if time() - anim_time > anim_wait then
			player.sprite += 1
			anim_time = time()
			if (player.sprite > 4 ) then
				player.sprite = 1
			end
		end	
	else
		anim_time = 0
		player.sprite = 1
	end
end

function move_player()	
	if conversation_state != "level1" then	-- if talking then don't walk away, it's rude.
		--when the user tries to move, only add the acceleration to the current speed.
		if (btn(⬅️)) then 
			player.velocity_x -= player.acceleration
			player.direction = -1
		end
		if (btn(➡️)) then 
			player.velocity_x += player.acceleration
			player.direction = 1
		end
		if (btn(⬆️)) then 
			player.velocity_y -= player.acceleration		
		end
		if (btn(⬇️)) then 
			player.velocity_y += player.acceleration		
		end

		-- max negative speed, player direction, max positive speed
		-- So if player.direction tries to exceed max, we refer to either - or + max instead
		-- essentially we ignore what player trying to do, until speed reduces
		player.velocity_x = mid(-player.max_x_speed,player.velocity_x,player.max_x_speed)
		player.velocity_y = mid(-player.max_y_speed,player.velocity_y,player.max_y_speed)

		-- if player still moving
		if (player.velocity_x != 0) or (player.velocity_y != 0) then

			-- call check_if_next_to_wall function for collision before letting player move
			-- essentially this allows play to move diaganolly along a solid object, as without this
			-- the can_move code prevents them moving
			check_if_next_to_wall(player)

			-- check player isn't trying to move into a solid object
			if (can_move(player, player.velocity_x, player.velocity_y)) then
				--actually move the player to the new location
				player.x += player.velocity_x
				player.y += player.velocity_y
				
			-- if player cannot move there, find out how close they can get and move them there instead.
			else 
				--create temporary variables to store how far the player is trying to move
				temp_direction_x = player.velocity_x
				temp_direction_y = player.velocity_y
				
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
		end	
	end
 
	-- if the player's still moving, then slow them down just a bit using the drag amount.
	-- Note: this actually takes effect whilst player trying to move, so I think it should only be
	-- used if player not pressing a button otherwise player cant reach top speed
	if (abs(player.velocity_x) > 0) player.velocity_x *= player.drag
	if (abs(player.velocity_y) > 0) player.velocity_y *= player.drag
	
	--if they are going slow enough in a particular direction, bring them to a halt.
	if (abs(player.velocity_x)<0.02) player.velocity_x = 0
	if (abs(player.velocity_y)<0.02) player.velocity_y = 0	
end

function camera_follow_player()
	if player.x > 60 and player.x <= (current_map_maximum_x -60) then 
		camera_x = player.x - 60
	end
	if player.y > 60 and player.y <= (current_map_maximum_y-60) then
		camera_y = player.y - 60
	end
end


-->8
-- character functions
function create_brian()
	brian={}
	brian.x = 74
	brian.y = 24
	brian.sprite = 22
	brian.speed = 0.3
	brian.direction = -1	
end

function move_brian()
	if (brian_collision(player.x,player.y,brian.x,brian.y)) == true then 
		-- this just stops Brian moving any closer and stops him pestering for a while		
	else
		-- check that Brian hasn't recently pestered player
		if notNowBrian == true then
			if (time() >= brianWaiting +20 ) then
				notNowBrian = false
			else return end
		else
			if player.x < brian.x then
				brian.x -= brian.speed
				brian.direction = -1
			end 
			if player.x > brian.x then	 	
				brian.x += brian.speed
				brian.direction = 1
			end 
			if player.y < brian.y then
				brian.y -= brian.speed
			end 
			if player.y > brian.y then
				brian.y += brian.speed
			end
		end
	end
end

function create_owl()
	owl={}
	owl.x = 476
	owl.y = 8
	owl.sprite = 5
end

function animate_owl()
	-- eliza says owl should NOT move if you're talking to him
	if player.x > 430 then
		if time() - owl_time > owl_wait then
			owl.sprite += 1
			owl_time = time()
			if (owl.sprite > 8 ) then -- owl flaps wings to pass the time
				owl.sprite = 6
			end
		end			
		if text.character == "owl" and conversation_state != "start" then
			owl.sprite = 5 -- owl sits down when talking
		end
	end
end

function create_signs()
	sign1={}
	sign1.x = 308
	sign1.y = 16
	sign1.sprite = 20	
	sign2={}
	sign2.x = 416
	sign2.y = 16
	sign2.sprite = 19
end


-->8
-- player collision functions
function check_if_next_to_wall(player)
	-- if player next to a wall stop them moving in that direction
	-- essentially this allows player to move along a wall holding two buttons. e.g. up and left
	-- what happens is that we ignore the left movement as it is set to zero meaning that we only
	-- apply the vertical movement. It's really just a player UX fix.
	-- player moving left
	if (player.velocity_x < 0) then
		--check both left corners for a wall
		local wall_top_left = solid(player.x -1, player.y)
		local wall_btm_left = solid(player.x -1, player.y + player.height)
		-- if wall in that direction, set x movement to 0
		if (wall_top_left or wall_btm_left) then
			player.velocity_x = 0
		end

	-- player moving right
	elseif (player.velocity_x > 0) then		
		local wall_top_right = solid(player.x + player.width + 1, player.y)
		local wall_btm_right = solid(player.x + player.width + 1, player.y + player.height)		
		if (wall_top_right or wall_btm_right) then
			player.velocity_x = 0
		end
	end

	-- player moving up
	if (player.velocity_y < 0) then		
		local wall_top_left = solid(player.x, player.y - 1)
		local wall_top_right = solid(player.x + player.width, player.y - 1)		
		if (wall_top_left or wall_top_right) then
			player.velocity_y = 0
		end

	-- player moving down
	elseif (player.velocity_y > 0) then		
		local wall_btm_left = solid(player.x, player.y + player.height + 1)
		local wall_btm_right = solid(player.x, player.y + player.height + 1)		
		if (wall_btm_right or wall_btm_left) then
			player.velocity_y = 0
		end
	end 
end

function can_move(object,direction_x,direction_y)
	--this function takes an object (only player currently) and it's x,y speed. It uses these
	--to check the four corners of the object to see it can move into that spot. (a map tile
	--marked as solid would prevent movement into that spot.)
	-- capture x,y coords for where trying to move
	local next_left = object.x + direction_x	
	local next_right = object.x + direction_x + object.width
	local next_top = object.y + direction_y
	local next_bottom = object.y + direction_y + object.height	
	-- BUG: getting stuck on edge if moving diagonal down/left (might be in check_if_next_to_a_wall)

	-- get x,y for each corner based on where trying to move, then use solid to convert that to a 
	-- map tile location and check if any solid sprites there
	local top_left_solid = solid(next_left, next_top)
	local btm_left_solid = solid(next_left, next_bottom)
	local top_right_solid = solid(next_right, next_top)
	local btm_right_solid = solid(next_right, next_bottom)

	--if all of those locations are NOT solid, the object can move into that spot.
	-- this is why it's return NOT so we get (I think) a true returned as if all 4 are false we can move there
	return not (top_left_solid or btm_left_solid or	top_right_solid or btm_right_solid)
end

function solid(x,y)	
	--checks x,y of player/object against the map to see if sprite marked as solid
	-- divide x,y by 8 to get map coordinates
	local map_x = flr(x/8)
	local map_y = flr(y/8)	
	local map_sprite = mget(map_x,map_y) -- find what sprite is at that map x,y	
	local flag = fget(map_sprite) -- and get what flag it has set	
	if flag == 1 then		
		return flag == 1 -- I'm using the first flag (1) for solid objects
	end		
end

function brian_collision(playerx,playery,charx,chary)
	if charx +10 > playerx and charx < playerx +10 and chary +10 > playery and chary < playery +10 then
	brian.speed = 0
  		if conversation_state == "none" then			
			conversation_state = "start"
			text.character = "brian"
			notNowBrian = true
			brianWaiting = time()
		end 
	else
		if text.character == "brian" then -- if player walks away instead of starting conversation			
			brian.speed = 0.2	 	
			conversation_state = "none"
			text.character = "nobody"
			text.active = false
		end
 	end
end

function owl_collision(playerx,playery,charx,chary)
	if charx +10 > playerx and charx < playerx +18 and chary +56 > playery and chary < playery +10 then
  		if conversation_state == "none" then			
			conversation_state = "start"
			text.character = "owl"
		end 
	else
		if text.character == "owl" then -- if player walks away instead of starting conversation			
			conversation_state = "none"
			text.character = "nobody"
			text.active = false
		end
 	end
end

function sign_collision(playerx,playery,charx,chary)
	if charx +10 > playerx and charx < playerx +10 and chary +10 > playery and chary < playery +10 then
  		if conversation_state == "none" then			
			conversation_state = "sign"
			readingSign = true	
			text.character = "sign"			
		end 
	else
		if text.character == "sign" then -- if player walks away instead of starting conversation			
			conversation_state = "none"
			readingSign = false
			text.character = "nobody"
			text.active = false
		end
 	end
end


-->8
-- conversation and text functions
function conversation_system()

	-- check if next to Wise Old Owl
	if (owl_collision(player.x,player.y,owl.x,owl.y)) == true then
	end

	-- check if next to a sign
	if player.x > 400 then
		if (sign_collision(player.x,player.y,sign2.x,sign2.y)) == true then
		end
	else
		if (sign_collision(player.x,player.y,sign1.x,sign1.y)) == true then
		end
	end

	-- none == no conversation
	-- start == player can choose to start conversation
	-- level1 == player in conversation
	if conversation_state == "start" then
		new_conversation({text.character,"press x to talk"})
		if (btnp(❎)) then						
			conversation_state = "level1"
		end	
	-- BRIAN
	elseif conversation_state == "level1" and text.character == "brian" then
		new_conversation({"ruff! morning furlock!"}) 
		if (btnp(❎)) then		
			conversation_state = "level2"
		end
	elseif conversation_state == "level2" and text.character == "brian" then		
		new_conversation({"i dont have anything","else to say!","bye!"})
		if (btnp(❎)) then
			conversation_state = "none"
		end

	-- OWL
	elseif conversation_state == "level1" and text.character == "owl" then
		new_conversation({"hmm, what now furlock?"}) 
		if (btnp(❎)) then		
			conversation_state = "level2"
		end
	elseif conversation_state == "level2" and text.character == "owl" then		
		new_conversation({"hurrumph!"})
		if (btnp(❎)) then		
			conversation_state = "none"
		end

	-- SIGNS
	elseif conversation_state == "sign" and player.x < 400 then
		new_conversation({text.character, "press x to read"})
		if (btnp(❎)) then		
			conversation_state = "sign2"			
		end
	elseif conversation_state == "sign2" then
		new_conversation({"it says 'owls house this way' "})
		if (btnp(❎)) then
			conversation_state = "none"
		end

	elseif conversation_state == "sign" and player.x > 400 then
		new_conversation({text.character, "press x to read"})
		if (btnp(❎)) then		
			conversation_state = "sign3"			
		end
	elseif conversation_state == "sign3" then
		new_conversation({"it says","'i'm very busy you know'"})
		if (btnp(❎)) then
			conversation_state = "none"
		end
	end
end

function format_text_centered(array, colour)
	-- only used for menu currently
	height = 50
	for i in all(array) do
		print(i,64-#i*2, height, colour)
		height += 6
	end
end

function init_conversation_text()
	text = {} -- create empty array to store multiple strings
	text.active = false -- initialise to false
	text.string = {} -- empty array to store individual string?
	text.character = "nobody"
	conversation_state = "none" -- semi-related code
end

function new_conversation(txt)
	text.string = txt -- enter received string(s) into array
	text.active = true
end

function draw_conversation()	
	-- determine longest line of text
	local maxTextWidth = 0
	for i=1, #text.string do 
		if #text.string[i] > maxTextWidth then -- loop through array and find longest text element
			maxTextWidth = #text.string[i] -- set max width to longest element so box wide enough
		end
	end

	-- define textbox with border
	local textbox_x = camera_x + 64 - maxTextWidth *2 -1 -- -1 for border and centred

	-- if player close to screen bottom, draw text box at top, else draw at bottom
	if (player.y < 200) then
		textbox_y = camera_y + 100 -- controls vertical location of text box (0 top, 127 bottom)
	else
		textbox_y = camera_y + 5 -- controls vertical location of text box (0 top, 127 bottom)
	end	
	
	local textbox_width = textbox_x+(maxTextWidth*4)  -- *4 to account for character width
	local textbox_height = textbox_y + #text.string * 6 -- *6 for character height

	-- draw outer border text box
	rectfill(textbox_x-2, textbox_y-2, textbox_width+2, textbox_height+2, 0)
	rectfill(textbox_x, textbox_y, textbox_width, textbox_height, 12)

	-- write text
	for i=1, #text.string do  -- the # gets the legnth of the array 'text'
		local txt = text.string[i]
		-- local tx = textbox_x +1 -- add 1 pixel of outside of box and text
		local tx = camera_x + 64 - #txt * 2 -- centre text based on length of string txt
		local ty = textbox_y -5+(i*6) -- padding for top of box but because for loop starts at 1 we need to subtract 5		
		if (conversation_state == "start") and i == 1 
		 or (conversation_state == "sign") and i == 1 
		 then 
			print(txt, tx, ty, 7) -- print first text line white
		else
			print(txt, tx, ty, 1)
		end
	end
end

text_array = {}
text_array[1] = "furlock bones"
text_array[2] = "the case of the lost animals"
text_array[3] = ""
text_array[4] = ""
text_array[5] = ""
text_array[6] = ""
text_array[7] = "press x to start"

-->8
-- back of house functions

function toggle_debug_mode()	
	if (btnp(🅾️)) and (debug_mode == false) then
		debug_mode = true	
	elseif (btnp(🅾️)) and (debug_mode == true) then
	  	debug_mode = false
	end	
end

function log(text,overwrite) -- external logging file
		printh(text, "log", overwrite)
end

function doMapStuff()
	-- if (btnp(🅾️)) then
	-- 	--squish=compressmap(0,0,128,16) -- compress current map 128x16 into squish
	-- 	decompressmap(0,0,map0) -- decompress map0 and load into active game
	-- 	--printh(squish, "temp", 1) -- this prints it to a file so I can copy and paste
	-- end
end

function compressmap(h,v,x,y)
	local r,b6,c6,n,c,lc="",0,0,0
	function to6(a)
		for i=1,#a do
		for j=0,7 do
			if (band(a[i],2^j)>0) c6+=2^b6
			b6+=1
			if (b6==6) r=r..chr6[c6] c6=0 b6=0
		end
		end
	end
	to6({x,y}) x-=1 y-=1
	for i=0,y do
		for j=0,x do
		c=mget(h+j,v+i)
		if (c==lc) n+=1
		if c!=lc or (j==x and i==y) then
			if n<2 then
			for k=0,n do
				to6({lc})
			end
			else
			to6({255,n,lc})
			end
			lc=c n=0
		end
		end
	end
	to6({c,0})
	return r
end

function decompressmap(h,v,t)
	local r,b6,c6,cp,n=t,0,0,1,0
	function to8()
	local s=0
		for i=0,7 do
		if (b6==0) c6=asc6[sub(r,cp,cp)] cp+=1
		if (band(c6,2^b6)>0) s+=2^i
		b6=(b6+1)%6
		end
		return s
	end
	local x,y,xp,yp,c=to8()-1,to8()-1,h,v
	repeat
		if n>0 then
		n-=1
		else
		c=to8()
		if (c==255) n=to8() c=to8()
		end
		mset(xp,yp,c)
		--spr(c,xp*8,yp*8)
		xp+=1
		if (xp>h+x) xp=h yp+=1
		if (yp>v+y) return
	until forever
end

function map_swapper()
	-- create 6-bit table to store maps
	chr6,asc6,char6={},{},"abcdefghijklmnopqrstuvwxyz.1234567890 !@#$%,&*()-_=+[{]};:'|<>/?"
	for i=0,63 do
	c=sub(char6,i+1,i+1) chr6[i]=c asc6[c]=i
	end
	char6=_n
end

-- music function
function musicControl()
	if (activeGame == false) and musicState != 'menu' then
			music(track_2start,0,120)
			musicState = 'menu'
	end
	if activeGame == true and musicState != 'level1' then
		music(track_1start,0,120)	
		musicState = 'level1'
	end
end

-- maps
owen="qa_?ce-?ja-?ciqabaaadmaadm-?ea6ace-?ea-aam-aa2-?ca6a??qc?pqba2aaam-aaaabay6bf<5caqabaa6bfaaaeqaaa2aaaqab?laaguaaaqab?taaeaaa?l6bf<)aa<)bea6bgaaafu-?daabe<?aa<)ag<pda<?ag<)aa2-?1a-b?}aai2-b?)aai6-?c2-?ja-?c6aca"
map0 = "ac_?@m=?t<6rh>pbp<ppam=? a6c?l_dgj[qh>?ap<ppam=?0aafli=d8<6ipi=d8<6i?5-dej{uf>?ap<ppam=?!a-?m-ahn<pbpy{v?t-d?+da9<)ja&7g?p-g%<)b1-rdpm_dpy]z?t-d?+da9<?iaauq9&=?n&_?c-ahny]z?t-d?+da9<?iaavu9<_k7[si*e8l7;si*[=g%<?a1-63}_rd?l-d?+da9<5jam=?l<-h,;8l*<)a([sl);-?c<-?<a-i?xca9<)gp<ppam=? a-i?,_d?+da9<5jam=?.<-?<a-i?xca9<?vam=? a-i?5fa9<5jam=?xb-i?xca9<?vam=? a-i?5faaa"

__gfx__
000000000000000000000000000700070007000700000000060006000600060006000600444b444bbbbbbbccbbbbbccc55555555cccccccc555ccc7ccccccccc
000000000007000700070007000777770007777706000600047474000474740004747400444444bbbbbbbcccbbbbcccc455454457ccccc7c55cccccccccc7ccc
00700700000777770007777770071771700717710474740007c4c70007c4c70007c4c700444444bbbbbbccccbbbccccc44444444cccccccc5ccccccccccccccc
000770007007177170071771700777e7700777e707c4c700044a4400044a4400044a440044444bbbbbbbccccbbbbcccc44444444cccccccccccccccccccccc7c
00077000700777e7700777e70776686007766860044a4400064446000644460006444600444b444bbbbcccccbbbbcccc44444444cccccccccc7cccccc7cccccc
007007000776686007766860077777700777777006444600064446006144416006444600444444bbbbbbccccbbbbcccc444444445ccc7ccccccccccccccccccc
00000000077777700777777070d0070670d07060064446000644460061444160064446004444bbbbbbbbccccbbbbcccc4444444455cccccccccccc7ccccccccc
00000000171d7160171d1716011111000111110006a4a60001a1a10011a1a11001a1a1004b44b4bbbbbcccccbbbbbccc44444444555ccccccccccccccccccccc
bbbbbbbbbbbbbbbbbbbbb9bbc44cc44cb44bb44bbbb33bbb000000000000000000000000bbbb4444444444444444444455d5cccc44444444bbbbbbbbccccc555
bbbbbbbbbbbbbbbbbbbb9bbb9999999999999999bb31b3bb000500050000000000000000bbb444444444d44444444444455d55cc44444444bbbbbbbbcccccc55
bbbbddbbbb224444444944bb4444444444444444b33b331b000444440000000000000000bb44444444444d44444444444455555c544545545bb5b55bccc7ccc5
bbbd6ddbb22229949994944b4224242442242424b13aa33b500414410000000000000000bbb444444dd444444444444444455d55555d5555555d5555cccccccc
bbd6dd5bb21222244244224b424224244242242433b5ab33500444e40000000000000000b4444444444d44444444444444445555555d5d55555d5d55cccccccc
b35dd553b22124442444441b4444444444444444313bb311044444400000000000000000bb4b444444444dd444444444444445555d55dd5d5d55dd5dcccccccc
bb35553bb12242122221223bc22cc22cb22bb22b13bb1b31044444400000000000000000bbbb44444444d4444444444444444455d555d55dd555d55dc7ccccc7
bbbbbbbb3311111111111133c22cc22c322332233113b331141d41400000000000000000bbb444444444444444444444444444455d5555d55d5555d5cccccccc
0000000044488444ccc88ccc65666566777777771b333111bbbbb333333bbbbb0000000044444444444444444444444454454554444444444444444444444444
00000000448f8244cc8f82c7555555557666666511b3bb11bbbb33333333bbbb00000000444444444444d4444444444455555555444444444444444444444444
0000000048888244cc8882cc666566657666666531333313bbb3a3baab333bbb000000004444444444444dd454454554555d555d544545545445455445545445
000000008f888e22c8888e2c5555555576666665b311113bbb3b3baaaab133bb0000000044444444444d44445555555555dd5d55555d5555555d5555555d5555
0000000088882222c8f8222c6566656676666665bb3223bbb33311baab13b33b00000000444444444dd4444455d55555d55d5d5d555d5d555555555555d55555
0000000055822255cc8222cc5555555576666665bb1442bb33ab333333bb113300000000444b444444444d44c55555555d55dd5d5d55dd5d5555555d55555d5c
00000000555115557cc11ccc6665666576666665314344133b11bb33131133b3000000004bbb4b444444d444c555d555d555d55dd555d55dd5555555555555cc
0000000055222255cc2222cc5555555555555555b333133b31b31133333ab31300000000bbbbbbb444444444cc55555555d555d555d555d555dd55d555555ccc
00000000bbbbbbbbbbbbbbbb444884440000000000000000131bb3b133ab1131000000004bbbbbbb444444444444444400000000000000000000000000000000
00000000bbb3bbbbbbbbbbbb448f82440000000000000000b1111133b311311b0000000044b4bbb444444444444d444400000000000000000000000000000000
00000000b33bbbbbbbbbbbbb488882440000000000000000bb11b113313311bb00000000b444b4b4444444444dd4444400000000000000000000000000000000
00000000bbbb3bbbbbbbbbbb8f888e220000000000000000bbb1113133111bbb0000000044b4b444444444444444d44400000000000000000000000000000000
00000000bbbbb33bbbbbbbbb888822220000000000000000bbb3111111113bbb00000000444444444444444444444dd400000000000000000000000000000000
00000000bb3bbbbbbbbbbbbb448222440000000000000000bb314211112413bb00000000444444444444444444d4444400000000000000000000000000000000
00000000bbb3bbbbbbbbbbbb444114440000000000000000b31421244212413b000000004444444444444444444d444400000000000000000000000000000000
00000000bbbbbbbbbbbbbbbb442222440000000000000000bb331441144133bb0000000044444444444444444444444400000000000000000000000000000000
bbbbbbbbbbbbbbbb333bb3b133ab133333aaa333333aaa33ccccc333333cccccbbbbbbbbbbbbbb4444bbbbbbbbbbbbbb00000000000000000000000000000000
bbbbbbbbbbbbbbbb33331133b311333333bab333333bab33cccc33333333ccccbbbbbbbbbbbb44999944bbbbbbbbbbbb00000000000000000000000000000000
bbbbbdddddddbbbbab3331133133a3ba333b13b11b31b333ccc3a3baab333cccbbbbbbbbbb4494aaa94944bbbbbbbbbb00000000000000000000000000000000
bbbbdd6d666ddbbbaab13331333b3baac3a313b11b313a3ccc3b3baaaab133ccbbbbbbbb449494aaaa444944bbbbbbbb00000000000000000000000000000000
bbbddddddd66ddbbab13b331133311bacc3b3b1331b3b3ccc33311baab13b33cbbbbbb44949444aaa949494944bbbbbb00000000000000000000000000000000
bbdddddddddd6ddb33bb113113ab3333ccc13a1bb1a31ccc33ab333333bb1133bbbb4494949494aaaa4949444944bbbb00000000000000000000000000000000
bb55dddddd55dddb131133344311bb33cccc11b11b11cccc3b11bb33131133b3bb449494949494aaaa494449494944bb00000000000000000000000000000000
b5555ddd66dd555b333ab31111b31133ccccc111111ccccc31b31133333ab313449494449444a444444a49494944494400000000000000000000000000000000
b55dd5d66dd5155b33ab1333333bb3b10000000000000000131bb3b11b3bb1312494949494a4442222444a494449494200000000000000000000000000000000
b151dddddd55155bb3113333333311330000000000000000c11111333311111c44949494a44422111122444a4949494400000000000000000000000000000000
33151dddd55551333133a3baab3331130000000000000000cc11b113311b11cc249444a444221111111122444a49444200000000000000000000000000000000
b33111555511133b333b3baaaab133310000000000000000ccc111b11b111ccc2494a4442211112222111122444a494200000000000000000000000000000000
bb333311113333bb133311baab13b3310000000000000000cccc11133111cccc24a44422111122222222111122444a4200000000000000000000000000000000
bbbb33333333bbbb13ab333333bb11310000000000000000ccccdd1111ddcccc2444221111222224422222111122444200000000000000000000000000000000
bbbbbbbbbbbbbbbb4311bb33131133340000000000000000cccc6d5dd5d6cccc2422111122222444444222221111224200000000000000000000000000000000
bbbbbbbbbbbbbbbb11b31133333ab3110000000000000000cccc26555566cccc2111112222244444444442222211111200000000000000000000000000000000
000000000000000000000000000000000000000000000000cccc26566562cccc1111122224444444444444422221111100000000000000000000000000000000
000000000000000000000000000000000000000000000000cccc62555566ccccb112122444111144444111444221211b00000000000000000000000000000000
000000000000000000000000000000000000000000000000cccc66566526ccccbb1221444111111444111114441221bb00000000000000000000000000000000
000000000000000000000000000000000000000000000000cccc62555566ccccb312242241111114441111142242213b00000000000000000000000000000000
000000000000000000000000000000000000000000000000cccc66566562ccccb311244441111914441111144442113b00000000000000000000000000000000
000000000000000000000000000000000000000000000000cccc26555526cccc3312124441111414442222244421213b00000000000000000000000000000000
000000000000000000000000000000000000000000000000cccc66566566cccc3331142241111114444444442241133b00000000000000000000000000000000
000000000000000000000000000000000000000000000000cccc66555566ccccb333311441111114424224244113333b00000000000000000000000000000000
00000000000000000000000000000000000000000000000055556256652655550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000054546655556645450000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000044442656656244440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000044446655552644440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000044442656656244440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000044466255556664440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000044626156651626440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000046261651156162640000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000010100010180800102000100000000000001010001010101010100000000010000000000000000000101000000000000000001010000010101010101010100000101010100000100010101010101000001010101000000000101010101010000010101010000000001010000000000000101
0101000001000001010100000000000001010000010000010101000000000000010101010100000001010000000000000101010001010000010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
232323232323232323232323232323232323232323232323232323232323232323232323232323230f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f46470f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2348494a4b321032323232323232323232323232323232323232323232323232323232323232320a0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f464243470f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2358595a5b404132323232323232323232323232323232323232323232323232323232323232320b220f220f220f220f220f220f0f0f0f0f0f0f0f445253450f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2368696a6b50513232323232323232323232323132323232323232323232323232323232323232190c0c0c0c0c0c0c0c0c0c0c0c0c1c0d0f0f0f0f0f56570f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
233232323232323232323232323232323232323232323232323232323132323232323232323232191b1a1b1b1b1b2a1b1b1b1b1b1b1b1c0d0f0f0f0f66670f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
233232313232323232323232323232323232323232323232323232323232323232323232324041232b331b331b331b331b331b331b1b1b0c0c0c1c0d66670f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
233232323232323232323232323232323232323232323232323232323232323232323232325051231f2b2c2c2c2c2c2c2c2c2c2c2d1b2a1b1b1b1b0c76771c0d0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
233232323232323232323232323232323232323232323232323232323232323232323232323232230f0f0f0f0f0f0f0f0f0f0f0f1f2b2e2e2d2e2e2e2d2d2f0e0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
233232313232323232323232323232323232323232323232323232323232323232323232323232230f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
233232323232323232323232323232323232323232103232323232323232323231323232323232230f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
233232323232323232323232323232323232323232323232323232323232323231323232323232230f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332323232323232323232323232323232313232323232323231323232323232323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332323232323232323232323232323232323232323232323232323232323232323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332323232323232323132323232323232323232323232323232323232323232323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332323232323232323232323232323232323232323232323232323232323232323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332323232323232323232323232323232323232323232323232323232323232323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332323232323232323232323132323232323232323232323232323232323231323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332323232323232323232323232323232323232323232323232323232323232323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332323232313232323232323232323132323232323232323232323232323232323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332323232323232323232323232323232323232323232323232323232323232323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332323232323232323232323232323232323232323232323232323232323232323232313232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332321032323232323232323232323232323232323131323232323132323232323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332103232323232323232323232323232323232323232323232323232323232323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332323232323132323210323232323232323232323232323232323232323232323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332323232323232323232323232313232323232323232323232323232323232323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332323232323232323232323232323232323232323232323232323232323232323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332323232323232321032323232323232323232323232103232323232323232323232323132322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2310323232323232323232323232323232323232323232323232323232323232323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332323232313232103232323232323232323232323232323232323232323231323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332103232323232323232323232323132323232323232313232323232323232323232323232102300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2332103210404132323232323232323232323232323232323232323232323232323232323210322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2323232323232323232323232323232323232323232323232323232323232323232323232323232300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011800200c0351004515055170550c0351004515055170550c0351004513055180550c0351004513055180550c0351104513055150550c0351104513055150550c0351104513055150550c035110451305515055
010c0020102451c0071c007102351c0071c007102251c007000001022510005000001021500000000001021013245000001320013235000001320013225000001320013225000001320013215000001320013215
003000202874028740287302872026740267301c7401c7301d7401d7401d7401d7401d7301d7301d7201d72023740237402373023720267402674026730267201c7401c7401c7401c7401c7301c7301c7201c720
0030002000040000400003000030020400203004040040300504005040050300503005020050200502005020070400704007030070300b0400b0400b0300b0300c0400c0400c0300c0300c0200c0200c0200c020
00180020176151761515615126150e6150c6150b6150c6151161514615126150d6150e61513615146150e615136151761517615156151461513615126150f6150e6150a615076150561504615026150161501615
00180020010630170000000010631f633000000000000000010630000000000000001f633000000000000000010630000000000010631f633000000000000000010630000001063000001f633000000000000000
001800200e0351003511035150350e0351003511035150350e0351003511035150350e0351003511035150350c0350e03510035130350c0350e03510035130350c0350e03510035130350c0350e0351003513035
011800101154300000000001054300000000000e55300000000000c553000000b5630956300003075730c00300000000000000000000000000000000000000000000000000000000000000000000000000000000
003000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01240020051450c145051450c145051450c145051450c145071450e145071450e145071450e145071450e1450d145141450d145141450d145141450d145141450c145071450c145071450c145071450c14507145
014800202174421740217402274024744247401f7441f7402074420740207401f7401d7401f7401c7441c7402174421740217402274024744247401c7441c7401d7441f740207402274024744247402474024745
012400200e145151450e145151450e145151450e145151450c145131450c145131450c145131450c145131450f145161450f145161450f145161450f145161450e145151450e145151450c145131450c14513145
011200200c1330960509613096131f6330960509615096150c1330960509613096130062309605096050e7130c1330960509613096131f6330960509615096150c1330960509613096130062309605096050e713
014800200c5240c5200c5200c52510524105201052010525115241152011520115251352413520135201352511524115201152011525135241352013520135251452414520145201452013520135201352013525
014800200573405730057300573507734077300773007735087340873008730087350c7340c7300c7300c73505734057300573005735077340773007730077350d7340d7300d7300d7350c7340c7300c7300c735
014800200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013200202005420050200502005520054200502005020055200542005020050200551e0541e0501c0541c05023054230502305023055210542105020054200501c0541c0501c0501c0501c0501c0501c0501c055
0132002025054250502505025055230542305021054210502805428050280502805527054270502305423050250542505025050250551e0541e0501e0501e0552305423050230502305023050230502305023055
0132002010140171401914014140101401714019140141400f14014140171401b1400f14014140171401b1400d1401014015140141400d1401014017140191400d1401014015140141400d140101401714019140
0132002015140191401c1401914015140191401c1401914014140191401b14017140121401414015140191401e1401914015140191401214014140151401914017140141401014012140171401e1401b14017140
013200202372423720237202372523724237202372023725237242372023720237252172421720207242072028724287202872028725257242572023724237202072420720207202072020720207202072020725
0132002028724287202872028725287242872028720287252c7242c7202c7202c7252a7242a72028724287202a7242a7202a7202a725257242572025720257252872428720287202872527724277202772027725
0019002001610016110161101611016110161104611076110b61112611166111b6112061128611306113561138611336112d6112961125611206111c6111861112611106110c6110861104611026110261101611
011e00200c505155351853517535135051553518535175350050015535185351a5350050515535185351a53500505155351c5351a53500505155351c5351a53500505155351a5351853500505155351a53518535
010f0020001630020000143002000f655002000020000163001630010000163002000f655001000010000163001630010000163002000f655002000010000163001630f65500163002000f655002000f60300163
013c002000000090750b0750c075090750c0750b0750b0050b0050c0750e075100750e0750c0750b0750000000000090750b0750c0750e0750c0751007510005000000e0751007511075100750c0751007510005
013c00200921409214092140921409214092140421404214022140221402214022140221402214042140421409214092140921409214092140921404214042140221402214022140221402214022140421404214
013c00200521405214052140521404214042140721407214092140921409214092140b2140b214072140721405214052140521405214042140421407214072140921409214092140921409214092140921409214
013c00202150624506285060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400181862500000000001862518625186251862500000186051862018625000001862500000000001862500000000001862518605186251862518605186250000000000000000000000000000000000000000
010f00200c0730000018605000000c0730000000000000000c0730000000000000000c0730000000000000000c0730000000000000000c0730000000000000000c0730000000000000000c073000000000000000
013c0020025500255004550055500455004550055500755005550055500755007550045500455000550005500255002550045500555004550045500555007550055500555007550095500a550095500755009550
013c00201a54526305155451a5451c545000001a5451c5451d5451c5451a545185451a5450000000000000001a5452100521545180051c5450000018545000001a545000001c545000001a545000000000000000
011e00200557005575025650000002565050050557005575025650000002565000000457004570045750000005570055750256500000025650000005570055750256500000025650000007570075700757500000
013c00200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013c00201d1151a1151a1151d1151a1151a1151c1201c1251d1151a1151a1151d1151a1151a1151f1201f1251d1151a1151a1151d1151a1151a1151c1201c1251d1151a1151a1151d1151a1151a1151f1201f125
011e0020091351500009135000050920515000091350000009145000000920500000071400714007145000000913500000091350000009205000000913500000091450000009205000000c2000c2050020000000
015000200706007060050600506003060030600506005060030600306005060050600206002060030600306007060070600506005060030600306005060050600306003060050600506007060070600706007060
01280020131251a1251f1251a12511125181251d125181250f125161251b125161250e125151251a125151250f125161251b1251612511125181251d125181250e125151251a125151251f1251a125131250e125
01280020227302273521730227301f7301f7301f7301f7352473024735227302273521730217351d7301d7351f7301f7352173022730217302173522730247302673026730267302673500000000000000000000
012800202773027735267302473524730247302473024735267302673524730267352273022730227302273524730247352273021735217302173021730217351f7301f7301f7301f7301f7301f7301f7301f735
015000200f0600f0600e0600e060070600706005060050600c0600c060060600606007060090600a0600e0650f0600f0600e0600e060070600706005060050600c0600a060090600206007060070600706007065
012800200f125161251b125161250e125151251a12515125131251a1251f1251a12511125181251d125181250f125161251b125161250e125151251a12515125131251a1251f1251a125131251a1251f1251a125
012800201a5201a525185201a525135101351013510135151b5201b5251a5201a525185201852515520155251652016525185201a52518520185251a5201b520155201552015520155251f5001f5001f5001f505
012800201f5201f5251d5201b525155101551015510155151d5201d5251b5201d5251a5101a5101a5101a5151b5201b5251a5201a52518520185201552015525165201652016520165251a5001a5001a5001a505
013c00201003500500000001003509000000000e0300e0351003500000000001003500000000000e0000e00511035000000000011035000000000010030100351103500000000001103500000000000400004005
011e00201813518505000001713517505000001513515505000001013010130101350000000000000000000015135000000000010135000000000011500115001150011500111301113011130111350000000000
01180020071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155051550c155081550c155051550c155081550c155051550c155081550c155051550c137081550c155
01180020071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1370c1550f155
01180020081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1370a1550e155
011800201305015050160501605016050160551305015050160501605016050160551605015050160501a05018050160501805018050180501805018050180550000000000000000000000000000000000000000
011800201305015050160501605016050160551305015050160501605016050160551605015050160501a0501b0501b0501b0501b0501b0501b0501b0501b0550000000000000000000000000000000000000000
011800201b1301a1301b1301b1301b1301b1351b1301a1301b1301b1301b1301b1351b1301a1301b1301f1301a130181301613016130161301613016130161350000000000000000000000000000000000000000
011800201b1301a1301b1301b1301b1301b1351b1301a1301b1301b1301b1301b1351b1301a1301b1301f1301d1301d1301d1301d1301d1301d1301d1301d1350000000000000000000000000000000000000000
01180020081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f1550a155111550e155111550a155111550e155111550a155111550e155111550a155111550e15511155
011800202271024710267102671026710267152271024710267102671026710267152671024710267102971027710267102471024710247102471024710247150000000000000000000000000000000000000000
01180020227102471026710267102671026715227102471026710267102671026715267102471026710297102b7102b7102b7102b7102b7102b7102b7102b7150000000000000000000000000000000000000000
011800202b720297202b7202b7202b7202b7252b720297202b7202b7202b7202b7252b720297202b7202e72029720277202672026720267202672026720267250000000000000000000000000000000000000000
011800202b720297202b7202b7202b7202b7252b720297202b7202b7202b7202b7252b720297202b7202e7202e7202e7202e7202e7202e7202e7202e7202e7250000000000000000000000000000000000000000
010c00200c133000000061500615176550000000615006150c133000000061500615176550000000615006150c133000000061500615176550000000615006150c13300000006150061517655000000061500615
0118002002070020700207002070040700407004070040700c0700c0700c0700c0700a0700a0700a0700a0700e0700e0700e0700e0700d0700d0700d0700d070100701007010070100700e0700e0700e0700e075
011800200000015540155401554015545115401154011540115451354013540135401354510540105401054010545115401154011540115451054010540105401054513540135401354013545095400954009545
0118002009070090700907009070070700707007070070700907009070090700907002070020700207002070030700307003070030700a0700a0700a0700a0700707007070070700707007070070700707007075
01180020000001054010540105401054511540115401154011545105401054010540105450e5400e5400e5400e545075400754007540075450e5400e5400e5400e54505540055400554005540055400554005545
__music__
01 08004243
00 08014300
00 03014300
00 02030500
00 02030500
00 03414300
00 08014500
00 03040500
00 03020500
00 03020500
02 08010706
01 0a4d0949
00 0a0d090c
00 0a4c0b4c
00 0a0d0e4e
02 0f4d0c09
01 10124316
00 11134316
00 10121416
00 11131516
00 12424316
02 13424316
01 19425b18
00 19175a18
00 19171a18
00 1b425c18
02 1a194318
01 1f1d5e60
00 1f1d5e20
00 1f1d4320
00 221d211e
00 231d211e
02 1c1d2444
01 25262744
00 292a2844
00 2526272b
02 292a282c
01 2d181e24
00 2d181e24
00 2d181e2e
00 2d181e2e
00 2d181e6e
02 2d181e6e
01 2f454305
00 30424305
00 2f324344
00 30334344
00 2f323705
00 30333805
00 31344344
00 36354344
00 31343905
02 36353a05
01 3c423b41
00 3c423b44
00 3c3d3b44
00 3c3d3b44
00 3e523b41
00 3e423b41
00 3e3f3b44
00 3e3f3b44
00 3e013b41
02 3e013b41

