extends AudioStreamPlayer3D

class_name MotorSom

@export var carro :VehicleBody3D = get_parent()

var pitch_inicial :float = 0.3
var pitch_maximo :float =  1.7
var pitch_escala :float = 10.0

func _process(delta: float) -> void:
	if not carro.get_vehicle_enabled():
		if not stream_paused:
			stop()
			return
	elif not playing:
		play()
	
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:	
	var pitch_velocity = carro.linear_velocity.length() * 0.05 * pitch_escala
	pitch_scale = pitch_inicial + pitch_velocity
	pitch_scale = clamp(pitch_scale, pitch_inicial, pitch_maximo)
		
