extends Polygon2D

class_name dispersar

var dir :Vector2 = Vector2.ZERO:
	set(value):
		dir = value
var velocidade :float = 150.0


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position +=(dir*velocidade*delta)
	
