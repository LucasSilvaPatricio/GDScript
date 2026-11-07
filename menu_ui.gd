extends Control

func _on_texture_button_button_up() -> void:
	get_tree().change_scene_to_packed(load("res://scenes/main.tscn"))

func _on_voltar_button_button_up() -> void:
	get_tree().change_scene_to_packed(load("res://scenes/main_ui.tscn"))
