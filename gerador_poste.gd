@tool
extends Node3D

class_name gerador_poste

@export var postes :Array[PackedScene]
@export var fiacao :Array[PackedScene]
@export var altura :float = 5.0
@export_tool_button("add") var btn := add_poste
@export_tool_button("fiacao") var btn2 := add_fiacao

var posicoes :Array[Node3D] = []

func _ready() -> void:
	pass # Replace with function body.

func add_poste():
	var poste :Node3D = postes[0].instantiate()
	add_child(poste)
	var scene_root = get_tree().edited_scene_root
	poste.owner = scene_root
	poste.position = Vector3.ZERO

var diferenca :float = 0.0

var root_fiacao :Node3D = null

func add_fiacao():
	if get_children().is_empty() or not get_children()[0].is_in_group("Postes"):
		root_fiacao = Node3D.new()
		add_child(root_fiacao)
		root_fiacao.global_transform.origin = Vector3.ZERO
		root_fiacao.quaternion = Quaternion.IDENTITY
		root_fiacao.add_to_group("Postes")
		root_fiacao.owner = get_tree().edited_scene_root
	else:
		root_fiacao = get_children()[0]
		
	var anterior :Node3D = null
	for pos in get_children():
		if anterior != null:
			#var pos = get_children()[1]
			var fio :MeshInstance3D = fiacao[0].instantiate()
	
			root_fiacao.add_child(fio)
			fio.owner = get_tree().edited_scene_root
			diferenca = anterior.global_position.distance_to(pos.global_position)
			#rotacao = (ponto2.global_position - ponto1.global_position).normalized()
	
			fio.global_position = (anterior.global_position + pos.global_position)/2.0
			fio.look_at(pos.global_position,Vector3.UP)
	
			fio.scale = fio.scale * Vector3(1,1,diferenca/fio.mesh.get_aabb().size.z)
			#print(diferenca)
			#DebugDraw3D.draw_line(anterior.global_position, pos.global_position,Color.RED,100.0)
					
		anterior = pos
	
	pass
