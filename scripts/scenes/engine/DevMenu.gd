extends ColorRect

var input					= ControllerInput.new();
var currentCall:Callable	= Callable(self,"menu_main");
var menuOption:int			= 0;
var defaultFont:Font
var horizontalBuffer:float	= .0;

func _ready():
	var label = Label.new();
	defaultFont = label.get_theme_default_font();

func _process(_delta):
	input.get_input_from_inputmap("1");
	queue_redraw();

func _draw():
	if(currentCall.is_valid()): currentCall.call();

func menu_main()->void:
	var options = [
		"Play",
		"Options",
		"Exit"];
	var confirm	= (input.pressed_a || input.pressed_c || input.pressed_start);
	#var back	= input.pressed_b;
	virticle_menu_control(options.size() - 1);
	if(confirm):
		match(menuOption):
			0: get_tree().change_scene_to_file("res://scenes/levels/Test.scn");
			1: currentCall = Callable(self,"menu_options");
			2: get_tree().quit();
	draw_text_array(options,8,menuOption,Vector2(0,-menuOption));

func menu_options()->void:
	var options = [
		"Back",
		"Max FPS: ",
		"VSync: ",
		"FPS Uncapped: ",
		"Force 60 FPS Logic: ",
		"Show FPS: ",
		];
	var confirm	= (input.pressed_a || input.pressed_c || input.pressed_start);
	#var back	= input.pressed_b;
	var hor = return_horizontal_control();
	virticle_menu_control(options.size() - 1);
	if(confirm):
		match(menuOption):
			0: currentCall = Callable(self,"menu_main");
			2: # There are actually 4 vsync options, but for simplicity just allow us to enable or disable it.
				if(DisplayServer.window_get_vsync_mode() != 0): DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED);
				else: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED);
			3: Game.uncapFps = !Game.uncapFps;
			4: Game.noDeltaTiming = !Game.noDeltaTiming;
			5: Game.showFps = !Game.showFps;
	if(!Game.uncapFps && !Game.noDeltaTiming): 
		if(menuOption == 1): Game.targetFps += hor;
		Game.targetFps = clamp(Game.targetFps,15,99999);
		options[1] += str(Game.targetFps);
	else:
		options[1] = "Max FPS Locked";
	# Add stuff to the option text
	options[2] += str(DisplayServer.window_get_vsync_mode() == 1);
	options[3] += str(Game.uncapFps);
	options[4] += str(Game.noDeltaTiming);
	options[5] += str(Game.showFps);
	draw_text_array(options,8,menuOption,Vector2(0,-menuOption));

## USABLE FUNCTIONS
# Controls the input
func virticle_menu_control(optionCount:int)->void:
	var vir = sign(int(input.pressed_down || input.pressed_select) - int(input.pressed_up));
	menuOption += vir;
	if(menuOption < 0): menuOption = optionCount;
	if(menuOption > optionCount): menuOption = 0;

func return_horizontal_control()->int:
	var hor = sign(int(input.right) - int(input.left));
	if(hor == 0): horizontalBuffer = 0;
	else:
		var prevHor = horizontalBuffer;
		if(horizontalBuffer != 0 && horizontalBuffer < 30): hor = 0;
		horizontalBuffer += Game.delta;
		if(horizontalBuffer >= 30): if(floor(prevHor) == floor(horizontalBuffer)): hor = 0;
	return hor;
# Draws onscreen text
func draw_text_array(strings:Array,distanceY:float,currentSelection:int = 0,offset:Vector2 = Vector2.ZERO)->void:
	var u = 0;
	for i in strings:
		var col = Color.WEB_GRAY;
		if(currentSelection == u): col = Color.YELLOW;
		var pos = Vector2(160,120) + (offset * Vector2(1,distanceY)) + Vector2(0,distanceY * u) - (defaultFont.get_string_size(i,HORIZONTAL_ALIGNMENT_LEFT,-1,8) / 2) + Vector2(0,defaultFont.get_ascent(8));
		draw_string(defaultFont,pos,i,HORIZONTAL_ALIGNMENT_LEFT,-1,8,col);
		u += 1;
