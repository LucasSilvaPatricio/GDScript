# classe responsavel por gerenciar os trigger, areas e cameras do player
# coloque ela dentro do characterbody3d
extends Node3D

class_name AuxiliarPlayer

@onready var Alvo: CharacterBody3D = $".."
@onready var AreaPlayer :Area3D = $AreaPlayer
@onready var TriggerPlayer :Area3D = $TriggerPlayer
@onready var CameraPivot :Node3D = $camera

func seguir(obj :Node3D, target: Vector3, ) -> void:
	obj.global_position = target

func _process(_delta: float) -> void:
	seguir(AreaPlayer, Alvo.global_position, )
	seguir(TriggerPlayer, Alvo.global_position, )
	seguir(CameraPivot, Alvo.global_position)
