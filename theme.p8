pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--pico ride tycoon
--by joseph
--@josephmakesgame

--bugs

--todo
--balance ~

--polish

--costly updates
--main menu animation ~
--selector shows stats 
--other connecting paths

--debug
function debug()
	print(debug_t,0,0,8)
	print(debug_2,0,8,8)
end
--debug_setup
function debug_setup()
	debug_t=""
	debug_2=""
end

function _init()

	variable_setup()
	
	add_visitors()

end

function _update()

 rcount = get_rcount()

	--update stats
	update_happiness()
	passive_change()
	check_unlocks()
	check_records()

 run_co()
 
 input()
end

function _draw()


 cls()
 if start_menu then
  draw_start_menu()
  draw_fv()
 else
		draw_map()
		draw_con_paths()
		draw_vis()
		
		draw_ride_sprite()
		
		if in_game then
			draw_selector()
		end
		
		draw_ui_frame()
		--build menu
		if open_build_menu then
			draw_build_menu()
		elseif open_records then
		 draw_records()
		elseif open_options then
		 draw_options()
		end
		
	end
	
	--debug()
end
-->8
--setup and draw to map functions
function variable_setup()
 actions = {}
 --debug_setup()
 
 setup_save()
 
 	--objects
	setup_vis()
	b = {} --buildings
	building_setup()
	ubn = 2 --unique building number
 rcount = 0 --ride count
 
 --ui
	setup_selector()
	setup_build_selector()
	setup_options_selector()
	setup_ui()
	start_anim() --start screen
	
	--text color bounce
	tcol_tick = 0
	tcol = 7
	
	setup_unlocks()
	
	--game state
	start_menu = true
	bottom_bar = false
	in_game = false
	open_build_menu = false
	open_records = false
	open_options = false
	
	--options
	sfx_on = true
	music_on = true
	
	music(0)
	
	find_paths(0,0,15,15)
end


function draw_map()
	map(0,0,0,0,128,64)
end

--draw selector
function draw_selector()
 if bs.tool == selector then
		sspr(s.sx,s.sy,s.sw,s.sh,
	     s.x*8,s.y*8)
	elseif bs.tool.size == 0 then
	 sspr(bs.tool.psx,bs.tool.psy,8,8,s.x*8,s.y*8)
	elseif bs.tool.size == 1 then
	 draw_blue_sq(1,1)
	 draw_arrows(1,1)
	 	sspr(96 ,120,8,8,s.x*8,s.y*8+8)
	elseif bs.tool.size == 2 then
	  draw_blue_sq(2,1)	--arrows
	 draw_arrows(2,1)
	elseif bs.tool.size == 4 then
	 draw_blue_sq(2,2)
			--arrows
	 draw_arrows(2,2)
	
	elseif bs.tool.size == 61 then
	 draw_blue_sq(2,2)
		--arrows
	 draw_arrows(2,2)
	elseif bs.tool.size == 62 then
		draw_blue_sq(3,2)
		--arrows
	 draw_arrows(3,2)
	end
end

--blue placement squares
function draw_blue_sq(dx,dy)
	for i=0,dx-1 do
		for j=0,dy-1 do
			sspr(104,120,8,8,s.x*8+8*i,s.y*8+j*8)
		end
	end
end

--placement arrows
function draw_arrows(dx,y)
 for i=0,dx-1 do
			sspr(96,120,8,8,s.x*8+8*i,s.y*8+y*8)
	end
end

--ui
--build menu
function setup_build_selector()
	bs = {}
	bs.x = 0
	bs.y = 0
	
	--active
	bs.tool = selector
end

function draw_build_menu()
 --box
	rectfill(7,99,120,121,7)
	rectfill(8,100,119,120,13)
	
 --icons
 sspr(88 ,112,8,8,10 ,102) --selector
 sspr(112,112,8,8,20 ,102) --path
	sspr(80 ,112,8,8,30 ,102) --toilet
 sspr(96 ,112,8,8,40 ,102) --burger
 sspr(104,112,8,8,50 ,102) --balloons
	sspr(72 ,112,8,8,60 ,102) --milkshake
	sspr(64 ,112,8,8,70 ,102) --chip
	sspr(40 ,112,8,8,80 ,102) --chocolate store
	sspr(56 ,112,8,8,90 ,102) --doghnut store
	sspr(48 ,112,8,8,100,102) --pub
	
	
	sspr(112,104,8,8,10,111) -- dodgems
	sspr(88 ,104,8,8,20,111) -- maze
	if ferris_wheel.unlocked == true then
		sspr(104,104,8,8,30,111) -- ferris wheel
	else
	 sspr(104,96,8,8,30,111) -- ferris wheel
	end
	if helter_skelter.unlocked == true then
		sspr(56 ,104,8,8,40,111) -- helter skelter
	else
	 sspr(56 ,96,8,8,40,111) -- helter skelter
	end
	if spinner.unlocked == true then
	 sspr(80 ,104,8,8,50,111) -- spinner
	else
	 sspr(80 ,96,8,8,50,111) -- spinner
	end
	if free_fall.unlocked == true then
	 sspr(72 ,104,8,8,60,111) -- free fall
	else
	 sspr(72 ,96,8,8,60,111) -- free fall
	end
	if pirate_ship.unlocked == true then
	 sspr(48 ,104,8,8,70,111) -- pirate ship
	else
	 sspr(48 ,96,8,8,70,111) -- pirate ship
	end
	if roller_coaster.unlocked == true then
	 sspr(96 ,104,8,8,80,111) -- roller coaster
	else
	 sspr(96 ,96,8,8,80,111) -- roller coaster
	end
	if log_flume.unlocked == true then
	 sspr(64 ,104,8,8,90,111) -- log flume
	else 
	 sspr(64 ,96,8,8,90,111) -- log flume
	end
	
	--destroy
	sspr(120 ,112,8,8,110,111)  -- burger

	--selector
	sspr(112,120,8,8,10+(bs.x*10),102+(bs.y*9))

	--price and name
	draw_build_text()
end

function draw_build_text()
	
 local n = bs.x + bs.y*11 + 1

	rectfill(7,88,120,97,7)
	rectfill(8,89,119,96,13)
	
	local build_options = {selector, path, toilet, burger_store, balloon_store, milkshake_store, chip_store, chocolate_store, doghnut_store, pub,nil,
																								dodgems, maze, ferris_wheel, helter_skelter, spinner, free_fall, pirate_ship, roller_coaster, log_flume,nil,demolish}
	
	
	local opt = build_options[n]
	if opt ~= nil then
	 if opt.unlocked or opt.unlocked == nil then
	 		if opt.build_cost == nil then
	 			print(opt.name,9,91,1)
	 			print(opt.name,9,90,7)
	 	 else
	 	  print(opt.name..": $"..opt.build_cost,9,91,1)
	 	  print(opt.name..": $"..opt.build_cost,9,90,7)
	 	 end
	 elseif opt.unlocked == false then
	 	  print("unlocked at $"..opt.build_cost,9,91,1)
	 			print("unlocked at $"..opt.build_cost,9,90,7)
	 end
 end
	
end

--run coroutines
function run_co()
		for c in all(actions) do
    if costatus(c) then
      coresume(c)
    end
    if costatus(c) == "dead" then
      del(actions,c)
    end
  end
end

--draw connecting paths
function draw_con_paths()
 for k, bld in pairs(b) do
 	if bld.cat == "store" 
 	 or bld.cat == "wc" 
 	 then

			px = bld.x*8
			py = bld.y*8
			
			--draw path 
			pset(px+3,py+8,15)
			pset(px+3,py+9,15)
			pset(px+3,py+10,15)
			pset(px+4,py+8,15)
			pset(px+4,py+9,15)
			pset(px+4,py+10,15)
		end
 end
 
end

--draw parts of rides

function draw_ride_sprite()
	for k, ride in pairs(b) do
		if ride.size == 61 
		 or ride.size == 2 
		 then
		 
			local mx = ride.x*8
			local my = ride.y*8
			
			if ride.psx ~= nil then
				sspr(ride.psx,ride.psy,16,8,ride.x*8,ride.y*8-8)
			else
			end
		end
	end
end



-->8
--visitors
function setup_vis()
	vis_col = {4,9,14}
	vis_shirt_col = {5,11,12}
	vis_sp_x = 8
	vis_sp_y = 15
	n_vis = 0
	no_v = 0 --current visitors
	vision = 7
	
	v = {}
	
	create_vis(n_vis)
	
	--temp
	--target = {8,2}
	targets = {{7,12},
												{9,12}}
	--[[
	targets = {{8,2},
	           {5,13},
	           {11,13},
	           {4,7},
	           {10,6},
	           {8,9},
	           {12,7},
	           {1,7}}
	--]]
end

function add_vis(_x,_y,_fc,_sc,_spd,_cash,_target)
	no_v += 1
	add(v,{
		
		--postion
		x = _x,
		y = _y,
		
		--face
		fc = _fc,
		--shirt
		sc = _sc,
		--draw sprite
		draw = true,
	
		--stats
		spd = _spd,
		cash = _cash,
		happy = 40,
		bladder = 20,
		hunger = 40,
		
		--pathing
		target = _target,
		target_building = nil,
		current_path = {},
		
		--functions
		leave=function(self)
		 no_v -= 1
			del(v,self)
		end,
		act=function(self)
			self:spend(self.target_building)
			self:occupy(self.target_building)
			self:change_stats(self.target_building)
		end,
		spend=function(self,build)
			self.cash -= build.cost
			money = mid(0,money+build.cost,32000)
		end,
		change_stats=function(self,build)
			self.bladder += build.bladder
		 self.hunger += build.hunger
		 self.happy += build.fun
		end,
		occupy=function(self,build)
				local c = cocreate(function()
	 
			 	self.draw = false
			 
					for i=1,build.tm*30 do
						yield()
					end
					
					self.draw = true
				end)
			add(actions,c)
		end
		
	})
end

--[[
--occupy moved outside visitors
function start_occupy(self,build)
	
	
end
--]]

function create_vis(nv)
	--spawning point
	for i=1,nv do
		local x =  vis_sp_x*8+rnd(4)+2
		local y =		vis_sp_y*8+rnd(4)+2
		
		--face col
		local fc = vis_col[flr(rnd(3)+1)]
		local sc = vis_shirt_col[flr(rnd(3)+1)]
	
		local spd = rnd(0.2) + 0.1
		local cash = rnd(500) + 500
		
		--create the visitor
		add_vis(x,y,fc,sc,spd,cash,target)
		
	end
end

