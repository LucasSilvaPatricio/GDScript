extends Node2D

@export var fragmentos :int = 100
var dir = Vector2.LEFT
var velocidade :float = 200.0
var explosao :bool = false

@onready var bullet :PackedScene = preload("res://scenes/bullet.tscn")

var partes :Array[Polygon2D] = []

func _process(delta: float) -> void:
	queue_redraw()
	if Input.is_action_just_pressed("ui_cancel") and not explosao:
		carrega_partes()
		explosao = true

	look_at(get_global_mouse_position())
	
	var direcao :Vector2 = Vector2(cos(rotation),sin(rotation)).normalized()
	var offset :float = 15.0 # 15 px
	var zoom = 2.0+sin(Time.get_ticks_msec()*0.0025)*0.3
	
	if get_global_mouse_position().distance_to(global_position) > $Sprite2D.get_rect().size.x+offset and not explosao:
		rotation = direcao.angle()
		translate(direcao*velocidade*delta)
	
	$Sprite2D.scale = Vector2.ONE * zoom
	
	if Input.is_action_just_pressed("ui_accept") and not explosao:
		var bullet_node = bullet.instantiate()
		bullet_node.global_position = $Muzzle.global_position
		bullet_node.rotation = direcao.angle()
		bullet_node.dir = direcao
		get_parent().add_child(bullet_node)

var cir = Vector2.ZERO
func carrega_partes() ->void:
	var poly :Polygon2D = $Polygon2D
	
	var polA = poly.polygon
	
	for i in range(0,fragmentos):

		polA.append(Vector2(randf_range(-32,32),randf_range(-32,32)))
	poly.polygon = polA
	var new_geometry :PackedInt32Array = Geometry2D.triangulate_delaunay(poly.polygon)
	
	for i in range(0, new_geometry.size(), 3):
		var new_poly = Polygon2D.new()
		new_poly.script = load("res://scripts/dispersar.gd")
		get_parent().add_child(new_poly)
		
		var vertex_a = poly.polygon[new_geometry[i]]
		var vertex_b = poly.polygon[new_geometry[i+1]]
		var vertex_c = poly.polygon[new_geometry[i+2]]
		
		var triangle :PackedVector2Array = PackedVector2Array([
			vertex_a,
			vertex_b,
			vertex_c
		])
		
		new_poly.polygon = triangle
		new_poly.uv = triangle
		
		new_poly.global_position = Vector2.ZERO		
		#new_poly.color = Color.RED
		new_poly.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		new_poly.texture = preload("res://sprites/aviao.png")
		new_poly.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		new_poly.rotation = rotation-PI
		new_poly.global_position = global_position
		new_poly.texture_offset = Vector2(-32,-32)
		new_poly.texture_scale = Vector2.ONE/2.0
	
		var centro = (vertex_a + vertex_b + vertex_c)/3.0
		var d = (poly.to_global(centro)-poly.global_position).normalized()
		new_poly.dir = d
		partes.append(new_poly)
		poly.visible=false

#func _draw() -> void:
	#
	#if partes.size() > 0:
		#var centro0 = (partes[0].polygon[0] + partes[0].polygon[1] + partes[0].polygon[2])/3.0
		#var centro1 = (partes[1].polygon[0] + partes[1].polygon[1] + partes[1].polygon[2])/3.0
		#
		#draw_circle(to_local(partes[0].to_global(centro0)),5.5,Color.RED)
		#
		#draw_circle(to_local(partes[1].to_global(centro1)),5.5,Color.RED)
