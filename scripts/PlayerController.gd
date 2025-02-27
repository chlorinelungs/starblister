extends CharacterBody2D

signal is_dead

#var acceleration := 40.0
var acceleration := 50.0
var max_acceleration := 550.0
var turn_speed := 8.5
var slow_turn_speed := turn_speed*2

var can_play := false
var play_timer_shoot := 0.0
var play_timer_hit := 0.0
var play_timer_increase := 0.5

var health := 100.0

@onready var hit_flash_animation_player = $HitFlash2D


func _ready(): 
	pass

func _physics_process(delta: float) -> void:

	var joystick_rotation = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	var shoot_vector = Vector2(-cos(%Pivot2D.rotation), -sin(%Pivot2D.rotation))

	# Rotates pivot at set rate
	%Pivot2D.rotation += joystick_rotation / turn_speed
	
	velocity = velocity.limit_length(max_acceleration)

	const DAMAGE := 10.0
	var overlapping_mobs = %Hurtbox2D.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		play_timer_hit += play_timer_increase
		print(play_timer_hit)

		if play_timer_hit >= 2.5:
			can_play = true
			play_timer_hit = 0
		else:
			can_play = false

		if can_play:
			%HurtSound2D.play()
		
		health -= DAMAGE * overlapping_mobs.size() * delta
		%HealthBar.value = health
		hit_flash_animation_player.play("hit_flash")
		if health <= 0.0:
			is_dead.emit()
			get_tree().reload_current_scene()

	if Input.is_action_just_pressed("holding"):
		%SkidSound2D.play()

	if Input.is_action_pressed("shoot"):
		play_timer_shoot += play_timer_increase
		print(play_timer_shoot)
		if play_timer_shoot >= 2:
			can_play = true
			play_timer_shoot = 0

			if can_play:
				%ShootSound2D.play()
			
		velocity += shoot_vector * acceleration
		if Input.is_action_pressed("holding"):
			%Camera2D.offset -= shoot_vector * 16
		else:
			%Camera2D.offset += shoot_vector * 4

		var camera_offset_limit := 100.0

		if Input.is_action_pressed("holding"):
			camera_offset_limit = camera_offset_limit * 2
		else:
			camera_offset_limit = 100.0

		if %Camera2D.offset.x > camera_offset_limit:
			%Camera2D.offset.x = camera_offset_limit
		if %Camera2D.offset.y > camera_offset_limit:
			%Camera2D.offset.y = camera_offset_limit
		
		if %Camera2D.offset.x < -camera_offset_limit:
			%Camera2D.offset.x = -camera_offset_limit
		if %Camera2D.offset.y < -camera_offset_limit:
			%Camera2D.offset.y = -camera_offset_limit

		shoot()
	else:
		%Camera2D.offset.x = lerpf(%Camera2D.offset.x,0,0.3)
		%Camera2D.offset.y = lerpf(%Camera2D.offset.y,0,0.3)

	if Input.is_action_pressed("holding"):
		#var hold_firmness = Input.get_action_strength("holding")
		turn_speed = slow_turn_speed
		slow_down()
	else:
		turn_speed = slow_turn_speed/2

	
	move_and_slide()

func slow_down():
	velocity.x = lerpf(velocity.x,0,0.2)
	velocity.y = lerpf(velocity.y,0,0.2)

func shoot():
	const BULLET = preload("res://scenes/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %GunSpawn2D.global_position
	new_bullet.global_rotation = %GunSpawn2D.global_rotation
	%GunSpawn2D.add_child(new_bullet)
