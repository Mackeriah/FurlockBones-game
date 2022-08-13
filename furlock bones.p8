pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--[[  

CS50 Final Project for Owen FitzGerald 2022: Furlock Bones: Consulting Dogtective

** REMINDERS **
CONTROL +K +J = unfold all
CONTROL +K +1 = fold at level 1 
U, D, L, R, O, and X are the buttons (up, down, left, right, o-button, x-button) 
CTRL + X deletes a line of code!
(btnp(🅾️))
(btnp(❎))

--]]

-- map compress related, try to add to function or init
_n = nil _={}
_[0] = false 
_[1] = true


--init, update and draw functions
function _init()
	timeStart = 0
	displayDev = false
	camera_x, camera_y = 0,0
	tmp_camera_x, tmp_camera_y = 0,0 -- don't remove this
	activeGame = false
	current_map_maximum_x = 624
	current_map_maximum_y = 248
	init_music()	
	map_swapper()
	create_player()
	create_woofton()
	create_owl()
	create_signs()	
	init_conversation()
	init_wordgame()	
	poke(0x5f5c, 255) -- this means a held button (btnp) only registers once				
	init_objective()
	lost_animals()
	shakeAmount = 0	
	wordgame.pagesCollected = true
	objective.current = "TAKE THE PAGES TO WOOFTON"	-- TESTING ONLY
	--owlBookState = "going upstairs"
	--objective.current = "PRESS Z TO VIEW PAGES"
	leaves = {} -- used to store leaves, obvs
	pages = {}
	leafCount = 0
	pageCount = 0
	credits = false
end

function displayDevName()
	rectfill(0, 0, 127, 127, 0) -- background colour
	if timeStart == 0 then
		timeStart = time()
	end
	if timeStart <= time() - 0 then
		print_centered("awopi developments", 44, 12)
		print_centered("presents", 56, 12)
	end	
	-- if timeStart <= time() - 3 then
	-- 	print_centered("furlock bones:", 54, 7)
	-- 	print_centered("consulting dogtective", 60, 7)
	-- end		
	if timeStart == 0 then
		timeStart = time()
	end
	if timeStart <= time() - 4 then
		displayDev = false
	end	
end

