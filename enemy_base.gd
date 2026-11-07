@tool
extends RigidBody2D

class_name enemy_base

@export var pontuacao_do_inimigo :int = 100:
	get: return pontuacao_do_inimigo
@onready var base_sprite :AnimatedSprite2D = $base
#@onready var torreta_sprite :AnimatedSprite2D = $torreta/torreta
@onready var progress_health :ProgressBar = $ProgressBar

## forca do motor
@export var speed_force :float = 50.0
## velocidade maxima
@export var speed_limit :float = 50.0
## velocidade do giro da base
@export var base_speed :float = 2.0 # velocidade do giro da base
## velocidade do giro da torreta
@export var torret_speed :float = 3.0
## velocidade de disparos
@export var firing_rate :float = 0.5 # quantos disparos por segundos

@onready var torreta :Node2D = $torreta
@onready var anim :AnimationPlayer = $anim
@export var som_explosao :AudioStreamPlayer
@export var som_hit :AudioStreamPlayer
var health :float = 100.0 # vida
var current_health :float = health # vida atual

var attack = false
var target :Area2D = null

var spawn_position :Vector2 

const ANIM_RUN = "run"
const ANIM_IDLE = "idle"

var dir :Vector2 = Vector2.ZERO #Vector2(target.global_position-global_position).normalized()
var target_distance :float = 0.0 #target.global_position.distance_to(global_position) # distancia entre o tanque e o player
var spawn_position_distance :float = 0.0 #global_position.distance_to(spawn_position)
var spawn_position_direction :Vector2 = Vector2.ZERO # (spawn_position-global_position).normalized()

const ANG_MIN :float = 0.90 # se a direção estiver acima de 0.90 mover em direção ao alvo
const MARGIN_CHECKPOINT = 0.5 # para não ir exatamente para posição 0,0 do checkpoint
var MINIMUN_DISTANCE_FROM_PLAYER :float = 100.0 # distancia minima do player, para não ficar exatamente em cima da posição do player

var destroyed :bool = false
@export var inimigo_movel :bool = false

@export var slices_value :float = 500.0

func _ready() -> void:
	base_sprite.play("run")
	if Engine.is_editor_hint():
		set_process(false)
		set_physics_process(false)
		return
		
	spawn_position = global_position
	target = get_tree().get_first_node_in_group("Player")
	$Timer.wait_time = firing_rate
	
	progress_health.value = health
	
	#_destroy_effect()
	
func _process(_delta: float) -> void:
	if anim != null:
		controladora_de_animacoes()
	
func _physics_process(delta: float) -> void:

	dir = (target.global_position-global_position).normalized()
	target_distance = target.global_position.distance_to(global_position) # distancia entre o tanque e o player
	spawn_position_distance = global_position.distance_to(spawn_position)
	spawn_position_direction = (spawn_position-global_position).normalized()
	
	movimentacao_da_torreta(delta)
	
	if inimigo_movel:
		movimentacao_da_base(delta)

func controladora_de_animacoes() -> void:
	
	var anim_name :String = ANIM_IDLE
	
	if abs(transform.x.dot(dir)) < ANG_MIN and attack:
		anim_name = ANIM_RUN
	
	if target_distance > MINIMUN_DISTANCE_FROM_PLAYER and attack:
		anim_name = ANIM_RUN
	
	if spawn_position_distance > MARGIN_CHECKPOINT and not attack:
		anim_name = ANIM_RUN
	
	anim.play(anim_name)
	
func movimentacao_da_torreta(delta :float) -> void:
	if attack:
		torreta.global_rotation = lerp_angle(torreta.global_rotation,dir.angle(), delta * torret_speed)
		
	else:
		torreta.rotation = lerp_angle(torreta.rotation,2.0*PI, delta * torret_speed)
		
func movimentacao_da_base(delta :float) -> void:
	if attack:
			global_rotation = lerp_angle(global_rotation,dir.angle(), delta * base_speed) # base_torque
			
	if abs(transform.x.dot(dir)) > ANG_MIN and attack and target_distance > MINIMUN_DISTANCE_FROM_PLAYER: # se o eixo x do tanque tiver alinhado com a direção para o inimigo 0.999 = alinhado
		apply_force(dir * speed_force * mass * (linear_damp))

	elif spawn_position_distance > MARGIN_CHECKPOINT and not attack:
		global_rotation = lerp_angle(global_rotation,spawn_position_direction.angle(), delta * base_speed)
		apply_force(spawn_position_direction * speed_force * mass * (linear_damp))
	else:
		linear_velocity = Vector2.ZERO
		angular_velocity =  0.0		
	
