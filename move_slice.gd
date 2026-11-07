extends Polygon2D

class_name move_slice

var dir :Vector2 = Vector2.ZERO :
	set(value):
		dir=value
var velocity :float = 100.0

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += dir * velocity * delta
