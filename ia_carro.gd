# use esse objeto como pai, ele vai conter os checkpoints dentro e os carros
@tool

extends Node3D

class_name SpawnCar

@export_tool_button("Visible Checkpoints","Add") var vsb = _visible
@export_category("Quant Spawn")
@export var _quantidade_veiculos :int = 1

@export_category("Settings I.A")
@export var enable_spawn_vehicle :bool = true # faz com que o spawn drope um veiculo
#@onready var carro :BotCarro = preload("res://objetos/ia_carro/carrinho.tscn").instantiate()
@onready var childrens :Array = get_children() # contem os checkpoints
@export_tool_button("Add","Add") var btn = _add_checkpoint
@export_tool_button("Clear", "Clear") var clr = _clear_checkpoints

@export_category("Conectores")
@export var _spawn_conectados :Array[SpawnCar] # vai conter os spawns em que ele estará ligado

var _checkpoints :Array
var _checkpoint_atual :int = 0
var _count_car :int = 0

func _ready():
	_load_checkpoints_in_game_mode() # carrega todos os checkpoints menos o veiculo na cena.
	
func _process(_delta :float) -> void:
	_gizmos()
		
func _load_checkpoints_in_game_mode() -> void: # carrega os checkpoints quando iniciar o jogo
	for value in get_children():
		if value.is_in_group("_checkpoint"):
			_checkpoints.append(value)
							
func _spawn_car() -> void: # spawna carros
	if enable_spawn_vehicle and _count_car < _quantidade_veiculos: # se tiver marcado para dropar carros então spawna até uma certa quantidade
		var carro = load("res://objetos/veiculos/carros/ford_fusion.tscn").instantiate()
		add_child(carro)
		carro = carro.get_child(0)
		carro.set_values_checkpoints_spawn(_checkpoints, _spawn_conectados)
		carro.global_position = transform.origin
		carro.global_rotation = Vector3(0,-90,0)
		_count_car+=1

func get_all_checkpoints() -> Array: # public get
	return _checkpoints

func get_all_spawns() -> Array: # public get
	return _spawn_conectados

# ============== funções executadas no modo editor ============== #

func _load_checkpoints_in_editor_mode() -> void:
	_reset_values()
	if Engine.is_editor_hint() and not get_children().is_empty() or true:
		for child in get_children():
			if child.is_in_group("_checkpoint"): # _ indica que é um objeto usado no modo editor
				_checkpoints.append(child)

func _add_checkpoint():
	var check :Node3D = load("res://objetos/ia_carro/checkpoint.tscn").instantiate()
	check.transform.origin = transform.origin
	add_child(check)
	if get_tree().edited_scene_root:
		check.owner = get_tree().edited_scene_root
	_load_checkpoints_in_editor_mode()

func _clear_checkpoints() -> void:
	for value in _checkpoints:
		if value.is_in_group("_checkpoint"):
			remove_child(value)
			value.queue_free()
	_reset_values()
	
func _reset_values() -> void:
	_checkpoints.clear()
	_checkpoint_atual = 0

func _visible() -> void:
	for value in get_children():
		if value.is_in_group("_checkpoint"):
			if value.visible:
				value.visible=false
			else:
				value.visible=true
		
func _gizmos() -> void:
	if (Engine.is_editor_hint() and not _checkpoints.is_empty()):
		DebugDraw3D.draw_gizmo(transform,Color.RED, true, 0)
		DebugDraw3D.draw_line(global_position, _checkpoints[0].global_position, Color.GREEN, 0)
		for i in range(0,_checkpoints.size()):
			if (i+1 < _checkpoints.size()):
				DebugDraw3D.draw_line(_checkpoints[i].global_position, _checkpoints[i+1].global_position, Color.GREEN, 0)
	
		for spawn in _spawn_conectados:
			DebugDraw3D.draw_line(_checkpoints[_checkpoints.size() - 1].global_position, spawn.position, Color.YELLOW, 0)

# sempre que acabar o tempo de spawn, ele spawna outro veiculo
func _on_timer_timeout() -> void:
	_spawn_car()
