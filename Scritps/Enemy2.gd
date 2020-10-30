extends KinematicBody2D


onready var player = get_node("/root/Main/Character")

var SPEED = 50
var linear_vel = Vector2()
var hp = 100 setget set_hp
var damage = 0.2

var coldown = 2.5

var timer =0

func shoot():
	var proyectile = load("res://Scene/Bullet_1.tscn")
	for i in range(12):
		var bullet = proyectile.instance()
		bullet.set_rotation_degrees(i*360/12)
		add_child_below_node(get_tree().get_root().get_node("Main"),bullet)


func receive_damage(amount):
	if hp>0:
		set_hp(hp-amount)

func set_hp(value):
	hp = clamp(value, 0, 100)
	$ProgressBar.value = hp
	if hp>0:
		$AnimationPlayer.current_animation = "idle"
	else:
		$AnimationPlayer.current_animation = "dies"

func _physics_process(delta):
	var target = player.position
	var diff = target - position
	var target_vel = diff.normalized() * SPEED
	if hp>0:
		linear_vel = lerp(linear_vel, target_vel, 0.5)
		linear_vel = move_and_slide(linear_vel)
	else:
		SPEED=0


func _process(delta):
	
	timer +=delta
	if timer>coldown:
		shoot()
		timer=0
	
	if linear_vel.x < 0: 
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
