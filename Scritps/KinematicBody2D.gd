extends KinematicBody2D

var target = Vector2()
var in_target = true
var linear_vel = Vector2()
var SPEED = 1000
var dashRange : float = 100
var hp = 100 setget set_hp
var damage = 20

onready var attack_area = get_node("AttackArea/CollisionShape2D")

# SCALING
var SCALE_SMALL = 0.5
var SCALE_NORMAL = 1
var SCALE_BIG = 2

onready var playback = $AnimationTree.get("parameters/playback")

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

func heal_by(value):
	set_hp(value + hp)

func set_hp(value):
	hp = clamp(value, 0, 100)
	$ProgressBar.value = hp


func _physics_process(delta):
	if Input.is_action_just_released("bigger") or Input.is_action_pressed("bigger") :
		
		var new_scale = min(scale.x + 0.1, SCALE_BIG) * Vector2.ONE
		
		var space_state = get_world_2d().direct_space_state
		var shape: RectangleShape2D = $CollisionShape2D.shape.duplicate()
		shape.extents *= new_scale
		var query = Physics2DShapeQueryParameters.new()
		query.set_shape(shape)
		query.exclude = [self]
		query.transform.origin = global_position
		var result = space_state.intersect_shape(query)
		var normal = Vector2()
		# can grow if blocked by 1 side or less
		var can_grow = true
		var only_left = true
		var only_right = true
		var only_up = true
		var only_down = true
		for r in result:
			if r.collider is TileMap:
				var tilemap: TileMap = r.collider
				# TODO make an inverse relationship
				var tile_normal = (global_position - tilemap.map_to_world(r.metadata)).normalized()
				only_left = only_left and (tile_normal.x > 0)
				only_right = only_right and (tile_normal.x < 0) 
				only_up = only_up and (tile_normal.y > 0)
				only_down = only_down and (tile_normal.y < 0)
				normal += tile_normal
		if result.size() > 0:
			target = global_position + normal.normalized()
			in_target = false
	#		position += normal.normalized() * 4
		if only_down or only_left or only_right or only_up:
			scale = new_scale
	#		linear_vel = move_and_slide(linear_vel)
		
	if Input.is_action_just_released("smaller") or Input.is_action_pressed("smaller"):
		scale = max(scale.x-0.1,SCALE_SMALL) * Vector2.ONE
#		linear_vel = move_and_slide(linear_vel)

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
			target = position
		
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.collider.is_in_group("player"):
				collision.collider.queue_free()
		
			
		if arrived:
			end_dash()
			
	
	if linear_vel.length_squared() == 0:
		playback.travel("Hold")
		
	if Input.is_action_just_pressed("dash"):
		playback.travel("Dash")
		
#	if hp == 0:
#		playback.travel("Die")
		
		
	if linear_vel.x < 0: 
		$Sprite2.flip_h = true
	if linear_vel.x > 0:
		$Sprite2.flip_h = false
		


func _on_AttackArea_body_entered(body):
	if body.is_in_group("enemy"):
		body.receive_damage(damage)
		print("enemigo atacado")
