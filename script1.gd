extends Sprite2D

var velocidade = 0.005
var amplitude = 1.0
var dir :Vector2 = Vector2.ZERO

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	var x = cos(Time.get_ticks_msec()*velocidade)*amplitude
	var y = sin(Time.get_ticks_msec()*velocidade)*amplitude
	dir =  Vector2(x*delta, y*delta).normalized()
	#position = dir
	rotation = dir.angle()
	queue_redraw()
	
func _draw() -> void:
	draw_line(position,Vector2.UP*100.0,Color.YELLOW,10.0)
	
