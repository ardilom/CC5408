extends KinematicBody2D

onready var player = get_node("/root/Main/Character")

var SPEED = 50
var linear_vel = Vector2()
var hp = 100 setget set_hp
var damage = 0.2
var dead = false

var coldown = 2.5

var coldown_spawn = 2

var timer =0
var alert = false 

func enemy_alerted(x):
	alert=x

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
	elif not dead:
		dead = true
		$AnimationPlayer.current_animation = "dies"

func _physics_process(delta):
	if alert and hp>0:
		var target = player.position
		var diff = target - position
		var target_vel = diff.normalized() * SPEED
		if hp>0:
			linear_vel = lerp(linear_vel, target_vel, 0.5)
			linear_vel = move_and_slide(linear_vel)
		else:
			SPEED=0

var enemies = [preload("res://Scene/Enemy.tscn"), preload("res://Scene/Enemy2.tscn")]

func instantiate_enemy(position):
#	var scene = get_node("")
	var enemy = enemies[randi()%2].instance()
	enemy.position = position
	add_child(enemy)


func _process(delta):
	
	timer +=delta
	if timer>coldown and alert and hp>0:
		shoot()
		timer=0
	
	if linear_vel.x < 0: 
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
		
	if timer > coldown_spawn:
		instantiate_enemy(Vector2(player.position.x+15, player.position.y))
		timer = 0




