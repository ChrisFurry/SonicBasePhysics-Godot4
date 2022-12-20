extends Node2D
class_name Player2D

# Define Identity
@export var controllerID:int = 0;
# Define Input
var input:Resource = ControllerInput;
# Define Movement
var inertia:float		= 0;
var movement:Vector2	= Vector2.ZERO;
# Define Surface
var surfaceNormal:Vector2	= Vector2.UP;
var floorCollision:bool		= false;
var wallCollision:bool		= false;
var roofCollision:bool		= false;
# Define Character
@export var currentPhysics:Resource = PlayerPhysicsResource.new();
var size:Vector2				= Vector2(9,19);
var wallSize:int				= 10;
var sizeMemory:Vector2			= Vector2.ZERO;
# Define State
var state:Callable				= Callable(self,"state_normal");
var subState:Callable			= Callable(self,"substate_normal");
# Define State Flags
var jumpHighFlag				= false;
var horizontalControlLock:float	= 0;
# Define Sensors
var floorRaycast	= RayCast2D.new();
var wallRaycast		= RayCast2D.new();
var roofRaycast		= RayCast2D.new();
var positionSensor	= Area2D.new();
# Togglable Constants
const floorRoofPercision:int	= 4;
const stepMod:int				= 8;
const cliffTolerance:float		= deg_to_rad(45);
const fallSpeed:float			= 2.5;

func _ready():
	# Set up Sensors
	_disable_sensors();
	floorRaycast.target_position = Vector2(0,size.y);
	wallRaycast.target_position = Vector2(wallSize,0);
	roofRaycast.target_position = Vector2(0,-size.y);
	positionSensor.monitoring = false;
	# Change their collision layers
	wallRaycast.set_collision_mask_value(1,false);
	roofRaycast.set_collision_mask_value(1,false);
	wallRaycast.set_collision_mask_value(2,true);
	roofRaycast.set_collision_mask_value(2,true);
	positionSensor.set_collision_layer_value(1,false);
	positionSensor.set_collision_mask_value(1,false);
	positionSensor.set_collision_layer_value(5,true);
	# Set up Area
	var pixelBox = CollisionShape2D.new();
	pixelBox.shape = RectangleShape2D.new();
	pixelBox.shape.size = Vector2(1,1);
	# Add Children
	add_child(floorRaycast);
	add_child(wallRaycast);
	add_child(roofRaycast);
	add_child(positionSensor);
	positionSensor.add_child(pixelBox);

func _process(_delta):
	queue_redraw(); # Just que redraws cuz the player's size can change at any moment.

func _physics_process(_delta):
	if(state.is_valid()): state.call();

func _draw(): # Since we don't have a sprite, just draw a faded rect of the player's size.
	draw_rect(Rect2(-size,size * 2),Color(1,1,0,0.25));
	draw_line(Vector2(-wallSize,8 * int(surfaceNormal == Vector2.UP && floorCollision)),Vector2(wallSize,8 * int(surfaceNormal == Vector2.UP && floorCollision)),Color(1,0,1,0.25),2);

# States and SubStates
# For controlling the player mostly
func state_normal()->void:
	input = _get_controller_input(controllerID,true);
	if(subState.is_valid()): subState.call();
	_handle_physics();

# For on-ground movement
func substate_normal()->void:
	_physics_slope_repel();
	if(action_jump()): return;
	if(action_roll()): return;
	action_ground_movement();
	_physics_slope_resist();
	if(!floorCollision): subState = Callable(self,"substate_jump");

# For ariel movement
func substate_jump()->void:
	var jump = (input.a || input.b || input.c);
	action_ariel_movement();
	# Low Jump
	if(jumpHighFlag && !jump && movement.y < -currentPhysics.jumpLow):
		jumpHighFlag = false;
		movement.y = -currentPhysics.jumpLow;
	# Gravity
	movement.y += currentPhysics.gravity;
	# Return to ground substate
	if(floorCollision):
		if(action_roll()): return;
		subState = Callable(self,"substate_normal");
		jumpHighFlag = false;
		size = Vector2(9,19);

