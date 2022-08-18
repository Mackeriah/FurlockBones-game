# Furlock Bones: Consulting Dogtective (a PICO-8 game)  
## Play the game here! <URL here>

### ***CS50 submission video***:  https://youtu.be/iVv2UNkHeEA

### ***Description***: A PICO-8 game where the player acts as Furlock Bones, a dogtective who is helping his friend Dr. Wooften write a story containing animal characters.
<br>


This game was developed using PICO-8 which is 'Fantasy Console'. Essentially this means that it is mimicking old consoles and computers of decades ago, which had many limitations and thus were 'harder' to code for. For example limited RAM, more basic languages less powerful processors. The PICO-8 language is Lua based.

[More information on PICO-8 can be found here.](https://www.lexaloffle.com/pico-8.php "Have fun!")

There is only one file for this project (furlock bones.p8) which can of course be viewed in any text or standard code editor. You may be interested to know that a big aspect of PICO-8 is the ability to share carts amongst the community and PICO-8 has a novel way of doing this. Each cart can be exported as a PNG image file. ALL game data (code, sprites, music, everything) is stored within the image. The PNG file will even contain an image header to it can be viewed as a standard PNG. It's quite awesome.

The concept for this game is essentially to enable children (or adults!) to learn facts about animals. The player takes on the role of 'Furlock Bones: Consulting Dogtective' who works with his colleague and friend Doctor Woofton to help complete a book he is writing, involving several animal characters. Woofton asks for Bone's help in gathering facts about the animals from their neighbour, the wise Old Owl.

After a series of conversations have taken place, Owl ventures into his secret library to look for a book for the current animal. After which he provides the book to Furlock but for 'reasons' the player must unscramble the animal facts before they can pass them on to Dr. Woofton. I have added a choice of difficulty levels to make it more or less challenging.

The graphical choices are limited to 8x8 sprites in PICO-8 which is a blessing and a curse. I have created some assets myself (the treehouse and Owl) and others I have used free assets (credited in game). I'm no artist but in the interests of time I'm very grateful for the ability to use other people's assets otherwise I doubt I would have completed this game by the end of 2022! Either that or the characters would be represented by ASCII art!

Initially the game would have had a part whereby the player had to collect various pages from the book, as the wind blew them around the level. However I was quickly reaching the file size limit that PICO-8 enforces, so I have earmarked this for a later release. (I will keep the CS50 link update with my submission and any future versions). I have 2 young daughters who helped me playtest it, which was very useful. There's a lot more I had/have planned but due to needing to finish it this year I have put those on the backburner.

Some of the functions can definitely be improved (especially a couple which are duplicated although only slightly different) but overall for my first project, and solo at that, I'm very proud. One aspect that PICO-8 brings with it's enforced limitations is that of keeping a project focused. I used a Trello board and Miro to capture the requirements and was very aggressive in how much I have moved into v2 or later. This also helped to keep the game focused around it's core loop which is that of the word game. Yes there is no jumping, or baddies, or pickups etc. but had I focused on those over the word game, I think the game would overall not have met my original idea.

One aspect I don't like about PICO-8 though is the lack of a decent debugger. This did make tracking down bugs a lot more painful and drawn out than they would otherwise have been. I do intend to work more on Furlock after my submission, but I'm not sure whether I would challenge myself to develop anything else in it for this reason alone.

About halfway through my project I read that PICO-8 is not best suited to text games. This is primarily because PICO-8 has limitations in place to mimic the experience of coding on machines from times gone by. For example there is a character limit of 65,536. It also has the concept of 'token's which are limited to 8,192 as per the manual.

>*The number of code tokens is shown at the bottom right. One program can have a maximum of 8192 tokens. Each token is a word (e.g. variable name) or operator. Pairs of brackets, and strings each count as 1 token. commas, periods, LOCALs, semi-colons, ENDs, and comments are not counted.* [Link to manual](https://www.lexaloffle.com/dl/docs/pico-8_manual.html "Code limits").

This limitation is of course particularly painful if your game is full of text! However, I still managed to produce the game I envisaged although I butted right up to the limit on my final day. I believe I can quite drastically reduce the code to allow me to further extend the game however. But arguably one learning from this is to ensure the language you choose is best-suited for your project! 

*Note: There are workarounds to the limitations as it's possible for your game to have multiple 'carts'.*

Music-wise I looked into creating my own but quickly decided that was one challenge too many, so opted to use freely available music instead, which is credited in-game. The music engine is quite powerful but also quite complex to learn and I decided that it wasn't the best use of my time. After all I could have easily included no music.

I also originally intended to include sound effects but have not. I actually found that the lack of sound effects were not jarring (at least not to me) as there is music playing constantly. Plus it meant that any necessary sound effects are text based which has the added benefit of being great for anyone who is hearing impaired.

I've often wondered how long I've spent on Furlock but without a shadow of a doubt it meets the criteria set by CS50. Probably by far more than I'd like to know!
>*"A one-person project, mind you, should entail more time and effort than is required by each of the course’s problem sets."*

Given that I am a working parent of two young children my free time is limited but I have poured 90+ percent of it into this project over the last few months and prior to that the rest of the CS50 course. So I'm also proud of myself for sticking to my guns and achieving this.

I think this more or less sums things up. I look forward to continuing this project and seeing what other cases Furlock may pick up. I had originally envisaged a rat form of Moriarty (Scuriarty) so that will have to wait for a future version.

Enjoy and thanks to all at CS50 for the fantastic course. It's been genuinely amazing and completing CS50 is one of my proudest achievements.

Cheers,

Owen FitzGerald - Aug 2022