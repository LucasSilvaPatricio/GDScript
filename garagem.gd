extends Node3D

class_name garagem

@export var carros :Array[PackedScene]

var carro_node_atual 
var carro_atual :int = 0
@onready var quant_carros :int = carros.size()
var velocidade :float = 0.5
var distancia_atual :float = 0
var posicao_inicial :float = -5 # posicao em que o veiculo é dropado
@onready var posicao :Node3D = $Posicao

func _ready() -> void:
	carrega_carro()

func _process(delta: float) -> void:
	posicao.position.z = lerpf(posicao.position.z, distancia_atual, 5 * delta)
	rotataciona_carro(delta)
	
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_right"):
		if carro_atual < quant_carros-1:
			carro_atual += 1	
		else:
			carro_atual = 0

		posicao.remove_child(carro_node_atual)
		carro_node_atual.queue_free()
		carrega_carro()
				
	if Input.is_action_just_pressed("ui_left"):
		if carro_atual > 0:
			carro_atual -= 1	
		else:
			carro_atual = quant_carros-1
		
		posicao.remove_child(carro_node_atual)
		carro_node_atual.queue_free()
		carrega_carro()

func carrega_carro() -> void:
	
	var carro :Variant = carros[carro_atual].instantiate()

	if "grande" in carro.name.to_lower():
		distancia_atual = 1
	if "medio" in carro.name.to_lower():
		distancia_atual = 3
	if "pequeno" in carro.name.to_lower():
		distancia_atual = 5

	if carro is VehicleBody3D:
		carro.freeze=true
	posicao.add_child(carro)
	posicao.rotation.y = 0
	posicao.position.z = posicao_inicial
	carro_node_atual = carro
	
func rotataciona_carro(delta :float) -> void:
	posicao.rotation.y += delta * velocidade
