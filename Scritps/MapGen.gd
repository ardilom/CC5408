extends Node2D

var scenes_tiles_size = 16*12
var target_size = 40

var character = preload("res://Scene/Character.tscn")
var enemies = [
	preload("res://Scene/Enemy.tscn"),
	preload("res://Scene/Enemy2.tscn"),
	#preload("res://Scene/Big_Boss.tscn")
]

var rooms_u = [preload("res://Rooms/RoomU.tscn")]
var rooms_r = [preload("res://Rooms/RoomR.tscn")]
var rooms_ru = [preload("res://Rooms/RoomRU.tscn")]
var rooms_d = [preload("res://Rooms/RoomD.tscn"), preload("res://Rooms/RoomD1.tscn"), preload("res://Rooms/RoomD2.tscn")]
var rooms_du = [preload("res://Rooms/RoomDU.tscn")]
var rooms_dr = [preload("res://Rooms/RoomDR.tscn"), preload("res://Rooms/RoomDR1.tscn"), preload("res://Rooms/RoomDR2.tscn")]
var rooms_dru = [preload("res://Rooms/RoomDRU.tscn")]
var rooms_l = [preload("res://Rooms/RoomL.tscn")]
var rooms_lu = [preload("res://Rooms/RoomLU.tscn")]
var rooms_lr = [preload("res://Rooms/RoomLR.tscn")]
var rooms_lru = [preload("res://Rooms/RoomLRU.tscn")]
var rooms_ld = [preload("res://Rooms/RoomLD.tscn")]
var rooms_ldu = [preload("res://Rooms/RoomLDU.tscn")]
var rooms_ldr = [preload("res://Rooms/RoomLDR.tscn")]
var rooms_ldru = [preload("res://Rooms/RoomLDRU.tscn")]

var rooms_start = [preload("res://Rooms/RoomLDRU.tscn")]

const UP = 0x1 #0001
const RIGHT = 0x2 #0010
const DOWN = 0x4 #0100
const LEFT = 0x8 #1000

var room_count = 0
var generated = false
var instanciated_enemies = []

func _process(delta):
	print(Global.times_generated)
	if Input.is_action_just_released("next"):
		if Global.times_generated > 5:
			get_tree().change_scene("res://Scene/GodotCredits.tscn")
		elif generated:
			Global.times_generated += 1
			get_tree().change_scene("res://Scene/MapGen.tscn")
	if not generated:
		run_generation()
		generated = true
	for instanciated_enemy in instanciated_enemies:
		if not instanciated_enemy.dead:
			return
	Global.times_generated += 1
	get_tree().change_scene("res://Scene/MapGen.tscn")

var rooms_dictionary = {
	#1Door
	UP : rooms_u,
	RIGHT : rooms_r,
	LEFT : rooms_l,
	DOWN : rooms_d,
	#2Doors
	UP+DOWN : rooms_du,
	RIGHT + LEFT : rooms_lr,
	#2DoorsL
	RIGHT+UP : rooms_ru, 
	UP+LEFT : rooms_lu, 
	LEFT+DOWN :  rooms_ld, 
	DOWN+RIGHT : rooms_dr,
	#3Doors
	RIGHT+UP+LEFT : rooms_lru, 
	UP+LEFT+DOWN : rooms_ldu, 
	LEFT+DOWN+RIGHT : rooms_ldr, 
	DOWN+RIGHT+UP : rooms_dru,
	#4Doors
	RIGHT+UP+LEFT+ DOWN : rooms_ldru
}

var current_rooms_id_dictionary = {}

var directions = {Vector2(0,-1) : UP, Vector2(1,0) : RIGHT, Vector2(0,1) : DOWN, Vector2(-1,0) : LEFT}

