extends Node

var controllerInputs = [];
var controllerInputsPhysics = [];

func _ready():
	process_priority = -99;
	process_mode = PROCESS_MODE_ALWAYS

func _process(_delta):
	controllerInputs = [];
	controllerInputs.append(_get_input_from_inputmap("1"));

func _physics_process(_delta):
	controllerInputsPhysics = [];
	controllerInputsPhysics.append(_get_input_from_inputmap("1"));

func _get_input_from_inputmap(start:String):
	# The temp var
	var inp = ControllerInput.new();
	# Get input
	inp.up = Input.is_action_pressed(start + "up");
	inp.down = Input.is_action_pressed(start + "down");
	inp.left = Input.is_action_pressed(start + "left");
	inp.right = Input.is_action_pressed(start + "right");
	inp.a = Input.is_action_pressed(start + "a");
	inp.b = Input.is_action_pressed(start + "b");
	inp.c = Input.is_action_pressed(start + "c");
	inp.start = Input.is_action_pressed(start + "start");
	inp.select = Input.is_action_pressed(start + "select");
	
	inp.pressed_up = Input.is_action_just_pressed(start + "up");
	inp.pressed_down = Input.is_action_just_pressed(start + "down");
	inp.pressed_left = Input.is_action_just_pressed(start + "left");
	inp.pressed_right = Input.is_action_just_pressed(start + "right");
	inp.pressed_a = Input.is_action_just_pressed(start + "a");
	inp.pressed_b = Input.is_action_just_pressed(start + "b");
	inp.pressed_c = Input.is_action_just_pressed(start + "c");
	inp.pressed_start = Input.is_action_just_pressed(start + "start");
	inp.pressed_select = Input.is_action_just_pressed(start + "select");
	
	inp.released_up = Input.is_action_just_released(start + "up");
	inp.released_down = Input.is_action_just_released(start + "down");
	inp.released_left = Input.is_action_just_released(start + "left");
	inp.released_right = Input.is_action_just_released(start + "right");
	inp.released_a = Input.is_action_just_released(start + "a");
	inp.released_b = Input.is_action_just_released(start + "b");
	inp.released_c = Input.is_action_just_released(start + "c");
	inp.released_start = Input.is_action_just_released(start + "start");
	inp.released_select = Input.is_action_just_released(start + "select");
	# Return the temp var
	return inp;
