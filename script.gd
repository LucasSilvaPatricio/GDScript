@tool
extends Node

var label :Label3D
var mesh :MeshInstance3D
var sphere_mesh :BoxMesh
var initialized :bool = false
var material :StandardMaterial3D

@export var visible_label: bool = true:
	set(value):
		visible_label = value
		if initialized:
			update_label()
	get():
		return visible_label
			
@export var text: String = "" :
	set(value):
		text = value
		if initialized:
			update_label()
	get():
		return text
		
@export_range(6,5000) var size :int = 12:
	set(value):
		size = value
		if initialized:
			update_label()
	get():
		return size
		
@export var billboard :bool = true:
	set(value):
		billboard = value
		if initialized:
			update_label()
	get():
		return billboard

@export var visible_point :bool = true:
	set(value):
		visible_point = value
		if initialized:
			update_mesh()
	get():
		return visible_point

@export var color :Color = Color.GREEN :
	set(value):
		color = value
		if initialized:
			update_mesh()
	get():
		return color
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Engine.is_editor_hint() and initialized:
		if label != null:
			label.visible = false
			mesh.visible=false
	else:	
		if not initialized and owner:
			create(text, billboard, size)
			update_label()
			update_mesh()
			initialized = true

func create(text: String,billb :bool, size :int) -> void:
	label = Label3D.new()
	label.text = text
	label.font_size = size
	label.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	label.no_depth_test = true
	
	mesh = MeshInstance3D.new()
	sphere_mesh = BoxMesh.new()
	sphere_mesh.size=Vector3(0.2,0.2,0.2)
	material = StandardMaterial3D.new()
	material.albedo_color = color
	#material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	sphere_mesh.material = material
	mesh.mesh = sphere_mesh
	
	mesh.visible=visible_point
	if billb:
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	else:
		label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	add_child(label)
	add_child(mesh)
	label.position = Vector3(0,0.15,0)	
	mesh.position = Vector3.ZERO

func update_label() -> void:
	label.text = text
	label.font_size = size
	label.visible=visible_label
	if billboard:
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	else:
		label.billboard = BaseMaterial3D.BILLBOARD_DISABLED

func update_mesh() -> void:
	mesh.visible = visible_point
	material.albedo_color = color
	if not visible_point:
		label.position = Vector3.ZERO
	else:
		label.position = Vector3(0,0.15,0)