func substate_roll()->void:
	if(action_jump()): return;
	# Movement
	var hor = sign(int(input.right) - int(input.left));
	if(hor != 0):
		if(hor != sign(inertia)): inertia = move_toward(inertia,0,Game.physicsDelta * currentPhysics.rollDeacceleration);
		else: inertia = move_toward(inertia,0,Game.physicsDelta * currentPhysics.rollFriction);
	else: inertia = move_toward(inertia,0,Game.physicsDelta * currentPhysics.rollFriction);
	# Slope Repel
	inertia -= ((currentPhysics.slopeFactorRollUp * sin(surfaceNormal.angle_to(Vector2.UP))) * Game.physicsDelta) if(sign(inertia) != sign(surfaceNormal.x))else ((currentPhysics.slopeFactorRollDown * sin(surfaceNormal.angle_to(Vector2.UP))) * Game.physicsDelta);
	_physics_slope_resist(false); # Slope resist but without player push
	# Go back to normal
	if(!floorCollision):
		subState = Callable(self,"substate_jump");
	else:
		if(abs(inertia) < 0.5):
			subState = Callable(self,"substate_normal");
			size = Vector2(9,19);

# Actions
# Normal Ground Movement
func action_ground_movement()->void:
	var hor = sign(int(input.right) - int(input.left));
	if(hor != 0):
		if(horizontalControlLock > .0):
			horizontalControlLock -= Game.physicsDelta;
			return;
		if(inertia == .0 || sign(inertia) == hor): inertia = move_toward(inertia,max(6,abs(inertia)) * hor,Game.physicsDelta * currentPhysics.acceleration);
		else: inertia = move_toward(inertia,0,Game.physicsDelta * currentPhysics.deacceleration);
	else:
		inertia = move_toward(inertia,0,Game.physicsDelta * currentPhysics.friction);
# Normal Ariel Movement
func action_ariel_movement()->void:
	var hor = sign(int(input.right) - int(input.left));
	if(hor != 0):
		movement.x = move_toward(movement.x,6 * hor,Game.physicsDelta * (currentPhysics.acceleration * 2));
# Jumping
func action_jump()->bool:
	var jump = (input.pressed_a || input.pressed_b || input.pressed_c);
	if(!jump): return false;
	jumpHighFlag = true;
	floorCollision = false;
	movement += surfaceNormal * currentPhysics.jumpHigh;
	size = Vector2(7,14);
	subState = Callable(self,"substate_jump");
	return true;

func action_roll()->bool:
	var roll = (sign(int(input.down) - int(input.up)) >= 1);
	if(!(roll && abs(inertia) >= 1)): return false;
	jumpHighFlag = false;
	size = Vector2(7,14);
	subState = Callable(self,"substate_roll");
	return true;

