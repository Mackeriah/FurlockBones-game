pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--snow
--snow
function _init()
    flakes = {}  -- create empty table which will store all flakes
    make_flake(64,64)
    make_flake(24,24)
end

function make_flake(x,y)
    local f = {} -- create empty table for individual flake    
    f.x = x
    f.y = y
    f.accelx = 0
    f.accely = 0
    f.frame = 1
    add(flakes,f) -- adds a flake to the flakes table
end

function flake_physics(f)
    f.x += f.accelx -- x movement
    f.y += f.accely -- y movement

    -- gravity
    f.accely += (rnd(.01))
    --if f.accely >= .01 then f.accely = 0.1 end

    -- apply horizontal movement (max right is 0.1 so max left is half that at 0.05)
    f.accelx += (rnd(.1) - 0.05)
    --if f.accelx >= 0.1 then f.accelx = 0.05 end
    --if f.accelx <= -0.1 then f.accelx = -0.05 end

    -- delete flake if off screen
    if f.y > 127 then
        del(flakes,f)
    end
end

function _update()
    if(btnp(4) == true) then
        make_flake(rnd(120),0)
    end
    
    -- call a function for each element in a table
    -- in this case apply physics to the snowflakes
    foreach(flakes, flake_physics)
end

function draw_flake(f)
    -- draws one flake from table of flakes
    spr(f.frame, f.x, f.y)
end

function _draw()
    cls()
    -- for each element in table flakes, run draw_flakes against it    
    foreach(flakes, draw_flake)
end



__gfx__
00000000600000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666600660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700006006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000006606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000600666060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000660600060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
