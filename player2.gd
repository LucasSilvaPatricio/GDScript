extends CharacterBody3D

class_name Player

const VELOCIDADE_DE_CORRIDA :float = 15.0
const VELOCIDADE_DE_CAMINHADA :float = 2.0
const SENSIBILIDADE_DO_MOUSE :float = 0.005

@export_group("Player Settings")
@export var camera :Camera3D
@export var animation_tree :AnimationTree
@export var horizontal_camera :Node3D
@export var armature :Node3D
@export var animation_player :AnimationPlayer

var speed :float = VELOCIDADE_DE_CAMINHADA
const JUMP_VELOCITY = 4.5

# variaveis de estado
var finished_entering :bool = false # terminou de entrar no carro?
var finished_exit_car :bool = false
var _control_enabled :bool = true # indica se o controle do personagem está ativado
var anim_playback :AnimationNodeStateMachinePlayback

var using_pistol :bool = false

@onready var script_tree :AnimationtreeController = $script_tree

func _ready() -> void:
	anim_playback = animation_tree.get("parameters/playback")
	floor_block_on_wall=false

func _process(_delta: float) -> void:
	using_pistol=input_handle()
	if Input.is_action_just_pressed("atirar") and get_player_enabled():
		script_tree.current_status = script_tree.status.SHOOT

func _physics_process(delta: float) -> void:
	gravidade(delta)
	jump()
	move_player()

func move_player() -> void: # função que movimenta o player
	var horizontal :Node3D = horizontal_camera
	var horizontal_y = atan2(horizontal.global_transform.basis.z.x,horizontal.global_transform.basis.z.z)
	var input_dir := Input.get_vector("ui_right","ui_left","ui_down","ui_up")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized().rotated(Vector3.UP, horizontal_y)
		
	if direction:
		script_tree.current_status = script_tree.status.WALK
		armature.rotation.y=atan2(direction.x, direction.z)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		script_tree.current_status = script_tree.status.IDLE
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	if Input.is_action_pressed("mirar"):
		armature.rotation.y = horizontal_y
		
	controls_velocity()
	move_and_slide()

func input_handle() -> bool:
	if Input.is_action_just_pressed("mirar"):
		script_tree.pistol_active=true
	if Input.is_action_just_released("mirar"):
		script_tree.pistol_active=false	
	return script_tree.pistol_active
	
func gravidade(delta :float) -> void: # Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

func jump() -> void: # Handle jump.
	if is_jump():
		velocity.y = JUMP_VELOCITY
		script_tree.current_status = script_tree.status.JUMP
		
func controls_velocity() -> void:
	speed = VELOCIDADE_DE_CORRIDA if Input.is_action_pressed("correr") and velocity.length() > 0 else VELOCIDADE_DE_CAMINHADA
	if speed == VELOCIDADE_DE_CORRIDA:
		script_tree.current_status = script_tree.status.RUNNING
		
func enter_vehicle() -> void: # função publica para invocar entrada no veiculo.
	script_tree.current_status = script_tree.status.ENTER_CAR
	finished_exit_car = false

func exit_vehicle(trigger :TriggerPortaVeiculo) -> void: # função publica para invocar saida do veiculo.
	global_position = Vector3(global_position.x,trigger.get_exit_position().global_position.y,global_position.z)
	script_tree.current_status = script_tree.status.EXIT_CAR

	finished_entering = false

func get_player_enabled() -> bool: # para saber se o controller do player tá ativado
	return _control_enabled
	
func set_player_enabled(value :bool) -> void: # controla estado do controle do player
	self._control_enabled = value
	camera.current = value
	set_physics_process(value)
	
func reset_rotation(rot :Vector3) -> void:
	rotation_degrees = rot

func reset_all_rotations() -> void: # reseta todas as rotações
	rotation_degrees.y = 0
	armature.rotation_degrees.y = 0

func lock_anim_in_driving_position() -> void: # trava o player na animação de sentado
	script_tree.current_status = script_tree.status.SITTING
	rotation_degrees.y = 0

func finished_getting_into_the_car() -> bool: # consulta de o player terminou de entrar no carro
	return finished_entering

func finished_getting_out_of_the_car() -> bool:
	return finished_exit_car

func is_running_with_pistol() -> bool:
	return script_tree.pistol_active #anim_playback.get_current_node().to_lower() == "pistol_run"

func aiming_with_a_gun() -> bool: # se esta mirando
	return using_pistol

func is_jump() -> bool:
	return true if Input.is_action_just_pressed("ui_accept") and is_on_floor() else false
	
func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name.to_lower() == "enter_car":
		finished_entering = true
	
	if anim_name.to_lower() == "exit_car":
		finished_exit_car = true
