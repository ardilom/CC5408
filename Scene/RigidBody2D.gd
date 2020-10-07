extends RigidBody2D

var vel : Vector2
var dashSpeed : float = 1000
var tolerance : float = 10
var dashRange : float = 100
var currentDashRange : float = dashRange
var isDashing : bool = false
var dashMousePos : Vector2



func _process(delta):
	if Input.is_action_just_pressed("dash"):
		_dash()
		print("DASH")

func _physics_process(delta):
	if (position - dashMousePos).length()<tolerance:
		_stop_dash()

func _dash():
	#if isDashing : return
	isDashing = true;
	
	#gets position on screen
	dashMousePos = get_global_mouse_position()
	
	#calculate vector direction based on position and range
	var direction = dashMousePos - position
	var length  = direction.length()
	if length < tolerance: return
	if length > dashRange:
		direction = direction.normalized() * dashRange
	
	#where char should end up
	dashMousePos = position + direction
	apply_impulse(Vector2(0.0,$CollisionShape2D.shape.extents.y/2), direction)

func _stop_dash():
	if(isDashing):
		currentDashRange = dashRange
		yield(get_tree().create_timer(0.3),"timeout")
		isDashing = false;
