@tool
extends EditorPlugin

@onready var pos :Vector3 = Vector3.ZERO

func _enter_tree() -> void:
	add_custom_type("Pin","Node3D",preload("res://addons/pin/script.gd"),preload("res://addons/pin/pin_icon.png"))
	pass

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("Pin")