func firing_bullet() -> void:
	var bullet_instance :Bullet = $selecao_de_bullet.get_bullet()
	bullet_instance.posicao = torreta.get_node("ponto").global_position
	bullet_instance.dir = Vector2(cos(torreta.global_rotation), sin(torreta.global_rotation)).normalized()
	bullet_instance.add_to_group("BulletEnemy")
	get_parent().get_parent().add_child(bullet_instance)
	
func _destroy_effect(sprite :AnimatedSprite2D) -> void:
	
	var sprite_size_x = sprite.sprite_frames.get_frame_texture(sprite.animation,sprite.frame).get_size().x * sprite.scale.x
	var sprite_size_y = sprite.sprite_frames.get_frame_texture(sprite.animation,sprite.frame).get_size().y * sprite.scale.y
	
	var polygon_vertex :PackedVector2Array = PackedVector2Array([
		Vector2(0,0),
		Vector2(sprite_size_x,0),
		Vector2(sprite_size_y,sprite_size_y),
		Vector2(0,sprite_size_y)
	]) 
	
	var padding :float = 5.0
	
	for i in range(0,slices_value-1):
		var vertex_x = randf_range(padding,(sprite_size_x)-padding)
		var vertex_y = randf_range(padding,(sprite_size_y)-padding)
		var vertex = Vector2(vertex_x,vertex_y)
		polygon_vertex.append(vertex)
		pass
		
	var new_polygon = Geometry2D.triangulate_delaunay(polygon_vertex)
	
	for k in range(0, new_polygon.size(), 3):
		
		var _polygon :Polygon2D = Polygon2D.new()
		_polygon.polygon = polygon_vertex
		_polygon.texture_repeat=CanvasItem.TEXTURE_REPEAT_ENABLED
		_polygon.texture = sprite.sprite_frames.get_frame_texture(sprite.animation,sprite.frame)
		_polygon.texture_scale=Vector2.ONE/sprite.scale
		_polygon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_polygon.rotation = sprite.global_rotation
		_polygon.offset = -Vector2(sprite_size_y/2.0,sprite_size_y/2.0)
		_polygon.top_level=true
		_polygon.global_position = sprite.global_position
		
		_polygon.polygon = PackedVector2Array([
			polygon_vertex[new_polygon[k]],
			polygon_vertex[new_polygon[k+1]],
			polygon_vertex[new_polygon[k+2]]
		])
		
		_polygon.uv = PackedVector2Array([
			polygon_vertex[new_polygon[k]],
			polygon_vertex[new_polygon[k+1]],
			polygon_vertex[new_polygon[k+2]]
		])
		
		var center_of_vertex = (polygon_vertex[new_polygon[k]]+polygon_vertex[new_polygon[k+1]]+polygon_vertex[new_polygon[k+2]])/3.0
		
		_polygon.set_script(load("res://scripts/move_slice.gd"))
		_polygon.dir = (_polygon.to_global(center_of_vertex-Vector2(sprite_size_y/2.0,sprite_size_y/2.0))-global_position).normalized()
		
		call_deferred("add_child",_polygon)
	
func _on_timer_timeout() -> void:
	if not destroyed:
		firing_bullet()

func _on_campo_de_attaque_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		attack = true
		$Timer.start()
	
func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		attack = false
		$Timer.stop()

func _destroy() -> void:
	
	Events.inimigo_destruido.emit(self)
	base_sprite.visible=false
	torreta.get_node("torreta").visible=false
	progress_health.visible=false
	_destroy_effect(base_sprite)
	_destroy_effect(torreta.get_node("torreta"))
	if som_explosao != null:
		som_explosao.play(0.0)
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("BulletPlayer"):
		if not destroyed:
			if som_hit != null :
				som_hit.play(0.0)
				
			health -= area.damager_force
			progress_health.value = health
		
			if health <= 0.0:
				
				_destroy()
				destroyed=true
				
			
