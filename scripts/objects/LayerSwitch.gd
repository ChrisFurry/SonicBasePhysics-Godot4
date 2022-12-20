extends Area2D

@export var backgroundLayer:bool = false;

func _ready():
	monitorable = false;
	set_collision_layer_value(1,false);
	set_collision_mask_value(1,false);
	set_collision_mask_value(5,true);
	connect("area_entered",Callable(self,"object_entered"),CONNECT_PERSIST);

func object_entered(area:Area2D):
	var player = area.get_parent();
	if !(player is Player2D): return;
	if(backgroundLayer):
		player.floorRaycast.set_collision_mask_value(1,false);
		player.wallRaycast.set_collision_mask_value(2,false);
		player.roofRaycast.set_collision_mask_value(2,false);
		player.floorRaycast.set_collision_mask_value(3,true);
		player.wallRaycast.set_collision_mask_value(4,true);
		player.roofRaycast.set_collision_mask_value(4,true);
	else:
		player.floorRaycast.set_collision_mask_value(1,true);
		player.wallRaycast.set_collision_mask_value(2,true);
		player.roofRaycast.set_collision_mask_value(2,true);
		player.floorRaycast.set_collision_mask_value(3,false);
		player.wallRaycast.set_collision_mask_value(4,false);
		player.roofRaycast.set_collision_mask_value(4,false);
