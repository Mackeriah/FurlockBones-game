pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--main

pl=nil
townname="mushroom"

viewx=0
viewy=0

coffset=64

displaybubble=false
displayname="error"
bubblecolor=7
namecolor=9
talksound=1

paused=false
panim=0
pausereleased=true
pausecur=1

twelvehour=true
hour=0
minute=0
ampm="am"

month=0
day=0

weather=0

seascol=1
seascols=
{
	{{6,13,7},{16,10,0,8},{16,10,0,8},{7,10,16,10}},
	{{9,11,3},{16,16,0,8},{16,16,0,8},{7,7,16,16}},
	{{9,11,3},{6,6,0,8},{16,16,0,8},{7,7,16,16}},
	{{9,2,4},{12,12,0,8},{16,16,0,8},{7,7,16,16}},
	{{9,2,4},{1,1,0,8},{16,16,0,8},{7,7,16,16}},
	{{9,2,4},{8,8,0,8},{16,16,0,8},{7,7,16,16}},
	{{6,13,7},{8,10,0,8},{16,10,0,8},{7,10,16,10}},
}

objects={}
vills={}
rocks_to_place=8


menuitem(1, "use 24-hour time", function() changetwelvehour() end)
function changetwelvehour()
	twelvehour=not twelvehour
	
	if twelvehour then
		menuitem(1, "use 24-hour time", function() changetwelvehour() end)
	else
		menuitem(1, "use 12-hour time", function() changetwelvehour() end)
	end
end

function _init()
	cartdata("superspacehero_tinymal-crossing")

	poke(0x5f5c, -1)
	music(0)
	
	peek(0x3200+68)

	dtb_init(3)

	pl=char()
	pl.name="player"
	pl.bells=0
	pl.nearbychar=nil
	
	pl.color3=14

	pl.nearbyitem=nil
	pl.inventory={}
	pl.invcap=15
	pl.itmperrow=5

	pl.wander=false
	pl.supdate=pl.update
	pl.update=function(c)
		c.mx=0
		c.my=0
		
		if (btn(0)) c.mx+=-1
		if (btn(1)) c.mx+=1
		if (btn(2)) c.my+=-1
		if (btn(3)) c.my+=1
		
		if (c.mx!=0) c.vx=c.mx
		if (c.my!=0) c.vy=c.my

		-- if button 5 is just pushed down and there is a nearby item, then play the sfx pickupsound and pickup the nearby item
		
		if btnp(5) and pl.nearbyitem!=nil then
			sfx(pickupsound)
			pl.pickupitem(pl.nearbyitem)
			pl.nearbyitem=nil
		end
		
		c.supdate(c)
	end

	pl.pickupitem=function(c, item)
		if #pl.inventory<pl.invcap then
			if item==nil then
				stop()
			end
			add(pl.inventory,item.itemcat[item.itemindex])
			del(objects,item)
		else dtb_disp("my pockets are full!")
		end
	end
	
	createchars(6)
	createitems()
	
	month=stat(91)
	day=stat(92)

	if (month==1 and day>=16) or (month==2 and day<=24) then seascol=1
	elseif (month==2 and day>=25) or (month==3 and day<=31) then seascol=2
	elseif (month==4 and day>=1) or (month==4 and day<=10) then seascol=3
	elseif (month==4 and day>=11) or (month>=5 and month<=10) or (month==10 and day<=16) then seascol=2
	elseif (month==10 and day>=17) or (month==11 and day<=9) then seascol=4
	elseif (month==11 and day>=10) or (month==11 and day<=25) then seascol=5
	elseif (month==11 and day>=26) or (month==12 and day<=10) then seascol=6
	elseif (month==12 and day>=11) or (month==1 and day<=15) then seascol=7 end
	
	srand(pl.name..townname)
	
	-- local bullboard=char(4,0)
	-- bullboard.x=248
	-- bullboard.y=176
	-- bullboard.static=true
	-- bullboard.wander=false
	-- bullboard.rotate=false
	
	-- bullboard.box={x1=0,y1=5,x2=16,y2=7}
	
	-- bullboard.name="bulletin board"
	-- bullboard.talkdistx=14
	
	-- bullboard.head={142, 2,2, 0,-8}
	-- bullboard.body={}
	
	-- bullboard.color1=8
	-- bullboard.color2=5
	-- bullboard.color3=15
	-- bullboard.shirtcol=1
	
	-- bullboard.namecol=-1
	-- bullboard.bubblecol=10
	
	-- bullboard.dialogue="be there or be square!"
	
	-- local mapboard=char(4,0)
	-- mapboard.x=224
	-- mapboard.y=32
	-- mapboard.static=true
	-- mapboard.wander=false
	-- mapboard.rotate=false
	
	-- mapboard.box={x1=-4,y1=-4,x2=12,y2=4}
	
	-- mapboard.name="map"
	-- mapboard.talkdistx=14
	
	-- mapboard.head={142, 2,2, 0,-8}
	-- mapboard.body={}
	
	-- mapboard.color1=8
	-- mapboard.color2=5
	-- mapboard.color3=15
	-- mapboard.shirtcol=3
	
	-- mapboard.namecol=-1
	-- mapboard.bubblecol=10
	
	-- mapboard.dialogue="be there or be square!"

	additem(items.houses,1,27,20)
	-- additem(items.items,1,27,22)

	local intro=room({
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000001111000000",
		"0000011111100000",
		"0000001111000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000"
	})

	local r1=room({
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0001111111111000",
		"0001111111111000",
		"0001111111111000",
		"0001111111111000",
		"0001111111111000",
		"0001111111111000",
		"0001111111111000",
		"0001111221111000"
	})
	door(27,19,nil,127,136,r1)
	door(20,19,nil,127,136,intro)
	
end

altpalette=
{
	0,129,130,131,132,133,134,6,136,137,9,139,140,141,142,143
}

function altpal()
	for i=0,15 do
		pal(i,altpalette[i+1],1)
	end
end

colset={
	{14,8,2},
	{7,12,13},
	{9,11,3},
	{7,6,5},
	{7,10,9},
	{7,14,2},
	{6,13,5},
	{15,4,2},
	{14,15,9},
	{7,7,6},
	{6,5,0},
	{10,9,4},
	{7,6,5},
	{7,6,13},
	{6,12,13},
	{11,3,5},
	{13,8,2},
}

function setpalette(col1,col2,col3,col4,scol1,scol2)
	pal(15,colset[col1][1])
	pal(4,colset[col1][2])
	pal(5,colset[col1][3])
	
	pal(10,colset[col2][1])
	pal(11,colset[col2][2])
	pal(3,colset[col2][3])
	
	if col3>0 then
		pal(6,colset[col3][1])
		pal(12,colset[col3][2])
		pal(13,colset[col3][3])
	else
		pal(6,colset[col1][1])
		pal(12,colset[col1][2])
		pal(13,colset[col1][3])
	end
	
	pal(14,colset[col4][1])
	pal(8,colset[col4][2])
	pal(2,colset[col4][3])
	
	if scol1>0 then pal(9,scol1) end
	if scol2>0 then pal(7,scol2) end
end

