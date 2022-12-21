# SonicBasePhysics-Godot4
 A simple base for a Sonic-like game for Godot 4 (beta 8) by ChrisFurry
 # Features
* 360 Sonic Physics
* Basic States
	* Normal Movement
	* Jumping
	* Rolling
* Layer Switching
* LOOPS!!!!!!!!!!
# How some things work
The "Game" autoload holds process delta and physics delta, you can change this if you want.
The reason for this is so then you can have a forced 60 FPS mode if you wanted. (So all nodes would not have to have special code for it)

The "DevMenu" scene is actually mostly controlled by a script in "res://scripts/scenes/engine/DevMenu.gd"
You can get back to the dev menu by pressing ESC.

The custom "Player2D" node holds all of the physics code, this is done without "CharacterBody2D" and instead a base Node2D, but if you want to use a CharacterBody instead there should be no issues.

Inside of Player2D, "state" and "subState" are both Callables(FuncRef's in Godot 3), making it easy to call a method from any node if needed.

There is a "PlayerPhysicsResource" which holds all of the character's physics data like acceleration and jump height, this can be changed but a lot of code editting would be needed.

There is a "ControllerInput" Resource that grabs all the input data you need. This can be modified.
# Misc
This framework will be updated if it breaks in newer versions of Godot (please contact me if it does and I don't notice)
Please contact me if you find any issues within the framework. (Or if you want to help)
