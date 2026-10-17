extends Node3D

@export var camera :Camera3D
@export var raycast_cam :RayCast3D

@export var bullet_point :Marker3D #bullet spawn origin
@export var player :Player
var bullet_time = 0.0

@onready var hud :Control = $Control
@onready var decal :Marker3D
@onready var gpu :GPUParticles3D
func _process(delta: float) -> void:
	input_handle(delta)

var _point :Vector3
var _normal :Vector3
var _eixo_x :Vector3
var _eixo_y :Vector3
var _eixo_z :Vector3

var time_life = 3.0

func input_handle(delta :float) -> void:
	if player.aiming_with_a_gun() and player.get_player_enabled():
		hud.visible=true
	else:
		hud.visible=false
		
	if Input.is_action_just_pressed("atirar") and player.aiming_with_a_gun() and player.get_player_enabled():
		if raycast_cam.is_colliding():
			decal = load("res://objetos/arma/decal.tscn").instantiate()
			gpu = load("res://objetos/arma/gpu_particles_shoot.tscn").instantiate()
			self.add_child(decal)
			self.add_child(gpu)
			
			_point = raycast_cam.get_collision_point()
			_normal = raycast_cam.get_collision_normal()
			
			decal.global_transform.origin = _point
			var vet = Vector3.UP if abs(Vector3.UP.dot(_normal)) < 0.99 else Vector3.FORWARD
			
			_eixo_x = _normal
			_eixo_y = vet.cross(_eixo_x).normalized()
			_eixo_z = _eixo_x.cross(_eixo_y).normalized()
			
			decal.transform.basis = Basis(_eixo_x,_eixo_y,_eixo_z)
			gpu.global_transform.origin = _point
			gpu.emitting=true
			
		$AudioStreamPlayer.play()
		$AnimationPlayer.play("fire")
		time_life += delta

		
#func draw() -> void:
	#DebugDraw3D.draw_arrow(_point,_point+_normal,Color.RED,0.005,false,3.0)
	#DebugDraw3D.draw_arrow(_point, _point+_eixo_z, Color.GREEN,0.005,false,3.0)
	#DebugDraw3D.draw_arrow(_point, _point+_eixo_y, Color.BLUE,0.005,false,3.0)
	#pass