# Physics Functions
func _handle_physics()->void:
	# Move player if their size has changed
	if(sizeMemory != size):
		if(floorCollision): global_position -= (sizeMemory.y - size.y) * surfaceNormal;
		sizeMemory = size;
	# Turn off collision flags except for floor collision
	wallCollision = false;
	roofCollision = false;
	# Adjust movement to ground speed
	if(floorCollision):
		movement = Vector2(
			inertia * -surfaceNormal.y,
			inertia * surfaceNormal.x);
	else: global_rotation = 0;
	# Set up for steps
	var steps = movement * Game.physicsDelta;
	var playthrough:bool = false;
	while(!playthrough || steps != Vector2.ZERO):
		# Set up this iteration's steps
		var stepAmmount;
		if(stepMod != 0):
			stepAmmount = Vector2(
				min(abs(steps.x),stepMod) * sign(steps.x),
				min(abs(steps.y),stepMod) * sign(steps.y));
			steps = steps.move_toward(Vector2.ZERO,stepMod);
		else: # If stepMod is set to 0, it will only do 1 step.
			stepAmmount = steps;
			steps = Vector2.ZERO;
		# Move global position
		global_position += stepAmmount;
		# Wall Collision
		var wallData = get_wall_collision();
		if(wallData.size() > 0): # If there is a collision, continue
			wallCollision = true;
			if(floorCollision): # If grounded, stop ALL speed
				inertia = 0;
				steps = Vector2.ZERO;
			else: # If in the air, stop only the X speed
				movement.x = 0;
				steps.x = 0;
			# Lock to wall
			lock_to_normal(wallSize,wallData[0].distance,wallData[0].normal);
		# Ceiling Collision
		if(movement.y < 0 || floorCollision):
			var roofData = get_roof_collision();
			if(roofData.size() > 0):
				roofCollision = true;
				if(!floorCollision):
					var normal = get_best_normal(roofData);
					# Get shortest distance
					var distance = null;
					for i in roofData:
						if(distance == null): distance = i.distance;
						elif(i.distance < distance): distance = i.distance;
					# Lock to ground
					lock_to_normal(size.y,distance,normal);
					# Check if it's possible to land
					var angle = normal.angle_to(Vector2.UP);
					var absAngle = abs(angle);
					if(absAngle > deg_to_rad(90) && absAngle < deg_to_rad(136)):
						# Land
						inertia = movement.y * -sign(sin(angle));
						floorCollision = true;
						# Rotate Player to Normal
						surfaceNormal = normal;
						global_rotation = -angle;
					else:
						# Stop y movement
						movement.y = 0;
						steps.y = 0;
		# Floor Collision
		if(!floorCollision): # Ariel floor collision
			if(movement.y > -2):
				var floorData = get_floor_collision();
				if(floorData.size() > 0):
					var normal = get_best_normal(floorData);
					# Get shortest distance
					var distance = null;
					for i in floorData:
						if(distance == null): distance = i.distance;
						elif(i.distance < distance): distance = i.distance;
					# Lock to ground
					lock_to_normal(size.y,distance,normal);
					# Check if the ground is landable
					var angle = normal.angle_to(Vector2.UP);
					var absAngle = abs(angle);
					if(absAngle < deg_to_rad(69.0)):
						floorCollision = true;
						# Rotate Player to Normal
						surfaceNormal = normal;
						global_rotation = -angle;
						# Set player's inertia
						inertia = movement.x;
						if(abs(movement.x) < movement.y):
							if(absAngle > deg_to_rad(45)): inertia = movement.y * -sign(sin(angle));
							elif(absAngle > deg_to_rad(22.5)): inertia = movement.y * 0.5 * -sign(sin(angle));
					# Modify step to work with surface
					steps = (steps.length() * sign(inertia)) * Vector2(-surfaceNormal.y,surfaceNormal.x);
		else: # Grounded floor collision
			var floorData = get_floor_collision();
			if(floorData.size() > 0):
				# Get normals that are within cliffTolerance
				var filteredNormals = [];
				for i in floorData:
					if(i.normal.dot(surfaceNormal) > cliffTolerance): filteredNormals.append(i);
				# Find the average Normal
				var avarageNormal = Vector2.ZERO;
				if(filteredNormals.size() > 0):
					for i in filteredNormals:
						avarageNormal += i.normal;
					avarageNormal /= filteredNormals.size();
				else: # There were no filtered normals
					for i in floorData:
						avarageNormal += i.normal;
					avarageNormal /= floorData.size();
				avarageNormal = avarageNormal.normalized();
				# Get shortest distance
				var distance = null;
				for i in floorData:
					if(distance == null): distance = i.distance;
					elif(i.distance < distance): distance = i.distance;
				# Rotate player
				surfaceNormal = avarageNormal;
				var angle = surfaceNormal.angle_to(Vector2.UP);
				global_rotation = -angle;
				# Lock player to ground
				lock_to_normal(size.y,distance,surfaceNormal);
				# Modify step to work with surface
				steps = (steps.length() * sign(inertia)) * Vector2(-surfaceNormal.y,surfaceNormal.x);
			else: # No floor collisions
				floorCollision = false;
				global_rotation = 0;
		playthrough = true; # Ensure that there has been at least one playthrough of the statement
	# Disable the sensors before exitting, to ensure they are turned off.
	_disable_sensors();

