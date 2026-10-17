extends Node3D

class_name Lamp_post

@export var light :Array[Sprite3D]
var enable_decal_blink :bool = false
var time_blink :float = 0.5
@onready var time:Timer = get_node("Timer")
@onready var decal :Decal = $Decal

var delay :float = 50.5

func _ready() -> void:
	time.wait_time = RandomNumberGenerator.new().randf_range(5.0,20.0)
	time.start()
	TimeManager.dusk.connect(_enable_lamp)
	TimeManager.dawned.connect(_disable_lamp)

	if  light[0].get_instance_shader_parameter("delay") != null:
		delay = light[0].get_instance_shader_parameter("delay")
		
func _process(_delta: float) -> void:
	if enable_decal_blink:
		decal_blink()
	else:
		decal.albedo_mix = 1.0
		
func decal_blink() -> void:
	var value = clamp(sin(Time.get_ticks_msec()*50.5),0.0,1.0)
	decal.albedo_mix = value
	pass
		
func _enable_lamp() -> void:
	for obj in light:
		obj.set_instance_shader_parameter("enable",true)

func _disable_lamp() -> void:
	for obj in light:
		obj.set_instance_shader_parameter("enable",false)
			
func _on_timer_timeout() -> void:
	for obj in light:
		obj.set_instance_shader_parameter("enable_blink",true)
		enable_decal_blink=true
	await get_tree().create_timer(time_blink).timeout
	for obj in light:
		obj.set_instance_shader_parameter("enable_blink",false)	
		enable_decal_blink=false
