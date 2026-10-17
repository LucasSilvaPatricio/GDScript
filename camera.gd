extends Node3D

class_name Camera

## adicione o rigidibody do helicoptero	
@export var helicoptero :RigidBody3D 

func _physics_process(_delta: float) -> void:
	global_position = helicoptero.global_position
	#global_transform = global_transform.interpolate_with(helicoptero.global_transform, 0.05)
	