function draw_vis()

	--for i=1,count(v) do
	for i, vis in pairs(v) do
	 
		
		if v[i].draw == true then
		
		 --for complex paths
		 if count(v[i].current_path) == 0 then
			 	
		 	create_target(i) 
		 
		 	mpos1 = flr(v[i].x/8)
		 	mpos2 = flr(v[i].y/8)
		 	if v[i].target ~= nil then
					find_path({mpos1,mpos2},v[i].target,i)
		 	end
		 end
		 
		 --face
			pset(v[i].x,v[i].y-1,v[i].fc)
			--shirt
			pset(v[i].x,v[i].y,v[i].sc)
		
		 --check if at next point
		 local mx = flr(v[i].x/8)--/8
		 local my = flr(v[i].y/8)--/8
		 
		 --need last in current path table
		 local length = count(v[i].current_path)
		 
		 local spillx = v[i].x%8
		 local spilly = v[i].y%8
		 
		 if length ~= 0 then
			 if v[i].current_path[length][1] == mx
			   and v[i].current_path[length][2] == my
			   then
			 	 	if   3<=spillx and spillx <=6
			   		and 3<=spilly and spilly <=6 then
			 	 		
			 	 		deli(v[i].current_path,length)
			 	 	
			 	 	 --act at location
			 	 		if length == 1 and v[i].target_building ~= nil then
			 	 		 v[i]:act()
			 	 		end
			 	 	
			 	 	elseif spillx < 3 then
			 	 		direction = "right"
			 	 	elseif spillx > 6 then
			 	 		direction = "left"
			 	 	elseif spilly < 3 then
			 	 		direction = "down"
			 	 	elseif spilly > 6 then
			 	 		direction = "up"
			 	 	end
						 
			 elseif count(v[i].current_path) ~= 0 then
			 	if (mx < v[i].current_path[length][1]) then
			 		direction = "right"
					elseif (mx > v[i].current_path[length][1]) then
			 		direction = "left"
					elseif (my < v[i].current_path[length][2]) then
			 		direction = "down"
					elseif (my > v[i].current_path[length][2]) then
			 		direction = "up"
			 	else 
				 	direction = ""
					end
				else 
				 direction = ""
			 end
		end
			--move 
		 if count(v[i].current_path) ~= 0 then
				if direction == "up" then
					v[i].y -= v[i].spd
				elseif direction == "left" then
				 v[i].x -= v[i].spd
				elseif direction == "right" then
				 v[i].x += v[i].spd
				elseif direction == "down" then
				 v[i].y += v[i].spd
				elseif direction == "" then
				end
			end
			
			--actions
			if  v[i].cash < 10 
			 or v[i].happy < 1 then
				v[i]:leave()
			end
			
		end
	end
end

function create_target(i)
	
	local searching = true
	
	while(searching) do
		--r1 = flr(rnd(count(targets)))+1
		
		--if rcount >= 2 then
		 create_target2(v[i])
		 searching = false
		 
	 --elseif targets[r1] ~= v[i].target then
	 	--v[i].target = targets[r1]
	 	--searching = false
	 --else
	  --direction = ""
	 --end
 end
end

function create_target2(v)
	local rides = {}
	local foods = {}
	local wcs   = {}
	local allb  = {}
	
	
	for i, build in pairs(b) do
		if build.cat == "ride" then
			add(rides,build)
			add(allb,build)
		elseif build.cat == "store" then
			add(foods,build)
			add(allb,build)
		elseif build.cat == "wc" then
			add(wcs,build)
			add(allb,build)
		else
		 add(allb,build)
		end
	end
	
	wcs_count = count(wcs)
	foods_count = count(foods)
	rides_count = count(rides)
	
	
	if v.bladder >= 80 
	 and wcs_count ~= 0 then 
			local r = flr(rnd(wcs_count))+1
				if v.target_building ~= wcs[r] 
				 and wcs[r] ~= nil then
					v.target = wcs[r].coord[1]
					v.target_building = wcs[r]
			 end
	elseif v.hunger >= 80 
	 and foods_count ~= 0 then 
			local r = flr(rnd(foods_count))+1
			 if v.target_building ~= foods[r] 
				 and foods[r] ~= nil then
					v.target = foods[r].coord[1]
					v.target_building = foods[r]
			 end
	elseif rides_count ~= 0 then 
	 if (rides_count == 1 and v.target_building == nil) 
	  or rides_count > 1 then 
				local r  = flr(rnd(rides_count))+1
				if v.target_building ~= rides[r] 
				 and rides[r] ~= nil then
					local r2 = flr(rnd(count(rides[r].coord)))+1
					v.target = rides[r].coord[r2]
					v.target_building = rides[r]
				end
		else
			random_target(v,allb)
		end
	else 
		random_target(v,allb)
	end
end

function random_target(v,allb)
 local r  = flr(rnd(count(allb)))+1
				if v.target_building ~= allb[r] 
				 and allb[r] ~= nil then
					local r2 = flr(rnd(count(allb[r].coord)))+1
					v.target = allb[r].coord[r2]
					v.target_building = allb[r]
				end
end

function add_visitors()
			local c = cocreate(function()
			 while happiness > 0 do
					for i=1,10*30 do
						yield()
					end
					
					new_v =flr((happiness/100)*10)
					
					new_v = mid(1,new_v-2,no_v)
					if not start_menu then
						create_vis(new_v)
					end
			 end
			end)
			add(actions,c)
end
-->8
--pathing
function find_paths(startx,starty,width,hight)
 	
	paths = {}
	
	for j = startx,width+startx do
		for i = starty,hight+starty do
				paths[vectoindex(j,i)] = mget(j,i)
		end
	end
end

--merge paths
function merge_paths(w,h)
	for i=0,w do --x
		for j=0,h do --y
		 local n = vectoindex(i,j)
		 local a = 0
				if paths[vectoindex(i,j)] <= 30 then
					
					--top
					if j ~= 0 then
						if paths[vectoindex(i,j-1)] <= 30 then
							a += 1000
						end
					end
					--bottom
					if j ~= h then
						if paths[vectoindex(i,j+1)] <= 30 then
							a += 100
						end
					end
				 --left
					if i ~= 0 then
						if paths[vectoindex(i-1,j)] <= 30 then
							a += 10
						end
					end
				 --right
					if i ~= w then
						if paths[vectoindex(i+1,j)] <= 30 then
							a += 1
						end
					end
				 
				 --allocate tile
				 tile = nil
				 if a == 1100 then tile = 16 
				 elseif a==11 then tile = 17 
				 elseif a==1111  then tile =18 
				 elseif a==1001  then tile =19 
				 elseif a==1010  then tile =20  
				 elseif a==110  then tile =21  
				 elseif a==101  then tile =22
				 elseif a==111 then tile = 23
				 elseif a==1101  then tile =24
				 elseif a==1011  then tile =25 
				 elseif a==1110  then tile =26 
				 elseif a==100  then tile =27  
				 elseif a==1  then tile =28  
				 elseif a==1000  then tile =29
				 elseif a==10  then tile =30  
				 else tile = 14 end
				 
				 mset(i,j,tile)
				end
		end
	end
end

--create an index from two points
function vectoindex(x,y)
	local index = (x+1)+16*y
	return index
end

--create a vector from a index
function indextovec(n)
	local x = (n-1)%16
	local y = flr((n-1)/16)
	local vector = {x,y}
	return vector
end

--create open closed paths
function reset_oc()

	found_path = false
	
 open_paths = {}
	closed_paths = {}
	
	tot_dist = {}		
	g_dist = {}
	h_dist = {}

 parent = {}						

end

--pathfinding
function find_path(start,target,index)	
	
	reset_oc()
	
	--first coord to analyse
	mx = start[1]
	my = start[2]

	--homex/y is start	
	homex = mx
	homey = my
	
	h_dist[vectoindex(mx,my)] = 0
	g_dist[vectoindex(mx,my)] = calc_dist_g(mx,my,target)
	tot_dist[vectoindex(mx,my)] = calc_dist(mx,my,target)

	--add to closed list
	closed_paths[vectoindex(mx,my)] = 1
 
 --find neighbours distance
 dist_nbs(mx,my,target)

 
	found_path = false
	local i = 0
 while not found_path do
 	i+=1
 	if i >= 200 then
 		v[index].target = nil
 		v[index].current_path = {}
 		return
 	end
 
  smallest_dist = 999
  smallest_dist_g = 999
	 new = find_smallest_node(target)
	 
	 mx=new[1]
	 my=new[2]
	 
		if found_path then
				--found path
		else 
		   closed_paths[vectoindex(mx,my)] = 1
			  --find neighbours distance
			 	dist_nbs(mx,my,target)
		end
		--printh("current coord = "..mx..", "..my,"log",true)
	end
	
	track_back({mx,my},index)
	--get_dir(vx,vy)
	
end

function calc_dist_g(x,y,target)
	local distx = abs(target[1] - x)
	local disty = abs(target[2] - y)
	local dist  = sqrt(distx*distx+disty*disty)

	return dist
end

function calc_dist(x,y,target)
	local dist = h_dist[vectoindex(mx,my)] + g_dist[vectoindex(mx,my)]
	return dist 
end

function new_dist(x,y,target)
	new_h = h_dist[vectoindex(mx,my)] + 1
	new_g = calc_dist_g(x,y,target)
	new_d = new_h + new_g
end

function fill_tables(x,y,ox,oy)

	local ind = vectoindex(x,y)

	tot_dist[ind] = new_d
	g_dist[ind] = new_g
	h_dist[ind] = new_h
	parent[ind] = {ox,oy}     
	open_paths[ind]=1
end

function dist_nbs(x,y,target)

			local ind
			
   if x-1 >= 0 then
   
				--calc new distance
	   new_dist(x-1,y,target)
	   
	   ind = vectoindex(x-1,y)
	   
    if closed_paths[ind] == nil
   	 and paths[ind] <= 30 then
   	 	if tot_dist[ind] == nil then
   	  	fill_tables(x-1,y,x,y)
   	  elseif new_d < tot_dist[ind] then
				 		fill_tables(x-1,y,x,y)
   	  end
		 	end
	 	end
	 	if x+1 <= 15 then 
	 	
				--calc new distance
	   new_dist(x+1,y,target)
	   
	   ind = vectoindex(x+1,y)
	 	
   	if closed_paths[ind] == nil
   	 and paths[ind] <= 30 then
   	 	if tot_dist[ind] == nil then
   	  	fill_tables(x+1,y,x,y)
   	  elseif new_d < tot_dist[ind] then
				 		fill_tables(x+1,y,x,y)
   	  end
		 	end
	 	end
	 	if y-1 >= 0 then 
	 	
				--calc new distance
	 		new_dist(x,y-1,target)
	 		
	 		ind = vectoindex(x,y-1)
	 	
   	if closed_paths[ind] == nil
   	 and paths[ind] <= 30 then
   	 	if tot_dist[ind] == nil then
   	  	fill_tables(x,y-1,x,y)
   	  elseif new_d < tot_dist[ind] then
				 		fill_tables(x,y-1,x,y)
   	  end
		 	end
	 	end
	 	if y+1 <= 15 then 
	 	
				--calc new distance
	  new_dist(x,y+1,target)
	 	
	 	ind = vectoindex(x,y+1)
	 	
   	if closed_paths[ind] == nil
   	 and paths[ind] <= 30 then
   	 	if tot_dist[ind] == nil then
   	  	fill_tables(x,y+1,x,y)
   	  elseif new_d < tot_dist[ind] then
				 		fill_tables(x,y+1,x,y)
   	  end
		 	end
	 	end
end


function find_smallest_node(target,next_to)
	
	for n, p in pairs(tot_dist) do	
	 if p < smallest_dist 
		 and p ~= nil
		 and closed_paths[n] ~= 1
		 and open_paths[n] == 1
		 then
				if g_dist[n] < smallest_dist_g then
				 mx = indextovec(n)[1]
				 my = indextovec(n)[2]
				 
				 smallest_dist = tot_dist[n]
				 smallest_dist_g = g_dist[n]
				 
				 if smallest_dist_g == 0 then 
				 	found_path = true
				 end
				end
		end
		
	end
	
	return {mx,my}
