extends Node2D

@export var width :float = 50.0
@export var height :float = 200.0
@export var padding :float = 10.0
## numero de pontos internos no retangulo, para 0 pontos, divide em 2 partes, para 1 pontos divide em 4 partes, para 2 pontos divide em 6 partes
@export var n_point :int = 10
## distancia minima entre os pontos
@export var min_dis_point :float = 10.0
@onready var build_array :PackedVector2Array = PackedVector2Array ([
	Vector2(0,0),
	Vector2(width,0),
	Vector2(width,height),
	Vector2(0,height)
])

func _ready() -> void:
	
	for i in range(0,n_point):
		var random_ponto :Vector2 = Vector2(randf_range(0.0+padding,width-padding), randf_range(0.0+padding,height-padding))
		var adicionar :bool = true
		for ponto in build_array:
			if ponto.distance_to(random_ponto) < min_dis_point:
				adicionar=false
		if adicionar:
			build_array.append(random_ponto)
		
	var material_de_fisica :PhysicsMaterial = PhysicsMaterial.new()
	material_de_fisica.bounce = 0.3
	
	var polA :Polygon2D = Polygon2D.new()
	polA.polygon = build_array
	polA.color = Color.RED
	#add_child(polA)
	
	var triangles :PackedInt32Array = Geometry2D.triangulate_delaunay(build_array)
	
	for k in range(0, triangles.size(), 3):
		var rig :RigidBody2D = RigidBody2D.new()
		var colisor :CollisionShape2D = CollisionShape2D.new()
		var formato_da_colisao :ConvexPolygonShape2D = ConvexPolygonShape2D.new()
		
		var a :Vector2 = build_array[triangles[k]]
		var b :Vector2 = build_array[triangles[k+1]]
		var c :Vector2 = build_array[triangles[k+2]]
		
		formato_da_colisao.points = PackedVector2Array([
			build_array[triangles[k]],
			build_array[triangles[k+1]],
			build_array[triangles[k+2]]
		])
		
		colisor.shape = formato_da_colisao
		
		var polNew :Polygon2D = Polygon2D.new()
		polNew.polygon = PackedVector2Array([
			build_array[triangles[k]],
			build_array[triangles[k+1]],
			build_array[triangles[k+2]]
		])
		polNew.color = Color.CRIMSON
		
		rig.physics_material_override = material_de_fisica
		rig.gravity_scale = 1.0
		rig.angular_damp = 0.0
		rig.center_of_mass_mode=RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
		rig.center_of_mass = (a+b+c)/3.0
		rig.add_child(colisor)
		rig.add_child(polNew)
		add_child(rig)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
