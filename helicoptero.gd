extends RigidBody3D

class_name Helicoptero 

# variveis de estado
var ocupado :bool = false :
	set(value): ocupado = value
	get: return ocupado
	
var limite_maximo_de_velocidade :float = 40.0

var velocidade :float = 50.0
var movimento_vertical :float = 0.0
var forca_subida_descida :float = 0.0

var velocidade_eixo_z :float = 20.5
var movimento_eixo_z :float = 0.0
var inercia_eixo_z :float = 0.0

var rotacao_horizontal :float = 0.0
var velocidade_rotacao_horizontal :float = 10.0

var sensibilidade :float = 0.05

# configurações de camera
@export var camera :Camera3D

# configurações dos rotores
@export_subgroup("Rotores")
@export var velocidade_rotor_principal :float = 100.0
@export var velocidade_rotor_secundario :float = 100.0

var res_rotacoes :bool = true

var dirigindo :bool = false:
	set(value): dirigindo = value
	get(): return dirigindo
	
func _physics_process(delta: float) -> void:
	forca_subida_descida = lerpf(forca_subida_descida, 0.0, 0.05)
	if dirigindo:
		camera.current = true
		# *** chamada de funções ***
		controladores_de_rotores()
		controle_vertical(delta)
		controle_da_rotacao(delta)
		controle_frente_tras(delta)
		if res_rotacoes:
			reseta_rotacoes()
	else:
		can_sleep=true
		
# *** controla a movimentação vertical do helicoptero ***
func controle_vertical(_delta :float) -> void:
	var direcao :int = int(Input.get_axis("subir","descer"))
	var forca :float = 0.0
	
	if direcao == 1:
		forca += mass * velocidade 
	elif direcao == -1 and not pousou():
		forca += mass * velocidade * -1
		
	forca_subida_descida = lerpf(forca_subida_descida, forca_subida_descida + forca,0.5)
	apply_central_force(Vector3.UP * forca_subida_descida)	


# *** controla a rotação do helicoptero ***
func controle_da_rotacao(delta :float) -> void:
	var direcao_horizontal :int = int(Input.get_axis("direita","esquerda"))
	
	if direcao_horizontal == 1:
		rotacao_horizontal += velocidade_rotacao_horizontal * delta
	elif direcao_horizontal == -1:
		rotacao_horizontal -= velocidade_rotacao_horizontal * delta
	else:
		rotacao_horizontal = 0.0

	angular_velocity.y = lerpf(angular_velocity.y, rotacao_horizontal, sensibilidade)
	angular_velocity.y = clamp(angular_velocity.y, -velocidade_rotacao_horizontal, velocidade_rotacao_horizontal)
	
	rotaciona_para_direita_ou_esquerda(direcao_horizontal)
	
# *** controla o movimento para frente e para trás do helicoptero. ***
func controle_frente_tras(delta :float) -> void: # movimentação no eixo z
	var direcao_frente_tras :float = Input.get_axis("tras","frente")
	
	if direcao_frente_tras == 1:
		movimento_eixo_z += velocidade_eixo_z * delta
		res_rotacoes=false		
	elif direcao_frente_tras == -1:
		movimento_eixo_z -= velocidade_eixo_z * delta
		res_rotacoes=false
	else:
		movimento_eixo_z = 0.0
		res_rotacoes=true
	
	rotaciona_para_frente_ou_tras(direcao_frente_tras)
	
	inercia_eixo_z = lerpf(inercia_eixo_z, movimento_eixo_z, 0.05)

	linear_velocity = global_transform.basis.z * inercia_eixo_z
	
# *** verifica se pousou ***
func pousou() -> bool:
	return true if $RayCast3D.is_colliding() else false

# *** reseta as rotações para dar equilibrio ao helicoptero ***
func reseta_rotacoes() -> void:
	rotation_degrees.z = lerpf(rotation_degrees.z, 0, 0.05)
	rotation_degrees.x = lerpf(rotation_degrees.z, 0, 0.05)
	angular_velocity.z = 0.0
	angular_velocity.x = 0.0

func rotaciona_para_frente_ou_tras(direcao :float) -> void:
	if direcao == 1:
		for node in get_children():
			if not "camera" in node.name.to_lower():
				node.rotation_degrees.x = lerpf(node.rotation_degrees.x, 15.0, 0.05)
	elif direcao == -1:
		for node in get_children():
			if not "camera" in node.name.to_lower():
				node.rotation_degrees.x = lerpf(node.rotation_degrees.x, -15.0, 0.05)
	else:
		reseta_rotacoes_dos_filhos_em_x()

func rotaciona_para_direita_ou_esquerda(direcao: float) -> void:
	if direcao == -1:
		for node in get_children():
			if not "camera" in node.name.to_lower():
				node.rotation_degrees.z = lerpf(node.rotation_degrees.z, 15.0, 0.05)
	elif direcao == 1:
		for node in get_children():
			if not "camera" in node.name.to_lower():
				node.rotation_degrees.z = lerpf(node.rotation_degrees.z, -15.0, 0.05)
	else:
		reseta_rotacoes_dos_filhos_em_z()
	
func reseta_rotacoes_dos_filhos_em_x() -> void:
	for node in get_children():
		if not "camera" in node.name.to_lower():
			node.rotation_degrees.x = lerpf(node.rotation_degrees.x, 0.0, 0.05)

func reseta_rotacoes_dos_filhos_em_z() -> void:
	for node in get_children():
		if not "camera" in node.name.to_lower():
			node.rotation_degrees.z = lerpf(node.rotation_degrees.z, 0.0, 0.05)		
					
func controladores_de_rotores() -> void:
	var rotor_principal :MeshInstance3D = $helicoptero/rotor_principal
	var rotor_secundario :MeshInstance3D = $helicoptero/rotor_secundario
	
	rotor_principal.rotate_y(velocidade_rotor_principal)
	rotor_secundario.rotate_x(velocidade_rotor_secundario)