function _update60()
	if displayDev == false then
		menuState()
		musicControl()
	end	
	if activeGame == false then		
		wordgame.displayed = true -- this is the menu not the wordgame (#hackyreuseoffunction)
	
	elseif activeGame == true  then 
		animate_player()
		animate_owl()		
		if wordgame.displayed == false then -- stop player moving if wordgame displayed
			move_player() -- MUST be before camera_follow_player
			camera_follow_player() -- MUST be after move_player
			conversation_system()
			move_woofton()
			check_character_collision()
			doMapStuff()
			newsigncollision()
			if owlBookState == "owl in library" then
				owl_knocking_stuff_over_in_library()				
			end
			foreach(leaves, leaf_physics)
			foreach(pages, page_physics)
		end
		if wordgame.pagesCollected == true then	wordgame_display_on_button_press() end	
	end	
end

function _draw()
	cls()
	displayDevName()
	if displayDev == false then
		draw_game()
	end
	-- player.x-20,player.y-20,8	
	--print("wrong: "..wordgame.wrongGuesses,20,10,8)	
	--print(animal.list[animal.active])	
end

function draw_game()	
	if activeGame == false then
		if wordgame.state == "menu"  then
				wordgame_draw_questions()
		elseif wordgame.state == "menuItems" then
			wordgame_draw_answers()
		end
	end
	if wordgame.displayed == true then
		camera_x, camera_y = 0,0 
		camera(camera_x,camera_y) --0,0 as I draw wordgame in top left
		wordgame_prepare_chosen_question()		
		if wordgame.state == "questionList" then 
			wordgame_draw_questions()				
		elseif wordgame.state == "chosenQuestion" then
			wordgame_draw_answers()
		end
	else
		if shakeAmount < .3 then
			camera(camera_x,camera_y) -- run before map to avoid wordgame stutter
		end
		map(0,0,0,0,128,32) -- draw current map
		draw_objective()
		foreach(leaves, draw_leaf) -- drop leaves when Owl in library
		foreach(pages, draw_page)
		draw_characters()
		if conversation.active == true then draw_conversation()	end
		if owlBookState == "going downstairs" then owlGoingDownstairs() end
		if owlBookState == "owl in library" then owlLookingForBook() end
		if owlBookState == "going upstairs" then owlGoingUpstairs() end
		if owlBookState == "owl outside" then 
			conversation_state = "owllibrary3"
			conversation.character = "wise old owl"
			owlBookState = "none"
		end		
	end
end

function lost_animals()
	animal = {}	
	animal.list = {"red foxes", "red pandas"}
	animal.active = 2
end

function init_objective()
	objective={}
	objective.active = false
	objective.current = "TALK TO DOCTOR WOOFTON"	
	objective.newObjective = true
	animateObjective = true
	slideObjective = 20
end

function draw_objective() -- draws current objective at top of screen (31 char limit)	
	rectfill(camera_x, camera_y+slideObjective, camera_x+127, camera_y+slideObjective+5, 6) -- heading
	print(objective.current, camera_x+2, camera_y+slideObjective, 3)

	-- slide new objective from middle to top of screen
	if objective.newObjective == true and animateObjective == false then
		slideObjective = 20
		animateObjective = true
	end
	if animateObjective == true and slideObjective != 0 then
		slideObjective -= 0.5
	end
	if slideObjective == 0 then
		objective.newObjective = false
		animateObjective = false
	end
end

function draw_credits()
	rectfill(6, 4, 121, 100, 7) -- background colour
	print_centered("music", 6,2)
	print_centered("\"nine songs in pico-8\"", 12,3)
	print_centered("robby duguay",18 ,3)
	print_centered("furlock and woofton sprites", 30,2)
	print_centered("lexaloffle games",36,3)
	print_centered("map compression code", 48,2)
	print_centered("dw817",54,3)
	print_centered("forest tileset", 66,2)
	print_centered("cluly@itch.io",72,3)
	print_centered("playtesting", 84,2)
	print_centered("eliza, imogen and carly", 90,3)
	--print_centered("cluly@itch.io",96,3)
	-- scrolling text
	-- if vloc <= 25 then
	-- 	vloc = 110
	-- elseif vloc <=vloc then	
	-- 	vloc -= 0.25
	-- end
end


-->8
-- conversation and menu functions
function init_conversation()
	conversation = {} -- create empty array to store multiple strings
	conversation.active = false -- initialise to false	
	conversation.string = {} -- empty array to store individual string?
	conversation.character = "nobody"
	conversation_state = "none" -- initialising to none (not done elsewhere)
end

function new_conversation(txt)
	-- function called if conversation_state is a certain value and when called
	-- predefined text is stored in the conversation.string array and can handle multiple strings
	-- being passed to it and stores each in their own array element
	conversation.string = txt
	conversation.active = true -- draw game displays conversation if this is true
end

function conversation_system()
	if wordgame.displayed == true then
		if (btnp(🅾️)) then	conversation_state = "none"	end -- reset conversation if wordgame shown (#hackyfix)
	end

	if conversation_state == "ready" then
		if conversation.character == "sign1" or conversation.character == "sign2" then
			new_conversation({"sign","PRESS X TO READ"}) -- player prompt
			if (btnp(❎)) then conversation_state = "level1" end
		else
			new_conversation({conversation.character,"PRESS X TO TALK"}) -- player prompt
			if (btnp(❎)) then conversation_state = "level1" end
		end

	elseif conversation_state != "ready" then

		-- DR WOOFTON
		if conversation.character == "woofton" then

			if objective.current == "TALK TO DOCTOR WOOFTON" then
				if conversation_state == "level1" then
					new_conversation({"ruff! morning furlock!"}) 
					if (btnp(❎)) then conversation_state = "woofton2" end			

				elseif conversation_state == "woofton2" then
					new_conversation({"i've decided to write","a book. the main character","will be a fox."})
					if (btnp(❎)) then conversation_state = "woofton3" end

				elseif conversation_state == "woofton3" then
					new_conversation({"but the thing is, i hardly","know anything about them!"}) 			
					if (btnp(❎)) then conversation_state = "woofton4" end

				elseif conversation_state == "woofton4" then
					new_conversation({"can you ask wise old owl","if he has a book","about them i could borrow?"})			
					owlGrumpy = false
					if (btnp(❎)) then
						conversation_state = "none"
						objective.newObjective = true
						objective.current = "TALK TO WISE OLD OWL"
					end
				end
			elseif objective.current == "TAKE THE PAGES TO WOOFTON" then
				if conversation_state == "level1" then
					new_conversation({"yip yip! hello furlock!"}) 
					if (btnp(❎)) then conversation_state = "pages2" end

				elseif conversation_state == "pages2" then
					new_conversation({"you have the book!","well, pages from the book."}) 
					if (btnp(❎)) then conversation_state = "pages3" end

				elseif conversation_state == "pages3" then
					new_conversation({"well pieces of pages!","i wonder if owl normally","rips his books up..."}) 
					if (btnp(❎)) then conversation_state = "pages4" end

				elseif conversation_state == "pages4" then
					new_conversation({"anyway, this is perfect.","thank you so much furlock!"}) 
					if (btnp(❎)) then 
						conversation_state = "pages5" 
						animal.active += 1
					end

				elseif conversation_state == "pages5" then
					new_conversation({"oh and by the way", "i have another favour to ask","when you have time."}) 
					if (btnp(❎)) then 
					conversation_state = "none" 
					objective.current = "TALK TO WOOFTON AGAIN"
					end					
				end
			elseif objective.current == "PRESS Z TO VIEW PAGES" then
				if conversation_state == "level1" then
					new_conversation({"ooh you have the pages","but what happened?!", "they're torn to shreds."}) 
					if (btnp(❎)) then conversation_state = "notReady1" end

				elseif conversation_state == "notReady1" then
					new_conversation({"hey maybe you could","fix them for me?","try pressing z"}) 
					if (btnp(❎)) then conversation_state = "none" end
				end
			elseif objective.current == "TALK TO WOOFTON AGAIN" then
				if conversation_state == "level1" then
					new_conversation({"hey furlock, thanks again.","another character for","my book is a red panda."}) 
					if (btnp(❎)) then conversation_state = "2ndanimal1" end

				elseif conversation_state == "2ndanimal1" then
					new_conversation({"any chance you could ask owl","if he has a book on them too?","i'd really appreciate it"}) 
					if (btnp(❎)) then 
						conversation_state = "none"
						objective.current = "TALK TO WISE OLD OWL AGAIN"
					end
				end

			else
				--if conversation_state == "level1" then
				new_conversation({"how's it going furlock?"}) 
				if (btnp(❎)) then conversation_state = "none" end
			end
		end



		



		-- WISE OLD OWL
		if conversation.character == "wise old owl" then
			if conversation_state == "level1" then

				if owlGrumpy == true then
					new_conversation({"hurrumph!","can't you see i was","doing my exercises?"}) 			
					if (btnp(❎)) then conversation_state = "owl_grumpy_1" end	
				end

				if owlGrumpy == false and objective.current != "TALK TO WISE OLD OWL" then
					if owlAnnoyanceLevel <= 1 then
						new_conversation({"sorry i'm a bit busy","right now. i'll talk","to you later furlock."})						
						if (btnp(❎)) then 
							conversation_state = "none" 
							owlAnnoyanceLevel += 1
						end
						
					elseif owlAnnoyanceLevel == 2 then
						new_conversation({"yup, still busy furlock","like i keep saying..."})
						if (btnp(❎)) then 
							conversation_state = "none" 
							owlAnnoyanceLevel += 1
						end
					elseif owlAnnoyanceLevel >2 and owlAnnoyanceLevel <6 then
						new_conversation({"are you trying to","annoy me furlock?"})
						if (btnp(❎)) then 
							conversation_state = "none" 
							owlAnnoyanceLevel += 1
						end
					elseif owlAnnoyanceLevel == 6 or owlAnnoyanceLevel <9 then
						new_conversation({"it wont work"})
						if (btnp(❎)) then 
							conversation_state = "none" 
							owlAnnoyanceLevel += 1
						end
					elseif owlAnnoyanceLevel == 9 or owlAnnoyanceLevel < 15 then
						new_conversation({"it.","wont.","work."})
						if (btnp(❎)) then 
							conversation_state = "none" 
							owlAnnoyanceLevel += 1
						end
					elseif owlAnnoyanceLevel == 15 or owlAnnoyanceLevel < 20 then
						new_conversation({"la la la","im not listening", "doo dee doo."})
						if (btnp(❎)) then 
							conversation_state = "none" 
							owlAnnoyanceLevel += 1
						end
					elseif owlAnnoyanceLevel == 20 then
						new_conversation({"ok you win!!!","agggh!","you're so annoying!"})
						if (btnp(❎)) then 
							conversation_state = "none" 
							owlAnnoyanceLevel = 0							
						end
					end				
				end


				if objective.current == "TALK TO WISE OLD OWL" then
					new_conversation({"hello furlock!"})
					if (btnp(❎)) then			
						conversation_state = "owllibrary1"
					end
				elseif objective.current == "PRESS Z TO VIEW PAGES" then
					new_conversation({"press z to fix up","the pages furlock"})
					if (btnp(❎)) then			
						conversation_state = "none"
					end
				end
				

			elseif conversation_state == "owllibrary1" then
				new_conversation({"so woofton wants to know", "about foxes eh?", "let me see what i can find."})
				if (btnp(❎)) then 					
					conversation_state = "owllibrary2"
				end

			elseif conversation_state == "owllibrary2" then
				new_conversation({"i'll go downstairs to","my library and look.","just a moment please."})
				if (btnp(❎)) then 					
					showDoor = true -- replace Owl sprite with door sprite		
					owlBookState = "going downstairs"
				end

			elseif conversation_state == "owllibrary3" then
				showDoor = false
				new_conversation({"phew that wasn't easy"})
				if (btnp(❎)) then
					conversation_state = "owllibrary4"
				end

			elseif conversation_state == "owllibrary4" then				
				new_conversation({"oooh...sorry but the","pages got a bit ripped","by my claws."})
				if (btnp(❎)) then
					conversation_state = "owllibrary5"
				end

			elseif conversation_state == "owllibrary5" then				
				new_conversation({"the animal facts","are all mixed up now"})
				if (btnp(❎)) then
					conversation_state = "owllibrary6"
				end

			elseif conversation_state == "owllibrary6" then				
				new_conversation({"you'll need to match","the answers","with the questions."})
				if (btnp(❎)) then
					conversation_state = "owllibrary7"
				end			

			elseif conversation_state == "owllibrary7" then
				new_conversation({"look at them","in your inventory","(z or b)"})
				if (btnp(❎)) then					
					conversation_state = "owllibrary8"					
				end
			
			elseif conversation_state == "owllibrary8" then				
				new_conversation({"i'll throw the pages down.","catch!"})
				if (btnp(❎)) then					
					owl_drops_pages()
					conversation_state = "none"					
				end			

			elseif conversation_state == "owl_grumpy_1" then
				new_conversation({"my wings will never get","stronger at this rate."})						
				if (btnp(❎)) then conversation_state = "owl_grumpy_2" end

			elseif conversation_state == "owl_grumpy_2" then
				new_conversation({"oh i'm sorry furlock","that was rude", "i'll talk to you later."})
				if (btnp(❎)) then
					conversation_state = "none"
					owlGrumpy = false
				end			

			elseif conversation_state == "owl2" then
				new_conversation({"hello owl 2"})
				if (btnp(❎)) then conversation_state = "owl3" end

			elseif conversation_state == "owl3" then
				new_conversation({"hello owl 3"})
				if (btnp(❎)) then conversation_state = "owl4" end

			elseif conversation_state == "owl4" then
				new_conversation({"hello owl 4"})			
				owlGrumpy = false
				if (btnp(❎)) then
					conversation_state = "none"					
				end
			end
		end


		-- SIGNS
		if conversation.character == "sign1" then
			if conversation_state == "level1" then
				new_conversation({"it says: "," \"owl's house this way\" "})
				if (btnp(❎)) then conversation_state = "none" end
			end
		end		
		if conversation.character == "sign2" then
			if conversation_state == "level1" then
				new_conversation({"it says: "," \"i'm very busy you know\" ","hmm..."})
				if (btnp(❎)) then conversation_state = "none" end
			end
		end

		-- you are reading these signs aren't you?!

	end	
end

function draw_conversation() 
	-- this runs if conversation.active is true and determines longest sentence length	
	local maxSentenceWidth = 19
	for i=1, #conversation.string do -- the # gets array length
		if #conversation.string[i] > maxSentenceWidth then -- loop through array and find longest text element
			maxSentenceWidth = #conversation.string[i] -- set max width to longest element so box wide enough
		end
	end

	-- define textbox with border (the -1 is for border and centred)
	local conversationBox_x = camera_x + 64 - maxSentenceWidth *2 -1

	-- if player close to screen bottom, draw text box at top, else draw at bottom
	if (player.y < 200) then
		conversationBox_y = camera_y + 95 -- controls vertical location of text box (0 top, 127 bottom)
	else
		conversationBox_y = camera_y + 12 -- controls vertical location of text box (0 top, 127 bottom)
	end	
	
	local conversationBox_width = conversationBox_x+(maxSentenceWidth*4)  -- *4 to account for character width
	local conversationBox_height = conversationBox_y + #conversation.string * 6 -- *6 for character height

	-- draw outer border text box
	if conversation_state == "ready" then -- allow "press x to talk" text
		rectfill(conversationBox_x-2, conversationBox_y-2, conversationBox_width+2, conversationBox_height+2, 1)
		rectfill(conversationBox_x, conversationBox_y, conversationBox_width, conversationBox_height, 7)
	elseif conversation_state == "sign" then -- allow "press x to talk" text
		rectfill(conversationBox_x-2, conversationBox_y-2, conversationBox_width+2, conversationBox_height+2, 1)
		rectfill(conversationBox_x, conversationBox_y, conversationBox_width, conversationBox_height, 7)
	else -- allow automation text "press x to continue"
		rectfill(conversationBox_x-2, conversationBox_y-2, conversationBox_width+2, conversationBox_height+2+8, 1) -- +8 for "press x to continue"
		rectfill(conversationBox_x, conversationBox_y, conversationBox_width, conversationBox_height+8, 7) -- +8 for "press x to continue
	end

	-- write text
	for i=1, #conversation.string do  -- the # gets the legnth of the array 'text'		
		local txt = conversation.string[i]
		local tx = camera_x + 64 - #txt * 2 -- centre text based on length of string txt
		local ty = conversationBox_y -5+(i*6) -- padding for top of box but because for loop starts at 1 we need to subtract 5			
		if i == #conversation.string then -- if we're on last line	
			if conversation_state == "ready" then
				print(txt, tx, ty, 6)			
			elseif conversation_state == "sign" then
				print(txt, tx, ty, 6)
			else
				print(txt, tx, ty, conversation.colour)
				print("PRESS X TO CONTINUE", camera_x+64-38, ty+8, 6) -- -64-38 is to centre
			end
		else
			print(txt, tx, ty, conversation.colour)
		end		
	end		
end


-->8
-- word game functions
function init_wordgame()
	wordgame = {} -- empty array to store multiple strings		
	wordgame.allQuestions = {}	
	wordgame.answered = {false, false, false, false} -- store when each question answered
	wordgame.answers = {} -- empty array to store answer strings
	wordgame.pagesCollected = false -- flag to check if player has collected all pages
	wordgame.selectedQuestion = 1
	wordgame.selectedAnswer = 1
	wordgame.state = "menu" --[[ menu, questionList, chosenQuestion, completed]]
	wordgame.displayed = false -- flag to check if displayed on screen or not
	wordgame.completed = false
	wordgame.correct = "empty"
	wordgame.wrongGuesses = 0
	wordgame.maximumGuesses = 6 -- default in case player doesn't change difficulty
	wordgame.tooManyWrong = false
end

function wordgame_store_answers(txt)
	wordgame.answers = txt
end

function wordgame_display_on_button_press()
	-- z to view wordgame
	if (btnp(🅾️)) and wordgame.pagesCollected == true and wordgame.displayed == false then
		wordgame.state = "questionList"
		wordgame.displayed = true
		tmp_camera_x = camera_x -- store current camera x,y so we can return to it later
		tmp_camera_y = camera_y
	-- let player exit only when completed #TRAPPED!
	elseif (btnp(🅾️)) and wordgame.displayed == true and wordgame.completed == true then
		wordgame.displayed = false
		camera_x = tmp_camera_x -- return camera to previous position
		camera_y = tmp_camera_y
	end
end

function wordgame_draw_questions()

	if wordgame.state == "menu" then
		credits = false
		rectfill(0, 0, 127, 127, 1) -- background colour
		print_centered("furlock bones:", 12, 12)
		print_centered("consulting dogtective", 18, 12)
		print_centered("the case of", 30, 7)
		print_centered("dr woofton's mysterious book", 36, 7)
		print_centered("UP,DOWN AND X TO SELECT", 120, 13)

	elseif wordgame.state == "questionList" then
		rectfill(0, 0, 127, 127, 7) -- background colour
		--print_centered("help furlock match", camera_y+14, 3)		
		--print_centered("answer animal facts for", camera_y+6, 3)
		print_centered(animal.list[animal.active], camera_y+6, 3)
		
		print("wrong",2,2,13)
		print(wordgame.wrongGuesses,2,8,13)
		print(" /"..wordgame.maximumGuesses-1,3,8,13)
		print_centered("UP,DOWN AND X TO SELECT", 120, 13)
		if wordgame.completed == true then 
			print_centered("you did it! press z to exit", 100, 8)
			objective.current = "TAKE THE PAGES TO WOOFTON"
		end		
	end	

	if (btnp(❎)) then 
		if wordgame.state == "menu" then
			if wordgame.selectedQuestion == 1 then
				activeGame = true
				wordgame.displayed = false
			elseif wordgame.selectedQuestion == 3 then
				credits = true
				wordgame.state = "menuItems"		
			else 
				wordgame.state = "menuItems"
			end				
		elseif wordgame.state == "questionList" then
			wordgame.state = "chosenQuestion"
		end		
		--[[ this updates the answered array using whatever the chosen question number
			was and sets it as true, so that when all questions are true we know
			the player has completed the wordgame ]]
		if wordgame.state == "questionList" or wordgame.state == "chosenQuestion" then			
			wordgame.answered[wordgame.selectedQuestion] = true
		end		
	end

	if credits == true then
		if (btnp(❎)) then
			--wordgame.state = "questionList"
		end
	end

	-- determine longest question
	local maxTextWidth = 0
	for i=1, #wordgame.allQuestions do -- the # gets array length
		if #wordgame.allQuestions[i] > maxTextWidth then -- loop through array and find longest text element
			maxTextWidth = #wordgame.allQuestions[i] -- set max width to longest element so box wide enough
		end
	end

	-- question text box horizontal location
	local textbox_xx = camera_x + 64 - maxTextWidth *2 -1 -- -1 for border and centred
	-- question text box vertical location
	if wordgame.state == "menu" then
		textbox_yy = camera_y + 48 -- first menu item location
	elseif wordgame.state == "questionList" then
		textbox_yy = camera_y + 8 -- first question location
	end
	local textbox_width2 = textbox_xx+(maxTextWidth*4)  -- *4 to account for character width
	local textbox_height2 = textbox_yy + 6 -- *6 for character height

	-- loop through questions, create box for each and add text
	for i=1, #wordgame.allQuestions do
		local txt = wordgame.allQuestions[i]
		local tx = camera_x + 64 - #txt * 2 -- centre text based on length of string txt
		local ty = textbox_yy - 5 +(i*14) -- padding for top of box but as loop starts at 1 we subtract 5
		
		-- selected question outer border
		if wordgame.selectedQuestion == i then rectfill(tx-4,ty-4,tx+#txt*4+2,ty+6+2,8) end
		
		-- inner question box
		if wordgame.state == "menu" then
			rectfill(tx-2,ty-2,tx+#txt*4,ty+6,12)
		elseif wordgame.state == "questionList" then
			if wordgame.answered[i] == true then
				rectfill(tx-2,ty-2,tx+#txt*4,ty+6,11) -- colour box green if already answered
			else
				rectfill(tx-2,ty-2,tx+#txt*4,ty+6,6)
			end
		end		
		print(txt, tx, ty, 0) -- display question text
	end

	-- use up and down to select a question unless already correctly answered
	if (btnp(3)) then -- 3 is down button and loop back to top
		if wordgame.selectedQuestion > #wordgame.allQuestions-1 then
			wordgame.selectedQuestion = 1
		else wordgame.selectedQuestion += 1 end
	end
	if (btnp(2)) then -- 2 is up button and loop back to bottom
		if wordgame.selectedQuestion == 1 then
			wordgame.selectedQuestion = #wordgame.allQuestions
		else wordgame.selectedQuestion -= 1 end
	end	

	-- check if all questions are answered correctly
	if wordgame.answered[1] == true
		and wordgame.answered[2] == true
		and wordgame.answered[3] == true
		and wordgame.answered[4] == true 
		and wordgame.answered[5] == true then
			wordgame.completed = true
	end	
end

function menuState() -- change what's in this table if menu or wordgame (hacky I think but SUE ME!)
	if wordgame.state == "menu" then
		wordgame.allQuestions = {"start game","change difficulty","view credits"}
	elseif wordgame.state == "questionList" then
		-- FOX QUESTIONS
		if animal.list[animal.active] == "red foxes" then
			wordgame.allQuestions = {"raise their babies in","females are called","their babies are called",
				"can run up to","a group of them is called",}

		-- RED PANDA QUESTIONS
		elseif animal.list[animal.active] == "red pandas" then
			wordgame.allQuestions = {"are related to","keep themselves warm by","keep clean by","eat ? bamboo leaves every day","spend most of their time",}
		end
	end
end

function wordgame_prepare_chosen_question()

	if wordgame.state == "menuItems" then
		if wordgame.selectedQuestion == 1 then				
				wordgame_store_answers({"this", "is", "just","placeholder"})
				wordgame.correct_answer = 1
			elseif wordgame.selectedQuestion == 2 then				
				wordgame_store_answers({"easy: 5 WRONG GUESSES", "medium: 3 WRONG GUESSES", "hard: 1 WRONG GUESS!"})
				wordgame.correct_answer = 1
			elseif wordgame.selectedQuestion == 3 then				
				wordgame_store_answers({"credits"})
				wordgame.correct_answer = 1
			end

	elseif wordgame.state == "chosenQuestion" then

		-- FOX ANSWERS
		if animal.list[animal.active] == "red foxes" then
			if wordgame.selectedQuestion == 1 then				
				wordgame_store_answers({"large dens", "bee hives", "treehouses","high trees","muddy riverbanks"})
				wordgame.correct_answer = 1
			elseif wordgame.selectedQuestion == 2 then				
				wordgame_store_answers({"foxette", "vexxed", "vera","fexen","vixen"})
				wordgame.correct_answer = 5
			elseif wordgame.selectedQuestion == 3 then				
				wordgame_store_answers({"foxies", "cats", "kits","kit kats","grubs"})
				wordgame.correct_answer = 3
			elseif wordgame.selectedQuestion == 4 then				
				wordgame_store_answers({"100 km/h", "5 km/h", "10 km/h","50 km/h","1,000 km/h"})
				wordgame.correct_answer = 4
			elseif wordgame.selectedQuestion == 5 then				
				wordgame_store_answers({"a posse", "a gang", "a foxtrot", "a skulk", "a pack"})
				wordgame.correct_answer = 4
			end

		-- RED PANDA ANSWERS
		elseif animal.list[animal.active] == "red pandas" then
			if wordgame.selectedQuestion == 1 then				
				wordgame_store_answers({"red foxes","pandas","bears","racoons","koalas"})
				wordgame.correct_answer = 4
			elseif wordgame.selectedQuestion == 2 then				
				wordgame_store_answers({"jumping", "wrapping their tail around", "putting on a scarf","rolling in mud","dancing"})
				wordgame.correct_answer = 2
			elseif wordgame.selectedQuestion == 3 then				
				wordgame_store_answers({"washing in a stream", "having a shower", "licking themselves","rolling in dust","rubbing against trees"})
				wordgame.correct_answer = 3
			elseif wordgame.selectedQuestion == 4 then				
				wordgame_store_answers({"exactly 5", "about 5,000", "up to 20,000","between 100-200","zero"})
				wordgame.correct_answer = 3
			elseif wordgame.selectedQuestion == 5 then				
				wordgame_store_answers({"in the bath", "in burrows", "under houses", "inside bushes", "high in trees"})
				wordgame.correct_answer = 5
			end
		end	
	end
end

function wordgame_draw_answers()

	-- store guess limit based on chosen difficulty
	if wordgame.state == "menuItems" and wordgame.selectedQuestion == 2 then
		if wordgame.selectedAnswer == 1 then
			wordgame.maximumGuesses = 6
		elseif wordgame.selectedAnswer == 2 then
			wordgame.maximumGuesses = 4
		elseif wordgame.selectedAnswer == 3 then
			wordgame.maximumGuesses = 2
		end
	end

 -- ** QUESTION LOGIC**
 	cls()
	-- if using menu
	if wordgame.state == "menuItems" then
		rectfill(0, 0, 127, 127, 1) -- background colour
		if credits == true then
			draw_credits()
		end
	-- if using wordgame
	elseif wordgame.state == "chosenQuestion" then
		rectfill(0, 0, 127, 127, 7) -- draw background screen colour
		print("wrong",2,2,13) -- incorrect guesses counter
		if wordgame.wrongGuesses >= wordgame.maximumGuesses -1 then
			wordgame.tooManyWrong = true
			print(wordgame.wrongGuesses,2,8,8) -- print in red
		else
			print(wordgame.wrongGuesses,2,8,13)
		end

		print(" /"..wordgame.maximumGuesses-1,3,8,13)
	end

	maxTextWidth = #wordgame.allQuestions[wordgame.selectedQuestion]

	-- define textbox with border
	textbox_x = camera_x + 64 - maxTextWidth *2 -1 -- -1 for border and centred

	-- draw text box at top of screen
	local textbox_y = camera_y + 16 -- controls vertical location of text box (0 top, 127 bottom)
	
	local textbox_width = textbox_x+(maxTextWidth*4)  -- *4 to account for character width
	local textbox_height = textbox_y + 6

	-- draw outer border text box
	if credits == true then
		-- rectfill(textbox_x+8, textbox_y-12, textbox_width-8, textbox_height-6, 12)
	else
		rectfill(textbox_x-2, textbox_y-2, textbox_width+2, textbox_height+2, 12)
	end
	
	-- write question at top of screen
	local txt = wordgame.allQuestions[wordgame.selectedQuestion]		
	local tx = camera_x + 64 - #txt * 2 -- centre text based on length of string txt
	local ty = textbox_y -5+(1*6) -- padding for top of box but because for loop starts at 1 we need to subtract 5		
	if credits == true then 
		--print_centered("credits", ty-9,7)
	else
		print_centered(animal.list[animal.active], camera_y+6, 3)
		print(txt, tx, ty, 1)		
	end
 -- ** ANSWER LOGIC ** 
	-- #wordgame.answers this is how many answers there are and thus how many boxes we need
	-- determine longest line of text
	local maxTextWidth = 0
	for i=1, #wordgame.answers do -- the # gets array length
		if #wordgame.answers[i] > maxTextWidth then -- loop through array and find longest text element
			maxTextWidth = #wordgame.answers[i] -- set max width to longest element so box wide enough
		end
	end

	-- horizontal text box location
	local textbox_xx = camera_x + 64 - maxTextWidth *2 -1 -- -1 for border and centred

	-- vertical text box location
	if wordgame.state == "menuItems" then
		if credits == true then
			textbox_yy = camera_y + 1000 -- first chosen menu option
		else
			textbox_yy = camera_y + 48
		end
	else
		textbox_yy = camera_y + 22 -- first question starts here
	end
	
	local textbox_width2 = textbox_xx+(maxTextWidth*4)  -- *4 to account for character width
	local textbox_height2 = textbox_yy + 6 -- *6 for character height

	-- write text
	for i=1, #wordgame.answers do  -- the # gets the legnth of the array 'text'
		local txt = wordgame.answers[i]
		local tx = camera_x + 64 - #txt * 2 -- centre text based on length of string txt
		local ty = textbox_yy - 5 +(i*14) -- padding for top of box but as loop starts at 1 we subtract 5
		
	if wordgame.state == "menuItems" then
		--rectfill(tx-4,ty-4,tx+#txt*4+2,ty+6+2,8) -- this draws the border (to select answer)
		rectfill(tx-2,ty-2,tx+#txt*4,ty+6,12) -- this draws the box
	end
	if wordgame.selectedAnswer == i then
		if wordgame.correct == "true" then 
			rectfill(tx-4,ty-4,tx+#txt*4+2,ty+6+2,11) -- colour green to indicate correct
			rectfill(tx-2,ty-2,tx+#txt*4,ty+6,11) -- this draws the box
		else
			if wordgame.state == "menuItems" then
				rectfill(tx-4,ty-4,tx+#txt*4+2,ty+6+2,8) -- this draws the border (to select answer)
				rectfill(tx-2,ty-2,tx+#txt*4,ty+6,12) -- this draws the box
			elseif wordgame.state == "chosenQuestion" then
				rectfill(tx-4,ty-4,tx+#txt*4+2,ty+6+2,8) -- this draws the border (to select answer)
				rectfill(tx-2,ty-2,tx+#txt*4,ty+6,7) -- this draws the box
			end
		end
	end
	print(txt, tx, ty, 0) -- print the answers in the boxes	
	end	

	-- use up and down to select a question
	if wordgame.correct == "true" then -- stop answer selection if already correct and return to questions on x button
		if (btnp(❎)) then 
			wordgame.correct = "empty"
			if wordgame.state == "menuItems" then
				wordgame.state = "menu"
			elseif wordgame.state == "chosenQuestion" then
				wordgame.state = "questionList"
			end
			
		wordgame.selectedAnswer = 1 -- reset to 1 for next question
		return -- quit function
		end -- return to list of questions		
	else
		if (btnp(3)) and wordgame.tooManyWrong == false then -- 3 is down
			if wordgame.selectedAnswer > #wordgame.answers-1 then
				wordgame.selectedAnswer = 1
				wordgame.correct = "empty"
			else
				wordgame.selectedAnswer += 1
				wordgame.correct = "empty"
			end
		end
		if (btnp(2)) and wordgame.tooManyWrong == false then -- 2 is up
			if wordgame.selectedAnswer == 1 then
				wordgame.selectedAnswer = #wordgame.answers
				wordgame.correct = "empty"
			else
				wordgame.selectedAnswer -= 1
				wordgame.correct = "empty"
			end
		end
	end

	-- check if correct
	if (btnp(❎)) then
		-- basically whatever user selects from menu is 'correct' 
		if wordgame.state == "menuItems" then
			wordgame.correct_answer = wordgame.selectedAnswer
			wordgame.correct = "true"
		end
		if wordgame.state == "menuItems" and credits == true then
			wordgame.state = "menu"
			credits = false
			wordgame.correct = false
		end
		if wordgame.state == "chosenQuestion" then
			if wordgame.selectedAnswer == wordgame.correct_answer then 
				wordgame.correct = "true"
			else 
				wordgame.correct = "false"
				wordgame.wrongGuesses += 1 -- keep track of incorrect guesses
			end
		end
		if wordgame.wrongGuesses >= wordgame.maximumGuesses then
			wordgame.answered = {false, false, false, false}
			wordgame.completed = false
			wordgame.state = "questionList"
			wordgame.wrongGuesses = 0
			wordgame.correct = "empty"
			wordgame.selectedAnswer = 1 -- reset so next question selector at top
			wordgame.tooManyWrong = false
		end
	end

	if wordgame.state == "menuItems" then
		if wordgame.correct == "true" then
			print_centered("difficulty chosen",102,11)
			print_centered("press x to continue",108,11)	
		end
		if credits == true then
			print_centered("press x to return",108,8)	
		end
	elseif wordgame.state == "chosenQuestion" then
		if wordgame.correct == "true" then
			print_centered("well done! press x to close",102,11)
		elseif wordgame.correct == "false" then
			if wordgame.wrongGuesses >= wordgame.maximumGuesses -1 then
				print_centered("oh no! you got too many wrong!", 100, 8)
				print_centered("x to try again", 106, 8)
			else
				print_centered("hmm that doesn't seem right", 100, 8)		
			end			
		end
	end
	if credits == false then print_centered("UP,DOWN AND X TO SELECT", 120, 13)	end
end


-->8
--player functions
function create_player() 
	player={}  --create empty table -- this means we're creating the player as an object!
	player.x = 16 -- 16 = house, 432 = owl (map location x8 for exact pixel location)
	player.y = 32
	player.direction = 1
	player.velocity_x = 0
	player.velocity_y = 0	
	player.max_x_speed = 1 -- 2
	player.max_y_speed = 1 -- 2
	player.acceleration = 0.2 -- 0.5
	player.drag = 0.7 -- 1 = no slow down, 0 = instant halt
	player.width = 7
	player.height = 7
	player.sprite = 1
	player.animTime = 0
	player.animWait = 0.1		
	player.pagesPickup = 0
end

function animate_player()
	if player.velocity_x != 0 or player.velocity_y != 0 then
		if time() - player.animTime > player.animWait then
			player.sprite += 1
			player.animTime = time()
			if (player.sprite > 4 ) then
				player.sprite = 1
			end
		end	
	else
		player.animTime = 0
		player.sprite = 1
	end
end

function move_player()	
	if conversation_state == "none" 
	or conversation_state == "ready" 
	or conversation_state == "sign" then	-- if talking then don't walk away, it's rude.
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

			-- call stop_at_wall function for collision before letting player move
			-- essentially this allows play to move diaganolly along a solid object, as without this
			-- the check_if_map_solid code prevents them moving
			stop_at_wall(player)

			-- check player isn't trying to move into a solid object
			if (check_if_map_solid(player, player.velocity_x, player.velocity_y)) then
				--actually move the player to the new location
				player.x += player.velocity_x
				player.y += player.velocity_y
				
			-- if player cannot move there, find out how close they can get and move them there instead.
			else 
				--create temporary variables to store how far the player is trying to move
				temp_direction_x = player.velocity_x
				temp_direction_y = player.velocity_y
				
				--make tempx,tempy shorter and shorter until we find a new position the player can move to
				while (not check_if_map_solid(player,temp_direction_x,temp_direction_y)) do
					
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
-- player collision functions
function stop_at_wall(player)
	-- if player next to a wall stop them moving in that direction
	-- essentially this allows player to move along a wall holding two buttons. e.g. up and left
	-- what happens is that we ignore the left movement as it is set to zero meaning that we only
	-- apply the vertical movement. It's really just a player UX fix.
	-- player moving left
	if (player.velocity_x < 0) then
		--check both left corners for a wall
		local wall_top_left = is_sprite_solid(player.x -1, player.y)
		local wall_btm_left = is_sprite_solid(player.x -1, player.y + player.height)
		-- if wall in that direction, set x movement to 0
		if (wall_top_left or wall_btm_left) then
			player.velocity_x = 0
		end

	-- player moving right
	elseif (player.velocity_x > 0) then		
		local wall_top_right = is_sprite_solid(player.x + player.width + 1, player.y)
		local wall_btm_right = is_sprite_solid(player.x + player.width + 1, player.y + player.height)		
		if (wall_top_right or wall_btm_right) then
			player.velocity_x = 0
		end
	end

	-- player moving up
	if (player.velocity_y < 0) then		
		local wall_top_left = is_sprite_solid(player.x, player.y - 1)
		local wall_top_right = is_sprite_solid(player.x + player.width, player.y - 1)		
		if (wall_top_left or wall_top_right) then
			player.velocity_y = 0
		end

	-- player moving down
	elseif (player.velocity_y > 0) then		
		local wall_btm_left = is_sprite_solid(player.x, player.y + player.height + 1)
		local wall_btm_right = is_sprite_solid(player.x, player.y + player.height + 1)		
		if (wall_btm_right or wall_btm_left) then
			player.velocity_y = 0
		end
	end 
end

function check_if_map_solid(object,direction_x,direction_y)
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
	local top_left_solid = is_sprite_solid(next_left, next_top)
	local btm_left_solid = is_sprite_solid(next_left, next_bottom)
	local top_right_solid = is_sprite_solid(next_right, next_top)
	local btm_right_solid = is_sprite_solid(next_right, next_bottom)

	--if all of those locations are NOT solid, the object can move into that spot.
	-- this is why it's return NOT so we get (I think) a true returned as if all 4 are false we can move there
	return not (top_left_solid or btm_left_solid or	top_right_solid or btm_right_solid)
end

function is_sprite_solid(x,y)	
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


-->8
-- character functions
function create_woofton()
	woofton={}
	woofton.x = 24
	woofton.y = 104
	woofton.sprite = 22
	woofton.speed = 0
	woofton.direction = 1
	woofton.wait = false	
	woofton.waitTime = 0
	woofton.speechColour = 9
end

function move_woofton()
	if (woofton_collision(player.x,player.y,woofton.x,woofton.y)) == true then 
		-- this just stops woofton moving any closer and stops him pestering for a while		
	-- else		
	-- 	if woofton.wait == true then -- wait if woofton's recently pestered player
	-- 		if (time() >= woofton.waitTime +5 ) then
	-- 			woofton.wait = false
	-- 		else return end
	-- 	else
	-- 		if player.x < woofton.x then
	-- 			woofton.x -= woofton.speed
	-- 			woofton.direction = -1
	-- 		end 
	-- 		if player.x > woofton.x then	 	
	-- 			woofton.x += woofton.speed
	-- 			woofton.direction = 1
	-- 		end 
	-- 		if player.y < woofton.y then
	-- 			woofton.y -= woofton.speed
	-- 		end 
	-- 		if player.y > woofton.y then
	-- 			woofton.y += woofton.speed
	-- 		end
	-- 	end
	end
end

function woofton_collision(playerx,playery,charx,chary)
	if charx +10 > playerx and charx < playerx +10 and chary +10 > playery and chary < playery +10 then
	woofton.speed = 0
		if wordgame.displayed == false then
			if conversation_state == "none" then			
				conversation_state = "ready"
				conversation.character = "woofton"
				conversation.colour = woofton.speechColour
				woofton.wait = true
				woofton.waitTime = time()
			end 
		end
	else
		if conversation.character == "woofton" then -- if player walks away instead of starting conversation			
			woofton.speed = 0.2	 	
			conversation_state = "none"
			conversation.character = "nobody"
			conversation.active = false
		end
 	end
end

function create_owl()
	owl={}
	owl.x = 480 -- 480 is treehouse
	owl.y = 8	-- 8 is treehouse
	owl.sprite = 5
	owl.time = 0
	owl.wait = 0.5
	showDoor = false
	owlTime = 0
	owlWait = 2
	stepTimeStart = 0	
	owlBookState = "none"
	itemsBroken = 0 -- used when owl is shaking screen brekaing stuff in library	
	owl.speechColour = 2
	owlGrumpy = true
	owlAnnoyanceLevel = 0	
end

function owl_collision(playerx,playery,charx,chary)
	if showDoor != true then
		if charx +10 > playerx and charx < playerx +18 and chary +56 > playery and chary < playery +10 then
			if conversation_state == "none" then			
				conversation_state = "ready"
				conversation.character = "wise old owl"
				conversation.colour = owl.speechColour
			end 
		else
			if conversation.character == "wise old owl" then -- if player walks away instead of starting conversation			
				conversation_state = "none"
				conversation.character = "nobody"
				conversation.active = false
			end
		end
	else
		conversation_state = "waiting"
		conversation.character = "nobody"
		conversation.active = false
	end
end

function animate_owl()
	-- eliza says owl should NOT move if you're talking to him
	--if player.x > 430 then
	if conversation_state != "ready" or conversation_state != "none" then
		if time() - owl.time > owl.wait then
			owl.sprite += 1
			owl.time = time()
			if (owl.sprite > 8 ) then -- owl flaps wings to pass the time
				owl.sprite = 6
			end
		end			
		if conversation.character == "wise old owl" and conversation_state != "ready" then
			owl.sprite = 5 -- owl sits down when talking
		end
	end
end

function owlGoingDownstairs()
	if stepTimeStart == 0 then
		stepTimeStart = time()
	end
	if stepTimeStart <= time() - 1 then
		print("clomp", owl.x+12, owl.y+20, 0)
	end
	if stepTimeStart <= time() - 2 then
		print("clomp", owl.x+14, owl.y+26, 0)
	end
	if stepTimeStart <= time() - 3 then
		print("creeeak", owl.x+16, owl.y+32, 0)
	end
	if stepTimeStart <= time() - 4 then
		print("clomp", owl.x+18, owl.y+38, 0)
	end
	if stepTimeStart <= time() - 5 then
		print("clomp", owl.x+20, owl.y+44, 0)		
	end
	if stepTimeStart <= time() - 8 then			
		print("where's the light switch?", owl.x-50, owl.y+60, owl.speechColour)
	end
	if stepTimeStart <= time() - 12 then			
		owlBookState = "owl in library"
	end	
end

function owlLookingForBook()
	if itemsBroken == 1 then
		print("snap", owl.x-15, owl.y+60, 0)
		print("whoops!", owl.x-15, owl.y+66, owl.speechColour)
		if leafCount < 5 then
			for i=1, 5 do
				make_leaf(owl.x+5+rnd(30)-15,owl.y+rnd(10))
			end
		end
	end
	if itemsBroken == 2 then
		print("crunch", owl.x-60, owl.y+60, 0)
		print("i probably didn't", owl.x-60, owl.y+66, owl.speechColour)
		print("need that anyway.", owl.x-60, owl.y+72, owl.speechColour)
		if leafCount < 10 then
			for i=1, 5 do
				make_leaf(owl.x+5+rnd(30)-15,owl.y+rnd(10))
			end
		end
	end
	if itemsBroken == 3 then
		print("whack", owl.x-35, owl.y+60, 0)
		print("ouch! my wing!", owl.x-35, owl.y+66, owl.speechColour)		
		if leafCount < 15 then
			for i=1, 5 do
				make_leaf(owl.x+5+rnd(30)-15,owl.y+rnd(10))
			end
		end
	end
	if itemsBroken == 4 then
		print("thud", owl.x-30, owl.y+60, 0)
		print("oh...that's not good.", owl.x-40, owl.y+66, owl.speechColour)		
		if leafCount < 20 then
			for i=1, 5 do
				make_leaf(owl.x+5+rnd(30)-15,owl.y+rnd(10)-5)
			end
		end
	end
	if itemsBroken == 5 then
		print("craaack", owl.x-50, owl.y+60, 0)
		print("aggh! not my fish tank!", owl.x-50, owl.y+66, owl.speechColour)		
		if leafCount < 40 then
			for i=1, 5 do
				make_leaf(owl.x+5+rnd(30)-15,owl.y+rnd(10)-5)
			end
		end		
	end	
	if itemsBroken == 6 then		
		print("aha, here's the book.", owl.x-60, owl.y+60, owl.speechColour)		
	end
	if itemsBroken == 7 then		
		print("i'm heading upstairs furlock!", owl.x-65, owl.y+60, owl.speechColour)						
	end
	if itemsBroken == 8 then
		stepTimeStart = 0
		owlBookState = "going upstairs"	
	end
end

function owl_knocking_stuff_over_in_library()
	if shakeAmount > 0 then screen_shake() end
	if time() >= owlWait then
		if itemsBroken < 8 then
			owlTime = time()
			if itemsBroken <= 3 then
				shakeAmount += 10
			elseif itemsBroken == 4 then
				shakeAmount += 50						
			end			
			owlWait = time() + 6 -- 6 is what I want		
			itemsBroken += 1
		elseif itemsBroken == 5 then
		end
	end
end

function owlGoingUpstairs()	
	if stepTimeStart == 0 then
		stepTimeStart = time()		
	end	
	if stepTimeStart <= time() - 2 then		
		print("clomp", owl.x+20, owl.y+44, 0)
	end
	if stepTimeStart <= time() - 3 then
		print("clomp", owl.x+18, owl.y+38, 0)
	end
	if stepTimeStart <= time() - 4 then
		print("creeeak", owl.x+16, owl.y+32, 0)
	end
	if stepTimeStart <= time() - 5 then
		print("clomp", owl.x+14, owl.y+26, 0)
	end
	if stepTimeStart <= time() - 6 then
		print("clomp", owl.x+12, owl.y+20, 0)
	end		
	if stepTimeStart <= time() - 8 then			
		owlBookState = "owl outside"
	end
end

function create_signs()
	sign1={}
	sign2={}
	sign1.x = 308
	sign1.y = 16
	sign2.x = 416
	sign2.y = 16
	sign1.sprite = 20
	sign2.sprite = 19
end

function check_character_collision()
	--check if next to Wise Old Owl
	if (owl_collision(player.x,player.y,owl.x,owl.y)) == true then
	end
end

function newsigncollision()
	-- check if player touching sign1
	if sign1.x +10 > player.x and sign1.x < player.x +10 and sign1.y +10 > player.y and sign1.y < player.y +10 then
		if conversation_state == "none" then			
			conversation_state = "ready"
			conversation.character = "sign1"
			conversation.colour = 0
		end
	elseif sign2.x +10 > player.x and sign2.x < player.x +10 and sign2.y +10 > player.y and sign2.y < player.y +10 then
		if conversation_state == "none" then			
			conversation_state = "ready"
			conversation.character = "sign2"
			conversation.colour = 0
		end
	else 
		if conversation.character == 'sign1' or conversation.character == 'sign2' then
			conversation_state = "none"
			conversation.character = "nobody"
			conversation.active = false
		end
	end
end

function draw_characters()	
	-- draw woofton
	spr(woofton.sprite,woofton.x,woofton.y,1,1,woofton.direction==-1)
	if showDoor == false then
		-- draw owl
		spr(owl.sprite,owl.x,owl.y,1,1,false,false)
	else
		-- draw door sprite
		spr(32,owl.x,owl.y,1,1,false, false)
	end
	-- draw signs
	spr(sign1.sprite,sign1.x,sign1.y,1,1,1)
	spr(sign2.sprite,sign2.x,sign2.y,1,1,1)

	-- draw player
	spr(player.sprite,player.x,player.y,1,1,player.direction==-1)
end

-- LEAVES
function make_leaf(x,y)
    local leaf = {} -- create empty table for individual leaf    
    leaf.x = x
    leaf.y = y
    leaf.accelx = 0
    leaf.accely = 0
    leaf.sprite = 23
    add(leaves,leaf) -- adds a leaf to the leaves table
	leafCount += 1
end

function leaf_physics(leaf)
    -- delete leaf if drops off screen
    if leaf.y > 52 then
        leaf.accely = 0
		--del(leaves,leaf)
    else
		leaf.x += leaf.accelx -- x movement
    	leaf.y += leaf.accely -- y movement
	end

    -- gravity
	if leaf.y <= 50 then
    	leaf.accely += (rnd(.005))    
	end

    -- apply horizontal movement unless on ground
    if leaf.accely != 0 then
		leaf.accelx += (rnd(0.01) - 0.005)
    end
end

function draw_leaf(leaf)
    -- draws one leaf from table leaves
    spr(leaf.sprite, leaf.x, leaf.y)
end

-- PAGES
function make_page(x,y)
    local page = {} -- create empty table for individual leaf    
    page.x = x
    page.y = y
    page.accelx = 0
    page.accely = 0
    page.sprite = 24
    add(pages,page) -- adds a leaf to the leaves table
	pageCount += 1
end

function page_physics(page)
    -- stop page at ground level
    if page.y > 52 then
        page.accely = 0
		--del(leaves,leaf)
    else
		page.x += page.accelx -- x movement
    	page.y += page.accely -- y movement
	end

    -- gravity
	if page.y <= 40 then
    	page.accely += (rnd(.01))		
	else
		objective.current = "PICK UP THE TORN PAGES"
	end

    -- apply horizontal movement unless on ground
    if page.accely != 0 then		
		page.accelx += (rnd(0.01) - 0.009)
    end

	-- player collision
	if objective.current == "PICK UP THE TORN PAGES" then
		if flr(page.x) == flr(player.x) then
			wordgame.pagesCollected = true
			objective.current = "PRESS Z TO VIEW PAGES"
			del(pages,page)
		end
	end
end

function draw_page(page)
    spr(page.sprite, page.x, page.y,1,1,false,false)	
end

function owl_drops_pages()
	if pageCount < 5 then
		for i=1, 1 do
			make_page(owl.x,owl.y)
		end
	end
end

-->8
-- back of house functions
function print_centered(str, height, colour)
	print(str, 64 - (#str * 2), height, colour)	
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

function init_music()
	track_1start = 0 -- this indicates the point in the music the track starts
	track_2start = 11	
	track_3start = 22
	track_4start = 33 -- end game music
	track_5start = 37 -- library music
	musicState = 'start' -- used for music, seems bizarely complex!
end

function musicControl()
	if (activeGame == false) and musicState != 'menu' then
			music(track_2start,0,120)
			musicState = 'menu'
	end
	if activeGame == true and musicState != 'level1' and showDoor == false then
		music(track_1start,0,120)	
		musicState = 'level1'
	end
	if activeGame == true and musicState != 'level5' and showDoor == true then
		music(track_5start,0,120)	
		musicState = 'level5'
	end
end

function screen_shake()
	local x_shake = rnd(shakeAmount) - (shakeAmount / 2)
	local y_shake = rnd(shakeAmount) - (shakeAmount / 2)

	-- shake camera 
	camera(camera_x + x_shake, camera_y + y_shake)

	-- reduce shake
	shakeAmount *= .9
	if shakeAmount < .3 then shakeAmount = 0 end
end


-- map strings
owen="qa_?ce-?ja-?ciqabaaadmaadm-?ea6ace-?ea-aam-aa2-?ca6a??qc?pqba2aaam-aaaabay6bf<5caqabaa6bfaaaeqaaa2aaaqab?laaguaaaqab?taaeaaa?l6bf<)aa<)bea6bgaaafu-?daabe<?aa<)ag<pda<?ag<)aa2-?1a-b?}aai2-b?)aai6-?c2-?ja-?c6aca"
map0 = "ac_?@m=?t<6rh>pbp<ppam=? a6c?l_dgj[qh>?ap<ppam=?0aafli=d8<6ipi=d8<6i?5-dej{uf>?ap<ppam=?!a-?m-ahn<pbpy{v?t-d?+da9<)ja&7g?p-g%<)b1-rdpm_dpy]z?t-d?+da9<?iaauq9&=?n&_?c-ahny]z?t-d?+da9<?iaavu9<_k7[si*e8l7;si*[=g%<?a1-63}_rd?l-d?+da9<5jam=?l<-h,;8l*<)a([sl);-?c<-?<a-i?xca9<)gp<ppam=? a-i?,_d?+da9<5jam=?.<-?<a-i?xca9<?vam=? a-i?5fa9<5jam=?xb-i?xca9<?vam=? a-i?5faaa"

__gfx__
000000000000000000000000000700070007000700000000060006000600060006000600444b444bbbbbbbccbbbbbccc55555555cccccccc555ccc7ccccccccc
000000000007000700070007000777770007777706000600047474000474740004747400444444bbbbbbbcccbbbbcccc455454457ccccc7c55cccccccccc7ccc
00700700000777770007777770071771700717710474740007c4c70007c4c70007c4c700444444bbbbbbccccbbbccccc44444444cccccccc5ccccccccccccccc
000770007007177170071771700777e7700777e707c4c700044a4400044a4400044a440044444bbbbbbbccccbbbbcccc44444444cccccccccccccccccccccc7c
00077000700777e7700777e70776686007766860044a4400064446000644460006444600444b444bbbbcccccbbbbcccc44444444cccccccccc7cccccc7cccccc
007007000776686007766860077777700777777006444600064446006344436006444600444444bbbbbbccccbbbbcccc444444445ccc7ccccccccccccccccccc
00000000077777700777777070d0070670d07060064446000644460063444360064446004444bbbbbbbbccccbbbbcccc4444444455cccccccccccc7ccccccccc
00000000171d7160171d1716011111000111110006a4a60000a0a00000a0a00000a0a0004b44b4bbbbbcccccbbbbbccc44444444555ccccccccccccccccccccc
bbbbbbbbbbbbbbbbbbbbb9bbc44cc44cb44bb44bbbb33bbb000000000000000000000000bbbb4444444444444444444455d5cccc44444444bbbbbbbbccccc555
bbbbbbbbbbbbbbbbbbbb9bbb9999999999999999bb31b3bb000400090000000000011111bbb444444444d44444444444455d55cc44444444bbbbbbbbcccccc55
bbbbddbbbb224444444944bb4444444444444444b33b331b00099999000b000000167671bb44444444444d44444444444455555c544545545bb5b55bccc7ccc5
bbbd6ddbb22229949994944b4224242442242424b13aa33b4009199100b3b00001777771bbb444444dd444444444444444455d55555d5555555d5555cccccccc
bbd6dd5bb21222244244224b424224244242242433b5ab33400999e9000b000016676761b4444444444d44444444444444445555555d5d55555d5d55cccccccc
b35dd553b22124442444441b4444444444444444313bb311044999900000000017777770bb4b444444444dd444444444444445555d55dd5d5d55dd5dcccccccc
bb35553bb12242122221223bc22cc22cb22bb22b13bb1b31049994400000000017676700bbbb44444444d4444444444444444455d555d55dd555d55dc7ccccc7
bbbbbbbb3311111111111133c22cc22c322332233113b331141d91400000000011111000bbb444444444444444444444444444455d5555d55d5555d5cccccccc
0000000044488444ccc88ccc65666566777777771b333111bbbbb333333bbbbb0000000044444444444444444444444454454554444444444444444444444444
05555500448f8244cc8f82c7555555557666666511b3bb11bbbb33333333bbbb00000000444444444444d4444444444455555555444444444444444444444444
0dd5550048888244cc8882cc666566657666666531333313bbb3a3baab333bbb000000004444444444444dd454454554555d555d544545545445455445545445
055555008f888e22c8888e2c5555555576666665b311113bbb3b3baaaab133bb0000000044444444444d44445555555555dd5d55555d5555555d5555555d5555
0555a50088882222c8f8222c6566656676666665bb3223bbb33311baab13b33b00000000444444444dd4444455d55555d55d5d5d555d5d555555555555d55555
0555550055822255cc8222cc5555555576666665bb1442bb33ab333333bb113300000000444b444444444d44c55555555d55dd5d5d55dd5d5555555d55555d5c
0dd55500555115557cc11ccc6665666576666665314344133b11bb33131133b3000000004bbb4b444444d444c555d555d555d55dd555d55dd5555555555555cc
0555550055222255cc2222cc5555555555555555b333133b31b31133333ab31300000000bbbbbbb444444444cc55555555d555d555d555d555dd55d555555ccc
00000000bbbbbbbbbbbbbbbb444884440000000000000000131bb3b133ab1131000000004bbbbbbb444444444444444400000000000000000000000000000000
00000000bbb3bbbbbbbbbbbb448f82440000000000000000b1111133b311311b0000000044b4bbb444444444444d444400000000000000000000000000000000
00000000b33bbbbbbbbbbbbb488882440000000000000000bb11b113313311bb00000000b444b4b4444444444dd4444400000000000000000000000000000000
00000000bbbb3bbbbbbbbbbb8f888e220000000000000000bbb1113133111bbb0000000044b4b444444444444444d44400000000000000000000000000000000
00000000bbbbb33bbbbbbbbb888822220000000000000000bbb3111111113bbb00000000444444444444444444444dd400000000000000000000000000000000
00000000bb3bbbbbbbbbbbbb448222440000000000000000bb314211112413bb00000000444444444444444444d4444400000000000000000000000000000000
00000000bbb3bbbbbbbbbbbb444114440000000000000000b31421244212413b000000004444444444444444444d444400000000000000000000000000000000
00000000bbbbbbbbbbbbbbbb442222440000000000000000bb331441144133bb0000000044444444444444444444444400000000000000000000000000000000
bbbbbbbbbbbbbbbb33333333333b33e33333333333333333ccccc333333cccccbbbbbbbbbbbbbb4444bbbbbbbbbbbbbbbbbbbbbbbbbbbb4444bbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb3333333333b333333383b333333b3b33cccc38333333ccccbbbbbbbbbbbb44999944bbbbbbbbbbbbbbbbbbbbbbbb44999944bbbbbbbbbbbb
bbbbbdddddddbbbb33333333333b33333333333333333383ccc333bbbb333cccbbbbbbbbbb4494aaa94944bbbbbbbbbbbbbbbbbbbb4494aaa94944bbbbbbbbbb
bbbbdd6d666ddbbb3333333333333333c33333b33b33333ccc3b3b3333b333ccbbbbbbbb449494aaaa444944bbbbbbbbbbbbbbbb449494aaaa444944bbbbbbbb
bbbddddddd66ddbb3333333333338333cc3b3b3383b3b3ccc33333bbbb38b33cbbbbbb44949444aaa949494944bbbbbbbbbbbb44949444aaa949494944bbbbbb
bbdddddddddd6ddb3333333333333333ccc1333bb3331ccc333b333333bb3333bbbb4494949494aaaa4949444944bbbbbbbb4494949494aaaa4949444944bbbb
bb55dddddd55dddb3333333333333333cccc11b11b11cccc3333bb33333333b3bb449494949494aaaa494449494944bbbb449494949494aaaa494449494944bb
b5555ddd66dd555b33333333333b3b33ccccc111111ccccc333333333333b333449494449444a444444a494949444944449494449444a444444a494949444944
b55dd5d66dd5155b3333333333b333b30000000000000000133bb3b33b3bb8312494949494a4442222444a49444949422494949494a444ff22444a4944494942
b151dddddd55155b333333333b33333b0000000000000000c11333333333311c44949494a44422111122444a4949494444949494a444ff111122444a49494944
33151dddd555513333bb3333333333330000000000000000cc11b113311b11cc249444a444221111111122444a494442249444a444ff1111111122444a494442
b33111555511133b3333b333833333330000000000000000ccc111b11b111ccc2494a4442211112222111122444a49422494a444ff1111ffff111122444a4942
bb333311113333bb38333b33333333330000000000000000cccc11133111cccc24a44422111122222222111122444a4224a444ff1111ffffffff1111ff444a42
bbbb33333333bbbb3333333333333b830000000000000000ccccdd1111ddcccc244422111122222442222211112244422444ff1111ffffffffffff1111ff4442
bbbbbbbbbbbbbbbb33333b3333b333330000000000000000cccc6d5dd5d6cccc2422111122222444444222221111224224ff1111ffffffffffffffff1111ff42
bbbbbbbbbbbbbbbb33b333833333b3330000000000000000cccc26555566cccc21111122222444444444422222111112211111ffffffffffffffffffff111112
333bb3b133ab133300000000000000000000000000000000cccc26566562cccc1111122224444444444444422221111111111ffffffffffffffffffffff11111
33331133b311333300000000000000000000000000000000cccc62555566ccccb112122444111144444111444221211bb11f1fffff2222fffff111fffff1f11b
ab3331133133a3ba00000000000000000000000000000000cccc66566526ccccbb1221444111111444111114441221bbbb1ff1fff222222fff11111fff1ff1bb
aab13331333b3baa00000000000000000000000000000000cccc62555566ccccb312242241111114441111142242213bb31ffffff222222fff11111ffffff13b
ab13b331133311ba00000000000000000000000000000000cccc66566562ccccb311244441111914441111144442113bb311fffff222292fff11111fffff113b
33bb113113ab333300000000000000000000000000000000cccc26555526cccc3312124441111414442222244421213b331f1ffff222242fff22222ffff1f13b
131133344311bb3300000000000000000000000000000000cccc66566566cccc3331142241111114444444442241133b33311ffff222222ffffffffffff1133b
333ab31111b3113300000000000000000000000000000000cccc66555566ccccb333311441111114424224244113333bb333311ff222222ffffffffff113333b
33ab1333333bb3b10000000000000000000000000000000055556256652655550000000000000000000000000000000000000000000000000000000000000000
b3113333333311330000000000000000000000000000000054546655556645450000000000000000000000000000000000000000000000000000000000000000
3133a3baab3331130000000000000000000000000000000044442656656244440000000000000000000000000000000000000000000000000000000000000000
333b3baaaab133310000000000000000000000000000000044446655552644440000000000000000000000000000000000000000000000000000000000000000
133311baab13b3310000000000000000000000000000000044442656656244440000000000000000000000000000000000000000000000000000000000000000
13ab333333bb11310000000000000000000000000000000044466255556664440000000000000000000000000000000000000000000000000000000000000000
4311bb33131133340000000000000000000000000000000044626156651626440000000000000000000000000000000000000000000000000000000000000000
11b31133333ab3110000000000000000000000000000000046261651156162640000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000010100010180800102000100000000000001000001010101010100000000010000000000000000000101000000000000000001010000010101010101010101010101010100000101010101010101010101010000000000000101010101010101010100000000000001010000000000000000
0101000001000001010100000000000001010000010000010101000000000000010101010100000001010000000000000101010001010000010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
232323232323232323232323232323232323232323232323232323232323232323232323232323230f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f46470f0f0f0f0f0f0f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2348494a4b321032323232323232323232323232323232323232323232323232323232323232320a0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f464243470f0f0f0f0f0f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2358595a5b404132323232323232323232323232323232323232323232323232323232323232320b220f220f220f220f220f220f0f0f0f0f0f0f0f445253450f0f0f0f0f0f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2368696a6b50513232323232323232323232323132323232323232323232323232323232323232190c0c0c0c0c0c0c0c0c0c0c0c0c1c0d0f0f0f0f0f56570f0f0f0f0f0f0f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
233232323232323232323232323232323232323232323232323232323132323232323232323232191b1a1b1b1b1b2a1b1b1b1b1b1b1b1c0d0f0f0f0f66670f0f0f0f0f0f0f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
233232313232323232323232323232323232323232323232323232323232323232323232324041232b331b331b331b331b331b331b1b1b0c0c0c1c0d66670f0f0f0f0f0f0f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
233232323232323232323232323232323232323232323232323232323232323232323232325051231f2b2c2c2c2c2c2c2c2c2c2c2d1b2a1b1b1b1b0c76771c0d0f0f0f0f0f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
233232323232323232323232323232323232323232323232323232323232323232323232323232230f0f0f0f0f0f0f0f0f0f0f0f1f2b2e2e2d2e2e2e2d2d2f0e0f0f0f0f0f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
233232313232323232323232323232323232323232323232323232323232323232323232323232230f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
233232323232323232323232323232323232323232103232323232323232323231323232323232230f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
234c4d4e4f32323232323232323232323232323232323232323232323232323231323232323232230f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
235c5d5e5f323232323232323232323232313232323232323231323232323232323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
236c6d6e6f323232323232323232323232323232323232323232323232323232323232323232322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

