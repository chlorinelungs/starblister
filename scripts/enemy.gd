extends CharacterBody2D

var speed = 150
var health = 7

@onready var player = get_node("/root/World2D/PlayerNode2D")
@onready var hit_flash_animation_player = $HitFlash2D

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)

	velocity = direction * speed
	move_and_slide()

	%HealthBar.value = health
func take_damage():
	health -= 1
	hit_flash_animation_player.play("hit_flash")

	if health == 0:
		queue_free()
