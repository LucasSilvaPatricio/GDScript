# classe que controla a camera do veiculo, antes de usar, passe o carro para ela
extends Node3D

class_name CameraCarro

@export_subgroup("Camera Settings")
@export var veiculo :Node3D # não esqueça de passar o carro para ela
@export var altura_da_camera :float = 1.5

@onready var camera :Camera3D = $Pivot/horizontal/vertical/SpringArm/Camera3D
@onready var pivot :Node3D = $Pivot
@onready var horizontal :Node3D = $Pivot/horizontal

# variaves do shake da camera
var camera_tremendo :bool = false :
	set(value): camera_tremendo = value
	get(): return camera_tremendo
@export var forca_da_tremedeira :float = 0.5 # forca da tremedeira da camera
var forca_da_tremedeira_tmp :float = forca_da_tremedeira
@export var suavizacao_tremedeira :float = 5.0 # valor para suavizar a tremedeira da camera
var velocidade_atual_do_carro :float = 0.0
@export var velocidade_max_para_tremer_camera :float = 5.0 # qual velocidade é preciso o veiculo está para que a camera trema ao bater no objeto
var mov_horizontal :float = 0.0
var trava_horizontal :bool = false

func _ready() -> void:
	camera.current = false

func _process(delta: float) -> void:
	if camera_tremendo:
		treme_a_camera(delta)
	velocidade_atual_do_carro = veiculo.linear_velocity.length()

func _physics_process(_delta: float) -> void:

	if veiculo.get_vehicle_enabled():
		camera.current = true
		pivot.global_position = veiculo.global_position
		pivot.global_position.y = veiculo.global_position.y + altura_da_camera
		
		if not trava_horizontal: # se a camera não tiver travada no movimento horizontal
			horizontal.rotation.y = lerp_angle(horizontal.rotation.y, veiculo.global_transform.basis.get_euler().y, 0.05)
	else:
		camera.current=false

	horizontal.rotate_y(-mov_horizontal * 0.005)
	mov_horizontal = 0
	
func treme_a_camera(delta :float) -> void:
	if forca_da_tremedeira_tmp > 0.1:
		forca_da_tremedeira_tmp = lerpf(forca_da_tremedeira_tmp, 0.0, suavizacao_tremedeira*delta)
		var shake = Vector2(randf_range(-forca_da_tremedeira_tmp,forca_da_tremedeira_tmp), randf_range(-forca_da_tremedeira_tmp,forca_da_tremedeira_tmp))
		camera.h_offset = shake.x
		camera.v_offset = shake.y
	else:
		forca_da_tremedeira_tmp = forca_da_tremedeira
		camera_tremendo = false

func activate_secondary_camera(value :bool) -> void:
	camera.current = not value
	#$Pivot/CameraSecundaria.current=value
		
func _on_area_3d_area_entered(_area: Area3D) -> void:
	if velocidade_atual_do_carro > velocidade_max_para_tremer_camera:
		camera_tremendo=true

func _on_area_3d_body_entered(_body: Node3D) -> void:
	if velocidade_atual_do_carro > velocidade_max_para_tremer_camera:
		camera_tremendo=true

func _input(event: InputEvent) -> void:
	if(event is InputEventMouseMotion):
		trava_horizontal = true
		mov_horizontal = event.relative.x

func _on_timer_timeout() -> void:
	if mov_horizontal == 0:
		trava_horizontal=false
