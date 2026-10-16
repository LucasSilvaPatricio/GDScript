extends Node2D

class_name PolygonTeste

var polygon_A :PackedVector2Array= PackedVector2Array([
	Vector2(0,0),
	Vector2(200, 0),
	Vector2(200,100),
	Vector2(0,100),

])

var polygon_B :PackedVector2Array = PackedVector2Array([
	Vector2(50,0),
	Vector2(100, 0),
	Vector2(200,100),
])

var rigs :Array[RigidBody2D]
var direcao
var origem
func _ready() -> void:
	for i in range(0,100):
		var padding = 10.0
		
		var x = randf_range(padding+0.0,200-padding)
		var y = randf_range(padding+0.0,100-padding)
		polygon_A.append(Vector2(x,y))
	var polA :Polygon2D = Polygon2D.new()
	polA.polygon = polygon_A
	polA.color = Color.INDIAN_RED
	#add_child(polA)
	
	var polB :Polygon2D = Polygon2D.new()
	polB.polygon = polygon_B
	polB.color = Color.AQUAMARINE
	#add_child(polB)
	
	#var pontos :Array[PackedVector2Array] = Geometry2D.clip_polygons(polygon_A, polygon_B)
	
	#for p in pontos:
	#	var polC = Polygon2D.new()
	#	polC.polygon = p
	#	polC.color = Color.ORANGE_RED
	#	add_child(polC)
	
	var triangulado = Geometry2D.triangulate_delaunay(polygon_A)

	for i in range(0, triangulado.size(),3):
		var rig = RigidBody2D.new()
		var col = CollisionShape2D.new()
		
		rig.gravity_scale = 0.0
		rig.center_of_mass = transform.origin
		rig.continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
		var phi :PhysicsMaterial = PhysicsMaterial.new()
		phi.friction = 0.5
		phi.bounce = 0.0
		col.disabled=true
		
		rig.physics_material_override = phi
		add_child(rig)
		rig.add_child(col)
		
		origem = Vector2(200.0/2.0, 100.0/2.0)
		
		var centro = (polygon_A[triangulado[i]]+polygon_A[triangulado[i+1]]+polygon_A[triangulado[i+2]])/3.0
		#rig.global_position = to_global(centro)
		#direcao = (rig.global_position-origem).normalized()

		var polC = Polygon2D.new()
		#polC.polygon = i
		polC.polygon = PackedVector2Array([
			polygon_A[triangulado[i]],
			polygon_A[triangulado[i+1]],
			polygon_A[triangulado[i+2]]
		])
		
		var convexPol :ConvexPolygonShape2D = ConvexPolygonShape2D.new()
		convexPol.points = polC.polygon
		col.shape = convexPol

		
		polC.texture_repeat=true
		
		polC.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		polC.texture = preload("res://sprites/nave.png")
		polC.uv = PackedVector2Array([
			Vector2(0,0),
			Vector2(10, 0),
			Vector2(10,10),
			Vector2(0,10),
		])
		

		
		rig.add_child(polC)
		rigs.append(rig)
		
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		for rig :RigidBody2D in rigs:
			rig.angular_velocity = randf_range(-2.0,2)
			rig.angular_damp = 0.0
			var col :CollisionShape2D = rig.get_child(0)
			var convexPol :ConvexPolygonShape2D = col.shape
			var centro = (convexPol.points[0]+convexPol.points[1]+convexPol.points[2])/3.0
			#rig.global_position = to_global(centro)
			var direcao = (to_global(centro)-origem).normalized()
			rig.apply_impulse(direcao*randf_range(10.0,20)*10)
