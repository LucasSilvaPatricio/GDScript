extends Node2D

class_name Bullet

var velocidade :float = 50.0
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	translate(Vector2.UP*velocidade*delta)
