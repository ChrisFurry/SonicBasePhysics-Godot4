extends Resource
class_name ControllerInput

@export var up:bool;
@export var down:bool;
@export var left:bool;
@export var right:bool;
@export var a:bool;
@export var b:bool;
@export var c:bool;
@export var start:bool;
@export var select:bool;

@export var pressed_up:bool;
@export var pressed_down:bool;
@export var pressed_left:bool;
@export var pressed_right:bool;
@export var pressed_a:bool;
@export var pressed_b:bool;
@export var pressed_c:bool;
@export var pressed_start:bool;
@export var pressed_select:bool;

@export var released_up:bool;
@export var released_down:bool;
@export var released_left:bool;
@export var released_right:bool;
@export var released_a:bool;
@export var released_b:bool;
@export var released_c:bool;
@export var released_start:bool;
@export var released_select:bool;

func get_input_from_inputmap(startString:String):
	# Get input
	up = Input.is_action_pressed(startString + "up");
	down = Input.is_action_pressed(startString + "down");
	left = Input.is_action_pressed(startString + "left");
	right = Input.is_action_pressed(startString + "right");
	a = Input.is_action_pressed(startString + "a");
	b = Input.is_action_pressed(startString + "b");
	c = Input.is_action_pressed(startString + "c");
	start = Input.is_action_pressed(startString + "start");
	select = Input.is_action_pressed(startString + "select");
	
	pressed_up = Input.is_action_just_pressed(startString + "up");
	pressed_down = Input.is_action_just_pressed(startString + "down");
	pressed_left = Input.is_action_just_pressed(startString + "left");
	pressed_right = Input.is_action_just_pressed(startString + "right");
	pressed_a = Input.is_action_just_pressed(startString + "a");
	pressed_b = Input.is_action_just_pressed(startString + "b");
	pressed_c = Input.is_action_just_pressed(startString + "c");
	pressed_start = Input.is_action_just_pressed(startString + "start");
	pressed_select = Input.is_action_just_pressed(startString + "select");
	
	released_up = Input.is_action_just_released(startString + "up");
	released_down = Input.is_action_just_released(startString + "down");
	released_left = Input.is_action_just_released(startString + "left");
	released_right = Input.is_action_just_released(startString + "right");
	released_a = Input.is_action_just_released(startString + "a");
	released_b = Input.is_action_just_released(startString + "b");
	released_c = Input.is_action_just_released(startString + "c");
	released_start = Input.is_action_just_released(startString + "start");
	released_select = Input.is_action_just_released(startString + "select");
