extends KinematicBody2D

var target = Vector2()
var in_target = true
var linear_vel = Vector2()
var SPEED = 200

var vel : Vector2
var dashSpeed : float = 1000
var dashRange : float = 100
var currentDashRange : float = dashRange
var isDashing : bool = false
var dashMousePos : Vector2



func _process(delta):
	if Input.is_action_just_pressed("dash"):
		target = get_global_mouse_position()
		in_target = false

func _physics_process(delta):
	if not in_target:
		var diff = target - position
		var dist = diff.length()
		
		if dist > dashRange:
			target = target.normalized() * dashRange
			diff = target - position
			dist = diff.length()
		
		var vec = diff/dist
		var target_vel = vec * SPEED
		var arrived = dist < SPEED * delta
		
		if arrived:
			target_vel = diff
		else:
			linear_vel = lerp(linear_vel, target_vel, 0.5)
		
		linear_vel = move_and_slide(linear_vel)
		
		if get_slide_count() > 0:
			in_target
			target = position
			
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.collider.is_in_group("player"):
				collision.collider.queue_free()
		
			
		if arrived:
			in_target = true
	
