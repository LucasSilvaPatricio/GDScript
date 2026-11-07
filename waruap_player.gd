extends CharacterBody2D

class_name Player

signal player_mudou_de_tile

@export var tilemap :TileMapLayer
## canhao com mira a mira travada, canhao normal apenas atira para frente
@export_enum("CANHAO_COM_MIRA","CANHAO_NORMAL") var tipo :int = 1
enum tipo_canhao {CANHAO_COM_MIRA=0, CANHAO_NORMAL=1}
@export var velocidade = 200.0
## adicione a sprite da mira aqui
@export var ponteiro :Sprite2D
@export var velocidade_de_disparo :float = 0.09

@onready var timer_node :Timer = $Timer
@onready var marker_pivot :Node2D = $markerPivot
@onready var progress_health :ProgressBar = $CanvasLayer/ProgressBar
@onready var tiro_som :AudioStreamPlayer = $Tiro
@onready var motor_som :AudioStreamPlayer = $motor_som

var health :float = 100.0

const PITCH_SCALE = 0.3

@export var camera :Camera2D

enum tipo_de_ponteiro {BRANCO=0,VERDE=1, VERMELHO=2}
var ponteiros_region :Array[Rect2] = [
	Rect2(617.0,57.0,30.0,30.0), # ponteiro branco x,y,w,h
	Rect2(617.0,122.0, 30.0,30.0), # ponteiro verde x,y,w,h
	Rect2(617.0, 89.0, 30.0, 30.0), # ponteiro vermelho x,y,w,h
]

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	motor_som.play(0.0)
	progress_health.value = health
	ponteiro.top_level = true
	timer_node.wait_time = velocidade_de_disparo
	camera.ignore_rotation = false
	ponteiro.visible = true if tipo == tipo_canhao.CANHAO_COM_MIRA else false

func _process(delta: float) -> void:

		
	camera.global_position = global_position
	
	var pitch_final :float = 0.5 + velocity.length() * PITCH_SCALE * delta
	motor_som.pitch_scale = lerpf(motor_som.pitch_scale, pitch_final, 0.01)
	
	var direcao_y = clamp(Input.get_axis("ui_up","ui_down"), -1, 0)

	var direcao :Vector2 = (get_global_mouse_position()-global_position).normalized() # direção para disco voador
	var movimento = (direcao * -direcao_y).normalized()
	velocity =  velocity.lerp(movimento * velocidade,0.1) #velocidade = deslocamento
	
	move_and_slide()
	
	processa_entrada_de_input()
	
	if tipo == tipo_canhao.CANHAO_COM_MIRA:
		marker_pivot.look_at(ponteiro.global_position) #trava mira em um ponto
	

	$PivotSkin.look_at(get_global_mouse_position())
	
	alerta_ponteiro_fora_da_tela()
	queue_redraw()

var mira_travada = false
var posicao_temporaria_do_mouse_travado :Vector2 = Vector2.ZERO

func processa_entrada_de_input() -> void:
	if not mira_travada:
		ponteiro.global_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("click_left"):
		posicao_temporaria_do_mouse_travado = get_global_mouse_position()
		ponteiro.global_position = posicao_temporaria_do_mouse_travado
		ponteiro.region_rect = ponteiros_region[tipo_de_ponteiro.VERDE]
		timer_node.start()
		mira_travada = true
		
	if Input.is_action_just_pressed("click_right"):	
		ponteiro.region_rect = ponteiros_region[tipo_de_ponteiro.BRANCO]
		mira_travada=false
		timer_node.stop()

func fire_bullet() -> void: # disparar
	tiro_som.play(0.0)
	var bullet_instance :Bullet = $selecao_de_bullet.get_bullet()
	bullet_instance.posicao = marker_pivot.get_child(0).global_position
	
	var direcao = transform.x
	if tipo != tipo_canhao.CANHAO_NORMAL:
		direcao = -(global_position-ponteiro.global_position).normalized()
		
	bullet_instance.dir = direcao
	
	bullet_instance.bullet_speed=650.0
	bullet_instance.add_to_group("BulletPlayer")
	get_parent().add_child(bullet_instance)
	Events.tiro_disparado.emit() # indicar que o player disparou um tiro
	
func _draw() -> void:
	pass

func _on_timer_timeout() -> void:
	fire_bullet()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("BulletEnemy"):
		health -= area.damager_force
		progress_health.value = health
		$DanoSom.play(0.0)
		shake()

var amplitude = 5.0
var frequencia = 200.0

func shake() -> void:
	if camera == null:
		return
		
	var time = 0
	while time < 0.5:
		camera.offset = Vector2(cos(time+frequencia),sin(time+frequencia))*randf_range(-1,1)*amplitude
		camera.rotation = deg_to_rad(randf_range(-2,2))
		time+=get_process_delta_time()
		await get_tree().process_frame
	camera.rotation=deg_to_rad(0.0)
	time=0.0

var mira_fora_da_tela :bool = false
@onready var direcao_sprite :Sprite2D = $markerPivot/Marker2D/LocalDaMira

func alerta_ponteiro_fora_da_tela() -> void:
	direcao_sprite.visible = true if mira_fora_da_tela else false
		
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	mira_fora_da_tela=true

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	mira_fora_da_tela=false

# o player vai ficar pedindo atualização da hud em relação aos dados da area
# atual
var cell_anterior :Vector2i = Vector2i.ZERO

func _on_process_loop_timeout() -> void:
	var cell_atual = tilemap.local_to_map(tilemap.to_local(global_position))
	if cell_atual!=cell_anterior:
		player_mudou_de_tile.emit()
		cell_anterior=cell_atual
		pass
