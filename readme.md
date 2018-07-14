# Entity Engine Version 0.2.0 Alpha (Revenant)

A game engine system that manages drawing all the objects in the game (entities), tracking and drawing them etc.
Supports physics, manages callbacks, turns concave polygons into objects consisting of multiple fixtures etc.

## Notes

Engine has been resurrected recently, 12/05/2018, after a period of inactivity on it. It has been cleaned up a bit, significant recent changes:
* my_lua_lib became ee_redruth_library (redruth is the project name of the generic library)
* lightworld is mostly being dropped, i might add support for a simpler more reliable lighting shader lib like:
	* https://github.com/matiasah/shadows
	* https://github.com/dylhunn/simple-love-lights
	* moonshine represents a mid-way replacement, no actual lighting 
	* possibly add custom shaders/basic distance based lighting (no shadows)
* lightworld mostly removed (it was unreliable, didn't support the right translations, and finally doesn't work on the new Love version)





