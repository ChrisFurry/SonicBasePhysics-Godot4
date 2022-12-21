extends ColorRect

const goto_scene = preload("res://scenes/engine/DevMenu.scn");

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().change_scene_to_packed(goto_scene);