end

--track back to original pos
function track_back(target,index)
  
	home_found=false
	local x = target[1]
	local y = target[2]

	while not home_found do
	--for i=1,sight do
	 if not home_found then
	 	
	 	local ind = vectoindex(x,y)
	 
	  --add point to track
	  add(v[index].current_path,{x,y})
	 
		 target1 = parent[ind][1]
		 target2 = parent[ind][2]
		 
		 --line((x)*8+3,(y)*8+3,target1*8+3,target2*8+3,8)

			target_sq = {x,y}

			local x2 = parent[ind][1]
			local y2 = parent[ind][2]
		 
		 x = x2
		 y = y2
		 
		 if x == homex and y == homey then
		  home_found = true
		 end
		end
	end
end


-->8
--building tools and objects

function select_tool()
 local n = bs.x + bs.y*11
 if     n==0 then bs.tool = selector
	elseif n==1 then bs.tool = path
	elseif n==2 then bs.tool = toilet
	elseif n==3 then bs.tool = burger_store
	elseif n==4 then bs.tool = balloon_store
	elseif n==5 then bs.tool = milkshake_store
	elseif n==6 then bs.tool = chip_store
	elseif n==7 then bs.tool = chocolate_store
	elseif n==8 then bs.tool = doghnut_store
	elseif n==9 then bs.tool = pub
	
	
	elseif n==11 then bs.tool = dodgems
	elseif n==12 then bs.tool = maze
	elseif n==13 and ferris_wheel.unlocked == true then bs.tool = ferris_wheel
	elseif n==14 and helter_skelter.unlocked == true then bs.tool = helter_skelter
	elseif n==15 and spinner.unlocked == true then bs.tool = spinner
	elseif n==16 and free_fall.unlocked == true then bs.tool = free_fall
	elseif n==17 and pirate_ship.unlocked == true then bs.tool = pirate_ship
	elseif n==18 and roller_coaster.unlocked == true then bs.tool = roller_coaster
	elseif n==19 and log_flume.unlocked == true then bs.tool = log_flume
	elseif n==21 then bs.tool = demolish
 end
end

--place sound
function place_sound()
		if sfx_on then
			sfx(14)
			sfx(15)
		end
end

--place buildings
function place()
	if bs.tool == path 
		and check_spot(1)
		and money >=3 then
		place_path(s.x,s.y)
		money -= 3
	elseif bs.tool == demolish then
	 destroy(s.x,s.y)
	elseif bs.tool.size == 1 
		and check_path(1) 
		and check_spot(1)
		and money >= bs.tool.build_cost then
		money -= bs.tool.build_cost
		add_building(bs.tool,s.x,s.y)
		mset(s.x,s.y,bs.tool.sn)
		add(targets,{s.x,s.y+1})
		place_sound()
	elseif bs.tool.size == 2 
		and check_path(2) 
		and check_spot(2)
		and money >= bs.tool.build_cost then
		money -= bs.tool.build_cost
		local bn2 = add_building(bs.tool,s.x,s.y)
		mset(s.x  ,s.y,bs.tool.sn+16)
		mset(s.x+1,s.y,bs.tool.sn+17)
		add(targets,{s.x  ,s.y+1})
		add(targets,{s.x+1,s.y+1})
		
		place_sound()
		
		if bs.tool.anim ~= nil then
		 b[bn2]:start_anim()
		end
	elseif bs.tool.size == 4 
		and check_path(4) 
		and check_spot(4)
		and money >= bs.tool.build_cost then
		money -= bs.tool.build_cost
		local bn2 = add_building(bs.tool,s.x,s.y)
		mset(s.x  ,s.y  ,bs.tool.sn)
		mset(s.x+1,s.y  ,bs.tool.sn+1)
		mset(s.x  ,s.y+1,bs.tool.sn+16)
		mset(s.x+1,s.y+1,bs.tool.sn+17)
		add(targets,{s.x  ,s.y+2})
		add(targets,{s.x+1,s.y+2})
		
		place_sound()
		
		if bs.tool.anim ~= nil then
		 b[bn2]:start_anim()
		end
	elseif bs.tool.size == 61
		and check_path(61) 
		and check_spot(61)
		and money >= bs.tool.build_cost then
		money -= bs.tool.build_cost
		local bn2 = add_building(bs.tool,s.x,s.y)
		mset(s.x  ,s.y,bs.tool.sn+16)
		mset(s.x+1,s.y,bs.tool.sn+17)
		mset(s.x  ,s.y+1,bs.tool.sn+32)
		mset(s.x+1,s.y+1,bs.tool.sn+33)
		
		add(targets,{s.x  ,s.y+2})
		add(targets,{s.x+1,s.y+2})
		
		
		place_sound()
		
		if bs.tool.anim ~= nil then
		 --b[count(b)]:start_anim()
		 b[bn2]:start_anim()
		end
		
	elseif bs.tool.size == 62
		and check_path(62) 
		and check_spot(62)
		and money >= bs.tool.build_cost then
		money -= bs.tool.build_cost
		local bn2 = add_building(bs.tool,s.x,s.y)
		mset(s.x  ,s.y  ,bs.tool.sn)
		mset(s.x+1,s.y  ,bs.tool.sn+1)
		mset(s.x+2,s.y  ,bs.tool.sn+2)
		mset(s.x  ,s.y+1,bs.tool.sn+16)
		mset(s.x+1,s.y+1,bs.tool.sn+17)
		mset(s.x+2,s.y+1,bs.tool.sn+18)
		
		add(targets,{s.x  ,s.y+2})
		add(targets,{s.x+1,s.y+2})
		add(targets,{s.x+2,s.y+2})
		
		place_sound()
		if bs.tool.anim ~= nil then
		 b[bn2]:start_anim()
		end
	else
	 if sfx_on then
	 	sfx(13)
	 end
	end
end

--check spot is empty
function check_spot(size)

	--local can_place = true
	
	for k, build in pairs(b) do
		for cd in all (build.build_coords) do
			--add(fs,cd)
			--if size == 1 or size == 2 or size == 4 or size == 62 or size == 61 then
				if cd[1] == s.x and cd[2] == s.y then
					return false
				end
			--end
			if size ~= 1 then
				 if cd[1] == s.x+1 and cd[2] == s.y then
				  return false
				end
			end
			if size ~= 1  and size ~= 2 then
				if (cd[1] == s.x and cd[2] == s.y+1)
				 or (cd[1] == s.x+1 and cd[2] == s.y+1) then
				  return false
				end
			end
			if size == 62 then
				 if  (cd[1] == s.x+2 and cd[2] == s.y)
				  or (cd[1] == s.x+2 and cd[2] == s.y+1) then
				  return false
				end
			end
		end
	end
	
	return true
	
end

--check there is a path
function check_path(size)
	if size == 1 or size == 2 then
		if paths[vectoindex(s.x,s.y+1)] >= 16 and
		   paths[vectoindex(s.x,s.y+1)] <= 31 
	  then
	   if size == 2 then
	    if paths[vectoindex(s.x+1,s.y+1)] >= 16 and
		   paths[vectoindex(s.x+1,s.y+1)] <= 31  
	  		then
						return true
					else
						return false
					end
				else 
				 return true
				end
		else
		 	return false
		end
	--[[elseif size == 2 then
		if paths[vectoindex(s.x,s.y+1)] >= 16 and
		   paths[vectoindex(s.x,s.y+1)] <= 31 and
		   paths[vectoindex(s.x+1,s.y+1)] >= 16 and
		   paths[vectoindex(s.x+1,s.y+1)] <= 31  
	  then
				return true
		else
		 	return false
		end--]]
	elseif size == 4 or size == 61 then
		if paths[vectoindex(s.x  ,s.y+2)] >= 16 and
		   paths[vectoindex(s.x  ,s.y+2)] <= 31 and
		   paths[vectoindex(s.x+1,s.y+2)] >= 16 and
		   paths[vectoindex(s.x+1,s.y+2)] <= 31 
		 then
				return true
		else
		 	return false
		end
	elseif size == 62 then
		if paths[vectoindex(s.x  ,s.y+2)] >= 16 and
		   paths[vectoindex(s.x  ,s.y+2)] <= 31 and
		   paths[vectoindex(s.x+1,s.y+2)] >= 16 and
		   paths[vectoindex(s.x+1,s.y+2)] <= 31 and
		   paths[vectoindex(s.x+2,s.y+2)] >= 16 and
		   paths[vectoindex(s.x+2,s.y+2)] <= 31 
		 then
				return true
		else
		 	return false
		end
	else 
	 return false
	end
end

function place_path(x,y)
	mset(x,y,18)
	find_paths(0,0,15,15)
	merge_paths(15,15)
end

--demolish
function destroy(x,y)
 --new_cd = {x,y}

	for i, build in pairs(b) do
	 check_coords(x,y,i,build)
	 
	end
	if sfx_on then 
	  sfx(12)	
	end 
 mset(x,y,32)
	find_paths(0,0,15,15)
 merge_paths(15,15)
end

function check_coords(x,y,i,build)
	for cd in all(build.build_coords) do
  if cd[1] == x
   and cd[2] == y then	
   	if sfx_on then 
   		sfx(12)	
   	end 
   	build.anim = false
	  	for cd in all(build.build_coords) do
			 	mset(cd[1],cd[2],32)
			 end
			 
			 
	  	deli(actions,build.anim_id)
	  	--deli(b,i)
	  	b[build.bn2] = nil
	  	--deli(b,build.bn)
	  	return
  end
 end
end


function add_building(building,_x,_y)
 local nb = clone(building)
 nb.x = _x
 nb.y = _y
 nb.coord = {} --have multiple coords
 if building.size == 1 then 
  add(nb.coord,{_x,_y+1})
  add(nb.build_coords,{_x,_y})
 	--nb.coord = {_x,_y+1}
 elseif building.size == 2 then
 	add(nb.coord,{_x  ,_y+1})
  add(nb.coord,{_x+1,_y+1})
  add(nb.build_coords,{_x,_y})
  add(nb.build_coords,{_x+1,_y})
 elseif building.size == 4 or building.size == 61 then
 	add(nb.coord,{_x  ,_y+2})
  add(nb.coord,{_x+1,_y+2})
  add(nb.build_coords,{_x,_y})
  add(nb.build_coords,{_x+1,_y})
  add(nb.build_coords,{_x,_y+1})
  add(nb.build_coords,{_x+1,_y+1})
 elseif building.size == 62 then
  add(nb.coord,{_x  ,_y+2})
  add(nb.coord,{_x+1,_y+2})
  add(nb.coord,{_x+2,_y+2})
  add(nb.build_coords,{_x,_y})
  add(nb.build_coords,{_x+1,_y})
  add(nb.build_coords,{_x+2,_y})
  add(nb.build_coords,{_x,_y+1})
  add(nb.build_coords,{_x+1,_y+1})
  add(nb.build_coords,{_x+2,_y+1})
 end
 
 nb.bn = ubn
 nb.bn2 = nb.name..tostr(ubn)
 b[nb.bn2] = nb
-- b[ubn] = nb
--	add(b,nb,ubn)
 ubn+=1
 return nb.bn2
end

