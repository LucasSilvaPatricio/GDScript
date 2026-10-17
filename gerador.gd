@tool
extends Node3D

class_name Gerador

@export_tool_button("Spawna Casa","Add") var spawn_button = set_numero_de_casas
@export_tool_button("Limpar Tudo","Clear") var clear_button = limpar_tudo

func set_numero_de_casas():
	if owner and Engine.is_editor_hint():
		add_casa()

func limpar_tudo():
	if Engine.is_editor_hint():
		for child in get_children():
			remove_child(child)
			child.queue_free()
	
		posicao_atual=global_position
		posicao_atual.z = 0
		posicao_atual.x = 0	

@export_subgroup("Casas")
@export var casas :Array[PackedScene]

var posicao_atual :Vector3 
	
func _enter_tree() -> void:
	posicao_atual = global_position
	posicao_atual.z = 0
	posicao_atual.x = 0
		
func add_casa():
	var casa_sorteada :Node3D = sorteia_casa().instantiate()
	add_child(casa_sorteada)
	casa_sorteada.position = posicao_atual
	var root = get_tree().edited_scene_root
	if root:
		casa_sorteada.owner = root
	else:
		print("Aviso: edited_scene_root é null.")
	
	posicao_atual.x = 0.0
	posicao_atual.z += casa_sorteada.get_child(0).mesh.get_aabb().size.z
	
func sorteia_casa() -> PackedScene:
	return casas[RandomNumberGenerator.new().randi_range(0, len(casas)-1)]

func remover_tudo() -> void:
	for casa in get_children():
		remove_child(casa)
		casa.queue_free()
	posicao_atual = global_position