function char(bubblex,bubbley)
	local c={}
	c.name="character"
	c.phrase="phrase"
	c.personality=nil
	c.talkcount=0
	c.daylasttalked=0
	
	c.birthday=1
	c.birthmonth=1
	
	c.x=216
	c.y=176
	
	c.mx=0
	c.my=0
	
	c.vx=0
	c.vy=0
	
	c.static=false
	
	-- c.collision={4,4,0,0}
	c.box = {x1=1,y1=5,x2=7,y2=7}
	c.solid=true
	
	c.head={64, 1,1, 0,-8}
	c.body={80, 1,1, 0,0}
	
	c.color1=9
	c.color2=2
	c.color3=0
	-- c.bodycol=1
	c.shirtcol=1
	c.eyecol1=1
	c.eyecol2=7
	
	c.namecol=9
	c.bubblecol=7
	
	if bubblex==nil then bubblex=0 end
	if bubbley==nil then bubbley=0 end
	c.bubblepos={bubblex,bubbley}
	
	c.talkdistx=12
	c.talkdisty=12
	
	c.animc=0
	c.animd=0
	c.dialogue=""
	c.wander=true
	c.talking=false
	c.rotate=true
	c.wantime=0
	c.idletime=0
	c.room=nil

	c.ysort=true
	
	c.init=function(c)
		c.hw=c.box.x2*0.5
		c.hh=c.box.y2*0.5
		
		if #c.head>0 then
			c.bubblepos[2]+=c.head[5]-(c.head[3]*8)
		end
	end
	
	c.frame=0
	c.previousframe=0
	c.playfootstep=false

	c.draw=function(c)
		local invt=false
		local invb=false
		local spritet=0
		local spriteb=0
		c.frame=flr(c.animc)
		if (c.animd==2) spritet=2
		if c.animd==0 or c.animd==2 then
			spriteb+=c.frame%2*16
			if (c.frame>=2) invb=true
		else
			spritet=1
			spriteb=1
			if c.animd==1 then 
				invb=true 
				invt=true
			end
			if (c.frame%4==1) spriteb=17
			if (c.frame%4==3) spriteb=33
		end
		
		setpalette(c.color1,c.color2,c.color3,c.shirtcol,c.eyecol1,c.eyecol2)
		
		if #c.head>0 then
			spr(c.head[1]+spritet,c.x+c.head[4],c.y+c.head[5],c.head[2],c.head[3],invt)
		end
		
		
		if #c.body>0 then
			spr(c.body[1]+spriteb,c.x+c.body[4],c.y+c.body[5],c.body[2],c.body[3],invb)
		end
		
		pal()
		
		if pl.nearbychar==c and not c.talking then
			spr(162,c.x+c.bubblepos[1],c.y+c.bubblepos[2])
		end
	end
	c.update=function(c)
		if not c.talking then
			local ismoving=false
			if c.wander then
				c.mx=0
				c.my=0
					
				if c.wantime>0 then
					c.wantime-=0.04
					if (c.animd==0) c.vy=1
					if (c.animd==1) c.vx=-1
					if (c.animd==2) c.vy=-1
					if (c.animd==3) c.vx=1
					
					c.mx=c.vx
					c.my=c.vy
				else
					if c.idletime<=0 then
						c.wantime=rnd(1)+0.5
						c.idletime=rnd(8)
						c.animd=flr(rnd(4))
					else
						c.idletime-=0.04
					end
				end
			end
			
			if c.mx!=0 or c.my!=0 then
				ismoving=true
				c.animc+=0.15
			else c.animc=0 end
			if c==pl and c.frame%2 == 0 then
				if (c.animc == 0.15 or c.previousframe != c.frame) and c.playfootstep then
					sfx(footstep)
					c.playfootstep=false
				else
					c.playfootstep=true
				end
			end
				
			c.previousframe=c.frame
			if (c.animc>=4) c.animc=0
			
			if (c.my>0) then
				c.animd=0
			elseif (c.my<0) then
				c.animd=2
			end
			if (c.mx<0) then
				c.animd=1
			elseif (c.mx>0) then
				c.animd=3
			end
			
			if c.vx!=0 or c.vy!=0 then
				move_actor(c)
			end
			
			if ismoving and c.vx==0 and c.vy==0 then
				c.wantime=0
			end		

			c.vx=0
			c.vy=0
			
			if abs(c.x-pl.x)<c.talkdistx and abs(c.y-pl.y)<c.talkdisty then
				if (#c.dialogue>0 or c.personality!=nil) and pl.nearbychar==nil then
					pl.nearbychar=c
				end
			elseif pl.nearbychar==c then pl.nearbychar=nil end
			
			if pl.nearbychar==c then
				if (btnp(4)) then
					if abs((c.x+c.hw)-(pl.x+pl.hw)) >= abs(c.y-pl.y) then
						if c.x < pl.x then
							if c.rotate then c.animd=3 end
							pl.animd=1
						elseif c.x >= pl.x then
							if c.rotate then c.animd=1 end
							pl.animd=3
						end
					elseif abs(c.y-pl.y) >= abs((c.x+c.hw)-(pl.x+pl.hw)) then
						if c.y < pl.y then
							if c.rotate then c.animd=0 end
							pl.animd=2
						elseif c.y >= pl.y then
							if c.rotate then c.animd=2 end
							pl.animd=0
						end
					end
					
					pl.talking=true
					pl.nearbychar.talking=true
					
					sfx(startmessage)
					if c.personality!=nil then
						if #c.dialogue!=0 then
							talksound=c.personality.voice
							dtb_disp(c.dialogue,c.name,c.namecol,c.bubblecol)
						else greeting(c) end

						if c.daylasttalked!=stat(92) and stat(93)>6 then c.talkcount=0 end
						c.talkcount+=1
					elseif c.dialogue!=0 then
						dtb_disp(c.dialogue,c.name,c.namecol,c.bubblecol)
					end
				end
			end
		end
	end
	add(objects,c)
	sorty(objects)
	c:init()
	return c
end

function item()
	local i={}
	i.name="item"

	i.interactive=false
	i.pickup=false
	i.buried=false
	
	i.x=260
	i.y=40
	i.vx=0
	i.vy=0

	i.originx=0
	i.originy=0

	i.icon=136
	i.itemcat={}
	i.itemindex=0
	
	i.sprites=
	{
		{136, 1,1, 0,0}
	}
	
	i.box = {x1=1,y1=0,x2=7,y2=8}
	i.solid=true
	
	i.usepalette=0
	i.color1=9
	i.color2=2
	i.color3=0
	i.color4=1
	i.singlecolor1=0
	i.singlecolor2=0
		
	i.intdistx=12
	i.intdisty=12
	
	i.animframes={}
	i.aframe=0
	i.animc=0
	i.dir=0
	
	i.room=nil

	
	i.ysort=true

	i.init=function(i)
	end
		
	i.draw=function(i)
		if #i.animframes>0 then
			i.aframe=i.animframes[flr(i.animc)+1]
		end
		
		if (i.usepalette==1) then
			setpalette(i.color1,i.color2,i.color3,i.color4,i.singlecolor1,i.singlecolor2)
		elseif i.usepalette>1 then
			local col=seascols[seascol][i.usepalette]
			setpalette(col[1],col[2],col[3],col[4],i.singlecolor1,i.singlecolor2)
		end
		
		local bubbley=2
		
		foreach(i.sprites, function(s)
			if s[6] then spr(s[1]+i.aframe, i.x-s[4],i.y-s[5], s[2],s[3], s[6])
			else spr(s[1], i.x-s[4],i.y-s[5], s[2],s[3], s[6]) end
			
			bubbley-=s[3]*8
		end)
		
		pal()
		
		if pl.nearbyitem==i then
			oval(i.x-(#i.name*2.5)+(i.sprites[1][2]*4)-1,i.y+bubbley-2,(#i.name*5)+2, 9, 10)
			print(i.name,i.x-(#i.name*2)+(i.sprites[1][2]*4),i.y+bubbley,1)
		end
		
		-- if (displaycolon) then
			-- pset(i.x,i.y,7)
		-- else
			-- pset(i.x,i.y,0)
		-- end
	end
	i.update=function(i)
		if #i.animframes>0 then
			i.animc+=0.15
			if (i.animc>=#i.animframes) i.animc=0
		end

		if abs(i.x-pl.x)<i.intdistx and abs(i.y-pl.y)<i.intdisty then
			if (i.interactive or i.pickup) and pl.nearbyitem==nil then
				pl.nearbyitem=i
			end
		elseif pl.nearbyitem==i then pl.nearbyitem=nil end
	end
	add(objects,i)
	sorty(objects)
	return i
end

--from p.craft by nusan
function sorty(t)
	local tv = #t-1
	for i=1,tv do
		if t[i].ysort then
			local t1 = t[i]
			local t2 = t[i+1]
			if t1.y > t2.y then
				t[i] = t2
				t[i+1] = t1
			end
		end
	end
end
-->8
--collision

function get_hitbox(a)
	local box = {}
	box.x1 = a.box.x1 + a.x
	box.x2 = a.box.x2 + a.x 
	box.y1 = a.box.y1 + a.y
	box.y2 = a.box.y2 + a.y
	return box
end

function collides(a, b)
	if b.solid then
		local box_a = get_hitbox(a)
		local box_b = get_hitbox(b)
		
		if box_a.x1 > box_b.x2 or
			box_a.y1 > box_b.y2 or
			box_b.x1 > box_a.x2 or
			box_b.y1 > box_a.y2 then
			return false
		end
		
		return true
	end
	return false
end

function push_away(a, b)
	if (a.x < b.x-2) then a.vx-=1
	elseif (a.x > b.x+2) then a.vx+=1
	end
	if (a.y < b.y-2) then a.vy-=1
	elseif (a.y > b.y+2) then a.vy+=1
	end
end

function move_actor(a)
	local canmove = true
	
	local box_a = get_hitbox(a)

	-- if a.vx!=0 and (check_collisions(a, a.vx, 0)) then a.vx=0 end
	-- if a.vy!=0 and (check_collisions(a, 0, a.vy)) then a.vy=0 end

	a.vx,a.vy=resolvecol(a, box_a.x1,box_a.y1,a.vx,a.vy)
	a.vx,a.vy=resolvecol(a, box_a.x1,box_a.y2,a.vx,a.vy)
	a.vx,a.vy=resolvecol(a, box_a.x2,box_a.y1,a.vx,a.vy)
	a.vx,a.vy=resolvecol(a, box_a.x2,box_a.y2,a.vx,a.vy)
	
	for b in all(objects) do
		if abs(a.x-b.x)<=a.box.x2*2 and abs(a.y-b.y)<=a.box.y2*2 then
			if (a != b and collides(a,b)) then
				push_away(a,b)
			end
		end
	end
	
	a.x += a.vx 
	a.y += a.vy
end

function walkable(x,y,px,py)
	local tx=flr(x/8)
	local ty=flr(y/8)
	local ptx=flr(px/8)
	local pty=flr(py/8)
	local ptile=mget(px/8,py/8)
	local tile=mget(x/8,y/8)
	
	if fget(tile,1) then
		if ((tile==33 or tile==34 or tile==35) and pty>ty) return false
		if ((ptile==33 or ptile==34 or ptile==35) and pty<ty) return false
		if ((tile==19 or tile==3 or tile==35) and ptx>tx) return false
		if ((ptile==19 or ptile==3 or ptile==35) and ptx<tx) return false
		if ((tile==2 or tile==1 or tile==3) and pty<ty) return false
		if ((ptile==2 or ptile==1 or ptile==3) and pty>ty) return false
		if ((tile==17 or tile==1 or tile==33) and ptx<tx) return false
		if ((ptile==17 or ptile==1 or ptile==33) and ptx>tx) return false
		return true
	end
	
	return false
end

function resolvecol(c, x,y,vx,vy)
	local nextx=x+vx
	local nexty=y+vy
	
	if c.room==nil then
		if nexty>=255 then
			x+=512
			nextx+=512

			y-=255
			nexty-=255
		end
	end
	
	local cur=walkable(x,y,x,y)
	local tot=walkable(nextx,nexty,x,y)
	local hor=walkable(nextx,y,x,y)
	local ver=walkable(x,nexty,x,y)
	if cur then
		if hor or ver then
			if not tot then
				if hor then
					vy=0
				else
					vx=0
				end
			end
		else
				vx=0
				vy=0
		end
	end
	return vx,vy
end
-->8

local rooms={}
function room(layout)
	local r={}
	r.layout={}
	for i=1,#layout do
		add(r.layout,{})
		for j=1,#layout[i] do
			local tile={}
			add(r.layout[i],tile)
			tile.floor=true
			tile.bdoor=false
			tile.fdoor=false
			local cha=sub(layout[i],j,j)
			if cha=="0" then
				tile.floor=false
			elseif cha=="2" then
				tile.fdoor=true
			elseif cha=="3" then
				tile.bdoor=true
			end
		end
	end
	r.cx=127-#r.layout[1]+flr((16-#r.layout[1])/2)
	r.cy=(112-#r.layout)/2
	r.render=function(r)
		for i=0,15 do
			for j=0,15 do
				mset(i+112,j+48,0)
			end
		end
		local cx=r.cx
		local cy=r.cy
		for i=1,#r.layout do
			for j=1,#r.layout[i] do
				if r.layout[i][j].floor then
					mset(cx+j,cy+i,160)
					if mget(cx+j,cy+i-1)==0 and
					mget(cx+j,cy+i-2)==0 and
					mget(cx+j,cy+i-3)==0 then
						mset(cx+j,cy+i-1,145)
						mset(cx+j,cy+i-2,129)
						if r.layout[i][j].bdoor then
							mset(cx+j,cy+i-1,147)
							mset(cx+j,cy+i-2,131)
						end
					end
					if r.layout[i][j].fdoor then
						mset(cx+j,cy+i+1,176)
					end
				end
			end
		end
		for i=0,15 do
			for j=0,15 do
				if mget(cx+j,cy+i)==145 and
							mget(cx+j+1,cy+i)==160 then
					mset(cx+j,cy+i,146)
					mset(cx+j,cy+i-1,130)
				end
				if mget(cx+j,cy+i)==145 and
							mget(cx+j-1,cy+i)==160 then
					mset(cx+j,cy+i,144)
					mset(cx+j,cy+i-1,128)
				end
			end
		end
	end
	add(rooms,r)
	return r
end

local doors={}
function door(x,y,room,x2,y2,room2)
	local d={}
	d.x=x
	d.y=y
	d.room=room
	d.x2=x2
	d.y2=y2
	d.room2=room2
	add(doors,d)
	return d
end

function updatedoors()
	foreach(objects,function(c)
		local x=flr((c.x+1)/8)
		local y=flr(c.y/8)
		foreach(doors,function(d)
			local ydist=y*8-c.y
			if x==d.x and y==d.y and pl==c and c.room==d.room then
				d.room2.render(d.room2)
				c.room=d.room2
				c.x=((d.x2+0.5)*8)
				c.y=d.y2*8
				if ydist<0 then
					c.y-=8
				else
					c.y+=8
				end
			elseif (x==d.x2 or x==d.x2+1) and y==d.y2 and c.room==d.room2 then
				c.room=d.room
				c.x=(d.x*8)
				c.y=(d.y*8)
				if ydist<0 then
					c.y-=8
				else
					c.y+=8
				end
			end
		end)
	end)
end

function oval(h,v,x,y,c)
	x=(x+1)/2 y=(y+1)/2 h-=1-x v-=1-y
	for i=-y,y do
		for j=-x,0 do
			if j*j/x/x+i*i/y/y<1 then
				rectfill(h+j,v+i,h-j,v+i,c)
				break
			end
		end
	end
end

animate=0
animtime=0

function animatetiles()
	animtime += 1
	if animtime>=12 then
		animate+=1
		if animate>3 then animate=0 end
		
		animtime=0
	end
end

overrideviewx=nil
overrideviewy=nil

function _draw()
	if pl!=nil and pl.room==nil then
		viewx=pl.x+4
		viewy=pl.y
		if viewx<coffset then viewx=coffset
		elseif viewx>448 then viewx=448 end
		
		if viewy<coffset then viewy=coffset
		elseif viewy>448 then viewy=448 end

		overrideviewx=nil
		overrideviewy=nil
	else
		overrideviewx=1024
		overrideviewy=1024
	end

	if (overrideviewx!=nil and overrideviewy!=nil) then
		viewx=overrideviewx
		viewy=overrideviewy
	end
	
	cls()
	
	camera(viewx-coffset,viewy-coffset)
	
	-- Changing the map
	
	if pl.room!=nil then
		map(112,48,960,960,16,16)
	else
		pal(10,seascols[seascol][1][1])
		pal(11,seascols[seascol][1][2])
		pal(3,seascols[seascol][1][3])
		
		map(0,0,0,0,64,32)
		map(64,0,0,256,64,32)
		
		animatetiles()
		if animate==0 then
			pal(14,12)
			pal(8,12)
			pal(2,12)
		elseif animate==1 then
			pal(7,12)
			pal(14,7)
			pal(8,12)
			pal(2,12)
		elseif animate==2 then
			pal(7,12)
			pal(14,12)
			pal(8,7)
			pal(2,12)
		elseif animate==3 then
			pal(7,12)
			pal(14,12)
			pal(8,12)
			pal(2,7)
		end
		
		map(0,0,0,0,64,32,10000000)
		map(64,0,0,256,64,32,10000000)

		pal()
	end
	
	foreach(objects,function(c)
		if (c.room==pl.room and (abs(c.x-viewx)<=88 and abs(c.y-viewy)<=88)) c.draw(c)
	end)
	
	if displaybubble then
		oval(viewx-coffset+1,viewy+31,126,24,bubblecolor-1)
		oval(viewx-coffset+1,viewy+41,126,32,bubblecolor-1)
		oval(viewx-coffset+1,viewy+31,126,24,bubblecolor)
		oval(viewx-coffset+1,viewy+41,126,32,bubblecolor)
		if (namecolor>=0) then oval(viewx-56,viewy+26,48,12,namecolor) end
	end
	
	if paused then
		oval(viewx-coffset+2,viewy-coffset+1,(coffset*2)-2,(coffset*1.1),10)
		oval(viewx-coffset+1,viewy-(coffset*0.5),(coffset*2)-2,(coffset*1.1),10)
		oval(viewx-coffset,viewy-4,(coffset*2)-2,(coffset*1.25),10)
		circfill(viewx-(coffset*0.5),viewy-(coffset*0.55)-1,coffset*0.3,12)
		
		setpalette(pl.color1,pl.color2,pl.color3,pl.shirtcol,pl.eyecol1,pl.eyecol2)
				
		panim+=0.15
		if (panim>=4) panim=0
		
		pframe=flr(panim)
		local pflip=pframe>=2
		pframe=pframe%2*16
		
		spr(pl.head[1],viewx-(coffset*0.5)-4,viewy-coffset*0.55-8)
		spr(pl.body[1]+pframe,viewx-(coffset*0.5)-4,viewy-coffset*0.55,1,1,pflip)
		
		pal()

		rectfill(viewx-4,viewy-(coffset*0.5)-8,viewx+4+(#pl.name*3),viewy-(coffset*0.5)-7,9)
		rectfill(viewx-4,viewy-(coffset*0.5)-2,viewx+4+(#townname*3),viewy-(coffset*0.5)-1,9)
		rectfill(viewx-4,viewy-(coffset*0.5)+4,viewx+22,viewy-(coffset*0.5)+5,9)
		
		print(pl.name.."\n"..townname.."\n$"..pl.bells,viewx-4,viewy-(coffset*0.5)-11,1)
		
		local itmx=0
		local itmy=0
		for i=1,pl.invcap do
			itmx+=1
			if itmx>pl.itmperrow then
				itmx=1
				itmy+=1
			end
			
			circfill(viewx-coffset+(itmx*12)-itmy-4,viewy+(itmy*12)-3,5,1)
			if (i==pausecur) spr(114, viewx-coffset+(itmx*12)-itmy-4,viewy+(itmy*12)-3)
			
			if #pl.inventory>=i then
				spr(pl.inventory[i][2],viewx-coffset+(itmx*12)-itmy-7,viewy+(itmy*12)-7)
			end
		end
	
	else
		oval(viewx-(coffset*1.2),viewy-(coffset*1.2),44,28,9)
		camera()
		dtb_draw()
		
		blinkcolon()
		text=""
		if twelvehour then
			if stat(93)>=12 then
				if stat(93)>12 then
					hour=stat(93)-12
				else
					hour=stat(93)
				end
			
				if stat(94)<10 then
					minute="0"..stat(94)
				else
					minute=stat(94)
				end
				
				ampm=" pm"
			else
				if stat(93) == 0 then
					hour="12"
				else
					hour=stat(93)
				end
			
				if stat(94)<10 then
					minute="0"..stat(94)
				else
					minute=stat(94)
				end
				
				ampm=" am"
			end
			
		else
			hour=stat(93)
			
			if stat(94)<10 then
				minute="0"..stat(94)
			else
				minute=stat(94)
			end
			
			ampm=""
		end
		text=hour..colon..minute..ampm.."\n"..month.."/"..day.."\n"
		
		print(text,2,2,1)
		print(text,1,1,7)
	end
	
	if pl.room==nil and (stat(93)<=6 or stat(93)>=18) then
		altpal()
	end
end

colontime=0
displaycolon=true
colon=":"
function blinkcolon()
	colontime += 1
	if colontime>=30 then
		displaycolon=not displaycolon
		if displaycolon then colon=":" else colon=" " end
		colontime=0
	end
end

function movepausecursor(dir)
	local curloc=pausecur+dir

	if curloc<=pl.invcap and curloc>0 then
		pausecur=curloc
		sfx(movecursor)
	end
end

function _update60()

	if (btn(4) and btn(5) and pausereleased and not pl.talking) then
		paused=not paused
		pausereleased=false
		
		if paused then
			-- zoom in
			poke(0x5f2c, 3)
			-- set button pressing to repeat
			poke(0x5f5c, 15)
			poke(0x5f5d, 8)
			coffset=32
			-- pausecur=1
			sfx(11)
		else
			-- zoom out
			poke(0x5f2c, 0)
			-- disable repeated button pressing
			poke(0x5f5c, -1)
			coffset=64
			sfx(12)
		end
	
		-- pl.shirtcol+=1
		-- if pl.shirtcol>#colset then pl.shirtcol=1 endsound
		
		return
	end
	
	if not (btn(4) and btn(5)) then
		pausereleased=true
	end

	if not paused then
		foreach(objects,function(c)
			if (c.room==pl.room and ((abs(c.x-viewx)<=88 and abs(c.y-viewy)<=88))or c.wander!=nil) c.update(c)
		end)
	else
		if (btnp(0)) movepausecursor(-1)
		if (btnp(1)) movepausecursor(1)
		if (btnp(2)) movepausecursor(-pl.itmperrow)
		if (btnp(3)) movepausecursor(pl.itmperrow)
	end
	sorty(objects)
	updatedoors()
		
	if #dtb_q>0 then
		dtb_update()
	elseif pl.talking then
		pl.talking=false
		pl.nearbychar.talking=false
	end
	
	month=stat(91)
	day=stat(92)
end
-->8
--dialogue display
fasttext=false
-- buttonreleased=false

function dtb_init(n)
	dtb_q={}
	dtb_f={}
	dtb_n=3
	if n then dtb_n=n end
	_dtb_c()
end

function dtb_disp(t,name,ncolor, bcolor,c)	
	local s,l,w,h,u s={}
	l=""
	w=""
	h=""
	u=function()
		if #w+#l>27 then
			add(s,l)
			l=""
		end
		l=l..w
		w=""
	end
	
	displayname=name
	namecolor=ncolor
	bubblecolor=bcolor
	
	for i=1,#t do
		h=sub(t,i,i)
		w=w..h
		if h==" "then
			u()
		elseif #w>28 then
			w=w.."-"
			u()
		end
	end
	u()
	
	if l~=""then
		add(s,l)
	end
	add(dtb_q,s)
	if c==nil then
		c=0
	end
	add(dtb_f,c)
end

function _dtb_c()
	dtb_d={}
	for i=1,dtb_n do
		add(dtb_d,"")
	end dtb_c=0
	dtb_l=0
end

function _dtb_l()
	dtb_c+=1
	for i=1,#dtb_d-1 do
		dtb_d[i]=dtb_d[i+1]
	end
	dtb_d[#dtb_d]=""
	-- sfx(stopmessage)
end

function dtb_update()
	-- if not buttonreleased then
	-- 	if not btn(4) then buttonreleased=true end
	-- end
				
	if #dtb_q>0 then
		if dtb_c==0 then
			dtb_c=1
			fasttext=true
			-- buttonreleased=false
		end
		local z,x,q,c
		z=#dtb_d
		x=dtb_q[1]
		q=#dtb_d[z]
		c=q>=#x[dtb_c]
		if c and dtb_c>=#x then
			if btnp(4) or btnp(5) --[[ and buttonreleased ]] then
				if dtb_f[1]~=0 then dtb_f[1]() end
				del(dtb_f,dtb_f[1])
				del(dtb_q,dtb_q[1])
				_dtb_c()
				
				if #dtb_q>0 then sfx(endsound)
				else sfx(stopmessage) end
				
			return end
		elseif dtb_c>0 then
		if fasttext then dtb_l-=2
		else dtb_l-=1 end
		-- dtb_l-=1
			if not c then
				if dtb_l<=0 then
					local v,h v=q+1
					h=sub(x[dtb_c],v,v)
					
					dtb_l=2
					
					if h~=" " then sfx(talksound) end

					-- function set_note(sfx, time, note)
					-- 	local addr = 0x3200 + 68*sfx + 2*time
					-- 	poke(addr, note[1])
					-- end
					if not fasttext then
						if h=="," then dtb_l=12 end
						if h=="." or h=="!" or h=="?" then dtb_l=24 end
					end
					dtb_d[z]=dtb_d[z]..h
				end
				
				if btnp(5) --[[ and buttonreleased ]] then
					fasttext=true
				end
			else
				_dtb_l()
			end
		end
	end
end

function dtb_draw()
	displaybubble=false
	if #dtb_q>0 then
		local z,o
		z=#dtb_d
		o=0
		if dtb_c<z then o=z-dtb_c end
		
		displaybubble=true
		
		if (namecolor>=0) then print(displayname,32-flr((#displayname*4)/2),93,0) end
		
		if dtb_c>0 and #dtb_d[#dtb_d]==#dtb_q[1][dtb_c] then
			if displaycolon then
				print("\x8e",117,118,1)
				print("\x8e",117,117,12)
			else
				print("\x8e",117,118,12)
			end
		end
		for i=1,z do print(dtb_d[i],9,i*8+119-(z+o)*8,0)end
	end
end
-->8
-- replace fnd with rep in str
-- originally from https://www.lexaloffle.com/bbs/?pid=72818
-- "yes. please use it!" - shiftalow [2020-02-07 02:19]
function replace(s,f,r)
	local a=''
	while #s>0 do
		local t=sub(s,1,#f)
		a=a..(t~=f and sub(s,1,1) or r or '')
		s=sub(s,t==f and 1+#f or 2)
	end
	return a
end
-->8
--dialogue
function setdialogue(thischar, message, timebased)
	if (timebased) then
		if stat(93)>=6 and stat(93)<11 then message=message.morning
		elseif stat(93)>=11 and stat(93)<14 then message=message.afternoon
		elseif stat(93)>=14 and stat(93)<17 then message=message.day
		elseif stat(93)>=17 and stat(93)<21 then message=message.evening
		elseif (stat(93)>=21 and stat(93)<24) or (stat(93)>=0 and stat(93)<6) then message=message.night end

		if weather==0 then message=message.neutral
		elseif weather==1 then message=message.rain
		elseif weather==2 then message=message.snow end
	end
	
	
	talksound=thischar.personality.voice


	dlg=replace(message[ceil(rnd(#message))], "[c]", thischar.phrase)
	
	dlg=replace(dlg, "[a]", thischar.name)
	dlg=replace(dlg, "[p]", pl.name)
	dlg=replace(dlg, "[v]", townname)
	
	dlg=replace(dlg, "[t]", hour..":"..minute..ampm)
	dlg=replace(dlg, "[h]", hour..ampm)
	
	dtb_disp(dlg,thischar.name,thischar.namecol,thischar.bubblecol)
end

function greeting(thischar)
	persona=thischar.personality
	
	setdialogue(thischar, persona.greetings, true)
	setdialogue(thischar, persona.starters)
	
end

normal=
{
	voice=2,
	
	meet=
	{
		"oh, hello. my name is [a]. how are you? so...are you new in town? how spendid! would you... uh... would you like to be friends with me? really? great! terrific! i'm so glad i got up the courage to ask, [c]! that could've gone badly... [p]... ok! i think i can remember that!"
	},
	greetings=
	{
		morning=
		{
			neutral=
			{
				"good morning, [c].",
			},
			snow=
			{
				"good morning, [p]. i knew it'd be cold today, but i didn't expect snow! bundle up or you'll catch cold, [c]!",
			}
		},
		afternoon=
		{
			neutral=
			{
				"hey, nice afternoon, isn't it, [c]? let's see...right now it's...[h], right? ...hee hee hee hee! you silly old goose! did you, maybe, oversleep? that's not healthy, you know! you should wake up at a more reasonable hour, [c]!",
			},
			snow=
			{
				"normal snow afternoon greeting",
			},
		},
		day=
		{
			neutral=
			{
				"normal neutral day greeting",
			},
			snow=
			{
				"normal snow day greeting",
			}
		},
		evening=
		{
			neutral=
			{
				"normal neutral evening greeting",
			},
			snow=
			{
				"normal snow evening greeting",
			}
		},
		night=
		{
			neutral=
			{
				"normal neutral night greeting",
			},
			snow=
			{
				"normal snow night greeting",
			},
		},
	},
	starters=
	{
		"so, what can i do for you, [c]?",
		"so, you must have had some reason for coming to see me, right, [c]?",
		"so, tell me, [p], what did you want, [c]?"
	}
}
peppy=
{
	voice=2,
	
	greetings=
	{
		morning=
		{
			neutral=
			{
				"peppy neutral morning greeting",
			},
			snow=
			{
				"hi there, [p]! goooooood morning! if i'd known it was gonna be this cold, i totally would've worn more layers or something, [c]!",
			},
		},
		afternoon=
		{
			neutral=
			{
				"peppy neutral afternoon greeting",
			},
			snow=
			{
				"if you're looking for the snow queen, then look no further! here's [a]! tah-dah, [c]! ...well, maybe i'm more of a snow jester or a snow peasant or something...",
			},
		},
		day=
		{
			neutral=
			{
				"ah, konnichiwa! not bad, eh? i've been studying japanese lately, [c]! cool, huh? [p], if you ever want to study with me, you just say the word, ok?",
			},
			snow=
			{
				"peppy snow day greeting",
			},
		},
		evening=
		{
			neutral=
			{
				"good evening, [c]!",
				"[p] [a] [h] [t] [v]"
			},
			snow=
			{
				"peppy snow evening greeting",
			},
		},
		night=
		{
			neutral=
			{
				"peppy neutral night greeting",
			},
			snow=
			{
				"peppy snow night greeting",
			},
		},
	},
	starters=
	{
		"hey, did you want something, or what, [c]?",
		"so, what's goin' on, [c]?",
		"anyway, what's up, [c]?"
	}
}
snooty=
{
	voice=2,
	
	greetings=
	{
		morning=
		{
			neutral=
			{
				"hmmmmmrgh? ah, [p]. good morning to you, [c]. you seem to be awfully peppy for such an early morning. so peppy it actually rather offends me, [c]!",
			},
			snow=
			{
				"snooty snow morning greeting",
			},
		},
		afternoon=
		{
			neutral=
			{
				"snooty neutral afternoon greeting",
			},
			snow=
			{
				"snooty snow afternoon greeting",
			},
		},
		day=
		{
			neutral=
			{
				"i'm sorry, but i'm in a hurry right now, [c]. oh... oh, my mistake! i thought you were going to hit on me or ask me for a favor, [c]. i seem to just as popular with boys and girls alike, you know. everyone wants to be my friend. ah, sometimes it's just too much, [c]!"
			},
			snow=
			{
				"snooty snow day greeting",
			},
		},
		evening=
		{
			neutral=
			{
				"snooty neutral evening greeting",
			},
			snow=
			{
				"snooty snow evening greeting",
			},
		},
		night=
		{
			neutral=
			{
				"snooty neutral night greeting",
			},
			snow=
			{
				"snooty snow night greeting",
			},
		},
	},
	starters=
	{
		"by the by, did you need something, [c]?",
		"but let's get right to the point. what can i do for you, [c]?",
		"so, what's goin' on, [c]?",
		"enough idle chitchat. did you need something from me, [c]?"
	}
}
jock=
{
	voice=1,
	
	greetings=
	{
		morning=
		{
			neutral=
			{
				"jock neutral morning greeting",
			},
			snow=
			{
				"morning, [c]! is there anything better than seeing the ground blanketed in white, [p]? it's so much fun to walk where there're no footprints! waah ha ha ha ha!",
			}
		},
		afternoon=
		{
			neutral=
			{
				"a hearty good afternoon to you! i'll say howdy just as often as you like, [c]!",
				"good afternoooooon! i'm absolutely wired today!! how about you? you peppy? you jolly, [c]? oh! is that right? great! all right, cool! yeah! rad! killer! super-sweet! awesome! keep it up, [c]!",
			},
			snow=
			{
				"jock snow afternoon greeting",
			},
		},
		day=
		{
			neutral=
			{
				"hey! how's it going? everything going smoothly for you, [c]? oh! really!? great! that's music to my ears, [c]! seriously! waah ha ha ha!",
				"boy howdy, [p]! you're looking like a picture of health, [c]! yeah, you look great! huh? not as great as i do? ...well, what an odd thing to say, [c]. i guess that's cool!",
				"i have a hunch something good's gonna happen today, [c]! boy, that's a good feeling! gimme an \"oh yeah!\"",
			},
			snow=
			{
				"jock snow day greeting",
			},
		},
		evening=
		{
			neutral=
			{
				"howdy! a good evening to ya, [c]! hey, listen. a thought just occurred to me. it's important to use your head now and again, [p]! so i'm doomed, i guess, [c]!",
				"hey, it's gotten pretty dark, hasn't it, [c]? either that or my eyes have gone kooky!",
				"what's going down? well, i'll tell you one thing that did: the sun!",
			},
			snow=
			{
				"jock snow evening greeting",
			},
		},
		night=
		{
			neutral=
			{
				"jock neutral night greeting",
			},
			snow=
			{
				"jock snow night greeting",
			},
		},
	},
	starters=
	{
		"tell me, [p], what's new, [c]?",
		"hey, so, what can i do for you, [c]?",
		"anyhoo, you probably want something, don't you? so, what is it, [c]?"
	}
}
cranky=
{
	voice=0,
	
	greetings=
	{
		morning=
		{
			neutral=
			{
				"cranky neutral morning greeting",
			},
			snow=
			{
				"morning, [c]! is there anything better than seeing the ground blanketed in white, [p]? it's so much fun to walk where there're no footprints! waah ha ha ha ha!",
			}
		},
		afternoon=
		{
			neutral=
			{
				"cranky neutral afternoon greeting",
			},
			snow=
			{
				"cranky snow afternoon greeting",
			},
		},
		day=
		{
			neutral=
			{
				"well! if it isn't my neighbor, [p]! my, my! loafing about as usual this afternoon, are we? looks like it to me, [c]! don't you have a job, [c]? you really should go get one."
			},
			snow=
			{
				"cranky snow day greeting",
			},
		},
		evening=
		{
			neutral=
			{
				"hey! how're you doing, [c]? oh yeah? glad to hear it. but hey, remember, if you overdo it, you'll ruin your body, [c]! i'm just saying, it's important to take it easy every now and then so you don't flip out, [c].",
			},
			snow=
			{
				"cranky snow morning greeting",
			},
		},
		night=
		{
			neutral=
			{
				"cranky neutral night greeting",
			},
			snow=
			{
				"cranky snow night greeting",
			},
		},
	},
	starters=
	{
        "so then, [c]...why are you here?",
        "yeah, so... what do you want, [c]?",
        "hey, why are you even talking to me, [c]?"
	}
}
lazy=
{
	voice=1,
	
	greetings=
	{
		morning=
		{
			neutral=
			{
				"morning, [p].",
				"hey. morning, [p]. you look like you're full of your usual morning pep, [c]. man, if only i had one iota of your pizzazz...",
			},
			snow=
			{
				"morning, [p]. the fact that you're shivering means that you need to have more strength of spirit! bear down and get some grit, already! stand up tall and laugh in the cold's face! heh heh, [c]!",
			},
		},
		afternoon=
		{
			neutral=
			{
				"hey, it's already lunch, huh? sweeeeeeeeeeet. i always get this huge blast of energy when it's almost time for a nice, tasty meal. just like a kid, huh?",
				"good afternoon! still good, [c]?",
				"good afternoon, [c].",
			},
			snow=
			{
				"lazy snow afternoon greeting",
			},
		},
		day=
		{
			neutral=
			{
				"hi, [p]!",
				"you know, [p], you've got one unusual name, [c]! i mean, it's just plain unusual. heh heh heh heh heh. i've been thinking about that since early yesterday, [c]. yep. that doesn't make me some kind of freak, does it?",
			},
			snow=
			{
				"lazy snow day greeting",
			},
		},
		evening=
		{
			neutral=
			{
				"the sun's about disappeared, hasn't it, [c]?",
				"oh my, it's already [h], [c]!",
			},
			snow=
			{
				"lazy snow evening greeting",
			},
		},
		night=
		{
			neutral=
			{
				"i guess you can't sleep either, huh, [c]?",
				"late night, huh, [c]?",
				"you looooooove the nightlife, huh, [c]?",
				"you looooooove to party, huh, [c]?",
			},
			snow=
			{
				"lazy snow night greeting",
			},
		},
		
	},
	starters=
	{
		"umm, what's up, [c]?",
		"yeah, so what did you need me for, [c]?",
		"so, what do you need, [c]?"
	}
}
-->8
-- sounds
startmessage=8
stopmessage=9
endsound=10
pause=11
unpause=12
movecursor=13
footstep=14

-->8
--object creation
function addchar(vil)
	local newchar=char()
	newchar.name=vil[1]
	newchar.phrase=vil[2]
	newchar.personality=vil[3]
	newchar.head[1]=vil[4]
	newchar.birthday=vil[5]
	newchar.birthmonth=vil[6]
	if vil[7] then newchar.body[1]=76
	else newchar.body[1]=78 end

	newchar.x+=ceil(rnd(24)*8)
	newchar.y+=ceil(rnd(24)*8)
	
	newchar.color1=vil[8]
	newchar.color2=vil[9]
	if (vil[10]<=0) then newchar.color3=vil[8] else newchar.color3=vil[10] end
	newchar.shirtcol=vil[11]
	
	local e1=vil[12]
	local e2=vil[13]
	
	if (e1==nil) then e1=1 end
	if (e2==nil) then e2=7 end
	
	newchar.eyecol1=e1
	newchar.eyecol2=e2
end

function createchars(numofchars)
	while #vills<numofchars do
		v=ceil(rnd(#villagers))
		
		for i=1,#vills do
			if v==vills[i] then
				v=-1
				break
			end
		end
		
		if v>0 then
			add(vills,v)
			addchar(villagers[v])
		end
	end
end

function additem(icat, iindex,ix,iy)
	local newitem=item()
	newitem.x=ix*8
	newitem.y=iy*8

	newitem.itemcat=icat
	newitem.itemindex=iindex
	
	itm = icat[iindex]
	
	newitem.name=itm[1]
	
	if itm[2]!=nil then
		newitem.icon=itm[2]
	end

	newitem.sprites=itm[3]
	newitem.animframes=itm[4]

	if itm[5]==0 then
		newitem.solid=false
	elseif #itm[5]>0 then
		newitem.box.x1=itm[5][1]
		newitem.box.y1=itm[5][2]
		newitem.box.x2=itm[5][3]
		newitem.box.y2=itm[5][4]
	end

	if (itm[6]!=nil) newitem.init=itm[6]
	
	newitem.usepalette=itm[7]
	if newitem.usepalette<=1 then
		newitem.color1=itm[8]
		newitem.color2=itm[9]
		if itm[10]!=nil then
			if itm[10]>0 then newitem.color3=itm[10] else newitem.color3=itm[8] end
		end
		if itm[11]!=nil then newitem.color4=itm[11] end
	end
	
	if itm[12]!=nil then newitem.singlecolor1=itm[12] else newitem.singlecolor1=1 end
	if itm[13]!=nil then newitem.singlecolor2=itm[13] else newitem.singlecolor2=7 end

	newitem.init(newitem)
end

function createitems()
	local fx,fy,tx,ty=0
	local p=false
	-- for x=1, 63 do
		-- for y=3,63 do
			-- fx=x fy=y
			-- p=not p
			-- if y>32 then fx+=64 fy-=32 end
			-- local placeitem=(rnd(1)>0.9) and fget(mget(fx,fy),2) and p
			-- if placeitem then additem(items.trees[ceil(rnd(#items.trees))],x,y) mset(fx,fy,37) end
		-- end
	-- end
	
	t=0
	while t<112 do
		tx=mid(1,flr(rnd(63)),63)	fx=tx
		ty=mid(3,flr(rnd(63)),63)	fy=ty
		if ty>32 then fx+=64 fy-=32 end
		
		if fget(mget(fx,fy),2) then
			additem(items.trees,ceil(rnd(#items.trees)),tx,ty)
			t+=1
			
			
			for x=tx-1, tx+1 do
				for y=ty-2,ty+1 do
					fx=x fy=y
					if y>32 then fx+=64 fy-=32 end
					
					if fget(mget(fx,fy),2) then mset(fx,fy,37) end
				end
			end
		end
	end
	
	local rocksplaced=0
	
	while rocksplaced<rocks_to_place do
		tx=mid(1,flr(rnd(63)),63)	fx=tx
		ty=mid(3,flr(rnd(63)),63)	fy=ty
		if ty>32 then fx+=64 fy-=32 end
		
		if fget(mget(fx,fy),2) then
			additem(items.rocks,ceil(rnd(#items.rocks)),tx,ty)
			rocksplaced+=1
			
			for x=tx-1, tx+1 do
				for y=ty-1,ty+1 do
					fx=x fy=y
					if y>32 then fx+=64 fy-=32 end
					
					if fget(mget(fx,fy),2) then mset(fx,fy,37) end
				end
			end
		end
	end

	local flowerstoplace = ceil(mid(16, 16+rnd(32), 64))
	local flowersplaced=0

	while flowersplaced<flowerstoplace do
		tx=mid(1,flr(rnd(63)),63)	fx=tx
		ty=mid(3,flr(rnd(63)),63)	fy=ty
		if ty>32 then fx+=64 fy-=32 end
		
		if fget(mget(fx,fy),2) then
			additem(items.flowers,ceil(rnd(#items.flowers)),tx,ty)
			flowersplaced+=1
			
			for x=tx-1, tx+1 do
				for y=ty-1,ty+1 do
					fx=x fy=y
					if y>32 then fx+=64 fy-=32 end
					
					if fget(mget(fx,fy),2) then mset(fx,fy,37) end
				end
			end
		end
	end

	local environtoplace = ceil(mid(16, 16+rnd(32), 64))
	local environplaced=0

	while environplaced<environtoplace do
		tx=mid(1,flr(rnd(63)),63)	fx=tx
		ty=mid(3,flr(rnd(63)),63)	fy=ty
		if ty>32 then fx+=64 fy-=32 end
		
		if fget(mget(fx,fy),2) then
			additem(items.environment,ceil(rnd(#items.environment)),tx,ty)
			environplaced+=1
			
			for x=tx-1, tx+1 do
				for y=ty-1,ty+1 do
					fx=x fy=y
					if y>32 then fx+=64 fy-=32 end
					
					if fget(mget(fx,fy),2) then mset(fx,fy,37) end
				end
			end
		end
	end
end
-->8
--items
items=
{
	environment=
	{
		{"hole", nil, {{180, 1,1, 0,0}}, {}, {}, nil, 0},
		{"weed", nil, {{185, 1,1, 0,0}}, {}, 0, nil, 0},
	},
	
	trees=
	{
		{"hardwood tree", nil, {{139, 2,3, 4,16}}, {}, {}, nil, 2},
		{"cedar tree", nil, {{137, 2,3, 4,16}}, {}, {}, nil, 3},
	},
	treestumps=
	{
		{"hardwood tree stump", nil, {{168, 1,1, 0,8},{171, 2,1, 4,0}}, {}, {}, nil, 2},
		{"cedar tree stump", nil, {{168, 1,1, 0,8},{169, 2,1, 4,0}}, {}, {}, nil, 2},
	},
	rocks=
	{
		{"rock", 164, {{164, 1,1, 0,0}}, {}, {}, nil, 4},
		{"rock", 165, {{165, 1,1, 0,0}}, {}, {}, nil, 4},
		{"rock", 166, {{166, 1,1, 0,0}}, {}, {}, nil, 4},
		{"rock", 167, {{167, 1,1, 0,0}}, {}, {}, nil, 4},
	},
	-- items=
	-- {
		-- {"pitfall seed", 136, {{136, 1,1 0,0}}, {}, 0, nil, 0}
	-- },
	flowers=
	{
		{"pink cosmos", 186, {{186, 1,1, 0,0}}, {}, 0, nil, 1, 6,3,5},
		{"yellow cosmos", 186, {{186, 1,1, 0,0}}, {}, 0, nil, 1, 5,3,8},
		{"blue cosmos", 186, {{186, 1,1, 0,0}}, {}, 0, nil, 1, 2,3,5},
		{"red tulips", 187, {{187, 1,1, 0,0}}, {}, 0, nil, 1, 1,3},
		{"white tulips", 187, {{187, 1,1, 0,0}}, {}, 0, nil, 1, 10,3},
		{"yellow tulips", 187, {{187, 1,1, 0,0}}, {}, 0, nil, 1, 5,3},
		{"white pansies", 188, {{188, 1,1, 0,0}}, {}, 0, nil, 1, 10,3,5,2},
		{"red pansies", 188, {{188, 1,1, 0,0}}, {}, 0, nil, 1, 17,3,5,10},
		{"yellow pansies", 188, {{188, 1,1, 0,0}}, {}, 0, nil, 1, 5,3,5,8},
	},
	houses=
	{
		{"player house", nil, {{7, 1,4, 16,24},{8, 1,2, 8,24},{41, 1,2, 8,8},{8, 1,4, 0,24},{9, 1,1, -8,24},{24, 1,1, -8,16},{41, 1,2, -8,8,true},{10, 1,4, -16,24}}, {}, 0, function(h) buildingcollision(h, -2,-2, 2,0, -2,2, 0,0) additem(items.houses,2,26,20.1) end, 1, 1,9,8},
		{"gyroid", 125, {{125, 1,1, 0,0}}, {0,0,1,2,2,1}, {}, nil, 1,12,12,12,12,1,1},
	},
}

function buildingcollision(building, x1,y1, x2,y2, ox1,ox2, dx,dy)
	for cy=y1, y2 do
		for cx=x1, x2 do
			if (cx!=dx or cy!=dy) then
				local tile=25
				
				if (cx==ox1 or cx==ox2) tile=37

				mset((building.x/8)+cx,(building.y/8)+cy,tile)
			end
		end
	end
end
-->8
--villagers
--villager types
	duck=70
	cat=86
	goat=102
	frog=118
	eagle=73
	mouse=89
	ostrich=105
	dog=121

villagers=
{
	{"apollo","pah",cranky,eagle,7,4,false,10,5,0,11},
	{"amelia","eaglet",snooty,eagle,7,4,false,10,14,1,11},
	{"drake","quacko",lazy,duck,6,25,false,8,3,3,5},
	{"dora","squeaky",normal,mouse,2,18,true,10,2,0,6,1,1},
	{"butch","rooooowf",cranky,dog,11,1,false,8,11,0,11},
	{"cookie","arfer",peppy,dog,6,18,true,10,6,0,11,6,1},
	{"nan","kid",normal,goat,8,24,true,7,5,5,6,7,1},
	{"sandy","speedy",normal,ostrich,10,21,false,5,1,2,2},
	{"huck","hopper",jock,frog,7,9,false,7,5,2,3},
}
__gfx__
00000000c5511151111111111111115cf4fff4fff4fff4fff4fff441000001111111111111111111111000000000000033a3aa3b33a3aa3b33a3aa3b01144110
00000000511bbb1bbb5bbb5bbbbbbb15f4fff4fff4fff4fff4fff44100001555555555551bbbbbb155510000000000003b33a3333b3344333b33a33314455441
000000001bbb33b33bbb3bb33bb33bb1f4fff4fff4fff4ffff4ff44100001555555555551b3333b155510000000000003bb3333444b4444344b333b345578754
000000001bb33bbb33333bbb33333bb1f4fff4fff4fff4ffff4ff44400001111111111111b3333b11111000000000000333334444444444444433bbb14466741
0000000051bbb3aa3b3bb3aa3b3bb3b11f4ff4ffff4fff4fff4fff4400001544454445441b1111b145410000000000003b3b4449494949494444b3aa45767655
000000001bb3b3a3bb33b3a3bb33b3b11f4fff4fff4fff4fff4fff4400001111111111111bbbbbb11111000000000000bb34449494949494944443a344777744
000000001b333b3333333b3333333bb11f4fff4fff4fff4ff4ffff440000144544454445133333314441000000000000333449494949494949444b3311155111
000000001ba3bbb33aa3bbb33aa3bb151f4fff4fff4fff4ff4ffff4100001445444544451333333144410000000000003344949499999999949444b300144100
ccccccc851b3aa3b33a3aa3b33a3aab1f4fff4fff4fff4fff4ffff41000015545554555433a3aa3b55510000d1dd1ddd33a44949999999999949443be7e7e7e7
ccc7cecc1b33a3333b33a3333b33a3b1f4fff4fff4fff4fff4fff44100001544454445443b33a333454100001dd111d13b4494999999999994944433ee7eeeee
2ccccccc1b3333b33bb333b33bb33bb114ffff4ff4fff4ffff4ff44100001544454445443bb333b345410000d44dd44d3444494999999999994943b38e8e8e8e
8ccceccc1bb33bbb33333bbb33333b15e14fff111111ff4ff11fff1e000014555455545533333bbb54510000666666663444949999999999949444bb8e828e82
ccc7cccc51bbb3aa3b3bb3aa3b3bbbb172111177772211111221112700001445444544453b3ba3aa44410000544554453b444949999999999949444a28282282
c2ccc8cc51b3b3a3bb33b3a3bb33bbb1ce7227ceceee2277777277cc0000144544454445bb33b3a3444100001441144dbb349499999999999494444322287222
ccccccec1bb33b3333333b3333333b15cccecccccc8ceeeceecccecc000015545554555433333b33555100001441d44d33444949999999999949443372777727
2cc7cccc1ba3bbb33aa3bbb33aa3bb15cccc8cccc2ccc8cc8ccccc8c00000111111111113aa3bbb311100000144d14413a4494999999999994944bb377e77777
cccccc8c51a3aa3b33a3aa3b33a3abb133a3aa3b33a3aa3b3311113b00000133333333333333333333100000d44d144d33a44949999999994944443bcccc7c2c
cc7ecccc1b33a3333b33a3333b33a3b13b33a3333b33a333111ff111000001bbbb1111bbcccccccbbb100000144114413b3444949494949494944433eccccccc
ccccc2cc1bb333b33bb333b33bb33bb13bb399993bb333b3ff1441ff000001bbb199991bc99c99cbbb100000d44dd44d3bb3444949494949494443b3cccc2cc8
cecc8ccc1b333bbb33333bbb3333bb1599999999333a3bbb44144144000001bb19999991c99c99cbbb10000066666666333344449494949444443bbbc7cccccc
cccccc7c51bbb3aa3b3bb3aa3b333bb1999999993b3bb3aa44144144000001bb19999991cccccccbbb100000544554453b3bb44444444444444bb43accc8ccec
8cc2cccc1bb3b3a3bbb3b3b33bbb3b1499999999bb33b3a311144111000001bb19999991c99c99cbbb1000001221122dbb33b334b44443444b33b3a3cc2ccccc
ccccccce414bbb4b3b4bbb4bbb4bbb447777999933333b3333144133000001bb19999991c99c99cbbb1000001d11dd1d33333b3333443b3333333b33cccce7cc
c2c7cccc44ffbf4fbf4fbf4fbf4fbf44222277773aa3bbb33a1441b3000001bb19999991cccccccbbb10000011dd11d13aa3bbb33aa3bbb33aa3bbb3c8cccccc
ccccc8ccf4fff4fff4fff4fff4ffff4122222222d5dd5ddd3311113b000001bb19999991bbbbbbbbbb1000009999999999494443999999993449499900000000
ceccccc7f4fff4fff4fff4fff4fff441888822225dd555d53b1ff133000001bb19999991bbbbbbbbbb1000009999999999949444999999944494949900000000
cc2cccccf4fff4fff4fff4fff4fff44188888888d55ddd5d3b1441b3000001bb19999991bbbbbbbbbb1000004999999999994944999999494949499900000000
8cccecccf4ffff4ff4fff4ffff4ff444eeee8888d5dddd5d331111bb000001bb19999991bbbbbbbbbb1000009499999999999494999994949494999900000000
c7cccccc4f4fff4fff4fff4fff4fff44eeeeeeee5d5dd5d53b1441aa000001bb11919191bbbbbbbbbb1000004949999999999949999949444949999900000000
c8ccc2cc4f4fff4fff4fff4fff4fff44cccceeee5dd55d5dbb1441a3000001bb10101011bbbbbbbbbb1000004494999999999994999494449499999900000000
eccccccc144ff444ff4fff44ff4fff417777cccc5d55dd5d33144133000000111101010111111111110000004449499999999999994944444999999900000000
2cc7cccc114444114414f4114414f411cccc777755dd55d53a1441b3000000000000000000000000000000003444949999999999999444439999999900000000
30888803308888003088880300088000888800000008800000000000000000000000000000044000044000000004400005288250005280000528825000528000
33888833338888803388883330888803388888003088880300cccc0000ccc00000cccc0000444400444440000044440054888845054588005488884505458800
3822228333882220388888833822228333882220388888830cccccc00ccccc000cccccc00cc44cc004ccc4000444444054888845054588005488884505458800
827447283822474088888888327447233822474038888883cc7bb7ccccccb7b0cccccccc011cc11044c11c000444444054888845054588005488884505458800
279449722244794028888882279449722244794028888882c79bb97cccbb79b0bccccccb079bb97004c79bb00444444005888850005888000888888008588880
479ff9744444794f42222224479ff9744444794f42222224b79aa97bcbbb79a0bbccccbb0cbbbbc0044ccbbb0444444000411400001411000041140000141100
544ff1455444414f54444445544ff1455444414f544444453baaaab33bbbbaaa3bbbbbb353bbbb355444bbb3d544445d01411410011411100141141001141110
0551155005555510055555500551155005555510055555500333333003333300033333300d3333d0dddd33330dddddd000111100001111000011110000111100
02888820002880000000000002888820002880000000000044000044044000004400004404400440044000000440044005288250005280000528825000528000
2888888202828800000000002888888202828800000000004b4004b404b40000444004444bb44bb44bb400005444444554888845054588005488884505458800
5488884505458800000000005488884505458800000000004444444404b44400444444444b3cc3b44b3c0000554cc45545888845545888004588884554588800
5422224505452200000000005488884505458800000000004794497444447940444444440074c7000cc4700000cccc0045888850545888004588885054588800
05dddd50005ddd0000000000022222200252222000000000479cc974444479c0444444440c933940cc4494330cccccc050408800058888005888888005888880
0041140000141100000000000041140000141100000000004ccbbcc4c4444ccbcc4444cc0c433440c44444300cccccc000411400004114000041140000411400
01b11b10011bb1100000000001b11b10011bb11000000000dc1cc1cddccc1cd0dccccccd054441505441450005cccc5001111410041111400111141004111140
0011110000111100000000000011110000111100000000000dd11dd00dddd1000dddddd000511500055510000055550000111400001111000011140000111100
0288882000288000000000000288882000288000000000000bb00bb0bbb000000b0000b000000000000000000000000000000000002580000025800000258000
2888888202828800000000002888888202828800000000004430034404bb00004bb00bb400445500004440000044440000000000005458000054580000545800
548888455458880000000000548888455458880000000000444cc444044b44004b3443b40cc44cc0044cc4000444444000000000005458000054580000545800
442222505452220000000000448888505458880000000000477c4774444477404344443407944970044794000444444000000000008545000085450000854500
50dddd0005dddd0000000000522888200522222000000000479449744444794444444444079bb970044794b00444444000000000008858000088580008885800
00b1dd000b4114b00000000000b222100b4114b00000000054444445544444445444444505333350054443330544445000000000004114000041140000411400
0111141001bb1b10000000000111141001bb1b100000000005144150054441450544445000555500005555000055550000000000041111400411114004111140
00111b00001111000000000000111b00001111000000000000511500005555100055550000055000000550000005500000000000001111000011110000111100
07777760008280000000060000000000008280000000000000000000000000000000000000000000000000000000000000000000000450000004500000045000
77787776002828000000676000000000002828000000000004400440004440000440044000b44b0000bbb00000b44b0000000000004445000044450000444500
7778777600545800000067670000000000545800000000004cc44cc4044cc000444444440bb44bb00bbbb4000bb44bb000000000044555500445555004455550
7777777600854500677777670000000000854500000000004794497404479000444444443774477333b77b003bb44bb300000000407475000077470000474705
0778776000dd5500666777770000000002225520000000000444444044444400044444403794497333b79b403bb44bb300000000459494454594994545494945
007760000b4114b000677777000000000b4114b000000000bb1441bb4bbb1440b444444b3bc11cb333bbbcc13b4444b300000000004945050049950040449500
0076000001bb1b10006677670000000001bb1b10000000003b4114b35bbb4110354444530dccc1d0054cc1cd0544445000000000014445100144451001444510
00600000001111000006660600000000001111000000000003555530053355000555555000d11d000055dd100055550000000000144455511444555114445551
1ffffffffffffffffffffff111111111000050000000000000000000000000000000000000000000100000000000001111000000dd61dd610882882882882880
1ffffffffffffffffffffff100000000000550000003303000000ff000ffcd0000777f0000000001b1000000000001bb33100000666166618828828888288288
1ffffffffffffffffffffff1000000000005550000bbb3000000f8900f99fcd0077877f00000001a3b10000000001baab331000011111111f1fff1ffff1fff1f
1ffffffffffffffffffffff1000000005555544400b33b3000f5ff280f9ffcd0077877f0000001ab3a3100000001baaabb3310001dd61dd60555555555555550
1ffffffffffffffffffffff100000000045444400b3b11310f555f820cf9cfd0077777f000001bbabab310000001bbbbbb33100011111dd60483888478778740
1ffffffffffffffffffffff1000000000044440013b111b11955ff981dccff911f787ff10001b33ab33ab1000011133bbbb510001dd61dd6033bb38477777740
1ffffffffffffffffffffff1000000000540440013b100101199991111ddd91111ffff11001555a555a5551001bbbb33445111001dd61dd603b83bb477d66750
1ffffffffffffffffffffff100000000040004000110000001111110011111100111111000011a53a55a11001bbaabb354bb33101dd616660022224476d66750
1ffffffffffffffffffffff100000000004400000000300000000000000000440004444000015ba3baba31001baaab335aabb3311dd6111100457875766d7700
1ffffffffffffffffffffff10000000000244f000003b000000ef00000000b4000004400001babab3abb3a101baabbb35abbb33116661dd600456675776d6700
1ffffffffffffffffffffff110101010028228f000999a0000eeef00003aab300000404001ba5555b555bba114bbbb351bbbb33111111dd60f57676576d667f0
1ffffffffffffffffffffff10101010102888880049999a00e2eeee00bbb3b3008840004001155a555a551101544455514bb335116661dd60447777477dd7750
1ffffffffffffffffffffff11010101002888880049999900e2eeee00b3bb30028f85884001aba3bb53ab10001555551544555511dd616660445554445544440
144444444444444444444441d1d1d1d1192888a114499941b9e2efbb13bb3311228528f801ab33a3aba3ba100011111215555510111111110015511111155100
1444444444444444444444411d1d1d1d119aaa1111444411139ff33111333110122522881bb5551525b555a10000022e21111100dd61dd610114411111144110
111111111111111111111111d6d6d6d601111110011111100111111001111100111152210111112e225111100000028e82200000666166610011111111111100
44444454ee8eeece07777760000000000330000000000330003330000003330000000000000002288e200000000002e88e20000011111111888fffff9f9f9f9f
44444454ea8aeaca77787776000000003aa3000000003aa303aaa300003aaa3000000000000002e8e820000000000288e8200000ddddddd18888f88892299222
55555555bbbcccbb77787776000000003aab33300333aab305faab3003aaa4500000000000011288e8e1100000012288e8211000555555d18888f88892229229
44544444eacaea8a77777776000000005fbb3aa33ab3fbb55ffff4455ffff44500000000001182e882e811000011e8ee8ee8110011111111fffff88899999999
44544444eeceee8e07787760000000005f444f455ff4f4455fff44455fff444500000000001822e228228100001ee8ee8828e100c1c1c17188ffffff5d5dd5d5
44544444eacaea8a007760000000000054444551155f4445544444455444445100eee8000011182118211100001118811ee111001c121c1888f888885dd55d5d
55555555ccbbbbbc0076000000000000155551100115555115555551155555100eee8ee0000118111121100000011e1111e11000ccccccce88f888885d55dd5d
44444454ea8aeaca00600000000000000111100000011110011111100111110002eeee20000001100110000000000110011000002cc7ccccfff8888855dd55d5
d6d6d6d600000000000000000000000000000000000000000000000000000000033bb3300000000000054500000450000550000011111111ff242222222242ff
1d1d1d1d000000000000000000000000000000000000000000000000000000003bb55bb3000000000004d4000004400005250440ddddddd1f98f88888888f8f9
d1d1d1d100000000000000000000000000555500000000000000000000000000b557865b00000010000545000004454052445840555555d19f8f88888888f89f
1010101000000000000000000000000005999950000000000000000000000000144667410100010005453545045b344044842d8411111111f9242222222242f9
0101010100000000000000000000000059444495000000000000000000000000457676550010110004d434d40443344048d848441ddd1dd19f888f8888f8889f
101010100000000000000000000000005444444500000000000000000000000044777744001110000545b5450441b3bb048445bb155d15d1f9888f8888f888f9
00000000000000000000000000000000054444500000000000000000000000001115511100011000bb3b1331bb3b1331b44b1331e111111e9f2224222242229f
000000000000000000000000000000000055550000000000000000000000000000144100000000001331011013310110133101108e7227e844dd55d555dd5544
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
__label__
999999999999999999999999999999993bbb33993bbb33993bbb33993bbb33993bbb355dd55d555dd55d555dd55d555dd55d53993bbb33993bbb33993bbb3399
977999999777979799999777977799993993b3393993b3393993b3393993b3393993b3393993bd5dd5dddd5dd5dddd5dd5ddd3393993b3393993b3393993b339
99719979991717171999971717771993393333b3393333b3393333b3393333b3393333b3393335dd555d55dd555d55dd555d53b3393333b3393333b3393333b3
9971999197771777199997771717199b333b33bb333b33bb333b33bb333b33bb333b33bb333b3d55ddd5dd55ddd5dd55ddd5d3bb333b33bb333b33bb333b33bb
9971997997111917199997111717199333bbb33333bbb33333bbb33333bbb33393bbb33393bbbd5dddd5dd5dddd5dd5dddd5d33393bbb33333bbb33333bbb333
977799919777999719999719971719b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3995d5dd5d55d5dd5d55d5dd5d53b3bb3993b3bb3993b3bb3993b3
991119999911199919999919991919b33b393bb33b393bb33b393bb33b393bb33b393bb33b3935dd55d5d5dd55d5d5dd55d5dbb33b393bb33b393bb33b393bb3
9777999797799777999999999999933333b3333333b3333333b3333333b3333333b3333333b335d55dd5d5d55dd5d5d55dd5d33333b3333333b3333333b33333
991719791971971119999999999933993bbb33993bbb33993bbb33993bbb33993bbb33993bbb355dd55d555dd55d555dd55d53993bbb33993bbb33993bbb3399
9997197199719777999999999993b339391111111111111111111111111111113993b3393993bd5dd5dddd5dd5dddd5dd5ddd3393993b3393993b3393993b339
999719719971991719999999993333b33122222222222222222221ffffff1222193333b3393335dd555d55dd555d55dd555d53b3393333b3393333b3393333b3
999717919777977719999999933b33bb3122222222222222222221f9999f1222133b33bb333b3d55ddd5dd55ddd5dd55ddd5d3bb333b33bb333b33bb333b33bb
99991919991119111999999393bbb3339111111111111111111111f9999f111113bbb33393bbbd5dddd5dd5dddd5dd5dddd5d33393bbb33333bbb33393bbb333
9999999999999999999993b3bb3993b3b128882888288828882881f1111f18281b3993b3bb3995d5dd5d55d5dd5d55d5dd5d53b3bb3993b3bb3993b3bb3993b3
39999999999999999b393bb33b393bb33111111111111111111111ffffff11111b393bb33b3935dd55d5d5dd55d5d5dd55d5dbb33b393bb33b393bb33b393bb3
331333355335111333b3333333b333333188288828882888288821999999188813b3333333b335d55dd5d5d55dd5d5d55dd5d33333b3333333b3333333b33333
3133bb33553335513bbb33993bbb3399318828882888288828882199999918881bbb33993bbb355dd55d555dd55d555dd55d53993bbb33993bbb33993bbb3399
313bbb3555bb33551993b3393993b339312282228222822282228222822282221993b3393993bd5dd5dddd5dd5ddd3393993b3393993b3393993b3393993b366
313bb33355b33355193333b3393333b331288828882888288828882888288828193333b3393335dd555d55dd555d53b3393333b3393333b3393333b33933336d
3133333551333355133b33bb333b33bb31288828882888288828882888288828133b33bb333b3d55ddd5dd55ddd5d3bb333b33bb333b33bb333b33bb333b36d7
915333555133355513bbb33393bbb3339182228222822282228222822282228213bbb33393bbbd5dddd5dd5dddd5d33393bbb33333bbb33333bbb33393bbb77c
bb155555153355551b3993b3bb3993b3b18828882888288828882888288828881b3993b3bb3995d5dd5d55d5dd5d53b3bb3993b3bb3993b3bb3993b3bb3997c9
3b311111215555513b393bb33b393bb3318828882888288828882888288828881b393bb33b3935dd55d5d5dd55d5dbb33b393bb33b393bb33b393bb33b393b7c
33b33322f211111333b3333333b333333122822282228222822282228222822213b3333333b335d55dd5d5d55dd5d33333b3333333b3333333b3333333b33b77
3bbb3324f42233993bbb33993bbb33993b1111111111111111111111111111113bbb33993bbb355dd55d555dd55d53993bbb33993bbb33993bbb33993bbb3133
3993b32f44f2b3393993b3393993b339391999999999999999999999999999913993b3393993bd5dd5dddd5dd5ddd3393993b3393993b3393993b3393993b339
393333244f4233b3393333b3393333b3391ff4444444fff1111fff4444444ff1393333b3393335dd555d55dd555d53b3393333b3393333b3393333b3393333b3
333b12244f4211bb333b33bb333b33bb331ff4114114ff111111ff4114114ff1333b33bb333b3d55ddd5dd55ddd5d3bb333b33bb333b33bb333b33bb333b33bb
93b11f4ff4ff411393bbb33393bbb333931ff4114114f11111111f4114114ff193bbb33393bbbd5dddd5dd5dddd5d33393bbb33333bbb33333bbb33393bbb333
bb31ff4ff4424f13bb3993b3bb3993b3bb1ff4444444f11111111f4444444ff1bb3993b3bb3995d5dd5d55d5dd5d53b3bb3993b3bb3993b3bb3993b3bb3993b3
3b31114411ff11133b393bb33b393bb33b1ff4114114f11111111f4114114ff13b393bb33b3935dd55d5d5dd55d5dbb33b393bb33b393bb33b393bb33b393bb3
33b311f1111f113333b3333333b33333331ff4114114f11111111f4114114ff133b3333333b335d55dd5d5d55dd5d33333b3333333b3333333b3333333b33333
3bbb33113b1133993bbb33993bbb33993b1ff4444444f11111111f4444444ff13bbb33993bbb355dd55d555dd55d53993bbb33993bbb33993bbb33993bbb3399
3993b3393993b3393993b3393993b339391fffff94fff11111111ffffffffff13993bd5dd5dddd5dd5dddd5dd5dddd5dd5ddd3393993b3393993b3311113b339
393333b3393333b3393333b3393333b3391ffff9994ff11111111ffffffffff1393335dd555d55dd555d55dd555d55dd555d53b3393333b339333313355133b3
333b33bb333b33bb333b33bb333b33bb331fff994444f11111111ffffffffff1333b3d55ddd5dd55ddd5dd55ddd5dd55ddd5d3bb333b33bb333b313bb35513bb
93bbb33393bbb33393bbb33393bbb333931ff9f1914ff11111111ffffffffff193bbbd5dddd5dd5dddd5dd5dddd5dd5dddd5d33393bbb33393bb13bbb3355133
bb3993b3bb3993b3bb3993b3bb3993b3bb1ff9419199411111111ffffffffff1bb3995d5dd5d55d5dd5d55d5dd5d55d5dd5d53b3bb3993b3bb391333333551b3
3b393bb33b393bb33b393bb33b393bb33b1ffff9194f41d151d11ffffffffff13b3935dd55d5d5dd55d5d5dd55d5d5dd55d5dbb33b393bb33b311155333351b3
33b3333333b3333333b3333333b3333333b11119994111151d1511111111111333b335d55dd5d5d55dd5d5d55dd5d5d55dd5d33333b333333313333553351113
3bbb33993bbb33993bbb33993bbb33993bbb31999444155dd55d53993bbb33993bbb355dd55d555dd55d555dd55d555dd55d53993bbb33993133bb3355333551
3993b3393993b3393993b3393993b3393993b3393993bd5dd5dddd5dd5dddd5dd5dddd5dd5dddd5dd5dddd5dd5dddd5dd5dddd5dd5ddd339313bbb3555bb3355
393333b3393333b3393333b3393333b3393333b3393335dd555d55dd555d55dd555d55dd555d55dd555d55dd555d55dd555d55dd555d53b3313bb33355b33355
333b33bb333b33bb333b33bb333b33bb333b33bb333b3d55ddd5dd55ddd5dd55ddd5dd55ddd5dd55ddd5dd55ddd5dd55ddd5dd55ddd5d3bb3133333551333355
33bbb33333bbb33333bbb33393bbb33393bbb33393bbbd5dddd5dd5dddd5dd5dddd5dd5dddd5dd5dddd5dd5dddd5dd5dddd5dd5dddd5d3339153335551333555
bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3995d5dd5d55d5dd5d55d5dd5d55d5dd5d55d5dd5d55d5dd5d55d5dd5d55d5dd5d53b3bb15555515335555
3b393bb33b393bb33b393bb33b393bb33b393bb33b3935dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5dbb33b31111121555551
33b3333333b3333333b3333333b3333333b3333333b335d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d33333b33322f2111113
3bbb33993bbb33993bbb33993bbb33993bbb33993bbb355dd55d555dd55d555dd55d555dd55d555dd55d555dd55d555dd55d555dd55d53993bbb3324f4223399
3993b3393993b3393993b3393993b3393993b3393993bd5dd5dddd5dd5dddd5dd5dddd5dd5dddd5dd5dddd5dd5dddd5dd5dddd5dd5ddd3393993b32f44f2b339
393333b3393333b3393333b3393333b3393333b3393335dd555d55dd555d55dd555d55dd555d55dd555d55dd555d55dd555d55dd555d53b3393333244f4233b3
333b33bb333b33bb333b33bb333b33bb333b33bb333b3d55ddd5dd55ddd5dd55ddd5dd55ddd5dd55ddd5dd55ddd5dd55ddd5dd55ddd5d3bb333b12244f4211bb
33bbb33333bbb33333bbb33333bbb33393bbb33393bbbd5dddd5dd5dddd5dd5dddd5dd5dddd5dd5dddd5dd5dddd5dd5dddd5dd5dddd5d33393b11f4ff4ff4113
bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3995d5dd5d55d5dd5d55d5dd5d55d5dd5d55d5dd5d55d5dd5d55d5dd5d55d5dd5d53b3bb31ff4ff4424f13
3b393bb33b393bb33b393bb33b393bb33b393bb33b3935dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5d5dd55d5dbb33b31114411ff1113
33b3333333eee33333b3333333b3333333b3333333b335d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d5d55dd5d33333b311f1111f1133
3bbb339937eeee993bbb33993bbb33993bbb33993bbb355dd55d555dd55d5588885d555dd55d555dd55d555dd55d555dd55d555dd55d53993bbb33113b113399
3993b3393e11e2293993b3393993b3393993b3393993b3393993bd5dd5ddd88888dddd5dd5dddd5dd5dddd5dd1dddd5dd5ddd3393993b3393993b3393993b339
393333b37e61e223393333b3393333b3344333b3393333b3393335dd555d522288dd55dd555d55dd555d55dd131d55dd555d53b3393333b3393333b3393333b3
333b33b177eee22b333b33bb3333444b4444344b333b33bb333b3d55ddd5df7f228ddd55ddd5dd55ddd5dd51b531dd55ddd5d3bb333b33bb333b33bb333b33bb
33bbb3367177763333bbb333334444444444444433bbb33393bbbd5dddd5df17ff22dd5dddd5dd5dddd5dd1b35b51d5dddd5d33393bbb33393bbb33393bbb333
bb3993b3166663b3bb3993b3b4449494949494444b3993b3bb3995d5dd5def17ffff55d5dd5d55d5dd5d5133b3b351d5dd5d53b3bb3993b3bb3993b3bb3993b3
3b393bb33b506bb33b393bb3444949494949494444393bb33b3935dd55d5ef1ffff9d5dd55d5d5dd55d51355b355b31d55d5dbb33b393bb33b393bb33b393bb3
33b333333556763333b33333449494949494949444b3333333b335d55dd5d1999995d5d55dd5d5d55dd1555b555b55515dd5d33333b3333333b3333333b33333
3bbb3399355676993bbb33344949499999999949444b33993bbb355dd55d5558825d555dd55d555dd55d11b55b55b11dd55d53993bbb33993bbb33993bbb3399
1113b339355676393993b33944949999999999949443b3393993b3393993b3882823bd5dd5dddd5dd5dd153b53b3b5193993b3393993b3393993b3393993b339
355133b3355563b3393333b44949999999999949444333b3393333b3393333889f9335dd555d55dd55513b3b35b335b1393333b3393333b3393333b3393333b3
b35513bb311713bb333b33444494999999999994943b33bb333b33bb333b33229f9b3d55ddd5dd55dd13b5555355533b133b33bb333b33bb333b33bb333b33bb
b33551331117113333bbb3444949999999999949444bb33333bbb33333bbb3ddd9bbbd5dddd5dd5dddd1155b555b551193bbb33333bbb33333bbb33333bbb333
333551b3b11113b3bb3993b44494999999999994944493b3bb3993b3bb399311f13995d5dd5d55d5dd51b3b53355b313bb3993b3bb3993b3bb3993b3bb3993b3
333351b33b393bb33b393bb3494999999999994944443bb33b393bb33b39311cc11935dd55d5d5dd551b355b5b3b53b13b393bb33b393bb33b393bb33b393bb3
5335111333b3333333b3333444949999999999949443333333b3333333b3331111b335d55dd5d5d5513355515253555b13b3333333b3333333b3333333b33333
553335513bbb33993bbb3394494999999999994944bb33993bbb33993bbb33993bbb355dd55d555dd5111112f22511113bbb33993bbb33993bbb33993bbb3399
55bb33551993b3393993b33944949999999994944443b3393993b3393993b3393993b3393993b3393993b32244f2b3393993b3393993b3393993b3393993b339
55b33355193333b3393333b34449494949494949444333b3393333b3393333b3393333b3393333b33933332f4f4233b3393333b3393333b3344333b3393333b3
51333355133b33bb333b33bb3444949494949494443b33bb333b33bb333b33bb333b33bb333b33bb333b11244f4f11bb333b33bb3333444b4444344b333b33bb
5133355513bbb33333bbb333344449494949444443bbb33333bbb33333bbb33393bbb33393bbb33393b1142f442f411393bbb333334444444444444433bbb333
153355551b3993b3bb3993b3bb44444444444444bb4393b3bb3993b3bb3993b3bb3993b3bb3993b3bb31422f22422413bb3993b3b4449494949494444b3993b3
215555513b393bb33b393bb33b334b44443444b33b393bb33b393bb33b393bb33b393bb33b393bb33b311142114211133b393bb3444949494949494444393bb3
f211111333b3333333b3333333b3333443b3333333b3333333b3333333b3333333b3333333b3333333b311411112113333b33333449494949494949444b33333
f42233993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33113b1133993bbb33344949499999999949444b3399
44f2b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b33944949999999999949443b339
4f4233b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b44949999999999949444333b3
4f4211bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333133bb333b33bb333b33bb333b33444494999999999994943b33bb
f4ff411393bbb33333bbb33333bbb33333bbb33333bbb33333bbb33333bbb33393bbb313931bb33393bbb33393bbb33393bbb3444949999999999949444bb333
f4424f13bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b1b11993b3bb3993b3bb3993b3bb3993b44494999999999994944493b3
11ff11133b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb111393bb33b393bb33b393bb33b393bb3494999999999994944443bb3
111f113333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333311b3333333b3333333b3333333b33334449499999999999494433333
3b1133993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb3394494999999999994944bb3399
3993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b33944949999999994944443b339
393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b34449494949494949444333b3
333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb3444949494949494443b33bb
93bbb33393bbb33333bbb33333bbb33333bbb33333bbb33333bbb33333bbb33393bbb33393bbb33393bbb33333bbb33333bbb333344449494949444443bbb333
bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb44444444444444bb4393b3
3b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b334b44443444b33b393bb3
33b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333443b3333333b33333
3bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb3399
3993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b339
393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3
333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb
33bbb33333bbb33333bbb33333bbb33393bbb33393bbb33393bbb33333bbb33393bbb33393bbb33393bbb33333bbb33333bbb33333bbb33333bbb33333bbb333
bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3
3b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb3
33b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b33333
3bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb3399
3993b3393993b3393993b3393993b3393993b3392e23b3393993b3393993b3393993b3223993b3393993b3393993b3393993b3393993b3393993b3393993b339
393333b3393333b3393333b3393333b3393333b3e9e333b3393333b3393333b339333326298833b3393333b3393333b3393333b3393333b3393333b3393333b3
333b33bb333b33bb333b33bb333b33bb333b33bb2e2b33bb333b33bb333b33bb333b3268827833bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb
93bbb33333bbb33333bbb33333bbb33393bbb32e232e233393bbb33333bbb33393bbb8878697833393bbb33393bbb33393bbb33333bbb33333bbb33333bbb333
bb3993b3bb3993b3bb3993b3bb3993b3bb3993e9e3e9e3b3bb3993b3bb3993b3bb399879787883b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3
3b393bb33b393bb33b393bb33b393bb33b393b2e2b2e2bb33b393bb33b393bb33b393b87882bbbb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb3
33b3333333b3333333b3333333b3333333b33bb3b133133333b3333333b3333333b33b88b133133333b3333333b3333333b3333333b3333333b3333333b33333
3bbb33993bbb33993bbb33993bbb33993bbb31331b1133993bbb33993bbb33993bbb31331b1133993bbb33993bbb33993bbb33993bbb33993bbb33993bbb3399
3993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3392e23b3393993b3393993b3393993b3393993b339
393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3e9e333b3393333b3393333b3393333b3393333b3
133b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb2e2b33bb333b33bb333b33bb333b33bb333b33bb
93bbb33333bbb33333bbb33333bbb33393bbb33393bbb33393bbb33333bbb33393bbb33393bbb33393bbb32e232e233393bbb33393bbb33393bbb33393bbb333
bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993e9e3e9e3b3bb3993b3bb3993b3bb3993b3bb3993b3
3b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393b2e2b2e2bb33b393bb33b393bb33b393bb33b393bb3
13b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b33bb3b133133333b3333333b3333333b3333333b33333
3bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb33993bbb31331b1133993bbb33993bbb33993bbb33993bbb3399
3993b3393993b3393993b3393993b3393993b3223993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3393993b3398293b3393993b339
393333b3393333b3393333b3393333b339333326298833b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3393333b3883333b3393333b3
333b33bb333b33bb333b33bb333b33bb333b3268827833bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb333b33bb882833bb333b33bb
93bbb33333bbb33333bbb33333bbb33393bbb8878697833393bbb33333bbb33333bbb33333bbb33393bbb33393bbb33393bbb33393bbb382b388b33393bbb333
bb3993b3bb3993b3bb3993b3bb3993b3bb399879787883b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb3993b3bb399388338893b3bb3993b3
3b393bb33b393bb33b393bb33b393bb33b393b87882bbbb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393bb33b393b881b3bbbb33b393bb3
33b3333333b3333333b3333333b3333333b33b88b133133333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b33bb3b133133333b33333

__gff__
0002020200000000000000000202020080020602808080000000000002020280800202028202000000000000020202808000000082020000020000020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000002000000000002000000000000000000020000020000000000000000000000008002000200000000000000000000000080122200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
131b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1113251212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121320202001251212121212122511
132b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b1113251212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121320202011121212121212122511
132626262626262626262626262626262626262626262626262626aeaeaeaeaeaeaeaeae2626262626262626adbdad212626262626262626262626262626261113251212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121320202021251212121212122511
132525252525252525252525252525252525222222252525252536aeaeaeaeaeaeaeaeae3625252525252513202020141125252525252525252525252525251113251212121212121212121212121212121222222212121212121212121212121212121212121212121212121212121212121320202014111212121212122511
132512121212121212121212121212121223151515211212122525afafafafafbebfafaf0c0d0e121212121203202020211212121212121212121212121225111325121212121212121212121212121212231515152112121212121212121212121212120c0d0e12121212121212121212122503202020212512121212122511
1325121225262626262626251212121213162020201411121212252535353525353525251c1d1e12120c0d0e13101010141112121212121212121212121225111325121212121212121212121212121213162020201411121212121212121212121212121c1d1e1212121212121212120c0d0e13202020141112121212122511
1325121225362525252536251212121213202020200112121212122525252525353525122c2d2e12121c1d1e12032020201112121212121212121212121225111325121212121212121212121212121213202020200112121212121212121212121212122c2d2e1212121212121212121c1d1e12032020201112121212122511
1325121225360c0d0e25362512121212120320200112121212121212121225353535251212121212122c2d2e12232020201112121212121212121212121225111325121212120c0d0e1212121212121212032020011212121212121212121212121212121212121212121212121212122c2d2e25232030201112121212122511
1325121225361c1d1e253625121212121212020212121212121212121212253535352512121212121212121223162030201112121212121212121212121225111325121212121c1d1e12121212121212121202021212121212121212121212121212121212121212121212121212121212122523163030301112121212122511
130c0d0e25362c2d2e2536251212120c0d0e121212121212121212121225353535250c0d0d0e1212121212131630303001121212121212121212121212122511130c0d0e12122c2d2e1212121212120c0d0e121212121212121212121212121212120c0d0d0e1212121212121212121212121316303030012512121212122511
131c1d3c0d262625252626251212121c1d1e121212121212121212121225353525121c1d1d1e12121225258d8d8d8d8d25251212121212121212121212122511131c1d3c0d0e1212121212121212121c1d1e121212121212121212121212121212121c1d1d1e1212121212121212121212252330303030111212121212122511
132c2d3b1d1e2525252525121212122c2d2e121212121212121212122535353525122c3b3d2e12121225259d9d9d9d9d25251212121212121212121212122511132c2d3b1d1e1212121212121212122c2d2e121212121212121212121212121212122c3b3d2e1212121212121212121212131620202001251212121212122511
1325122c2d2e121212121212121212121212121212121212121212122535353525120c3e3c0e1212121213bdadadadbd111212121212121212121212121225111325122c2d2e121212121212121212121212121212121212121212121212121212120c3e3c0e1212121212121212121212132020202021251212121212122511
132512121212121212121212121212121212121212121212121212122535353535251c1d1d1e1212121212032020202011121212121212121212121212122511132512121212121212121212121212121212121212121212121212121212121212121c1d1d1e1212121212121212121212132020202014111212121212122511
132512121212121212121212121212121212121212121212121212122525353535252c2d2d2e1212121212132020202021121212121212121212121212122511132512121212121212121212121212121212121212121212121212121212121212122c2d2d2e1212121212121212121212250320202020212512121212122511
1325121212121212121212121212121212121212121212121212121212253535353525121212121212121213202020101421222212121212121212121212251113251212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212122503202020141112121212122511
13251212121212121212121212121212121212121212121212121212122525353535251212121212121212120320101010141515212212121212121212122511132512121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121225258d8d8d8d2525121212122511
13251212121212122512121212122512121212121212121225252525252525353535251212121212121212121203101010101010141521221212121212122511132512121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121225259d9d9d9d2525121212122511
1325121212121212251212121212251212121212121212122535353535352535352512121212121212121212121203101010101010101415211212121212251113251212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212122523bdadadbd1112121212122511
1325121212121212251212121212251212121212121212122535353535352535352512121212121212121212121212020202031010101020141112121212251113251212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121225222316303030301112121212122511
1325121212121212251212121212251212121212121212122535353535353535353525121212121212121212121212121212120203202020202112121212251113251212121212121212121212121212121212121212121212121212121212121212121212121212121212121212122523151630303030012512121212122511
1325121212121212122525252525121212121212121212122525253535353535353535251212121212121212121212121212121212031010101411121212251113251212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121316303030303030111212121212122511
1325121212121212121212121212121212121212121212121225253535353535353535251212121212121212121212121212121212132020202011121212251113251212121212121212121212121212121212121212121212121212121212121212121212121212121212121212252330303030303001251212121212122511
1325121225252525251212121212121212121212121212120c0d0e253535353535352512121212121212121212121212121212121213202020201112121225111325121212121212121212121212121212121212121212120c0d0e12121212121212121212121212121212121212131630303030010225121212121212122511
1325121213252525111212121212121212121212121212121c1d1e121225353535251212121212121212121212121212121212121223202020201112121225111325121212121212121212121212121212121212121212121c1d1e12121212121212121212121212121212121212132020202001251212121212121212122511
1325121213252525212212121212121212121212121212122c2d2e121212121212120c0d0e1212121212121212121212121212121316303030011212121225111325121212121212121212121212121212121212121212122c2d2e121212121212120c0d0e121212121212121212132020202011121212121212121212122511
132212122325252504051112121212121212121212121212121212121212121212121c1d1e121212121212121212121212121212133030303011121212122511132512121212121212121212121212121212121212121212121212121212121212121c1d1e121212121212121212132020202011122525252525252525252521
130521230625252531321112121212121212121212121212121212121212121212122c2d2e121212121212121212121212121212233030303011121212122511132525252525252525252525252525252525252525252525252525252525252525252c2d2e252525252525121212132020202011122524242424242424242404
1332040633252525252511121212121212121212121212121212121212121212121212121212121212121212121212121212121316303030011212121212251106242424242424242424242424242424242424242424242424242424242424242424242424242424242411121225231f1f1f1f11121334343434343434343404
1325313325251212252511121212121212121212121212121212121212121212121212121212121212120c0d0e1212121212122330303030111212121212251106343434343434343434343434343434343434343434343434343434343434343434343434343434343421222223161f1f1f1f2122232f2f20202f2f2f2f2f14
1325252525121225250112121212121212121212121212121212121212121212121212121212121212121c1d1e12121212121316303030011212121212122511162f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f1415151620202020201415162f2f20202f2f2f2f2f2f
1325121212121225011212121212121212121212121212121212121212121212121212121212121212122c2d2e121212121213303030301112121212121225112f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f303020202020102f2f2f2f20202f2f2f2f2f2f
__sfx__
9102000002170031700417005170061553f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
910200001e1301d1501c1501b1501a155000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
910200002a73029750287502775026755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900000a0700e071110711607139000340003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900000a0700e071110711607139000340003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900000a0700e071110711607139000340003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900000a0700e071110711607139000340003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900000a0700e071110711607139000340003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0109000010070150711c0711c07500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a000019070120710d0710d07500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000033050300502c050290502605025050220501f0501f0401f0301f0311f0211f01119000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
51080000307702e7702c77025770227701e7701e77500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
510800002077024770277702c7702e770307703077500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
910100001e050210502205025050280502c0502d05030050300503005030050300500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
49040000186252362539000340003b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900000a0700e071110711607139000340003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00000521005210052100521000000327000000000000241102410000000000000e2100e21000000007000c2100c2100c2100c21000000007000c2100c2102411000000007000070000210002102410011700
010a000009605000000960509605306052d000096052d00028110271000c60322000186031f0000c6031f00409605000000960509605096052d000096052f00028110220000c60322000186031f0002810000000
010a00000c133000000960500000106250000000000096053c615000000000000000106252d000096052d0000c13300000271000910310625000000c133000003c615000000960509605106252d0000960500000
010a0000097050070009605096051d7321d732097052d7001f7321f7320c7022270221732217320c7021f70209702007020970209702097022d702097022f70224732247320c7022270222732227322870000700
010a00000d705047000d6050d60521732217320d7023170222732227321070226702247322473210702237020d702047020d7020d7020d702317020d702337022873228732107022670226732267322870000700
010a000000000000000000000000096050000009605096051f7321f732097022d70221732217320c6032200021300213000c6031f00409605000000960509605281102d000096052f00024300243000c60022000
010a00000d60504000000000000000000000000d6050d60522732227320d7023170224732247321060326000243002430010600230000d605040000d6050d6050d605310000d6053300028300283001060026000
590a00000d600040000d6000d60021300213000d60031000223002230010600260002430024300106032300430730307350d6050d6052d7302d7350d605330002e7302e735106002600030730307303073030735
590a00000d600040000d6000d60021300213000d60031000223002230010600260002430024300106032300430700307000d6000d60030750307550d6050d6052475024755106002600024750247553070030700
010a0000097050070009605096051c7301c730097052d7001d7301d7300a703207001f7301f7300c7031f70409705007000970509705097052d700097052f70022730227300a7032070021730217302870000700
010a00000d705047000d6050d6051f7301f7300b7052f70021730217300e7032470022730227300e703217040b705027000b7050b7050b7052f7000b7053170026730267300e7032470024730247302670000700
010a000000000000000000000000096050000009605096051d7301d730077052b7001f7301f7300c6032200021300213000c6031f00409605000000960509605281102d000096052f00024300243000c60022000
010a00000d60504000000000000000000000000d6050d60521730217300b7052f70022730227301060326000243002430010600230000d605040000d6050d6050d605310000d6053300028300283001060026000
590a00000d600040000d6000d60021300213000d6003100022300223001060026000243002430010603230042e7302e7350b6050b6052b7302b7350b605310002d7302d7350e600240002e7302e7302e7302e735
590a00000d600040000d6000d60021300213000d6003100022300223001060026000243002430010603230042d7302d7350a6050a60529730297350a605300002b7302b7350d600230002d7302d7302d7302d735
590a00000a600010000a6000a6001e3001e3000a6002e0001f3001f3000d6002300021300213000d603200042b7302b73508605086052873028735086052e00029730297350b600210002b7302b7302b7302b735
051e00000c0002e0102e0012e0102e0102b0102c0102e0102e0102e0102e0102e0102e0012c0102c001220102b0102b0112a0112b0112b0112b0112b0112b0112b00124000240000000000000000000000000000
051e00000c7002e0102e0012e0102e010300102b0102e0102e0102e0102e0102e0102e0012c0102c0012b0102901029011280112901129011290112901129011290010c0000c0000c0000c0000c0000c7000c700
011e00000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c5100c5150c5100c5100c5150c5100c5150c5100c5150c5100c5150c5150c5100c5150c5100c515
011e00001a7101a7151a7101a7101a7151a7101a7151a7101a7151a7101a7151a7151a7101a7151a7101a71518710187151871018710187151871018715187101871518710187151871518710187151871018715
911e00000000022730247302773026730267302273024730247302473024730247302473024730247302473535720357203571135715307203072130711307150000000000000000000000000000000000000000
911e000000000227302473027730267302673022730247302473024730247302473024730247302473024735357203572035711357150c7000c7000c7000c7003072030721307113071500000000000000000000
911e00001f7302273026730297302972129725000000000000000000000000000000000000000000000000001d730207302473027730277212772500000000000010000100001000010000000000000000000000
010f00000c5100c5100c5100c5150c5100c5100c5100c5100c5100c5150c5100c5100c5100c5150c5100c5100c5100c5150c5100c5100c5100c5150c5100c5150c5100c5100c5100c5150c5100c5100c5100c515
011e0000004000040000400004000040000400004000040000400004000040000400004000040000400004000f0100f0100f0100f0100a0100a0100a0100a0100f0100f0100f0100f0100a0100a0100a0100a010
911e00000f0100f0100f0100f0150a0100a0100a0100a0150f0100f0100f0100f0150a0100a0100a0100a0150f0100f0100f0100f0150a0100a0100a0100a0150f0100f0100f0100f0150a0100a0100a0100a015
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00001f05028050280501f0501d050260502605023050240500000022050000001805018050180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 10111244
00 10111244
00 10131214
00 10151216
00 10111244
00 10111217
00 10111218
00 1019121a
00 101b121c
00 1011121d
00 10111218
00 10131214
00 10151216
00 101e1217
00 10111218
00 1019121a
00 101b121c
00 101d121f
02 10111218
00 10111244
00 20222844
00 41232944
01 20232944
00 21232944
00 24232944
00 25232944
00 26634344
00 26634344
00 41272944
02 41232944