func run_generation():
	instantiate_room(pick_from_array(rooms_start), Vector2.ZERO)
	instantiate_character()
	current_rooms_id_dictionary[Vector2.ZERO] = 15
	var open_rooms = directions.keys()
	var current_size = 1
	
	while room_count <= target_size:
		#choose a random available room space and place the correct room on it
		spawn_fitting_room_on(open_rooms, false)

	while open_rooms.size() > 0:
		#same but prefering rooms with low doors
		spawn_fitting_room_on(open_rooms, true)
	
	for instanciated_enemy in instanciated_enemies:
		add_child(instanciated_enemy)
	
	print("Rooms generated: ", room_count)


func instantiate_character():
	var main_character = character.instance()
	main_character.scale = main_character.SCALE_SMALL * Vector2.ONE
	add_child(main_character, true)
	
func instantiate_enemy(position):
	var enemy = enemies[randi()%len(enemies)].instance()
	enemy.position = position
	instanciated_enemies.append(enemy)
	

func instantiate_room(room_scene , coord : Vector2):
	var room = room_scene.instance()
	add_child(room)
	room.position.y = coord.y * scenes_tiles_size
	room.position.x = coord.x * scenes_tiles_size
	if randf() < 0.08:
		instantiate_enemy(room.position)
	room_count+=1

#put room into an available spot
func spawn_fitting_room_on(open_rooms, one_pref):
	#pop an available coordinate
	var coord = pop_from_array(open_rooms)
	#figure out which kin rooms fit that postion based on his neighbours
	var valid_rooms = find_valid_rooms(coord)
	#choose one kind of room based on preferences
	var id = pick_id(valid_rooms,one_pref)
	var rooms = rooms_dictionary.get(id)
	
	#add room to database
	current_rooms_id_dictionary[coord] = id

	#add availables spot based on his doors
	for dir in get_directions(id):
#		print("dir: " ,dir)
		if current_rooms_id_dictionary.get(coord + dir) == null and not open_rooms.has(coord+dir):
			open_rooms.append(coord+dir)
	
	#instantiate it into the world
	instantiate_room(pick_from_array(rooms), coord)

func find_valid_rooms(cell):
	var b1 = [1,2,4,8]
	var b2 = [3,5,6,9,10,12]
	var b3 = [7,11,13,14]
	var b4 = [15]
	return [check_fitting_room_by_ids(b1, cell),
	check_fitting_room_by_ids(b2, cell),
	check_fitting_room_by_ids(b3, cell),
	check_fitting_room_by_ids(b4, cell)]

func check_fitting_room_by_ids(array, cell):
	var matches=[]
	for i in array:
		var is_match = false
		for n in directions.keys():
			var neighbor_id = current_rooms_id_dictionary.get(cell + n)
			if neighbor_id != null:
				var dirn = directions[-n]
				var dirN = directions[n]
				if(neighbor_id& dirn)/dirn == (i&dirN)/dirN:
					is_match = true
				else:
					is_match = false
					break
		if is_match:
			matches.append(i)
	return matches

func pick_id(valid_rooms, one_pref):
	if  one_pref:
		for i in range(4):
			if valid_rooms[i].size()>0:
				return pick_from_array(valid_rooms[i])
		print("EXCEPTION ONE PREF")
	if not one_pref:
		var order = [1,2,3]
		order.shuffle()
		
		for i in order:
			if not valid_rooms[i].empty():
				return pick_from_array(valid_rooms[i])
		print("???!?!! valid rooms: ", valid_rooms, " order: ", order)
		return pick_from_array(valid_rooms[0])
	print("EXCEPTION NOT ONE PREF")

func get_directions(id):
	var dirs=[]
	for dir in directions.keys():
		if(id%2==1):
			dirs.append(dir)
		id= id/2
	return dirs

func pick_from_array(array):
	var size = array.size()
	if(size == 0):
		print("UN ARRAY DE LARGO CERO")
		return
	randomize()
	return array[randi() % array.size()]

func pop_from_array(array):
	var size = array.size()
	if(size == 0):
		print("UN ARRAY DE LARGO CERO")
		return
	randomize()
	var index = randi() % array.size()
	var pick = array[index]
	array.remove(index)
	return pick
