@tool
extends Node
# personalização do veiculo

class_name personalizacao_de_veiculo

@export_category("Personalização")
@export var material_principal: StandardMaterial3D
@export var material_secundario :StandardMaterial3D

@export var cor_principal :Color :
	set(value):
		cor_principal = value
		if material_principal != null:
			material_principal.albedo_color = cor_principal
	get: return cor_principal
	
@export_range(0,1) var metalico :float :
	set(value):
		metalico = value
		if material_principal != null:
			material_principal.metallic = value
	get: return metalico

@export_range(0,1) var fosco :float :
	set(value):
		fosco = value
		if material_principal != null:
			material_principal.roughness = value
			
@export var cor_secundaria :Color :
	set(value):
		cor_secundaria = value
		if material_secundario != null:
			material_secundario.albedo_color = cor_secundaria
	get: return cor_secundaria
	
@export_range(0,1) var metalico_secundario :float :
	set(value):
		metalico_secundario = value
		if material_secundario != null:
			material_secundario.metallic = value
	get: return metalico_secundario

@export_range(0,1) var fosco_secundario :float :
	set(value):
		fosco_secundario = value
		if material_secundario != null:
			material_secundario.roughness = value	

@export_category("Configuração de suspensão")

@export var rodas_dianteira :Array[VehicleWheel3D]
@export var rodas_traseira :Array[VehicleWheel3D]
			
@export_range(-1,1) var suspensao_geral :float :
	set(value):
		suspensao_geral = value
		if not rodas_traseira.is_empty():
			for roda :VehicleWheel3D in rodas_traseira:
				roda.position.y = -value
		if not rodas_dianteira.is_empty():
			for roda in rodas_dianteira:
				roda.position.y = -value
				
@export_range(-1,1) var suspensao_dianteira :float :
	set(value):
		suspensao_dianteira = value
		if not rodas_dianteira.is_empty():
			for roda in rodas_dianteira:
				roda.position.y = -value
				
@export_range(-1,1) var suspensao_traseira :float :
	set(value):
		suspensao_traseira = value
		if not rodas_traseira.is_empty():
			for roda :VehicleWheel3D in rodas_traseira:
				roda.position.y = -value

@export_range(0.5,2.0) var distancia_eixo_x :float :
	set(value):
		distancia_eixo_x = value
		if not rodas_dianteira.is_empty():
			for roda :VehicleWheel3D in rodas_dianteira:
				if "right" in roda.name:
					roda.position.x = -value
				if "left" in roda.name:
					roda.position.x = value

		if not rodas_traseira.is_empty():
			for roda :VehicleWheel3D in rodas_traseira:
				if "right" in roda.name:
					roda.position.x = -value
				if "left" in roda.name:
					roda.position.x = value


@export var escala_roda :float = 1.0 :
	set(value): 
		escala_roda = value
		
		if not rodas_dianteira.is_empty():
			for roda :VehicleWheel3D in rodas_dianteira:
				if roda != null:
					var mesh_wheel :MeshInstance3D = roda.get_node_or_null(roda.name.get_file())
					mesh_wheel.scale = Vector3.ONE * value
					roda.wheel_radius = (mesh_wheel.get_aabb().size.y/2.0) * value
					
		if not rodas_traseira.is_empty():
			for roda :VehicleWheel3D in rodas_traseira:
				if roda != null:
					var mesh_wheel :MeshInstance3D = roda.get_node_or_null(roda.name.get_file())
					mesh_wheel.scale = Vector3.ONE * value
					roda.wheel_radius = (mesh_wheel.get_aabb().size.y/2.0) * value
