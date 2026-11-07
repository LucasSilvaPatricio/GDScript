extends Control

class_name status_hud

@onready var pontos_label :Label = $CanvasLayer/VBoxContainer/Pontos
@onready var moedas_label :Label = $CanvasLayer/VBoxContainer/Moedas
@onready var inimigos_derrotados_area_atual_label :Label = $CanvasLayer/VBoxContainer/InimigosDerrotadosAreaAtual
@onready var total_inimigos_derrotados_label :Label = $CanvasLayer/VBoxContainer/InimigosTotalDerrotados
@onready var areas_conquistadas_label :Label = $CanvasLayer/VBoxContainer/AreasConquistadas
@onready var disparos_label :Label = $CanvasLayer/VBoxContainer/Disparos
@onready var et_regastados_label_ :Label = $CanvasLayer/VBoxContainer/EtResgatados

var _pontos :int = 0
var _moedas :float = 0.0
var _dados_area_atual :Dictionary = {}
var _inimigos_derrotados_area_atual :int = 0
var _total_inimigos_derrotados :int = 0
var _areas_dados :Dictionary
var _disparos :int = 0
var _et_resgatados :int = 0

func _ready() -> void:
	Events.inimigo_destruido.connect(incrementar_pontuacao)
	Events.area_conquistada.connect(area_conquistada)
	Events.tiro_disparado.connect(_tiro_disparado)
	Events.atualizar_informacao_area_atual.connect(_atualizar_dados_area_atual)
	
func incrementar_pontuacao(inimigo :enemy_base) -> void:
	_pontos += inimigo.pontuacao_do_inimigo
	pontos_label.text = "pontuação "+str(int(_pontos))
	total_inimigos_derrotados()
	
func area_conquistada(dados :Dictionary) -> void:
	_areas_dados = dados
	areas_conquistadas_label.text = "areas conquistadas "+str(_areas_dados["areas_conquistadas"])+"/"+str(_areas_dados["total_de_areas"])

func _tiro_disparado() -> void:
	_disparos+=1
	disparos_label.text = "disparos "+str(_disparos)

func total_inimigos_derrotados() -> void:
	_total_inimigos_derrotados+=1
	total_inimigos_derrotados_label.text = "total de inimigos derrotados "+str(_total_inimigos_derrotados)

func _atualizar_dados_area_atual(dados :Dictionary) -> void:
	_dados_area_atual=dados
	inimigos_derrotados_area_atual_label.text="Inimigos derrotados da area atual "+str(_dados_area_atual["inimigos_derrotados"])+"/"+str(_dados_area_atual["inimigos"])
	pass
