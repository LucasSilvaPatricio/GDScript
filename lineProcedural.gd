extends Line2D

var velocidade = 500.0

func _ready() -> void:
	velocidade = randf_range(200.0, 900.0)

func _process(delta: float) -> void:
	for i in range(points.size()):
		var points_copy = points
		points_copy[i].y = sin(Time.get_ticks_msec()/velocidade+i)*20.0
		points_copy[i] = points_copy[i] + get_global_mouse_position()
		points = points_copy
		
