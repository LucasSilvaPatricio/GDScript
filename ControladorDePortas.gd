"""
	Essa classe controla as portas do carro,
	precisa incluir esse código em um node vazio do tipo Node
	e passar o Animation com as animações das portas e capô.
	[by: Lucas Silva]
"""
extends Node

class_name ControladorDePortas

var capo_aberto :bool = false
var porta_1_aberta :bool = false
var porta_2_aberta :bool = false
var porta_3_aberta :bool = false
var porta_4_aberta :bool = false
var animacao_tocando :bool = false

@export_category("Adicione o Animation do Carro")
@export var anim: AnimationPlayer

func _process(_delta: float) -> void:
	controle_de_portas()

func controle_de_portas() -> void:
	
	if not animacao_tocando:
		
		if(Input.is_action_just_pressed("capo") and capo_aberto == false):
			anim.play("capo")
			capo_aberto=true
			
		elif Input.is_action_just_pressed("capo") and capo_aberto == true:
			anim.play_backwards("capo")
			capo_aberto=false

		if(Input.is_action_just_pressed("porta_1") and porta_1_aberta == false):
			anim.play("porta_esquerda_frente")
			porta_1_aberta=true
			
		elif Input.is_action_just_pressed("porta_1") and porta_1_aberta == true:
			anim.play_backwards("porta_esquerda_frente")
			porta_1_aberta=false
		
		if(Input.is_action_just_pressed("porta_2") and porta_2_aberta == false):
			anim.play("porta_esquerda_traseira")
			porta_2_aberta=true
			
		elif Input.is_action_just_pressed("porta_2") and porta_2_aberta == true:
			anim.play_backwards("porta_esquerda_traseira")
			porta_2_aberta=false
		
		if(Input.is_action_just_pressed("porta_3") and porta_3_aberta == false):
			anim.play("porta_direita_frente")
			porta_3_aberta=true
			
		elif Input.is_action_just_pressed("porta_3") and porta_3_aberta == true:
			anim.play_backwards("porta_direita_frente")
			porta_3_aberta=false

		if(Input.is_action_just_pressed("porta_4") and porta_4_aberta == false):
			anim.play("porta_direita_traseira")
			porta_4_aberta=true
			
		elif Input.is_action_just_pressed("porta_4") and porta_4_aberta == true:
			anim.play_backwards("porta_direita_traseira")
			porta_4_aberta=false
# executa quando a animação é finalizada
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	animacao_tocando = false

# executa quando a animação é iniciada
func _on_animation_player_animation_started(_anim_name: StringName) -> void:
	animacao_tocando = true
