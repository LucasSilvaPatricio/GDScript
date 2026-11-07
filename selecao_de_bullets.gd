extends Node
		
var bullets = [
	"res://scenes/bullet_type_1.tscn",
	"res://scenes/bullet_type_2.tscn",
	"res://scenes/bullet_type_3.tscn"
]

@export_enum("bullet_type_1","bullet_type_2","bullet_type_3") var bullet :int = 0

func get_bullet() -> Bullet:
	return load(bullets[bullet]).instantiate()
