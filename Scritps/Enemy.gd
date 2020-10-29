extends KinematicBody2D

onready var player = get_node("/root/Main/Character")
var SPEED = 100
var linear_vel = Vector2()
var hp = 100 setget set_hp
var damage = 1

func receive_damage(amount):
	set_hp(hp-amount)

func set_hp(value):
	hp = clamp(value, 0, 100)
	$ProgressBar.value = hp
	if hp >0:
		$AnimationPlayer.current_animation = "idle"
	else:
		$AnimationPlayer.current_animation = "dies"

func _physics_process(delta):
	var target = player.position
	var diff = target - position
	var target_vel = diff.normalized() * SPEED
	
	linear_vel = lerp(linear_vel, target_vel, 0.5)
	linear_vel = move_and_slide(linear_vel)

func _process(delta):
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if hp>0:
			if collision.collider.is_in_group("player"):
				collision.collider.receive_damag(damage)
				$AnimationPlayer.current_animation = "attack"
		else:
			$AnimationPlayer.current_animation = "dies"
			
	if linear_vel.x < 0: 
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false


