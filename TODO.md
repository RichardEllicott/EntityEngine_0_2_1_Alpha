# Links:

* <https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet> - markdown guide
* <https://jbt.github.io/markdown-editor/> - markdown editor
* <http://markdownlivepreview.com> - markdown preview
* <https://uploadfiles.io/> - file upload
* <http://orteil.dashnet.org/gamegen> - random game ideas
* <https://en.wikipedia.org/wiki/Glossary_of_video_game_terms> --useful wiki page

# Words:
* "make it slow" -make things work slow and organized rather than not at all, always prototype (be aware of potential optimizations however, don't make it slow just for the sake of it!)

# StackOverflow curiosities:

* can lua be sandboxed, i'd love it for mods of a game
* japan guy, did you do a slice with a line?
	* check on net for solution
	* idea one:
		* get the intersection of all the lines of the poly
		* find the points either of the line equation
		* also need to make the line through the middle of the slicing boolean (so triangles are different)
	* idea 2 (i think it's the carmack method), lead line out from the polygon to a VISIBLE vertex (there will always be a visible vertex)
	* use this to construct a connected "horseshoe"
	* it might fail with standard bool, so use method 1
	* carmack used a rotation? a spiral (it didn't work)
* test if boolean can use concave polygons?








#Random Priority:


* gravity (black holes etc)
* investigate cog shapes, whether the physics engine allows them to turn each other (pushing and stuff)
* collection system, like collect a powerup
* on death spawn explosion (perhaps look at eventing system again)
* love.graphics.newMesh we now have textures
* control schemes ALL FOR NETBOOK :)) ...??? mac netbook audience?
* look at raycast? maybe even the lightning bolt
* resize fixtures???? lead here: https://love2d.org/forums/viewtopic.php?t=28746
* want to do a cool custom particle system
* can we resize shapes dynamically, it seems we have not altered collision (we need to post a support thread note, maybe with box2d)
* investigate chain shape, but don't waste too much time!!
* the edge shape teleport will require slightly more time, ignoring for now

## Creative Priority:
* "simple bubble", simple shapes, maybe add vector draw, simple start to fin, screen wrap, need to accelerate past moving but not too fast
	* absolute move
	* controls: mouse and space or left mouse hold to apply force... or joypad
	* serialize level? 
	* 3 levels
		* no moving platforms, screen wrap
		* moving platforms
		* hunter?
* "simple puzzle", like atomix with screen wrap 
	* shuffle?
* level editors to allow designers? i can't be bothered to make levels
* 2D computer world, maybe with the virtual life system, perhaps random physics move creatures, get infected with virus
* gravity rest on floor platform system test? with physics
* add that cool logo (cog plus wings) just to test the sequence really, any button starts game, so we have a sequence of screen etc



* convert something like Atomix, or an asteroids that runs off sides of screen gameplay
    * hit full-screen for the above
    * we have to solve the wander off edge to other edge illusion
        * teleportircle (round teleporter) weird ideas for alternate videogame universe, the AI went fucking mad


## High Priority:
* animation system, will evolve to have nested sub animations in sequences ******* ??? 
	* also maybe sync these timers?? OPTIMIZE
	* animation frame save system, to pre-render animations?
* contextual menu system (ignore mouse commands if hovering the box)
* FULLSCREEN FOR THE TRAIL RENDER NOT YET DONE, WE HAD AN EXAMPLE IN OLD CODE??? still dont work
* ARE ANY FLOATING REFERENCES LEFT ALIVE IN OUR DEATH CODE?
* random polygon code that puts them in bounds, for asteroids
* torture test that checks for memory leaks (concerning fixtures left alive perhaps etc)
* our sensor teleport
* animation system to be able to work for in game objects (get cool teleport and )
* ADVANCED physics persisting (what is it persisting with etc). Monitor the fixture contacts, but only present the gameobject contacts

## Low Priority:
* loading schemes, no command gen now just package it
* camera rotation (ruins grid and world translations from the perspective of the mouse)
* early sounds, audio playback and music sync system
* in game edit map (needs like a save to)
* globals checker as well
* also float point issue... much later (32, 64 128)
* draw nice spirals like golden mean graphics stuff??? nah
* more physics investigation beyond sensor bullets




## To Impress Others
* that animation system, some nice animations
* get some of the pixel art animation in as a quick visual test (try some alpha perhaps due to trails)
* test the other odd shader


# Notes


## Game Object Names
* player
* missile
* block
* teleport - will have an entrance and an exit, needs to not go in a loop (wait until player/unit leaves the exit)
* lightning - an animated hazard

## Some ideas
* lightning discharge hazard
* destroyable grid
* destroyable poly reduction physics


## Artist Symbolism
* teleporter like a hole, maybe a global "heartbeat" as we get near thing thing to destroy (like music)
* the center is a "nexus", it must be destroyed, the world changes we must escape
* turrets, both enemy ones and player ones (blue and red?)
* find nexus? rescue things, they become tale, take to nexus? clue is tale is not long enough "call that a tale?"
    -we're not even sure how long tale must be, but color changes?
* "welcome to the orange world, we like to call it tangerine"
* "welcome to the blue world, we like to call it aqua, or sky blue to be specific"
* so you've made it to the red world, well, we just call this one red
* green, or lime if you will
* we don't like red people here
* we like green and blue, sometimes a bit of orange, but i'm not sure about those folk
* i've lost my memory, everything changes i guess

## Enemies
* blobs, varying sizes link together
* turrets (start shooting before they aim at player)
* arrows turn to face player, launch at player
* gravity wells
* spawn enemy things
* weapons are plasma, grenades, lasers (good for enemies that don't dodge)
* snakes??
* generators


# Bugs
`
Error

ee_entity.lua:196: Box2D assertion failed: false


Traceback

[C]: in function 'newPolygonShape'
ee_entity.lua:196: in function 'initialize_physics'
main.lua:216: in function 'manual_load_test20180615'
main.lua:19: in function 'test1'
main.lua:149: in function 'load'
[C]: in function 'xpcall'
[C]: in function 'xpcall'
`













