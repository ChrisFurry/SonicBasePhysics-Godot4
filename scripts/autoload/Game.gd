extends Node

var fps:float = 60.0;
var targetFps:int = 60;
var delta:float = .0;
var physicsDelta:float = .0;

var noDeltaTiming:bool = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	process_priority = -100;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(noDeltaTiming): 
		delta = 1.0;
		Engine.max_fps = 60;
		return;
	else:
		Engine.max_fps = targetFps;
	delta = _delta * fps;

func _physics_process(_delta):
	if(noDeltaTiming): 
		physicsDelta = 1.0;
		return;
	physicsDelta = _delta * fps;