--clone the original object to create a new reference
function clone(t)
	local table,k,v={}
	
	for k,v in pairs(t) do
		table[k]=type(v)=="table" and clone(v) or v
	end
	
	return table
end

--define buildings
function building_setup()

 --blank 
 blank = {
  coord = {{8,12}},
		fun = 5,
		cost = 3,
		tm = 0,
		hunger = 0,
		bladder = 0,
 }
  --blank 
 blank2 = {
  coord = {{8,13}},
		fun = 5,
		cost = 3,
		tm = 0,
		hunger = 0,
		bladder = 0,
 }
 add(b,blank)
 add(b,blank2)

 --selector
 selector = {
  name="selector",
  unlocked = true,
  --build_cost = nil,
  --sprite
 	sn = 255
 }
 
 --demolish
 demolish = {
  name = "demolish",
  unlocked = true,
  build_cost = nil,
  --sprite
 	psx = 88,
 	psy = 120,
 	--stats
 	size=0
 }
 
 --paths
 path = {
 	name="path",
 	--place sprite
 	psx=120,
 	psy=104,
 	--stats
 	size = 0,
 	build_cost = 3,
 }
	
	--shops
	balloon_store = {
	 --details
	 name="balloon store",
	 path_type="store",
	 cat="ride",
	 build_coords={},
	 unlocked = true,
	 bn = nil,
	
		--sprite
		sn = 48,
		size = 1,
 	psx=0,
 	psy=24,
	
		--stats
 	size = 1,
		fun = 5,
		cost = 3,
		tm = 2,
		hunger = 0,
		bladder = 0,
 	build_cost = 40,
		
	}
	
	burger_store = {
	 --details
	 name="burger store",
	 path_type="store",
	 cat="store",
	 build_coords={},
	 unlocked = true,
	 bn = nil,
	 
		--sprite
		sn = 49,
		size = 1,
 	psx=8,
 	psy=24,
		
		--stats
 	size = 1,
		fun = 1,
		cost = 5,
		hunger = -70,
		bladder = 40,
		tm = 2,
 	build_cost = 20,
	}
	
	toilet = {
	 --details
	 name="toilets",
	 path_type="store",
	 cat="wc",
	 build_coords={},
	 unlocked = true,
	 bn = nil,
	 
		--sprite
		sn=33,
		size = 1,
		psx=8,
		psy=16,
	
		--stats
 	size = 1,
		fun = -5,
		cost = 1,
		bladder = -100,
		hunger = -5,
		tm = 5,
 	build_cost = 10,
	}
	
	chip_store = {
	 --details
	 name="chip shop",
	 path_type="store",
	 cat="store",
	 build_coords={},
	 unlocked = true,
	 bn = nil,
	 
		--sprite
		sn = 56,
		size = 1,
 	psx=64,
 	psy=24,
		
		--stats
 	size = 1,
		fun = 1,
		cost = 4,
		hunger = -50,
		bladder = 35,
		tm = 2,
 	build_cost = 80,
	}
	
	milkshake_store = {
	 --details
	 name="milk store",
	 path_type="store",
	 cat="store",
	 build_coords={},
	 unlocked = true,
	 bn = nil,
	 
		--sprite
		sn = 55,
		size = 1,
 	psx=56,
 	psy=24,
		
		--stats
 	size = 1,
		fun = 3,
		cost = 6,
		hunger = -30,
		bladder = 40,
		tm = 2,
 	build_cost = 50,
	}
	
	chocolate_store = {
	 --details
	 name="chocolate store",
	 path_type="store",
	 cat="store",
	 build_coords={},
	 unlocked = true,
	 bn = nil,
	 
		--sprite
		sn = 61,
		size = 1,
 	psx=104,
 	psy=24,
		
		--stats
 	size = 1,
		fun = 5,
		cost = 6,
		hunger = -30,
		bladder = 40,
		tm = 2,
 	build_cost = 120,
	}
	
	pub = {
		--details
	 name="pub",
	 path_type="store",
	 cat="store",
	 build_coords={},
	 unlocked = true,
	 bn = nil,
	 
		--sprite
		sn = 62,
		size = 1,
 	psx=112,
 	psy=24,
		
		--stats
 	size = 1,
		fun = 7,
		cost = 10,
		hunger = -50,
		bladder = 50,
		tm = 7,
 	build_cost = 200,
	}
	
	doghnut_store = {
	--details
	 name="doghnut store",
	 path_type="store",
	 cat="store",
	 build_coords={},
	 unlocked = true,
	 unlock_pop = 150,
	 bn = nil,
	 
		--sprite
		sn = 60,
		size = 1,
 	psx=96,
 	psy=24,
		
		--stats
 	size = 1,
		fun = 6,
		cost = 8,
		hunger = -20,
		bladder = 30,
		tm = 3,
 	build_cost = 150,
	}
	
	
	--rides
	dodgems = {
		--details
		name="dodgems",
		cat="ride",
	 build_coords={},
	 bn = nil,
	
	 --sprite
	 sn =34,
		psx=16,
		psy=16,
	
		--stats
 	size = 4,
		fun=20,
		cost=5,		
		tm = 5,
		bladder = 1,
		hunger = 0,
		
		--animation
		anim = false,
		anim_time = 30,
		anim_id = nil,
 	build_cost = 30,
		
		--functions
		start_anim=function(self)
		 self.anim = true
			animate_4(self.x,self.y,self.sn,self)
		end
	}
	
	maze = {
		--details
		name="maze",
		cat="ride",
	 build_coords={},
	 bn = nil,
		
	 --sprite
	 sn =106,
		psx=80,
		psy=48,
	
		--stats
 	size=4,
		fun=23,
		cost=5,		
		tm = 8,
		bladder = 5,
		hunger = 5,
		
		--animation
		anim = false,
		anim_time = 30,
		anim_id = nil,
 	build_cost = 50,
		
		--functions
		start_anim=function(self)
		 self.anim = true
			animate_4(self.x,self.y,self.sn,self)
		end
	}
	
	helter_skelter = {
		--details
		name="helter skelter",
		cat="ride",
	 build_coords={},
	 bn = nil,
		
	 --sprite
	 sn =140,
		psx=86,
		psy=64,
	
		--stats
 	size=4,
		fun=25,
		cost=4,		
		tm = 4,
		bladder = 0,
		hunger = 0,
 	build_cost = 250,
 	unlocked = false,
		
		--animation
		anim = false,
		anim_time = 30,
		anim_id = nil,
		
		--functions
		start_anim=function(self)
		 self.anim = true
			animate_4(self.x,self.y,self.sn,self)
		end
	}
	
	pirate_ship = {
		--details
		name="pirate ship",
		cat="ride",
	 build_coords={},
	 bn = nil,
		
	 --sprite
	 sn =136,
		psx=64,
		psy=64,
	
		--stats
 	size=4,
		fun=20,
		cost=10,		
		tm = 5,
		bladder = 5,
		hunger = -10,
 	build_cost = 1500,
 	unlocked = false,
		
		--animation
		anim = false,
		anim_time = 30,
		anim_id = nil,
		
		--functions
		start_anim=function(self)
		 self.anim = true
			animate_4(self.x,self.y,self.sn,self)
		end
	}
	
	
	
	spinner = {
		--details
		name="spinner",
		cat="ride",
	 build_coords={},
	 bn = nil,
		
	 --sprite
	 sn =74,
		psx=nil,
		psy=nil,
	
		--stats
 	size=2,
		fun=27,
		cost=6,		
		tm = 7,
		bladder = 10,
		hunger = 0,
 	build_cost = 500,
 	unlocked = false,
		
		--animation
		anim = false,
		anim_time = 20,
		psx1=96,
		psy1=32,
		psx2=96,
		psy2=40,
		anim_id = nil,
		
		--functions
		start_anim=function(self)
		 self.anim = true
			animate_2_spin(self.x,self.y,self.sn,self)
		end
	}
	
	
	ferris_wheel = {
		--details
		name="ferris wheel",
		cat="ride",
	 build_coords={},
	 bn = nil,
		
	 --sprite
	 sn =70,
		psx=48,
		psy=32,
	
		--stats
 	size=61,
		fun=30,
		cost=9,
		tm = 10,
		bladder = 5,
		hunger = 0,
 	build_cost = 130,
 	unlocked = false,
		
		--animation
		anim = false,
		anim_time = 30,
		psx1=48,
		psy1=32,
		psx2=64,
		psy2=32,
		anim_id = nil,
		
		--functions
		start_anim=function(self)
		 self.anim = true
		 --b[self.bn2].anim = true
			animate_61(self.x,self.y,self.sn,self,self.bn)
		end
	}
	
	free_fall = {
		--details
		name="free fall",
		cat="ride",
	 build_coords={},
	 bn = nil,
		
	 --sprite
	 sn =128,
		psx=0,
		psy=64,
	
		--stats
 	size=61,
		fun=35,
		cost=12,
		tm = 8,		
		bladder = 5,
		hunger = 0,
 	build_cost = 700,
 	unlocked = false,
		
		--animation
		anim = false,
		anim_time = 60,
		psx1=0,
		psy1=64,
		psx2=16,
		psy2=64,
		anim_id = nil,
		
		--functions
		start_anim=function(self)
		 self.anim = true
			animate_61(self.x,self.y,self.sn,self)
		end
	}
	
	roller_coaster = {
		--details
		name="roller coaster",
		cat="ride",
	 build_coords={},
	 bn = nil,
		
	 --sprite
	 sn =64,
		psx=0,
		psy=32,
	
		--stats
 	size=62,
		fun=60,
		cost=25,
		tm = 14,	
		bladder = 15,
		hunger = 0,	
 	build_cost = 3500,
 	unlocked = false,
		
		--animation
		anim = false,
		anim_time = 10,
		anim_id = nil,
		
		--functions
		start_anim=function(self)
		 self.anim = true
			animate_62(self.x,self.y,self.sn,self)
		end
	}
	
	log_flume = {
		--details
		name="log flume",
		cat="ride",
	 build_coords={},
	 bn = nil,
		
	 --sprite
	 sn =96,
		psx=0,
		psy=48,
	
		--stats
 	size=62,
		fun=60,
		cost=30,
		tm = 12,		
		bladder = 5,
		hunger = 0,
 	build_cost = 7000,
 	unlocked = false,
		
		--animation
		anim = false,
		anim_time = 10,
		anim_id = nil,
		
		--functions
		start_anim=function(self)
		 self.anim = true
			animate_62(self.x,self.y,self.sn,self)
		end
	}
	
end
-->8
--selector and input
function setup_selector()
	s = {
	
	--position
	x = 1,
	y = 1,
	
	--sprite sheet
	sx=120,
	sy=120,
	sw=8,
	sh=8
	}
end

--imput
function input()
	if bottom_bar then
	 bar_input()
 elseif in_game then
		game_input() 
	elseif open_build_menu then
	 build_menu_input()
	elseif open_records then
		records_input()
	elseif open_options then
	 options_input()
	end
end

function bar_input() 
 --selector
	if btnp(⬅️) then
		u.x = mid(0,u.x-1,2)
	elseif btnp(➡️) then
		u.x = mid(0,u.x+1,2)
	elseif (btnp(❎)) then
	 --select
	 if u.x == 0 then
	  bottom_bar = not bottom_bar
	 	open_build_menu = not open_build_menu
	 elseif u.x == 1 then
	  
	  bottom_bar = not bottom_bar
	 	open_records = not open_records
	 elseif u.x == 2 then
	 
	  bottom_bar = not bottom_bar
	 	open_options = not open_options
	 end
	elseif (btnp(🅾️)) then
	 --nothing
	end
