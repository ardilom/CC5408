extends Node2D

func _process(delta):
	if Input.is_action_just_released("next"):
		get_tree().change_scene("res://Scene/MapGen2.tscn")
