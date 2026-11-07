extends Node2D

class_name Bullet

@export var bullet_speed :float = 100.0 :
	set(value):
		bullet_speed = value

var dir :Vector2 = Vector2.ZERO :
	set(value):
		dir = value
		rotation = dir.angle()
var posicao :Vector2 = Vector2.ZERO :
	set(value):
		global_position = value

## força do dano que a bala causa
@export var damager_force :float = 22.0 : 
	get:
		return damager_force
			
func _process(delta: float) -> void:
	translate(dir*bullet_speed*delta)
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("DestructibleObject"):
		queue_free()
