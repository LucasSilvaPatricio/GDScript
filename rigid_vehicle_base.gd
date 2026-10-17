@tool
class_name RigidVehicle extends RigidBody3D
#ray_lenght = 10.0
#forca = 50
#dustancia_mola = 0.6
#damp = 1.0
#k = 200.0
#mass = 10.0
#gravity_scale = 3.0
#linear_damp = 3.0
#angular_damp = 0.3
@export_category("RigidBodyVehicle Settings")
@export var centro_de_massa :Marker3D
@export var forca :float = 50.0
@export var distancia_mola :float = 0.8 ## distorção da mola

@export var rays :Array[RayCast3D]
@export var wheels_mesh :Array[MeshInstance3D]
var forca_tmp :float = 0.0
@export var damp :float = 2.5
var tolerancia :float = 0.0
var inicio_mola :float = 0.2
var raio_roda :float = 1.0
@export var k :float = 100.0 ## constante elastica

const ESCALA :float = 50.0
# personalização do veiculo
#@export_category("Personalização")
#@export var material: StandardMaterial3D
#@export var cor_principal :Color :
	#set(value):
		#cor_principal = value
		#set_color(cor_principal)
	#get: return cor_principal
#
#func set_color(color :Color) -> void:
	#material.albedo_color = color

@export_category("Settings Vehicle Deprecated")
#@export var centro_de_massa :Marker3D
@export var camera_secondary :Camera3D

@export var velocidade_maxima :float = 50.0
@export var engine_forca :float = 100.0
@export var angulo_da_roda :float = 0.9 
@export var sensibilidade_do_giro :float = 0.03 * ESCALA # giro da roda
@export var anim_portas :AnimationPlayer :
	get: return anim_portas
@export var all_wheels : Array[VehicleWheel3D]:
	set(value): all_wheels = value
@export var rodas_de_freio :Array[VehicleWheel3D]

var _friccao :float = 1.5
var _freio :float = 200.0

# variveis de estado
var direcao :float = 0.0:
	get: return direcao

var velocidade_atual_do_carro :float :
	get(): return velocidade_atual_do_carro

var _control_enabled :bool = false
const DAMP :float = 3.0

# atalho de auto configuração, adiciona uma configuração default para o veiculo;
@export_tool_button("Auto Config Vehicle","Add") var auto = auto_config_car
func auto_config_car() -> void:
	pass#AutoConfCar.new(self).auto_config()


func _ready() -> void:
	
	# configura roda
	tolerancia = 0.05 # diminui o raio da roda, isso evita que a roda parece não enconstrar no chão
	raio_roda = wheels_mesh[0].mesh.get_aabb().size.y/2.0 if wheels_mesh.size() > 0 else 0.3
	raio_roda -= tolerancia
	
	center_of_mass = centro_de_massa.position
	
	
	if get_parent() and get_parent().get_parent():
		shader_blur = get_parent().get_parent().get_node_or_null("blurspeed")
	if centro_de_massa != null:
		center_of_mass = centro_de_massa.position
		
	if not Engine.is_editor_hint(): # não executa no modo editor;
		for roda in rodas_de_freio:
			if roda == null:
				rodas_de_freio.clear()
	else: # desativa physics quando no modo editor;
		set_physics_process(false)
		set_process(false)
	
	if not Engine.is_editor_hint():
		control_process() # vai desativar os process
	
	
var shader_blur :ColorRect
		
func _process(_delta: float) -> void:
	
	if shader_blur != null:
		var blur_value = clamp(remap(velocidade_atual_do_carro, 0.0, 200.0,0.0,2.0),0.0,2.0)
		
		shader_blur.set_instance_shader_parameter("intensity",blur_value)	
		if not get_vehicle_enabled():
			shader_blur.set_instance_shader_parameter("intensity",0.0)
	
	#var mesh_roda :MeshInstance3D = $MeshInstance3D

	for i in len(rays):
		var pivot_mola = rays[i].global_position
		#pivot_mola.y = pivot_mola.y-inicio_mola
		var distancia =pivot_mola.distance_to(rays[i].get_collision_point())
		DebugDraw3D.draw_sphere(pivot_mola ,0.05,Color.GREEN)
		if rays[i].is_colliding() and distancia < distancia_mola-raio_roda:
			
			wheels_mesh[i].global_position = Vector3(rays[i].get_collision_point().x,(rays[i].get_collision_point().y)+raio_roda,rays[i].get_collision_point().z)
			DebugDraw3D.draw_sphere(rays[i].get_collision_point(),0.05,Color.GREEN)
	_draw()
	if Input.is_action_pressed("ui_accept"):
		apply_central_force(Vector3.UP*500)
		
func _physics_process(delta: float) -> void:
	
	var dir = Input.get_axis("ui_up","ui_down")
	if dir == 0.0:
		linear_velocity = linear_velocity.lerp(Vector3.ZERO, 0.04)
		angular_velocity = angular_velocity.lerp(Vector3.ZERO, 0.04)
	apply_force(dir*-transform.basis.z*mass*forca)
	apply_torque(Vector3.UP* Input.get_axis("ui_right","ui_left") * 30.0 * linear_velocity.length()/PI)
	for ray in rays:
		if ray.is_colliding():

			var direcao = (ray.global_position - ray.get_collision_point()).normalized()
			var pivot_mola = ray.global_position
			#pivot_mola.y = pivot_mola.y-inicio_mola
			var distancia = pivot_mola.distance_to(ray.get_collision_point())
			var f = k *  (distancia_mola - distancia)
			var forca_final =  f - (linear_velocity.dot(direcao)*damp)
			var posicao_roda = ray.get_collision_point()-global_position
			apply_force(Vector3.UP*forca_final, posicao_roda) 
	"""		
	if get_vehicle_enabled():
		controlador(delta)
		#controla_freios()
		controle_som_do_motor()
	velocidade_atual_do_carro = linear_velocity.length()*3.6 
	"""