end

function game_input() 
 --selector
	if btnp(⬅️) then
		s.x = mid(1,s.x-1,14)
	elseif btnp(➡️) then
		s.x = mid(1,s.x+1,14)
	elseif btnp(⬆️) then
		s.y = mid(1,s.y-1,12)
	elseif btnp(⬇️) then
		s.y = mid(1,s.y+1,12)
	elseif (btnp(❎)) then
		place()
	elseif (btnp(🅾️)) then
	 open_build_menu = not open_build_menu
	 in_game = not in_game
	 --draw_paths()
	end
end

function build_menu_input()
	if btnp(⬅️) then
		bs.x = mid(0,bs.x-1,10)
	elseif btnp(➡️) then
		bs.x = mid(0,bs.x+1,10)
	elseif btnp(⬆️) then
		bs.y = mid(0,bs.y-1,1)
	elseif btnp(⬇️) then
		bs.y = mid(0,bs.y+1,1)
	elseif btnp(❎) then
		select_tool()
		open_build_menu = not open_build_menu
	 in_game = not in_game
	elseif (btnp(🅾️)) then
	 open_build_menu = not open_build_menu
	 bottom_bar = not bottom_bar
	end
end

function setup_options_selector()
	os = {}
	os.y = 0
end

function options_input()
	if btnp(⬆️) then
		os.y = mid(0,os.y-1,1)
	elseif btnp(⬇️) then
		os.y = mid(0,os.y+1,1)
	elseif btnp(❎) then
		if os.y == 0 then
			sfx_on = not sfx_on
		elseif os.y == 1 then
		 music_on = not music_on
		 if not music_on then
		 	music(-1,100)
		 else
		  music(0,100)
		 end 
		end 
	elseif (btnp(🅾️)) then
	 open_options = not open_options
	 bottom_bar = not bottom_bar
	end
end

--records input
function records_input()
	if btnp(❎) or btnp(🅾️) then
		bottom_bar = not bottom_bar
	 	open_records = not open_records
	end
end

--build menu
--[[
function open_build_menu()
	open_build = true
end
--]]
-->8
--animations
function animate_61(x,y,pn,obj,bn2)
	local c = cocreate(function()
		while obj.anim == true do
		 --first frame
		 if obj.anim == true then
			 obj.psx=obj.psx1
			 obj.psy=obj.psy1 
			 
			 mset(x  ,y,pn+16)
			 mset(x+1,y,pn+17)
			 mset(x  ,y+1,pn+32)
			 mset(x+1,y+1,pn+33)
		 end
		 
		 for i=1,obj.anim_time do
		 	yield()
		 end
		 
		 --second frame
		 if obj.anim == true then
			 obj.psx=obj.psx2
			 obj.psy=obj.psy2
			 
			 mset(x  ,y,pn+18)
			 mset(x+1,y,pn+19)
			 mset(x  ,y+1,pn+34)
			 mset(x+1,y+1,pn+35)
		 end
		 
		 for i=1,obj.anim_time do
		 	yield()
		 end
		 
	 end
	end)
	add(actions,c)
end

function animate_62(x,y,pn,obj)
	local c = cocreate(function()
		while obj.anim == true do
		 
		 
		 if obj.anim == true then
			 --first frame
			 mset(x  ,y  ,pn)
			 mset(x+1,y  ,pn+1)
			 mset(x+2,y  ,pn+2)
			 mset(x  ,y+1,pn+16)
			 mset(x+1,y+1,pn+17)
			 mset(x+2,y+1,pn+18)
			 for i=1,obj.anim_time*3 do
			 	yield()
			 end
			 
			end
		 
		 --second frame
		 
		 if obj.anim == true then
			 mset(x+2,y,pn+5)
			 for i=1,obj.anim_time do
			 	yield()
			 end
		 end
		 
		 --third frame
		 if obj.anim == true then
			 mset(x+2,y,pn+2)
			 mset(x+1,y,pn+4)
			 for i=1,obj.anim_time do
			 	yield()
			 end
		 end
		 
		 --fourth frame
		 if obj.anim == true then
			 mset(x+1,y,pn+1)
			 mset(x ,y  ,pn +3)
			 for i=1,obj.anim_time do
			 	yield()
			 end
		 end
		 
		 --fifth frame
		 if obj.anim == true then
			 mset(x ,y  ,pn)
			 mset(x+1,y+1,pn+20)
			 for i=1,obj.anim_time do
			 	yield()
			 end
		 end
		 
		 --sixth frame
		 if obj.anim == true then
			 mset(x+1,y+1,pn+17)
			 mset(x+2,y+1,pn+21)
			 for i=1,obj.anim_time do
			 	yield()
			 end
		 end
		 
	 end
	end)
	add(actions,c)
end

function animate_4(x,y,pn,obj)
	local c = cocreate(function()
		while obj.anim == true do
		 
		 --first frame
		 if obj.anim == true then
			 mset(x  ,y  ,pn)
			 mset(x+1,y  ,pn+1)
			 mset(x  ,y+1,pn+16)
			 mset(x+1,y+1,pn+17)
			 
			 for i=1,obj.anim_time do
			 	yield()
			 end
		 end
		 
		 --second frame
		 if obj.anim == true then
			 mset(x  ,y  ,pn+2)
			 mset(x+1,y  ,pn+3)
			 mset(x  ,y+1,pn+18)
			 mset(x+1,y+1,pn+19)
			 
			 for i=1,obj.anim_time do
			 	yield()
			 end
		 end
		 
	 end
	end)
	add(actions,c)
	obj.anim_id = count(actions)
end

function animate_2_spin(x,y,pn,obj)
	local c = cocreate(function()
		while obj.anim == true do
		 
		 --first frame
		 if obj.anim == true then
			 obj.psx=nil
			 obj.psy=nil
			 
			 mset(x  ,y,pn+16)
			 mset(x+1,y,pn+17)
			 
			 for i=1,obj.anim_time*4 do
			 	yield()
			 end
		 end		 
		 --second frame
		 if obj.anim == true then
			 obj.psx=obj.psx1
			 obj.psy=obj.psy1
			 
			 mset(x  ,y,pn)
			 mset(x+1,y,pn+1)
			 
			 for i=1,obj.anim_time do
			 	yield()
			 end
		 end
		 
		 --third frame
		 if obj.anim == true then
			 obj.psx=obj.psx2
			 obj.psy=obj.psy2
			 
			 
			 for i=1,obj.anim_time do
			 	yield()
			 end
		 end
		 
		 --second frame
		 if obj.anim == true then
			 obj.psx=obj.psx1
			 obj.psy=obj.psy1
			 
			 for i=1,obj.anim_time do
			 	yield()
			 end
		 end
		 
		 --third frame
		 if obj.anim == true then
			 obj.psx=obj.psx2
			 obj.psy=obj.psy2
			 
			 for i=1,obj.anim_time do
			 	yield()
			 end
		 end
		 
	 end
	end)
	add(actions,c)
end
-->8
--ui
function setup_ui()
	--ui variables
	--stats
	money = 100
	happiness = 50
	
	--ui selector
	u = {}
	u.x = 0
	u.y = 0
end

function draw_ui_frame()
	
	sspr(0 ,118,8,10,0,15*8-2)
	for i=0,15 do
		sspr(8,118,8,10,8+(i*8) ,15*8-2)
	end
	sspr(16,118,8,10,15*8,15*8-2)
	
	--selector
	sspr(0,108,20,10,0+(u.x*25),15*8-2)
	
	sspr(48,120,8,8,6,15*8-1)
	sspr(32,120,8,8,31,15*8-1)
	sspr(40,120,8,8,56,15*8-1)
	
	--population
	sspr(24,120,8,8,70,15*8-1)
	print(no_v,80,15*8+1,1)
	print(no_v,80,15*8,7)
	
	--happiness
	if happiness >= 70 then
		sspr(72,120,8,8,92,15*8-1)
	elseif happiness >= 40 then
		sspr(64,120,8,8,92,15*8-1)
	elseif happiness < 40 then
		sspr(56,120,8,8,92,15*8-1)
	end
	
	--moneys
	print_bold("$"..money,102,15*8,7)
end

--draw records
function draw_records()
	rectfill(20,20,108,85,13)
	rect(20,20,108,85,7)
	
	print_bold("records",51,30,7)
	
	print_bold("visitors: ".. max_visitors,31,50,7)
	
	print_bold("avg happiness: ".. ceil(max_happiness),31,60,7)
	
	print_bold("money: ".. max_money,31,70,7)
end

--draw optionss
function draw_options()
	rectfill(20,20,108,85,13)
	rect(20,20,108,85,7)
	
	print_bold("options",51,30,7)
	
	if music_on then
		music_text = "on"
	else
	 music_text = "off"
	end
	
	if sfx_on then
		sfx_text = "on"
	else
	 sfx_text = "off"
	end
	
	if os.y == 0 then
		opt1_col = 10
		opt2_col = 7
	else 
	 opt1_col = 7
	 opt2_col = 10
	end
	
	print_bold("sfx: "..sfx_text ,31,50,opt1_col)
	print_bold("music: "..music_text ,31,65,opt2_col)

end


--get the average happiness stat
function update_happiness()
 local ht = 0
	for v in all(v) do
		ht += v.happy
	end
	
	happiness = ht / count(v)
	
end

function passive_change()
 for v in all(v) do
		v.hunger  = mid(0,v.hunger+0.01,100)
		v.bladder = mid(0,v.bladder+0.01,100)
		v.happy = mid(0,v.happy,100)
		
		if v.hunger > 90 or v.bladder > 90 then
			v.happy -= 0.1
		end
	end
end
-->8
--unlocks
function setup_unlocks()
	all_b = {ferris_wheel, helter_skelter,
	         spinner, free_fall,
	         pirate_ship, roller_coaster,
	         log_flume}
end

function check_unlocks()
	if money > 130 then ferris_wheel.unlocked = true end
	if money > 250 then helter_skelter.unlocked = true end
	if money > 500 then spinner.unlocked = true end
	if money > 700 then free_fall.unlocked = true end
	if money > 1500 then pirate_ship.unlocked = true end
	if money > 3500 then roller_coaster.unlocked = true end
	if money > 7000 then log_flume.unlocked = true end
end

--records
--[[
function setup_records()
	
	max_visitors = 0
	max_happiness = 0
	max_money = 0
	
end
--]]

function check_records()
	
	if max_visitors < no_v then
		max_visitors = no_v
		dset(0,max_visitors)
	end
	if max_happiness < happiness and no_v ~= 0 then
		max_happiness = happiness
		dset(1,max_happiness)
	end
	if max_money < money then
		max_money = money
		dset(2,max_money)
	end
	
end
-->8
--general functions
function print_bold(text,x,y,col)
	print(text,x,y+1,1)
	print(text,x,y,col)
end

function print_bold2(text,x,y,col)
	print(text,x,y+1,1)
	print(text,x,y-1,1)
	print(text,x+1,y,1)
	print(text,x-1,y,1)
	print(text,x,y,col)
end

function get_rcount()
 local n = 0
		for k, v in pairs(b) do
		 n+=1
		end
	return n
