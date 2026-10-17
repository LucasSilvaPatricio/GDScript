extends RayCast3D

# verifica se tá colidindo em algo e desenha um objeto no ponto de colisão
@onready var ponto :MeshInstance3D = preload("res://objetos/arma/ponto_de_colisao.tscn").instantiate()
@onready var mesh :ImmediateMesh = ImmediateMesh.new()
@onready var meshInstance :MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	# inicializa a espera de luz
	add_child(ponto)
	ponto.visible=false

func _physics_process(delta :float) -> void:
	
	# se mirar começa a desenhar o laser da mira
	if Input.is_action_pressed("mirar"):
		desenha_laser()
		
	# limpa a mesh se mirar tiver acabado de terminar de ser usado	
	if Input.is_action_just_released("mirar"): 
		mesh.clear_surfaces()
	
	# se a mira tiver colidindo em algum objeto, ele desenha uma esfera de luz
	if is_colliding() and Input.is_action_pressed("mirar"):
		ponto.global_position = get_collision_point() # define a posição da espera como o ponto de colisão
		ponto.visible=true # torna a esfera visivel
	else:
		ponto.visible=false # se não tiver colisão e não tiver mirando, a esfera fica invisivel


# desenha a linha do laser
func desenha_laser() -> void:
	var material :StandardMaterial3D = StandardMaterial3D.new() # cria um material para a minha line mesh
	mesh.clear_surfaces() # limpa buffer
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material) # define o tipo de mesh e o material a ser usado
	mesh.surface_add_vertex(meshInstance.position) # cria um vertex que indica a posição de inicio da mira
	if not is_colliding(): # desenha a linha do laser até a ponta do raycast
		mesh.surface_add_vertex(meshInstance.position + target_position) # cria um vertex que indicia a posição final do raycast
	else: # desenha a linha até onde o raycast colidir
		mesh.surface_add_vertex(meshInstance.to_local(get_collision_point())) # cria um vertex que indica a posição onde o raycast colidiu
	mesh.surface_end() # finaliza a criação da mesh
	
	material.albedo_color = Color.GREEN # define uma cor para o material
	material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED # define um shading mode, uso para não criar sombras na linha e não ter interferencia de nenhuma outra luz externa
	meshInstance.mesh = mesh # passa a nova mesh(linha) para meu MeshInstance3d

 
