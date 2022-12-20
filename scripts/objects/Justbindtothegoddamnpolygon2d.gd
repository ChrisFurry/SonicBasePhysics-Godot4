extends CollisionPolygon2D
# Get objects
@onready var poly = $Polygon2D;

func _ready():
	poly.polygon = polygon;
