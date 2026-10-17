extends VehicleBody3D

class_name BotCarro

@export var raycasts :Node3D
var _checkpoints :Array
var distancia_de_colisao :float = 2.0
var checkpoint_atual :int = 0
var proj_vetorial :float = 0
var velocidade :float = 8.0
var _spawns :Array[SpawnCar]
var stop_car :bool = false # indica quando o carro tiver que parar por ter algo na frente

func _ready() -> void:
	pass#_checkpoints = get_parent().get_parent().get_all_checkpoints()
	#_spawns = get_parent().get_parent().get_all_spawns()
	
func _process(_delta):
		IA()
		verify_raycast_collisions()
		#gizmos()

func set_values_checkpoints_spawn(checkpoints, spawns) -> void: # antes de iniciar, passar esse valores para o bot
	_checkpoints = checkpoints
	_spawns = spawns
	
func IA():
	var posicao_do_carro = global_position
	
	if posicao_do_carro.distance_to(_checkpoints[checkpoint_atual].global_position) < distancia_de_colisao:
		if checkpoint_atual < _checkpoints.size() - 1:
			checkpoint_atual += 1
		else:
			checkpoint_atual = 0 # volta pro primeiro, ou carrega novo spawn
			load_checkpoints_in_new_spawn() # pode remover o objeto da arvore nesse momento 
	
	# verifica se ainda está na arvore, pois pode ter sido executado o metodo load_checkpoints_in_new_spawn
	# e possa ser que ele já tenha excluido o meu objeto atual
	if is_inside_tree():		
		var direcao = (_checkpoints[checkpoint_atual].global_position -global_position).normalized()
	
		proj_vetorial = direcao.dot(transform.basis.x)
	
		steering = clamp(proj_vetorial, -1, 1)
		
		if not stop_car:
			brake=0
			engine_force = pow(velocidade,2)
		else:
			
			engine_force = lerpf(engine_force, 0, 0.05)
			linear_velocity = lerp(linear_velocity, Vector3.ZERO, 0.05)
			if linear_velocity == Vector3.ZERO:
				brake = 100
			
func load_checkpoints_in_new_spawn() -> void: # carrega os checkpoints de um novo spawn
	if _spawns.size() > 0:
		var new_spawn = _spawns[randi() % _spawns.size() - 1]
		_checkpoints = new_spawn.get_all_checkpoints()
		_spawns = new_spawn.get_all_spawns()
	else:
		#print("Removido", name)
		get_parent().remove_child(self)
		queue_free()

func verify_raycast_collisions() -> void: # indica se tem algum raycast colidingo, se tiver ele para o carro usando stop_car
	var count_ray_colliding :int = 0
	for raycast :RayCast3D in raycasts.get_children():
		if(raycast.is_colliding()):
			count_ray_colliding += 1
	stop_car = true if count_ray_colliding > 0 else false
		
func gizmos() -> void:
	if is_inside_tree(): # executa somente se meu objeto ainda estiver na arvore
		DebugDraw3D.draw_line(global_position, _checkpoints[checkpoint_atual].global_position, Color(0,2,0), 0)
