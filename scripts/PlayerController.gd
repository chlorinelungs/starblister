extends CharacterBody2D

#var acceleration := 40.0
var acceleration := 50.0
var max_acceleration := 550.0
var turn_speed := 7.5
var slow_turn_speed := turn_speed*2



func _ready(): 
	pass

func _physics_process(delta: float) -> void:

	var joystick_rotation = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	
	var shoot_vector = Vector2(-cos(%Pivot2D.rotation), -sin(%Pivot2D.rotation))

	# Rotates pivot at set rate
	%Pivot2D.rotation += joystick_rotation / turn_speed
	
	velocity = velocity.limit_length(max_acceleration)

	if Input.is_action_pressed("shoot"):
		velocity += shoot_vector * acceleration
		shoot()

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
