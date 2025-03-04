extends CharacterBody2D

signal is_dead

#var acceleration := 40.0
var acceleration := 50.0
var max_acceleration := 550.0
var turn_speed := 8.5
var slow_turn_speed := turn_speed*2

var play_increase = 0.5
var play_timer := 0.0

var health := 15.0

var level := 0
var level_max := 3
var level_inc := 0.5
var level_progress := 0.0

var button_held := 0
var fire_timer = 0.0

var touching := false

var score := 0

@onready var hit_flash_animation_player = $HitFlash2D

func _ready(): 
	pass

func _physics_process(delta: float) -> void:
	var joystick_rotation = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	
	print(level)
	
	%LevelBar.value = level_progress
	
	if level >= level_max:
		level = level_max
	
	# Rotates pivot at set rate
	%Pivot2D.rotation += joystick_rotation / turn_speed
	
	velocity = velocity.limit_length(max_acceleration)

	if Input.is_action_pressed("holding"):
		if Input.is_action_just_pressed("holding"):
			%SkidSound2D.play()
		#var hold_firmness = Input.get_action_strength("holding")
		turn_speed = slow_turn_speed
		
		velocity.x = lerpf(velocity.x,0,0.2)
		velocity.y = lerpf(velocity.y,0,0.2)
	else:
		turn_speed = slow_turn_speed/2
	
	if Input.is_action_pressed("shoot"):
		var fire_max = 4 - level
		fire_timer += 0.5
		if fire_timer >= fire_max:
			fire_gun()
			fire_timer = 0.0
			
	damage_player(delta)
	camera_controls()
	
	move_and_slide()

func shoot():
	const BULLET = preload("res://scenes/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %GunSpawn2D.global_position
	new_bullet.global_rotation = %GunSpawn2D.global_rotation
	%GunSpawn2D.add_child(new_bullet)

	
func damage_player(delta: float) -> void:
	const DAMAGE := 10.0
	var overlapping_mobs = %Hurtbox2D.get_overlapping_bodies()
		
	if overlapping_mobs.size() > 0:
		play_timer += play_increase
		play_sound(%HurtSound2D,2.5)
		health -= DAMAGE * overlapping_mobs.size() * delta
		%HealthBar.value = health
		hit_flash_animation_player.play("hit_flash")
		
		kill_player()
		
	
func kill_player():
	if health <= 0.0:
			is_dead.emit()
			get_tree().reload_current_scene()

func fire_gun():
	
	var shoot_vector = Vector2(-cos(%Pivot2D.rotation), -sin(%Pivot2D.rotation))
	#play_timer += play_increase
	#play_sound(%ShootSound2D,2.5)
	%ShootSound2D.play()
	shoot()
	velocity += shoot_vector * acceleration

func camera_controls():
	if Input.is_action_pressed("shoot"):
		var shoot_vector = Vector2(-cos(%Pivot2D.rotation), -sin(%Pivot2D.rotation))
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
	else:
		%Camera2D.offset.x = lerpf(%Camera2D.offset.x,0,0.3)
		%Camera2D.offset.y = lerpf(%Camera2D.offset.y,0,0.3)

func play_sound(_sound_source,_sound_length):
	
	var can_play := false
	
	if play_timer >= _sound_length:
		can_play = true
		play_timer = 0
	else:
		can_play = false
	if can_play:
		_sound_source.play()

func gain_xp():
	%GainXp2D.play()
	if level >= level_max:
		level = level_max
	else:
		%LevelUp2D.play()
		if level_progress >= 1:
			level_progress = 0
			level += 1
			score += 1
			
		level_progress += level_inc
		if level == 1:
			level_inc = 0.5
		elif level == 2:
			level_inc = 0.3
		elif level == 3:
			level_inc = 0.2
	
	


func _on_hurtbox_2d_body_entered(body: Node2D) -> void:
	
	if body.has_method("is_touching"):
		body.is_touching()
