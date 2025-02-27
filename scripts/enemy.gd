extends CharacterBody2D

var speed = 150
var health = 7

var play_timer_hit := 0.0
var play_timer_increase := 0.5
var can_play := false

@onready var player = get_node("/root/World2D/PlayerNode2D")
@onready var hit_flash_animation_player = $HitFlash2D

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)

	velocity = direction * speed
	move_and_slide()

	%HealthBar.value = health
func take_damage():
	health -= 1
	play_timer_hit += play_timer_increase
	if play_timer_hit >= 1.5:
		can_play = true
		play_timer_hit = 0
	else:
		can_play = false
	
	if can_play:
		%HurtSound2D.play()

	#%HurtSound2D.play()
	hit_flash_animation_player.play("hit_flash")

	if health == 0:
		queue_free()
