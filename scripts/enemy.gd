extends CharacterBody2D

signal enemy_death

var speed = 150
var health = 5

var play_timer = 0 
var play_timer_increase = 0.5
var touching := false
var touch_count := 0.0

@onready var player = get_node("/root/World2D/PlayerNode2D")
@onready var hit_flash_animation_player = $HitFlash2D

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	
	if touching:
		touch_count += 1
		if touch_count >= 3:
			kill()
		print(touch_count)

	velocity = direction * speed
	move_and_slide()

func take_damage():
	health -= 1
	play_timer += play_timer_increase
	
	play_sound(%HurtSound2D,2)
	
	#%HurtSound2D.play()
	hit_flash_animation_player.play("hit_flash")

	if health <= 0:
		kill()
		
func play_sound(_sound_source,_sound_length):
	
	var can_play := false
	
	if play_timer >= _sound_length:
		can_play = true
		play_timer = 0
	else:
		can_play = false
	if can_play:
		_sound_source.play()
		
func kill():
	#enemy_death.emit(global_position)
	
	if not touching:
		spawn_xp()
	queue_free()


func spawn_xp():
	const XP = preload("res://scenes/xp.tscn")
	var new_xp = XP.instantiate()
	new_xp.global_position = global_position
	get_node("..").add_child(new_xp)
	
func is_touching():
	touching = true
	
	pass
	#kill()
