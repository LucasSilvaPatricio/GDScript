# controla a simulação dos farois
extends Node

class_name FarolCarro

@export_subgroup("Farois")
@export var sirene :Array[MeshInstance3D]
@export var farois_dianteiros :MeshInstance3D
@export var farois_traseiros :MeshInstance3D
var min_farol_traseiro :float = 2.0 # itensidade minima do farol traseiro
var max_farol_traseiro :float = 10.0 # itensidade maxima do farol traseiro

@export var controle_do_carro :ControleCarro
@export var abilitar_simulacao_de_farois :bool = true:
	set(value):
		abilitar_simulacao_de_farois = value
	get:
		return abilitar_simulacao_de_farois

var mat_farois_traseiros :StandardMaterial3D
var mat_farois_dianteiros :StandardMaterial3D

# inicilização dos farois
func _ready() -> void:
	if(farois_traseiros != null):
		mat_farois_traseiros = farois_traseiros.get_active_material(0)
		mat_farois_traseiros.emission_enabled = true
		mat_farois_traseiros.emission_energy_multiplier = min_farol_traseiro
	else:
		push_warning("Farois traseiros não setado")	
	
	if(farois_dianteiros != null):
		mat_farois_dianteiros = farois_dianteiros.get_active_material(0)
		mat_farois_dianteiros.emission_enabled = true
	else:
		push_warning("Farois dianteiros não setado")

	for si in sirene:
		si.get_active_material(0).emission_enabled=true
		si.get_active_material(0).emission_energy_multiplier=0
func _process(delta: float) -> void:
	farol_controle()
	sirene_controle(delta)
	
func farol_controle() -> void:
	if(farois_traseiros != null && abilitar_simulacao_de_farois):
		if(Input.is_action_pressed("freio") || Input.is_action_pressed("tras")):
			mat_farois_traseiros.emission_energy_multiplier = max_farol_traseiro
		if(Input.is_action_just_released("freio") || Input.is_action_just_released("tras")):
			mat_farois_traseiros.emission_energy_multiplier = min_farol_traseiro
		
	if(farois_dianteiros != null && abilitar_simulacao_de_farois):
		if(controle_do_carro.dirigindo):
			mat_farois_dianteiros.emission_enabled = true
		else:
			mat_farois_dianteiros.emission_enabled = false

var vel = 0
func sirene_controle(delta: float) -> void:
	vel += delta
	for si:MeshInstance3D in sirene:
		si.get_active_material(0).emission_energy_multiplier= sin(vel * 50) * 50
		si.get_active_material(0).emission_energy_multiplier = clamp(si.get_active_material(0).emission_energy_multiplier, 1, 50)
	if(vel >= 1):
		vel = 0
