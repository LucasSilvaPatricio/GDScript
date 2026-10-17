@tool
extends Node3D

class_name path_script

@onready var path :Path3D = $Path3D
## distancia entre objetos
@export var distancia_entre :float = 5.0
@export var objetos :Array[PackedScene]

@export var inverter_dir :bool = false
@export_tool_button("add","Add") var add_button = instanciar_casas
@export_tool_button("clear all","Clear") var clear_button = clear_all
@export_tool_button("bake","ActionPaste") var bake_button = bake
var curva :Curve3D
var distancia_atual :float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		resetar()
		
# instancia casas automaticamente
func instanciar_casas():
	if get_child_count() > 1:
		resetar()
		clear_all()
		
	while distancia_atual < path.curve.get_baked_length():
		var obj_instance :Node3D = get_random_obj()
		add_child(obj_instance)
		obj_instance.owner = get_tree().edited_scene_root
		var pos = path.curve.sample_baked_with_rotation(distancia_atual)
		if inverter_dir:
			pos.basis = pos.basis.rotated(Vector3.UP, PI)
		else:
			pos.basis = pos.basis.rotated(Vector3.UP,0.0)
		obj_instance.transform = pos
		distancia_atual+=distancia_entre
		
# remove todas as casas
func clear_all() -> void:
	for ch in get_children():
		if ch is not Path3D:
			remove_child(ch)
			ch.queue_free()
	resetar()

func get_random_obj() -> Node3D: # retorna um objeto aleatorio
	return objetos[randi_range(0, len(objetos)-1)].instantiate()

# reseta variaveis
func resetar() -> void:
	distancia_atual = 0.0
	curva = path.curve
	
@onready var root_node : = self
var transf = null
func bake() -> void:
	for ch in get_children():
		if ch is not Path3D:
			transf = ch.global_transform
			remove_child(ch)
			root_node.add_child(ch)
			ch.global_transform = transf
			ch.owner = get_tree().edited_scene_root
	
	remove_child(path)
	path.queue_free()
	set_script(null)

# chamado quando ctrl + s
func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_POST_SAVE:
		pass#if Engine.is_editor_hint():
			#resetar()
