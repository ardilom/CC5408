extends KinematicBody2D

var target = Vector2()
var in_target = true
var linear_vel = Vector2()
var SPEED = 1000
var dashRange : float = 100
var hp = 100 setget set_hp
var damage = 15

onready var attack_area = get_node("AttackArea/CollisionShape2D")

# SCALING
var SCALE_SMALL = 0.5
var SCALE_NORMAL = 1
var SCALE_BIG = 2



func start_dash():
	target = get_global_mouse_position()
	in_target = false
	attack_area.disabled = false

func end_dash():
	in_target = true
	attack_area.disabled= true
	target = position

func _ready():
	attack_area.disabled= true

func receive_damag(amount):
	set_hp(hp-amount)

func set_hp(value):
	hp = clamp(value, 0, 100)
	$ProgressBar.value = hp


func _physics_process(delta):
	if Input.is_action_just_released("bigger") or Input.is_action_pressed("bigger") :
		scale = min(scale.x+0.1,SCALE_BIG) * Vector2.ONE
		linear_vel = move_and_slide(linear_vel)
		
	if Input.is_action_just_released("smaller") or Input.is_action_pressed("smaller"):
		scale = max(scale.x-0.1,SCALE_SMALL) * Vector2.ONE
		linear_vel = move_and_slide(linear_vel)

	if Input.is_action_just_pressed("dash"):
		start_dash()
		
	
	if not in_target:
		var diff = target - position
		var dist = diff.length()
	
		if dist > dashRange:
			target = position + diff.normalized() * dashRange
			dist = dashRange
	
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
			end_dash()
	


func _on_AttackArea_body_entered(body):
	if body.is_in_group("enemy"):
		body.receive_damage(damage)
		print("enemigo atacado")
