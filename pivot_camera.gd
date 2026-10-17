# coloque o node da camera dentro do CharacterBody3D
extends Node3D

class_name Pivot_camera

const SENSIBILIDADE_DO_MOUSE :float = 0.005

@export_category("Altura da Camera")
@export var altura_pivot :float = 1.5
@export var sensibilidade :float = 0.005
@export var velocidade :float = 0.5
var horizontal :float = 0.0
var vertical :float = 0.0
var vertical_2 :float = 0.0
var zoom :float = 75.0
var fov_speed :float = 0.5
@export var armature :Node3D
@onready var camera_root :Node3D = $"."
@onready var camera :Camera3D = $horizontal/vertical/SpringArm3D/Camera3D
@onready var horizontal_node :Node3D = $horizontal
@onready var vertical_node :Node3D = $horizontal/vertical
@onready var spring :SpringArm3D = $horizontal/vertical/SpringArm3D
@onready var player :Player = $".."
var camera_root_pos :Vector3
var mirando :bool = false
@export var animation_tree :AnimationTree

@onready var skeleton :Skeleton3D = $"../gothic_woman/Armature/GeneralSkeleton"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_root_pos = camera_root.position
	process_priority=1
	
func _process(delta: float) -> void:
	set_physics_process(player.get_player_enabled())

func _physics_process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("mirar"):
		horizontal_node.global_rotation.y = armature.rotation.y
	if Input.is_action_pressed("mirar"):
		armature.rotate_y(-horizontal * sensibilidade)

	
	if Input.is_action_just_pressed("mirar"):
		var tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(camera,"fov",40.0, fov_speed)

	if Input.is_action_just_released("mirar"):
		var tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(camera,"fov", 75.0, fov_speed)

		vertical_node.rotation_degrees = Vector3.ZERO
		spring.rotation_degrees.y = 0
		
	horizontal_node.rotate_y(-horizontal * sensibilidade)
	vertical_node.rotate_x(vertical * sensibilidade)
	
	if not Input.is_action_pressed("mirar"):
		vertical_node.rotation_degrees.x = clamp(vertical_node.rotation_degrees.x, -90.0, 90.0)

	horizontal = 0
	vertical = 0
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:	 
		horizontal = clamp(event.relative.x,-30, 30) 
		vertical = clamp(event.relative.y, -30,30)
