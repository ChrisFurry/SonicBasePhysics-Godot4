extends Resource
class_name PlayerPhysicsResource

@export var acceleration:float		= 0.046875;
@export var deacceleration:float	= 0.5;
@export var friction:float			= 0.046875;

@export var gravity:float			= 0.21875;
@export var jumpHigh:float			= 6.5;
@export var jumpLow:float			= 4;
@export var airAcceleration:float	= 0.09375;

@export var slopeFactor:float			= 0.125;
@export var slopeFactorRollUp:float		= 0.078125;
@export var slopeFactorRollDown:float	= 0.3125;

@export var rollFriction:float			= 0.0234375;
@export var rollDeacceleration:float	= 0.125;
