@tool
extends RigidBody2D

class_name Tank

@onready var base_sprite :Sprite2D = $base
@onready var torreta_sprite :Sprite2D = $torreta/torreta

@export_color_no_alpha var cor_da_base :Color = Color.WHITE :
	set(value):
		cor_da_base = value
		if Engine.is_editor_hint() and base_sprite != null:
				base_sprite.set_instance_shader_parameter("modulate", cor_da_base)
		
@export_color_no_alpha var cor_da_torreta :Color = Color.WHITE :
	set(value):
		cor_da_torreta = value
		if Engine.is_editor_hint() and torreta_sprite != null:
				torreta_sprite.set_instance_shader_parameter("modulate", cor_da_torreta)
## forca do motor
@export var speed_force :float = 50.0
## velocidade maxima
@export var speed_limit :float = 50.0
@export_enum("bullet_1","bullet_2") var bullet :int
## velocidade do giro da base
@export var base_speed :float = 2.0 # velocidade do giro da base
## velocidade do giro da torreta
@export var torret_speed :float = 3.0
## velocidade de disparos
@export var firing_rate :float = 0.5 # quantos disparos por segundos

@onready var torreta :Node2D = $torreta
@onready var anim :AnimationPlayer = $anim


var attack = false
var target :Area2D = null
var bullets_type = ["res://scenes/bullet_type_1.tscn","res://scenes/bullet_type_2.tscn"]

var max_dist :float = 100.0

var spawn_position :Vector2 

func _ready() -> void:
	if base_sprite != null:
		base_sprite.set_instance_shader_parameter("modulate", cor_da_base)
	
	if torreta_sprite != null:
		torreta_sprite.set_instance_shader_parameter("modulate", cor_da_torreta)
				
	if Engine.is_editor_hint():
		set_process(false)
		set_physics_process(false)
		return
		
	spawn_position = global_position
	target = get_tree().get_first_node_in_group("Player")
	$Timer.wait_time = firing_rate
	
func _physics_process(delta: float) -> void:
	
	var dir = (target.global_position-global_position).normalized()
	var target_distance = target.global_position.distance_to(global_position) # distancia entre o tanque e o player
	var spawn_position_distance = global_position.distance_to(spawn_position)
	var spawn_position_direction = (spawn_position-global_position).normalized()
	
	if attack:
		torreta.global_rotation = lerp_angle(torreta.global_rotation,dir.angle(), delta * torret_speed)
		global_rotation = lerp_angle(global_rotation,dir.angle(), delta * base_speed) # base_torque
	else:
		torreta.rotation = lerp_angle(torreta.rotation,2.0*PI, delta * torret_speed)
	
	if abs(transform.x.dot(dir)) > 0.9 and attack and target_distance > max_dist: # se o eixo x do tanque tiver alinhado com a direção para o inimigo 0.999 = alinhado
		if linear_velocity.length() < speed_limit:
			apply_force(dir * speed_force * linear_damp)
		anim.play("run")	
		
	elif spawn_position_distance > 0.5 and not attack:
		global_rotation = lerp_angle(global_rotation,spawn_position_direction.angle(), delta * base_speed)
		apply_force(spawn_position_direction * speed_force * linear_damp)
		anim.play("run")
	else:
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		anim.play("idle")	
	
func firing_bullet() -> void:
	var bullet_instance :Bullet = load(bullets_type[bullet]).instantiate()
	bullet_instance.posicao = $torreta/ponto.global_position
	bullet_instance.dir = Vector2(cos(torreta.global_rotation), sin(torreta.global_rotation)).normalized()
	get_parent().add_child(bullet_instance)
	
func _on_timer_timeout() -> void:
	firing_bullet()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		attack = true
		$Timer.start()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		attack = false
		$Timer.stop()
