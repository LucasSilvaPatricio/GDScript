extends Node3D

class_name TriggerPortaVeiculo

var _hud_veiculo :Control = null
var _player_in_trigger :bool = false
var _player :CharacterBody3D = null

@export_category("Veiculo")
@export var veiculo :RigidBody3D
@export var posicao_do_banco_do_carro :Node3D
## posicao de sair do player
@export var exit_position :Node3D
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("entrar") and _player_in_trigger: # se o player estiver na porta do veiculo pedindo para entrar
		entrar_no_veiculo()
		
	if Input.is_action_just_pressed("sair") and veiculo.get_vehicle_enabled():
		sair_do_carro()
		
func _on_trigger_body_entered(player: CharacterBody3D) -> void: # detecta sempre que um player entrar, mask collision ativada apenas para um objeto player;
	_player_in_trigger = true
	_player = player
	if player.get_player_enabled(): # só mostra a hud de entrada, se não está dirigindo no momento;
		load_hud()
		
func _on_trigger_body_exited(player: CharacterBody3D) -> void:
	_player_in_trigger = false
	remove_hud()
		
func fade() -> void:
	$ColorRectFade.visible=true
	$AnimationPlayer.play("fade")

func entrar_no_veiculo() -> void:
	_player.set_player_enabled(false) # desabilita o controle do player
	_player.enter_vehicle()
	veiculo.activate_secondary_camera()
	_player.reset_all_rotations()
	_player.global_position = $ponto_de_entrada.global_position
	_player.global_rotation_degrees.y = $ponto_de_entrada.global_rotation_degrees.y - 90
	remove_child(_hud_veiculo)
	_hud_veiculo.queue_free()
	
	while not _player.finished_getting_into_the_car():
		await get_tree().process_frame
	
	move_player_to_car()	
	veiculo.set_vehicle_enabled(true)
		
	#await get_tree().create_timer(1.2).timeout
	#veiculo.open_door() # abre a porta do carro
	#await get_tree().create_timer(2.5).timeout
	#veiculo.close_door() # fecha a porta do carro
		
func sair_do_carro() -> void:
	_player.rotation_degrees.y = 0
	veiculo.activate_secondary_camera()
	_player.exit_vehicle(self)
	veiculo.set_vehicle_enabled(false) # para não dirigir mais o carro
	
	while not _player.finished_getting_out_of_the_car():
		await get_tree().process_frame
	
	move_player_to_world()
	
	_player.global_position = $ponto_de_entrada.global_position
	_player.set_player_enabled(true)
	_player=null

func load_hud() -> void:
	_hud_veiculo = load("res://HUD/HUDVeiculo.tscn").instantiate()
	add_child(_hud_veiculo)
	
func remove_hud() -> void:
	if is_instance_valid(_hud_veiculo):
		remove_child(_hud_veiculo)

func move_player_to_car() -> void: # move o jogador para dentro do carro
	_player.get_parent().remove_child(_player)
	posicao_do_banco_do_carro.add_child(_player)
	_player.position = Vector3.ZERO
	_player.lock_anim_in_driving_position()

func move_player_to_world() -> void:
	_player.get_parent().remove_child(_player)
	get_tree().current_scene.add_child(_player)
	_player.position = Vector3.ZERO

func get_exit_position() -> Node3D:
	return exit_position