func control_process() -> void:
	if not get_vehicle_enabled(): # desativa process quando não dirigindo o carro
		set_physics_process(false)
		set_process(false)
		reset_moviments()
		
		
	if get_vehicle_enabled(): # ativa process quando dirigindo carro
		set_physics_process(true)
		set_process(true)



	
func controlador(delta :float) -> void:
	#a.x²+x.b+c
	if velocidade_atual_do_carro < velocidade_maxima:
		
		pass#engine_force = Input.get_axis("tras","frente") * engine_forca#( velocidade* pow(time,1.5) + time*1)  
	else:
		pass#engine_force = 0.0
	var x = clamp(remap(linear_velocity.length()/0.5, 0.0, velocidade_maxima, angulo_da_roda, 0.1), 0.2, angulo_da_roda)
	
	pass#steering = lerpf(steering, Input.get_axis("direita","esquerda") * x, sensibilidade_do_giro * delta)
	#DebugDraw2D.set_text("Velocidade: "+str(velocidade_atual_do_carro))
func controla_freios() -> void:
	if rodas_de_freio.is_empty():
		pass#brake = _freio if Input.is_action_pressed("freio") else _friccao - abs(Input.get_axis("tras","frente")) * _friccao 
	else:
		for i in rodas_de_freio.size():
			rodas_de_freio[i].brake = _freio if Input.is_action_pressed("freio") else _friccao - abs(Input.get_axis("tras","frente")) * _friccao 

func open_door() -> void:
	if anim_portas and anim_portas.has_animation("open_door"):
		anim_portas.play("open_door")
		
func close_door() -> void:
	if anim_portas and anim_portas.has_animation("open_door"):
		anim_portas.play_backwards("open_door")

func deslocar() -> void:
	pass#engine_force = 500.0

func forca_a_virar_player(value :bool) -> void:
	set_collision_layer_value(2,value)
	deslocar()

func set_vehicle_enabled(control_enabled :bool) -> void: # chame para dirigir o carro
	angular_damp = 0.3
	linear_damp = 0.3
	self._control_enabled = control_enabled
	change_group_to_player(control_enabled)
	control_process() # verifica se deve ativar ou desativar os process
	controle_som_do_motor()
	
func get_vehicle_enabled() -> bool: # chame para saber se o carro está sendo dirigido
	return _control_enabled

func activate_secondary_camera() -> void:
	if camera_secondary != null:
		camera_secondary.current = true

func reset_moviments() -> void: # zera movimentos
	pass#engine_force = 0

	var in_ground = vehicle_is_in_ground()

	while linear_velocity.length() > 0.05 or angular_velocity.length() > 0.05: 
		linear_velocity = linear_velocity.lerp(Vector3.ZERO, 0.05)
		angular_velocity = angular_velocity.lerp(Vector3.ZERO, 0.05)

		await get_tree().process_frame
	
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	await get_tree().create_timer(3.5).timeout
	
	while not in_ground:
		in_ground = vehicle_is_in_ground()
		
		# is inside tree, se não tiver na fila, ele quebra para não chamar o process frame
		if not is_inside_tree() or in_ground:
			break
			
		await get_tree().process_frame	
	
	angular_damp = DAMP
	linear_damp = DAMP
	sleeping=true
	pass#brake=0.0
	
func vehicle_is_in_ground() -> bool:
	var in_ground = false
	for wheel in all_wheels:

		if wheel != null and wheel.is_in_contact():
			in_ground=true
	return in_ground
	
func change_group_to_player(value:bool) -> void:
	if value:
		if is_in_group("Carro"):
			remove_from_group("Carro")
		add_to_group("Player")
	else:
		if is_in_group("Player"):
			remove_from_group("Player")
		add_to_group("Carro")

@export_category("Settings motor")
@export var som_motor :AudioStreamPlayer3D
@export var pitch_minimo :float = 0.3
@export var pitch_maximo :float =  1.7
@export var velocidade_de_transicao :float = 0.05

func controle_som_do_motor() -> void:
	
	if som_motor == null:
		return
		
	if not get_vehicle_enabled():
		if not som_motor.stream_paused:
			som_motor.stop()
			return
	elif not som_motor.playing:
		som_motor.play()

	var pitch_velocity = velocidade_atual_do_carro
	var pitch_remap = remap(pitch_velocity, 0, velocidade_maxima, pitch_minimo,pitch_maximo)
	var pitch_final = pitch_remap + angular_velocity.length()*0.005*PI
	som_motor.pitch_scale = lerpf(som_motor.pitch_scale, pitch_final, velocidade_de_transicao)
	som_motor.pitch_scale = clamp(som_motor.pitch_scale, pitch_minimo, pitch_maximo)

func _draw() -> void:
	for ray in rays:
		DebugDraw3D.draw_sphere(ray.get_collision_point(), 0.05,Color.RED)
		DebugDraw3D.draw_arrow(ray.global_position, ray.get_collision_point(),Color.YELLOW, 0.01)
