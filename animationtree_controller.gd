extends Node

class_name AnimationtreeController

@onready var anim_tree :AnimationTree = $"../AnimationTree"
@onready var player: CharacterBody3D = $".."
@onready var copy_transform :CopyTransformModifier3D = $"../gothic_woman/Armature/GeneralSkeleton/CopyTransformModifier3D"
@onready var ccdik :CCDIK3D = $"../gothic_woman/Armature/GeneralSkeleton/CCDIK3D"

enum status {DEFAULT=0,IDLE,PISTO, WALK, RUNNING, JUMP, SHOOT, ENTER_CAR, EXIT_CAR, SITTING}
var using_pistol :bool = false

var current_status = status.DEFAULT:
	set(value):
		current_status=value
		update_animation(value)
	get:
		return current_status
		
var pistol_active = false:
	set(value):
		pistol_active=value
	get:
		return pistol_active
		
const ANIM_MAIN = "parameters/main/transition_request"
const PISTOL = "parameters/pistol/blend_amount"
const ANIM_TYPE = "parameters/anim_type/blend_amount"
const JUMP = "parameters/jump/request"
const SHOOT = "parameters/despair/request"

@export var transition_speed :float = 0.5
@export var transition_pistol_speed :float = 0.2

func _ready() -> void:
	current_status=status.IDLE

func _process(_delta: float) -> void:
	pass
	
func update_animation(status_value: status) -> void:

	if not current_status >= status.ENTER_CAR:
		anim_tree.set(ANIM_MAIN,"default")
		copy_transform.active=true
	else:
		copy_transform.active=false

	if pistol_active:
		ccdik.active=true
		
		var tween = get_tree().create_tween()
		tween.tween_property(anim_tree,PISTOL, 1.0, transition_pistol_speed)
	else:
		ccdik.active=false
		
		var tween = get_tree().create_tween()
		tween.tween_property(anim_tree,PISTOL, 0.0, transition_pistol_speed)
				
	match status_value:
		status.IDLE:
			var tween = get_tree().create_tween()
			tween.tween_property(anim_tree,ANIM_TYPE, -1.0, transition_speed)
		status.WALK:
			var tween = get_tree().create_tween()
			tween.tween_property(anim_tree,ANIM_TYPE, 0.0, transition_speed)
		status.RUNNING:
			var tween = get_tree().create_tween()
			tween.tween_property(anim_tree,ANIM_TYPE, 1.0, transition_speed)
		status.JUMP:
			anim_tree.set(JUMP, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		status.ENTER_CAR:
			anim_tree.set(ANIM_MAIN,"enter_car")
		status.EXIT_CAR:
			anim_tree.set(ANIM_MAIN,"exit_car")	
		status.SITTING:
			anim_tree.set(ANIM_MAIN,"sitting")
		status.SHOOT:
			anim_tree.set(SHOOT,AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
