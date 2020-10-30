extends Area2D

var A = 0.25
var f = 1.5
var x = 0.0

var amount = 40

func _physics_process(delta):
	position.y += A*sin(x*f)
	x = x+delta

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.heal_by(amount)
		self.queue_free()