end
-->8
--save data
function setup_save()
	cartdata("joseph_themepark_v1")

	--0 is visitors
	max_visitors = dget(0)
	--1 is happiness
	max_happiness = dget(1)
	--2 is money
	max_money = dget(2)
	
	--reset
	--dset(0,0)
	--dset(1,0)
	--dset(2,0)
	
end

-->8
--main menu
--draw opening menu
function draw_start_menu()
	map(32,0,0,0,128,64)
	
	print_bold2("by Owen",48,40,7)
	print_bold2("@josephmakesgame",33,50,7)
	
 --start text col
 tcol_tick += 1
  if tcol_tick >= 30 then
  	if tcol == 7 then
  		tcol = 10
  	else 
  	 tcol = 7
  	end
  	tcol_tick = 0
  end

	print("press ❎ to start a park!",16,62,1)
	print("press ❎ to start a park!",16,61,tcol)

	if btnp(❎) then
		start_menu = false
		bottom_bar = true
	end
end

--start animation
function start_anim()
	-- fake vis
	fv = {}
	for i=1,20 do
	
		local _x = rnd(17)*8
		local _y = 14*8+2 + rnd(4)
		
		local _fc = vis_col[flr(rnd(3)+1)]
		local _sc = vis_shirt_col[flr(rnd(3)+1)]
	
		local _spd = rnd(0.2) + 0.1
		local _dir = flr(rnd(2)) 
	
		add(fv,{
			x = _x,
			y = _y,
			fc=_fc,
			sc=_sc,
			spd=_spd,
			dir=_dir
		})
	end
end

