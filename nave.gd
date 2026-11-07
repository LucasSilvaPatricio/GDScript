extends Node2D

class_name Nave

var velocidade :float = 100.0
var direcao :Vector2 = Vector2.ZERO :
	set(value):
		direcao = value
		
var bullets = [
	"res://scenes/bullet_type_1.tscn",
	"res://scenes/bullet_type_2.tscn",
	"res://scenes/bullet_type_3.tscn"
]

@export var atacar :bool = false
@export var armas_marker :Array[Marker2D]
@export_enum("bullet_type_1","bullet_type_2","bullet_type_3") var bullet :int = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	#global_position += direcao * velocidade * delta
	if atacar:
		disparar_balas()
		
func disparar_balas() -> void:
	for marker in armas_marker:
		var bullet_instance :Bullet = $selecao_de_bullet.get_bullet()
		bullet_instance.posicao = marker.global_position
		bullet_instance.dir = direcao
		bullet_instance.bullet_speed = velocidade
		bullet_instance.add_to_group("BulletPlayer")
		get_parent().add_child(bullet_instance)
	
	
