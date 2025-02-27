extends CharacterBody2D

var speed = 150
var health = 10

@onready var player = get_node("/root/World2D/PlayerNode2D")

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)

	velocity = direction * speed
	move_and_slide()

func take_damage():
	health -= 1

	if health == 0:
		queue_free()