function draw_fv()

	for fvis in all(fv) do
	
		pset(fvis.x,fvis.y-1,fvis.fc)
		pset(fvis.x,fvis.y,fvis.sc)
		
		if fvis.dir == 0 then
			fvis.x += fvis.spd
		else 
			fvis.x -= fvis.spd
		end
		
		if fvis.x > 17*8 then
			fvis.x = 0
		elseif fvis.x < 0 then
		 fvis.x = 16*8
		end
	end
	
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffff3333333377777777
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666333ff33377777777
007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555555533ffff3377777777
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555553ffffff377777777
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555553ffffff377777777
007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555555533ffff3377777777
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555555333ff33377777777
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555777753333333377777777
33ffff333333333333ffff3333ffff3333ffff3333333333333333333333333333ffff3333ffff3333ffff33333333333333333333ffff333333333355effe55
33ffff33333333333ffffff333fffff33fffff3333333333333333333333333333fffff33ffffff33fffff33333333333333333333ffff3333333333bebffbeb
33ffff33ffffffffffffffff33ffffffffffff33ffff33333333ffffffffffff33ffffffffffffffffffff33333333333333ffff33ffff33fffff333333ff333
33ffff33ffffffffffffffff33ffffffffffff33fffff333333fffffffffffff33ffffffffffffffffffff33333ff333333fffff33ffff33ffffff33ffffffff
33ffff33ffffffffffffffff333ffffffffff333ffffff3333ffffffffffffff33ffffffffffffffffffff3333ffff33333fffff333ff333ffffff33ffffffff
33ffff33ffffffffffffffff3333ffffffff3333ffffff3333ffffffffffffff33ffffffffffffffffffff3333ffff333333ffff33333333fffff333bebffbeb
33ffff33333333333ffffff333333333333333333fffff3333fffff33ffffff333fffff3333333333fffff3333ffff3333333333333333333333333333effe33
33ffff333333333333ffff33333333333333333333ffff3333ffff3333ffff3333ffff333333333333ffff3333ffff3333333333333333333333333355bffb55
3333333377733777333333333333333333333333333333333333733333333333333333333333333377377377377337737737737700000000333333e3333333a3
33333333666bb6663333333333333333333333333333333333336333333333333333333333333333dd6dd6dd6dd66dd6dd6dd6dd00000000e33e33b3a33a33b3
3333333361633616336666666666663333666666666666333337333333733373333333733733333376666666666666666666666700000000b3eb3e33b3ab3a33
33333333ffffffff36dddddddddddd6336dddddddddddd6333363333736373633333736336373333d6666666666666666666666d0000000033b3eb3e33b3ab3a
33333333777ff7773655555555555563365555555555556333337333633363333333633333363333776776776776677677677677000000003e33b33b3a33b33b
33333333666ff6663655cc55555bb5633655ccbb5555556333336333333333333337333333337333dd6dd6dd6dd66dd6dd6dd6dd000000003b33e3e33b33a3a3
33333333616ff6163655115555533563365511335555556333373333333333333336333333336333dddddddddddddddddddddddd00000000e33eb3b3a33ab3b3
33333333ffffffff36555555aacc55633655555aacc5556333363333333333333333333333333333dddddddddddddddddddddddd00000000b33b3333b33b3333
38833aa333aaaa33365555559911556336555559911555633333e333336633333333333333333333333333333a3aa3a333aaaa33336637333333333333333383
8228a99a3a9999a336555bb5555555633655555555bb5563333e8e3333dd377333a3a3a33333333337733773393993933a9999a33355767333777733833833b3
22e299a9399999933655533555555563365555555533556333788873337d7663339a9a933333933336677663a9a99a9a399999933395666333666633b38b3833
22229999344444433d666665566666d33d666665566666d333678763336666633399999333994993366666639999999939933993334444333399993333b38b38
322339933464464333ddddd55ddddd3333ddddd55ddddd333366666333e9e9e333899983334444433366663339999993399aa99333444433339999333833b33b
336776333995599333333ffffff3333333333ffffff333333e66666e33e9e9e3e3e888e33334443333366333339999333999999333454433339559333b338383
33f66f33333ff3333b3b33ffff33b3b33b3b33ffff33b3b33b36563b83e959e8b3885883336464633dd55dd3377997733b9559b33bfffb33b33ff33b8338b3b3
3ffffff33b3ff3b333b3b33ff33b3b3333b3b33ff33b3b333333f333b33fff3b33bfffb333ddddd3355555533666666333bffb33b3fff3b33b3ff3b3b33b3333
339999333339999333333333339997dd333777933333333300000000000000000000000000000000337633333333673300000000000000003333333333333333
394444993394334933333993394447773397dd493333399300000000000000000000000000000000336633333333663300000000000000003333333333333333
349933449993ee3933399449349933449993ee393339944900000000000000000000000000000000336333333333363300000aaaaaa000003333333773333333
3444934344988889399443393444934344988889399443390000007ee70000000000007777000000336333333333363300077aaaaaa770003333333663333333
343349434393ee3994434394343349434393ee399443dd7400007762267700000000ee6666ee0000336333333333363300066999999660003333333ee3333333
34334493439333944343994434334493439333944343777400076606606670000007220660227000336335555553363300060999999060003333333883333333
34334349334999434399443434334349334999434399443400ee00066000ee000076000660006700336335555553363300060000000060003333333773333333
34334343999944999944343434334343999944999944343400227006600722000ee6700660076ee0333ffffffffff33300060000000060003333333663333333
33737373444493443933333333737373444493443933333337636736637636733223673663763223337733333333773300000000000000003333333663333333
33d6d6d3333349333493333333d6d6d3333349333493333336333676676333633633367667633363336633333333663300000000000000003333999669993333
3b66666b33333933334993333b66666b33333933334997ddee777766667777ee3677776666777763336633333333663300000999999000003333444664443333
b3767673b339943333344993b3767673b3399433333447772266666666666622366666666666666333663aaaaaa366330007799999977000333ff446644ff333
33d6d6d3399443333333344933d6d6d3399443333333344936733766667337633ee3376666733ee333667aaaaaa7663300066aaaaaa66000333ffff66ffff333
33ddddd3944333399333399433ddddd3944dd7399333399433637636636736333223763663673223336669999996663300060aaaaaa060003333337667333333
b3dd5dd34999999449999443b3dd5dd3499777944999944333ee63366336ee333367633663367633336639999993663300060000000060003333336666333333
3b3ff33b34444443344443333b3ff33b344444433444433333227736637722333336ee3663ee6333333ffffffffff333000600000000600033333ffffff33333
3333333333333333333333333333333333333333333333333337667ee76673333337227667227333999999999999999999999999999999993333333333333333
33ccc333333333333333333333ccc3333333333333333333377667622676677337766766667667739444944f49494449944f9444494944493333333333333333
3cccccc333333333333333333cccccc33333333333333333366666666666666336666666666666639393439934393939939a4399343939393339333773333333
cc111cccc33333333333733755111cccc4533333333373373333ff3333ff33333333ff3333ff3333939999943999393993999994399939393394333663333333
cc33111cccc333333333d66d5533111cc44553333333d66db333ffffffff333bb333ffffffff333b93444493994439f993444493994439393344333663333333
cc3313311cccc33333336666443313311cc443333333666633333ffffff3333333333ffffff3333393999393443999c993999f93443999393344eeeeeeee3333
cc331333111cccc333337667cc331333111cccc3455376673b33333ff33333b33b33333ff33333b3999443999999443999944899999944393344888778883333
1cccc33313311cccccccd66d1cccc33313311ccc444cd66d333b3b3ff3b3b333333b3b3ff3b3b333944393444449399994439344444939993344888668883333
11cccc331333111ccccc666611cccc331337661ccc6c667633333383333333833333338333333383939999799799344993999979979934493344333663333333
13111cc3133313311111766713111cc31376176111177667833833b3833833b3833833b3833833b39f4444d66d443939934444d66d44f9393344337667333333
131331cc333333333333d66d131331cc333376373367676db38b3833b38b3833b38b3833b38b38339899936666333939939993666633c9393334336666333333
1313311cc3333333333366661313311cc55463663556767633b38b7ee7b38b3833b38b7777b38b3893449376673939399344937667393939333ffff66ffff333
13133131cccccccccccc766713133131c444c67c74677667383377622677b33b3833ee6666eeb33b999999d66d999999999999d66d999999333ffff66ffff333
331331331cccccccccccd66d331331331ccc6c6cc776767d3b3766866b6673833b3722866b227383444444dddd444444444444dddd4444443333337667333333
33133133311111111111dddd33133133311111111117dd7d83eeb3b66338eeb38376b3b6633867b3bbbbbbd5ddbbbbbbbbbbbbd5ddbbbbbb3333336666333333
33333333333333333333dd5d33333333333333333333775db322733663372233bee6733663376ee3333333ffff333333333333ffff33333333333ffffff33333
0000000cc00000000000000cc0000000cccccccccccccccccccccccccccccccc333333333333333333333333333333333333333e77333333333333377e333333
000000c88c000000000000c88c000000cccccc2222cccccccccccc4444cccccc3333333393333333333337779333333333333338663333333333333668333333
000000888800000000000a8888a00000cccc22eeee22cccccccc44aaaa44cccc33333777433333333333366647777733333333a99ea33333333333a99ea33333
00000080080000000000aa8008aa0000ccc2eeeeeeee2cccccc4aaaaaaaa4ccc3333366647777333333336664666663333333399e993333333333399e9933333
00000080080000000000a999999a0000cc288888888882cccc499999999994cc333336664666633333333666466666333333339e995333333333339e99533333
0000008cc8000000000099aaaa990000cc288eee8ee882cccc499aaa9aa994cc33333666466663333333366646666333333333e999773333333333e999773333
00000088880000000000099999900000cc2888e88ee882cccc4999a99aa994cc3333336646663333333333664666633333333a994766333333333a997f663333
00000080080000000000008008000000cc2888e88e8882cccc4999a99a9994cc3333336646633333333333664666333333333977669e333333333977669e3333
33333383383333333333338338333333ccc2888888882cccccc4999999994ccc399999364339999339999936433999933333f76699e933333333746699e93333
3333338cc83333333333338cc8333333ccc2eeeeeeee2cccccc4aaaaaaaa4ccc3446449949944643344a449949944a43333366999e993333333366999e993333
33333388883333333333338888333333cccc2eeeeee2cccccccc4aaaaaa4cccc334544444644454333a7a4444a44a7a33333a999e997f3333333a999e99f7333
33333383383333333333338338333333ccccc2eeee2cccccccccc4aaaa4ccccc3334444445444443333a4444a7a44a433333999e977663333333999e97766333
33333383383333333333338338333333cccccc2222cccccccccccc4444cccccc3333444444444443333344444a444443333a997746669a33333a997776669a33
33333a8cc8a333333333338cc8333333cccccc1cc1cccccccccccc1cc1cccccc3333344445544433333334444554443333397766669959333339476666995933
3333aa8888aa33333333338888333333cccccc1111cccccccccccc1111cccccc33333333ffff333333333333ffff33333b3f6633333fff3b3b3f6633333fff3b
3333a999999a33333333338338333333ccccccc11cccccccccccccc11ccccccc33b3b3b3ffff33b333b3b3b3ffff33b333bfffffffffffb333bfffffffffffb3
bbbb99dddd99bbbbbbbbbc8cc8cbbbbbcc0770077077007707700770777700ccc00000000ccccccccccccccccccccccccc000000cccccccccccccccccccccccc
b3b3c999999c3b3bb3b3cc8cc8cc3b3bcc07777770777777077777707777700cc07777770cccccccccccccccccccccccc00777700ccccccccccccccccccccccc
bfbfc888888cfbfbbfbfc888888cfbfbcc077777707777770777770077077700c07777770cccccccccccccccccccccccc07777770ccccccccccccccccccccccc
bfbf88888888fbfbbfbf88888888fbfbcc077000007700770770777077007770c0777777000000000000000000000000c07777770000000000000000000000cc
bfbf33333333fbfbbfbf33333333fbfbcc0770ccc07700770770077077000770c0007700000770777707700077077770c07700770077770077777007700770cc
bfbffffffffffbfbbfbffffffffffbfbcc0770ccc000000000000000000c0000ccc07707700770777707770777077770c07700770777777077777707700770cc
bfbbbbbffbbbbbfbbfbbbbbffbbbbbfbcc0770ccccccccccccccccccccccccccccc07707700770777707777777077770c07777770777777077777707707770cc
3f33333ff33333f33f33333ff33333f3cc0770ccccccccccccccccccccccccccccc07707700770770007777777077000c07777770770077077007707777700cc
333333ecc33333e3333333ecc33333e3cc0000ccccccccccccccccccccccccccccc07707777770777007707077077700c0777770077007707700770777700ccc
e33e33c88c3e33b3e33e33c88c3e33b3ccccccccccccccccccccccccccccccccccc07707777770777007700077077700c07700000777777077777707777700cc
b3eb3e8888eb3e33b3eb3a8888ab3e33ccccccccccccccccccccccccccccccccccc07707777770770007700077077000c0770ccc07777770777770077077700c
33b3eb8e38b3eb3e33b3aa8e38aaeb3eccccccccccccccccccccccccccccccccccc07707700770777707700077077770c0770ccc07700770770777077007770c
3e33b38b3833b33b3e33a999999ab33bccccccccccccccccccccccccccccccccccc07707700770777707700077077770c0770ccc07700770770077077000770c
3b33e38cc833e3e33b3399aaaa99e3e3ccccccccccccccccccccccccccccccccccc00000000000000000000000000000c0000ccc000000000000000000c0000c
e33eb388883eb3b3e33eb999999eb3b3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
b33b3383b83b3333b33b3383b83b3333cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0000004444444444444444cccccccccccccccc999999999900000000000000000000000000000000000000000000000000000000000000000000000000000000
00004499999999999999cc6666666666666699aaaaaaaaaa00011100000110000000000000011000010000100000000000011100010110100000000000000000
004499999999999999cc6666666666666699aaaaaaaaaaaa00111110000110000000000000011000010000100000000000100010001001000000000000000000
004999999999999999c6666666666666669aaaaaaaaaaaaa00111110001111000011110000011000010000100000000000100010010000100000000000000000
04999999999999999c6666666666666669aaaaaaaaaaaaaa01111110001111000111111000111100011111100000000001110100010000100000000000000000
04999999999999999c6666666666666669aaaaaaaaaaaaaa01111110011111100111111000011000011111100000000001111000001001000000000000000000
4999999999999999c6666666666666669aaaaaaaaaaaaaaa00111100011111100111111000111100010000100000000001110110010110100000000000000000
4999999999999999c6666666666666669aaaaaaaaaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000079700000aa00000000000000cc0000700007009990990000999000e0770e000dddd0000ffff00
000000000000000000000000000000000000000000000000007646700009e0000000000000088000060000600449044000900090007007000d1111d00ffffff0
0000000000000000000000000000000000000000000000000066466000ae9a000045550000088000060000600909090000900090070000700d5535d00ffffff0
1111111111111111111c00000000000000000000000000000999499000e99e000c4444c00099990006aaaa60090409000cdd0900070000700d5955d00ffffff0
1cccccccccccccccccc60000000000000000000000000000044444400a99e9a00cccccc00008800006999960090999900ccc90000070070001dddd100ffffff0
1cccccccccccccccccc6000000000000000000000000000000444400099e999001111110008888000600006004044440099909900e0770e00011110000ffff00
1cccccccccccccccccc6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1cccccccccccccccccc6000033333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000008888880
1cccccccccccccccccc6000033333333333333330660070000777700000990000000a000006600000000000007700770009f9f000088000003f3f33088889988
1cccccccccccccccccc60000333333333333333300607770007777000099990000a0aa000006770007070770070000700999999008878a000ffffff088889098
1cccccccccccccccccc6ff00733333b333bbb3b300444700009999000990099000aaaa0000777700070707000000000000bbbb0008888a700ffffff089989098
1cccccccccccccccccc6ff0063b3b3b333b3b3b3004444000099990009900990008aa80000e9e9000777070000000000004444000088aaa003fffff088999998
c6666666666666666666ff0033b3b3b333b3b3b30044440000999900009999000088880000e9e9000777077007000070099999900006aa000ffffff088955958
66666666666666666666666d333b33b3b3bbb3b30044440000999900000990000088880000e9e9000000000007700770009999000006000003f3ff3089955958
6dddddddddddddddddddddd533333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000008888880
6dddddddddddddddddddddd500000000000000000000000000000000000000000000000000000000000bbbb00000000000000000cccccccc0cccccc077000077
6dddddddddddddddddddddd50000000000aaaa00000770000050000000eeee0000aaaa0000bbbb00000333300800008000077000c000000cc000000c70000007
6dddddddddddddddddddddd5009904400a9999a000766700074707700e5ee5e00a5aa5a00b5bb5b0000300000080080000777700c0cccc0cc000000c00000000
6dddddddddddddddddddddd5009904400999999007666670066606600eeeeee00aaaaaa00bbbbbb000b3bb000008800007777770c0c00c0cc000000c00000000
6dddddddddddddddddddddd500ee05500099990006600660004006600ee55ee00aaaaaa00b5bb5b0003333000008800000077000c0c00c0cc000000c00000000
6dddddddddddddddddddddd500ee055000a99a0006677660004006600e5ee5e00a5555a00bb55bb0000300000080080000077000c0cccc0cc000000c00000000
6dddddddddddddddddddddd50000000000999900006666000040040000eeee0000aaaa0000bbbb0000b3bbb00800008000077000c000000cc000000c70000007
d5555555555555555555555500000000000000000000000000000000000000000000000000000000003333300000000000000000cccccccc0cccccc077000077
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccc2222cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc22eeee22cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccc2eeeeeeee2ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc288888888882cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc288eee8ee882cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc2888e88ee882cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc2888e88e8882cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccc2888888882cccccccccccc00000000ccccccccccccccccccccccccc000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccc2eeeeeeee2cccccccccccc07777770cccccccccccccccccccccccc00777700ccccccccccccccccccccccccccccccccccccc4444cccccccccccccc
cccccccccccc2eeeeee2ccccccccccccc07777770cccccccccccccccccccccccc07777770ccccccccccccccccccccccccccccccccccc44aaaa44cccccccccccc
ccccccccccccc2eeee2cccccccccccccc0777777000000000000000000000000c07777770000000000000000000000ccccccccccccc4aaaaaaaa4ccccccccccc
cccccccccccccc2222ccccccccccccccc0007700000770777707700077077770c07700770077770077777007700770cccccccccccc499999999994cccccccccc
cccccccccccccc1cc1ccccccccccccccccc07707700770777707770777077770c07700770777777077777707700770cccccccccccc499aaa9aa994cccccccccc
cccccccccccccc1111ccccccccccccccccc07707700770777707777777077770c07777770777777077777707707770cccccccccccc4999a99aa994cccccccccc
ccccccccccccccc11cccccccccccccccccc07707700770770007777777077000c07777770770077077007707777700cccccccccccc4999a99a9994cccccccccc
ccccccccccccccccccccccccccccccccccc07707777770777007707077077700c0777770077007707700770777700cccccccccccccc4999999994ccccccccccc
cccccccccccccccccccccc4444ccccccccc07707777770777007700077077700c07700000777777077777707777700ccccccccccccc4aaaaaaaa4ccccccccccc
cccccccccccccccccccc44aaaa44ccccccc07707777770770007700077077000c0770ccc07777770777770077077700ccccccccccccc4aaaaaa4cccccccccccc
ccccccccccccccccccc4aaaaaaaa4cccccc07707700770777707700077077770c0770ccc07700770770777077007770cccccccccccccc4aaaa4ccccccccccccc
cccccccccccccccccc499999999994ccccc07707700770777707700077077770c0770ccc07700770770077077000770ccccccccccccccc4444cccccccccccccc
cccccccccccccccccc499aaa9aa994ccccc00000000000000000000000000000c0000ccc000000000000000000c0000ccccccccccccccc1cc1cccccccccccccc
cccccccccccccccccc4999a99aa994cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1111cccccccccccccc
cccccccccccccccccc4999a99a9994ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11ccccccccccccccc
ccccccccccccccccccc4999999994ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccc4aaaaaaaa4ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccc4aaaaaa4cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccc4aaaa4ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccc4444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccc1cc1cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccc1111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccc11ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc111c1c1ccccc111cc11cc11c111c111c1c1ccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc177717171ccc1777117711771777177717171cccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc171717171cccc171171717111711171717171cccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc177117771cccc171171717771771177717771cccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc171711171cccc171171711171711171117171cccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc177717771ccc1771177117711777171c17171cccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc111c111ccccc11cc11cc11cc111c1ccc1c1ccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccc1cc111cc11cc11c111c111c1c1c111c111c1c1c111cc11cc11c111c111c111cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc1711777117711771777177717171777177717171777117711771777177717771ccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc1717117117171711171117171717177717171717171117111711171717771711cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc1717117117171777177117771777171717771771177117771711177717171771cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc1711c171171711171711171117171717171717171711c1171717171717171711cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc1771771177117711777171c17171717171717171777177117771717171717771ccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccc11c11cc11cc11cc111c1ccc1c1c1c1c1c1c1c1c111c11cc111c1c1c1c1c111cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33733373337333733373337333733373337333733373337333733373337333733373337333733373337333733373337333733373337333733373337333733373
73637363736373637363736373637363736373637363736373637363736373637363736373637363736373637363736373637363736373637363736373637363
63336333633363336333633363336333633363336333633363336333633363336333633363336333633363336333633363336333633363336333633363336333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
333333a3333333a3333333a333333383333333833333338333333383333333e3333333e3333333e3333333e33333338333333383333333833333338333333383
a33a33b3a33a33b3a33a33b3833833b3833833b3833833b3833833b3e33e33b3e33e33b3e33e33b3e33e33b3833833b3833833b3833833b3833833b3833833b3
b3ab3a33b3ab3a33b3ab3a33b38b3833b38b3833b38b3833b38b3833b3eb3e33b3eb3e33b3eb3e33b3eb3e33b38b3833b38b3833b38b3833b38b3833b38b3833
33b3ab3a33b3ab3a33b3ab3a33b38b3833b38b3833b38b3833b38b3833b3eb3e33b3eb3e33b3eb3e33b3eb3e33b38b3833b38b3833b38b3833b38b3833b38b38
3a33b33b3a33b33b3a33b33b3833b33b3833b33b3833b33b3833b33b3e33b33b3e33b33b3e33b33b3e33b33b3833b33b3833b33b3833b33b3833b33b3833b33b
3b33a3a33b33a3a33b33a3a33b3383833b3383833b3383833b3383833b33e3e33b33e3e33b33e3e33b33e3e33b3383833b3383833b3383833b3383833b338383
a33ab3b3a33ab3b3a33ab3b38338b3b38338b3b38338b3b38338b3b3e33eb3b3e33eb3b3e33eb3b3e33eb3b38338b3b38338b3b38338b3b38338b3b38338b3b3
b33b3333b33b3333b33b3333b33b3333b33b3333b33b3333b33b3333b33b3333b33b3333b33b3333b33b3333b33b3333b33b3333b33b3333b33b3333b33b3333
333333e3333333ecc33333e3333333e3333333e3333333e3333333e333333383333333833333338333333383333333a3333333a3333333a3333333a3333333a3
e33e33b3e33e33c88c3e33b3e33e33b3e33e33b3e33e33b3e33e33b3833833b3833833b3833833b3833833b3a33a33b3a33a33b3a33a33b3a33a33b3a33a33b3
b3eb3e33b3eb3a8888ab3e33b3eb3e33b3eb3e33b3eb3e33b3eb3e33b38b3833b38b3833b38b3833b38b3833b3ab3a33b3ab3a33b3ab3a33b3ab3a33b3ab3a33
33b3eb3e33b3aa8e38aaeb3e33b3eb3e33b3eb3e33b3eb3e33b3eb3e33b38b3833b38b3833b38b7777b38b3833b3ab3a33b3ab3a33b3ab3a33b3ab3a33b3ab3a
3e33b33b3e33a999999ab33b3e33b33b3e33b33b3e33b33b3e33b33b3833b33b3833b33b3833ee6666eeb33b3a33b33b3a33b33b3a33b33b3a33b33b3a33b33b
3b33e3e33b3399aaaa99e3e33b33e3e33b33e3e33b33e3e33b33e3e33b3383833b3383833b3722866b2273833b33a3a33b33a3a33b33a3a33b33a3a33b33a3a3
e33eb3b3e33eb999999eb3b3e33eb3b3e33eb3b3e33eb3b3e33eb3b38338b3b38338b3b38376b3b6633867b3a33ab3b3a33ab3b3a33ab3b3a33ab3b3a33ab3b3
b33b3333b33b3383b83b3333b33b3333b33b3333b33b3333b33b3333b33b3333b33b3333bee6733663376ee3b33b3333b33b3333b33b3333b33b3333b33b3333
333333833333338338333333333333a3333333a39999999999999999333333a3333333a33223673663763223333333e3339999333339999333333333333333e3
833833b33333338cc8333333a33a33b3a33a33b39444944f49494449a33a33b3a33a33b33633367667633363e33e33b3394444993394334933333993e33e33b3
b38b38333333338888333333b3ab3a33b3ab3a339393439934393939b3ab3a33b3ab3a333677776666777763b3eb3e33349933449993ee3933399449b3eb3e33
33b38b38333333833833333333b3ab3a33b3ab3a939999943999393933b3ab3a33b3ab3a366666666666666333b3eb3e34449343449888893994433933b3eb3e
3833b33b33333383383333333a33b33b3a33b33b93444493994439f93a33b33b3a33b33b3ee3376666733ee33e33b33b343349434393ee39944343943e33b33b
3b3383833333338cc83333333b33a3a33b33a3a393999393443999c93b33a3a33b33a3a332237636636732233b33e3e33433449343933394434399443b33e3e3
8338b3b33333338888333333a33ab3b3a33ab3b39994439999994439a33ab3b3a33ab3b33367633663367633e33eb3b3343343493349994343994434e33eb3b3
b33b33333333338338333333b33b3333b33b33339443934444493999b33b3333b33b33333336ee3663ee6333b33b3333343343439999449999443434b33b3333
33333333bbbbbc8cc8cbbbbb3366373338833aa393999979979934493366333333aaaa33333722766722733333aaaa3333737373444493443933333333aaaa33
33a3a3a3b3b3cc8cc8cc3b3b335576738228a99a9f4444d66d44393933dd37733a9999a337766766667667733a9999a333d6d6d333334933349333333a9999a3
339a9a93bfbfc888888cfbfb3395666322e299a99899936666333939337d7663399999933666666666666663399999933b66666b333339333349933339999993
33999993bfbf88888888fbfb3344443322229999934493766739393933666663344444433333ff3333ff333339933993b3767673b33994333334499334444443
33899983bfbf33333333fbfb3344443332233993999999d66d99999933e9e9e334644643b333ffffffff333b399aa99333d6d6d3399443333333344934644643
e3e888e3bfbffffffffffbfb3345443333677633444444dddd44444433e9e9e33995599333333ffffff333333999999333ddddd3944333399333399439955993
b3885883bfbbbbbffbbbbbfb3bfffb3333f66f33bbbbbbd5ddbbbbbb83e959e8333ff3333b33333ff33333b33b9559b3b3dd5dd34999999449999443333ff333
33bfffb33f33333ff33333f3b3fff3b33ffffff3333333ffff333333b33fff3b3b3ff3b3333b3b3ff3b3b33333bffb333b3ff33b34444443344443333b3ff3b3
33ffff33333333333333333333ffff3333ffff33333333333333333333ffff3333ffff33333333333333333333ffff3333ffff33333333333333333333333333
3ffffff3933333343333e3333ffffff33ffffff333333333333433333ffffff33ffffff333333333333333334ffffff33ffffff3333333333333333333333333
fffeffffbffffff5ffffcfeffffffffffffffffffffffffffff5fffffffffeffffff4fffffffffffffffffffcfffffffffffffffffffffffffffffffffffefff
f9fbfffff9ffffffffffffbffffffffffffefffffffffffffffffffffffff5ffffffb4ffffffffffffefffffffffffffffffffffffffffffffffff4fffffcfff
fbfffffffcfffffffffffffffffffffffff5ffffffff4ffffffffffffffffffffffffbffffffffffff5fff9ffffffffffffffeffffffffffffffffbfffffffff
ffffffffffffffffffffffffffffffffffffffffffffcfffffffffffffffffffffffffffffffffffffffff5ffffffffffffffcffffffffffffffffffffffffff
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33733373337333733373337333733373337333733373337333733373337333733373337333733373337333733373337333733373337333733373333333333333
736373637363736373637363736373637363736373637363736373637363736373637363736373637363736373637363736373637363736373633333b333bbb3
63336333633363336333633363336333633363336333633363336333633363336333633363336333633363336333633363336333633363336333b3b3b333b3b3
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333b3b3b333b3b3
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333b33b3b3bbb3
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333

