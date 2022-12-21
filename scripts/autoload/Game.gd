extends Node

# Delta is controlled by this autoload. You don't really need this but I have it for noDeltaTiming mode.
var delta:float = .0;
var physicsDelta:float = .0;

var targetFps:int		= 60;
var noDeltaTiming:bool	= false;
var uncapFps:bool		= false;
var showFps:bool		= true;

var fpsCounter:Label	= Label.new();

const devmenu_packed = preload("res://scenes/engine/DevMenu.scn");

# Called when the node enters the scene tree for the first time.
func _ready():
	process_priority = -100; # This runs first at all times.
	Engine.time_scale = 60.0; # This should make delta time force itself to 60.
	# Create a canvas layer along with label settings... ALONG with a invert shader
	var canvasLayer = CanvasLayer.new();
	var labelSettings = LabelSettings.new();
	var labelMaterial = ShaderMaterial.new();
	labelSettings.font_size = 8; # FPS counter's size should be small.
	labelMaterial.shader = preload("res://shaders/invertback.gdshader"); # Get our really simple invert shader
	fpsCounter.label_settings = labelSettings; # Give the label settings to the fps counter
	fpsCounter.material = labelMaterial; # Give the fps counter the material
	add_child(canvasLayer); # add canvas layer child
	canvasLayer.add_child(fpsCounter); # it gave birth

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(noDeltaTiming):
		delta = Engine.time_scale;
		Engine.max_fps = 60;
		return;
	else:
		Engine.max_fps = 0 if(uncapFps)else targetFps;
	delta = _delta;
	fpsCounter.visible = showFps;
	fpsCounter.text = str(Engine.get_frames_per_second());

func _physics_process(_delta):
	if(noDeltaTiming):
		physicsDelta = Engine.time_scale;
		return;
	physicsDelta = _delta;

func _unhandled_input(event):
	if(event is InputEventKey):
		if(event.pressed && event.keycode == KEY_ESCAPE && get_tree().get_current_scene().name != "DevMenu"):
			get_tree().change_scene_to_packed(devmenu_packed);
