extends TileMapLayer

@onready var tile_map :TileMapLayer = $"."
@export var player :CharacterBody2D

var tile_id :int = 3 #tile set que indica terreno dominado
var areas_conquistadas :int = 0
var areas :int = 0 # quantidade de areas para ser conquistadas
var dados_por_areas :Dictionary = {}

func _ready() -> void:
	Events.inimigo_destruido.connect(verifica_areas_conquistadas)
	areas = tile_map.get_used_cells().size() # quantas cell(areas criadas) estão sendo usadas
	Events.area_conquistada.emit({"areas_conquistadas":areas_conquistadas,"total_de_areas":areas})
	player.player_mudou_de_tile.connect(_player_mudou_de_tile)
	
	# cria o dicionario com informações por cada celula
	for cell_used :Vector2i in tile_map.get_used_cells():
		dados_por_areas[cell_used] = {
			"tile_id": tile_map.get_cell_source_id(cell_used),
			"conquistado":false,
			"inimigos":0,
			"inimigos_derrotados":0,
		}
		
		
	for inimigo in get_tree().get_nodes_in_group("GroundEnemy"):
		var cell = tile_map.local_to_map(tile_map.to_local(inimigo.global_position))
		if dados_por_areas.has(cell):
			dados_por_areas[cell]["inimigos"]+=1
	
	# cell na qual o player esta em cima
	var cell_do_player = tile_map.local_to_map(tile_map.to_local(player.global_position))
	Events.atualizar_informacao_area_atual.emit(dados_por_areas[cell_do_player])
	
func verifica_areas_conquistadas(enemy :RigidBody2D) -> void:
	
	var cell = tile_map.local_to_map(tile_map.to_local(enemy.global_position))
	
	if dados_por_areas.has(cell):
		dados_por_areas[cell]["inimigos_derrotados"]+=1

		if dados_por_areas[cell]["inimigos_derrotados"] >= dados_por_areas[cell]["inimigos"] :
			tile_map.set_cell(cell,tile_id,Vector2i.ZERO)
			var pos = tile_map.map_to_local(cell)
			var flag_node = load("res://scenes/flag.tscn").instantiate()
			add_child(flag_node)
			flag_node.global_position = to_global(pos)	
			areas_conquistadas+=1
			Events.area_conquistada.emit({"areas_conquistadas":areas_conquistadas,"total_de_areas":areas})
			dados_por_areas[cell]["conquistado"]=true
	
	_player_mudou_de_tile() #invoca atualização da hud para area atual
			
	if areas_conquistadas == tile_map.get_used_cells().size():
		print("ganhou")

func _player_mudou_de_tile() -> void: #invoca atualização da hud para area atual
	var cell_do_player = tile_map.local_to_map(tile_map.to_local(player.global_position))
	if dados_por_areas.has(cell_do_player):
		Events.atualizar_informacao_area_atual.emit(dados_por_areas[cell_do_player])
#var current_cell :Vector2i = Vector2i.ZERO
#var time :float = 0.0
#var inimigos_da_cell :Array = [] # armazena cell em que o inimigo esta

	#"cell":
		#{
			#"area_id":null,
			#"inimigos":null,
			#"inimigos_derrotados":null
		#}
		
	#inimigos_da_cell.erase(cell)
	#if not cell in inimigos_da_cell:
		#tile_map.set_cell(cell,tile_id,Vector2i.ZERO)
		#var pos = tile_map.map_to_local(cell)
		#var flag_node = load("res://scenes/flag.tscn").instantiate()
		#add_child(flag_node)
		#flag_node.global_position = to_global(pos)	
		#areas_conquistadas+=1
		#Events.area_conquistada.emit({"areas_conquistadas":areas_conquistadas,"total_de_areas":areas})
		
	#process
	#var tile = tile_map.get_local_mouse_position()
	#var cell = tile_map.local_to_map(tile)
	
	#if current_cell != cell:
		#current_cell = cell
		#time = 0.0
	#else:
		#if time >= 3.0:
			#if tile_map.get_cell_source_id(cell) != tile_set_value: # verifica se já foi adicionado o azul
				#pass#tile_map.set_cell(cell,tile_set_value,Vector2i.ZERO)
			#pass
		## fica verificando o tempo 
		#pass
	#time += delta	
