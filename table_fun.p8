pico-8 cartridge // http://www.pico-8.com
version 36
__lua__


function _init()

    family = {"owen", "carly"}
    family.kids = {"eliza", "imogen"}
    print(family[1])
    print(family[2])
    print(#family)
    print(#family.kids)

    questions = {}
    questions.answered = {false, false}
    print(questions.answered[1])

end

function _update60()
    if (btnp(❎)) then 
    questions.answered[1] = true 
    print(questions.answered[1])
    end

end



function _draw()
    
	
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