func _physics_slope_repel()->void:
	inertia -= (currentPhysics.slopeFactor * sin(surfaceNormal.angle_to(Vector2.UP))) * Game.physicsDelta;

func _physics_slope_resist(pushPlayer:bool = true)->void:
	if(abs(inertia) < fallSpeed):
		var angle = surfaceNormal.angle_to(Vector2.UP);
		var absAngle = abs(angle);
		if(absAngle > deg_to_rad(45)): # Slipping range
			if(absAngle >= deg_to_rad(90)): # Falling Range
				floorCollision = false;
			# Slipping code
			if(pushPlayer): 
				horizontalControlLock = 30.0;
				inertia -= 0.5 if(angle > 0)else -0.5;

# Collision Functions

func get_floor_collision():
	var data = [];
	for i in floorRoofPercision:
		floorRaycast.position = Vector2(((float(i)) / ((float(floorRoofPercision - 1)) / 2.0) - 1.0) * size.x,0);
		floorRaycast.target_position = Vector2(0,size.y + (float(floorCollision) * 8));
		floorRaycast.enabled = true;
		floorRaycast.force_raycast_update();
		if(floorRaycast.is_colliding()): data.append({
			normal = floorRaycast.get_collision_normal(),
			distance = get_raycast_distance(floorRaycast)
		})
	floorRaycast.enabled = false;
	return data;

func get_wall_collision():
	var data = [];
	if(inertia == 0 if(floorCollision)else movement.x == 0): return [];
	# Set up and force update
	wallRaycast.position = Vector2(0,8 * int(surfaceNormal == Vector2.UP && floorCollision));
	wallRaycast.target_position = Vector2(wallSize * sign(inertia) if(floorCollision)else wallSize * sign(movement.x),0);
	wallRaycast.enabled = true;
	wallRaycast.force_raycast_update();
	# If colliding, get information
	if(wallRaycast.is_colliding()):
		data.append({
			normal = wallRaycast.get_collision_normal(),
			distance = get_raycast_distance(wallRaycast)
		})
	# Disable sensor
	wallRaycast.enabled = false;
	return data;

func get_roof_collision():
	var data = [];
	for i in floorRoofPercision:
		roofRaycast.position = Vector2(((float(i)) / ((float(floorRoofPercision - 1)) / 2.0) - 1.0) * size.x,0);
		roofRaycast.target_position = Vector2(0,-size.y);
		roofRaycast.enabled = true;
		roofRaycast.force_raycast_update();
		if(roofRaycast.is_colliding()): data.append({
			normal = roofRaycast.get_collision_normal(),
			distance = get_raycast_distance(roofRaycast)
		})
	roofRaycast.enabled = false;
	return data;

func get_best_normal(collisionData:Array)->Vector2:
	var normal = Vector2.ZERO;
	for i in collisionData:
		normal += i.normal;
	normal /= collisionData.size();
	if(normal == Vector2.ZERO): normal = Vector2.UP;
	return normal.normalized();

func get_raycast_distance(raycast:RayCast2D):
	var origin = raycast.global_transform.origin; # Grab the global origin
	var collision_point = raycast.get_collision_point(); # Get the position the raycaster hit
	var distance = origin.distance_to(collision_point); # Return the distance the raycaster went
	return distance;

func lock_to_normal(size:float,distance:float,normal:Vector2):
	var high = distance - size;
	global_position -= Vector2(high * normal.x,high * normal.y);

func _disable_sensors()->void:
	floorRaycast.enabled = false;
	wallRaycast.enabled = false;
	roofRaycast.enabled = false;

func _get_controller_input(id:int,physics:bool):
	if(physics):
		if(Controller.controllerInputsPhysics.size() <= 0): return ControllerInput.new();
		return Controller.controllerInputsPhysics[clamp(id,0,Controller.controllerInputsPhysics.size()-1)];
	if(Controller.controllerInputs.size() <= 0): return ControllerInput.new();
	return Controller.controllerInputs[clamp(id,0,Controller.controllerInputs.size()-1)];
