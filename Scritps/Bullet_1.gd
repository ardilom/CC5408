extends KinematicBody2D

var vel = -300

func _physics_process(delta):
	move_and_slide(vel*get_global_transform().y)
