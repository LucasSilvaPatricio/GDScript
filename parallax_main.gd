extends Control

@onready var background_1 :TextureRect = $texture
@onready var background_2 :TextureRect = $texture2
@onready var centro = Vector2.ZERO 

var amplitude = 5.0
var frequencia = 0.5
var time = 0.0

func _process(delta: float) -> void:
	background_1.global_position = centro + Vector2(cos(time*frequencia) , sin(time*frequencia))*amplitude
	background_2.global_position = (centro+ Vector2(sin(time*frequencia) ,0)*amplitude)*-1
	time += delta
	
func _on_jogar_button_up() -> void:
	get_tree().change_scene_to_packed(load("res://scenes/menu_ui.tscn"))
