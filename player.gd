extends CharacterBody2D

class_name Player

@export var velocidade = 200.0
@export var ponteiro :Sprite2D
var direcao :Vector2 = Vector2.ZERO

func _ready() -> void:
	ponteiro.top_level = true

func _process(_delta: float) -> void:
	if Input.is_action_pressed("click"):
		ponteiro.global_position = get_global_mouse_position()
	
	direcao = (get_global_mouse_position()-global_position).normalized()
	
	look_at(get_global_mouse_position())
	
	queue_redraw()
	
func _physics_process(_delta: float) -> void:
	
	var direcao_y = clamp(Input.get_axis("ui_up","ui_down"), -1, 0)

	var movimento = (direcao * -direcao_y).normalized()
	velocity =  velocity.lerp(movimento * velocidade,0.1) #velocidade = deslocamento
	
	move_and_slide()
	
func _draw() -> void:
	draw_circle(to_local(ponteiro.global_position),10.0,Color.WHITE,true)
	draw_line(to_local(global_position), to_local(ponteiro.global_position),Color.WHITE, 3.0)

	
	
	
