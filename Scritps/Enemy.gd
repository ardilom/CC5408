extends KinematicBody2D


onready var player = get_node("/root/Main/Character")
onready var playback = $AnimationTree.get("parameters/playback")
var SPEED = 100
var linear_vel = Vector2()
var hp = 100 setget set_hp
var damage = 0.2
var dead = false
var alert = false #variable de alerta si enemy esta en el area de character
func receive_damage(amount):
	if hp>0:
		set_hp(hp-amount)

func set_hp(value):
	hp = clamp(value, 0, 100)
	$ProgressBar.value = hp
	if hp >0:
		playback.travel("idle")
	else:
		playback.travel("dies")

func _physics_process(delta):
	if alert:
		var target = player.position
		var diff = target - position
		var target_vel = diff.normalized() * SPEED
		if hp>0:
			linear_vel = lerp(linear_vel, target_vel, 0.5)
			linear_vel = move_and_slide(linear_vel)
		else:
			SPEED=0
	else:
		playback.travel("idle")
		



func _process(delta):
	if hp>0:
		var near_player = false
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			
			if collision.collider.is_in_group("player"):
				collision.collider.receive_damag(damage)
				near_player = true
		if near_player:
			playback.travel("attack")
		else:
			playback.travel("idle")
	elif not dead:
		playback.travel("dies")
		dead = true

			
	if linear_vel.x < 0: 
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
		
	if linear_vel.length_squared()>10 and hp>0:
		playback.travel("demon_walk")

func enemy_alerted(x):
	alert=x
	
	
