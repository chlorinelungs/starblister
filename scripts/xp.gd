extends Area2D

var sin_increase = 0.02
var warp_scale = 0

var current_life = 0
var life_max = 4


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%Sprite2D.rotation += 0.05
	
	current_life += 0.005
	
	if current_life >= life_max:
		queue_free()
	
	warp_scale += sin_increase
	
	%Sprite2D.scale = Vector2(sin(warp_scale),sin(warp_scale))
	clampf(warp_scale,0.5,1)

func _on_body_entered(body: Node2D) -> void:
	queue_free()
	if body.has_method("gain_xp"):
		global_position += body.global_position
		body.gain_xp()