__gff__
0000000000000000000000000000000001010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
282727272727272727272727272727290f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0fb5b5b5b7b7b5b5b5b5b5b5b5b5b5b5b50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
262020202020202020202020202020260f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0fb58485b7b7b5b5b5b5b5b5b5b5b5b5b50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
262020202020202020202020202020260f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0fb59495b5a8a9aaabacadaeafb58687b50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
262020202020202020202020202020260f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0fb5b58687b8b9babbbcbdbebfb59697b50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
262020202020202020202020202020260f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0fb5b59697b7b7b7b7b7b7b7b7b5b5b5b50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
262020202020202020202020202020260f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0fb5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
262020202020202020202020202020260f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0fb5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
262020202020202020202020202020260f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0fb5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
262020202020202020202020202020260f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0fb5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
262020202020202020202020202020260f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f272727272727272727272727272727270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
262020202020202020202020202020260f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f2f2f2f3f3f3f3f2e2e2e2e3f3f3f3f3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
262020202020202020202020202020260f0f0f0f0f0f0f0f0f0f0f0f0f0f0f202eb2b32e2e2e2e3f3f78792f2f2f2f2f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
262020202020201c171e2020202020260f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f3f92932f2f6a6b2f2f58592e4041422e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2b2b2b2b2b2b2b2c102a2b2b2b2b2b2b0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f38a2a33d307a7b373168693c505152310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
202020202020202010202020202020200f0f0f0f0f0f0f0f0f0f0f0f0f0f1111191111191911111919111119191111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
202020202020202010202020202020200f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f2727272727272727272727272727e3e40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
941600000f7340f7251b7041b7050a7340a72518704187050f7340f7251f7041f7050a7340a72518704187050f7340f7251f7041f7050a7340a72518704187050f7340f7250a7340a7250c7340c7250e7340e725
491600000b0130000025600000000b0130000025600000000b0130000025600000000b013000002e615000000b0130000025600000000b0130000025600000000b0130000025600000000b013000002e6152e615
5316000013510135151b5101b5151f5101f51522510225151b5101b515165101651522510225151f5101f51500505005050050500505005050050500505005050050500505005050050500505005050050500505
5316000013510135151b5101b5151f5101f51522510225151b5101b51516510165151f5101f5151b5101b51500000000000000000000000000000000000000000000000000000000000000000000000000000000
a31600001f2101f21527210272152b2102b2152e2102e215272102721522210222152e2102e2152b2102b21500200002000020000200002000020000200002000020000200002000020000200002000020000200
a31600001f2101f21527210272152b2102b2152e2102e215272102721522210222152b2102b215272102721500200002000020000200002000020000200002000020000200002000020000200002000020000200
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bc1000002e0522a002350002400224002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
bd1000000000035052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001161011615006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500000
001000000055500555005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
011000000062400625006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500005
011000000b0000b013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00414344
00 00014344
01 00010244
00 00010344
00 00010204
00 00010305
00 00010244
00 00010344
00 00014344
02 00014344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 0e0f4344

