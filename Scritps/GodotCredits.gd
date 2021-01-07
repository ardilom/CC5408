extends Node2D

const section_time := 2.0
const line_time := 0.3
const base_speed := 100
const speed_up_multiplier := 10.0
const title_color := Color.blueviolet

var scroll_speed := base_speed
var speed_up := false

onready var line := $CreditsContainer/Line
var started := false
var finished := false

var section
var section_next := true
var section_timer := 0.0
var line_timer := 0.0
var curr_line := 0
var lines := []

var credits = [
	[
		"A game by Compumundohipermegarred®"
	],[
		"Desarrollo y Diseño",
		"Marcos Gómez",
		"Pedro Popelka",
		"Felipe Ardila",
		"Raimundo Lorca"
	],[
		"Asset Heroe",
		"Kronovi-",
		"https://darkpixel-kronovi.itch.io/rogue-knight"
	],[
		"Asset Enemigos",
		"Sanctumpixel",
		"https://sanctumpixel.itch.io/imp-axe-demon-pixel-art-character"
	],[
		"Asset Mapa 1",
		"Pixel_Poem",
		"https://pixel-poem.itch.io/dungeon-assetpuck"
	],[
		"Asset Mapa 2",
		"",
		""
	],[
		"Asset Proyectiles",
		"Godot",
		"https://pixel-poem.itch.io/dungeon-assetpuck"
	],[
		"Musica y SFX",
		"Pedro Popelka"
	],[
		"Developed with Godot Engine",
		"https://godotengine.org/",
	],[
		"Script Creditos",
		"Ben Bishop",
		"https://github.com/benbishopnz/godot-credits"
	],[
		"Special thanks",
		"W.W",
		
	]
]


func _process(delta):
	var scroll_speed = base_speed * delta
	
	if section_next:
		section_timer += delta * speed_up_multiplier if speed_up else delta
		if section_timer >= section_time:
			section_timer -= section_time
			
			if credits.size() > 0:
				started = true
				section = credits.pop_front()
				curr_line = 0
				add_line()
	
	else:
		line_timer += delta * speed_up_multiplier if speed_up else delta
		if line_timer >= line_time:
			line_timer -= line_time
			add_line()
	
	if speed_up:
		scroll_speed *= speed_up_multiplier
	
	if lines.size() > 0:
		for l in lines:
			l.rect_position.y -= scroll_speed
			if l.rect_position.y < -l.get_line_height():
				lines.erase(l)
				l.queue_free()
	elif started:
		finish()


func finish():
	if not finished:
		finished = true
		# NOTE: This is called when the credits finish
		# - Hook up your code to return to the relevant scene here, eg...
		Global.times_generated = 0
		get_tree().change_scene("res://presentacion/portada.tscn")


func add_line():
	var new_line = line.duplicate()
	new_line.text = section.pop_front()
	lines.append(new_line)
	if curr_line == 0:
		new_line.add_color_override("font_color", title_color)
	$CreditsContainer.add_child(new_line)
	
	if section.size() > 0:
		curr_line += 1
		section_next = false
	else:
		section_next = true


func _unhandled_input(event):
	if event.is_action_pressed("next"):
		finish()
	if event.is_action_pressed("bigger") and !event.is_echo():
		speed_up = true
	if event.is_action_released("smaller") and !event.is_echo():
		speed_up = false
