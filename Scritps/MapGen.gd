extends Node2D

var scenes_tiles_size = 64

var target_size = 100

var character = preload("res://Scene/Character.tscn")
var enemies = [preload("res://Scene/Enemy.tscn"), preload("res://Scene/Enemy2.tscn")]

var rooms_1door = [preload("res://Rooms/Room1.tscn")]
var rooms_2_long = [preload("res://Rooms/Room2.tscn")]
var rooms_2_L = [preload("res://Rooms/Room2L.tscn")]
var rooms_3 = [preload("res://Rooms/Room3.tscn")]
var rooms_4 = [preload("res://Rooms/Room4.tscn")]
var rooms_start = [preload("res://Rooms/Room4.tscn")]
var rooms_boss = [preload("res://Rooms/Room1.tscn")]

const UP = 0x1
const RIGHT = 0x2
const DOWN = 0x4
const LEFT = 0x8

var room_count = 0
var generated = false
var instanciated_enemies = []

func _process(delta):
	if Input.is_action_just_released("next"):
		if generated:
			get_tree().change_scene("res://Scene/MapGen.tscn")
			generated = false
	if not generated:
		run_generation()
		generated = true
	for instanciated_enemy in instanciated_enemies:
		if not instanciated_enemy.dead:
			return
	get_tree().change_scene("res://Scene/MapGen.tscn")
	generated = false
	

var rooms_dictionary = {
	#1Door
	UP : [rooms_1door, 0],
	RIGHT : [rooms_1door, 90],
	LEFT : [rooms_1door, -90],
	DOWN : [rooms_1door, 180],
	#2Doors
	UP+DOWN : [rooms_2_long, 0],
	RIGHT + LEFT : [rooms_2_long, 90],
	#2DoorsL
	RIGHT+UP : [rooms_2_L, 0], 
	UP+LEFT : [rooms_2_L, -90], 
	LEFT+DOWN : [rooms_2_L, 180], 
	DOWN+RIGHT : [rooms_2_L, 90],
	#3Doors
	RIGHT+UP+LEFT : [rooms_3, 0], 
	UP+LEFT+DOWN : [rooms_3, -90], 
	LEFT+DOWN+RIGHT : [rooms_3, 180], 
	DOWN+RIGHT+UP : [rooms_3, 90],
	#4Doors
	RIGHT+UP+LEFT+ DOWN : [rooms_4,0]
}

var current_rooms_id_dictionary = {}

var directions = {Vector2(0,-1) : UP, Vector2(1,0) : RIGHT, Vector2(0,1) : DOWN, Vector2(-1,0) : LEFT}

func run_generation():
	instantiate_room(pick_from_array(rooms_start), Vector2.ZERO, 0.0)
	current_rooms_id_dictionary[Vector2.ZERO] = 15
	var open_rooms = directions.keys()
	var current_size = 1
	
	while room_count <= target_size:
		#choose a random available room space and place the correct room on it
		spawn_fitting_room_on(open_rooms, false)

	while open_rooms.size() > 0:
		#same but prefering rooms with low doors
		spawn_fitting_room_on(open_rooms, true)
	instantiate_character()
	for instanciated_enemy in instanciated_enemies:
		add_child(instanciated_enemy)
	
	print("Rooms generated: ", room_count)


func instantiate_character():
	var main_character = character.instance()
	main_character.scale = main_character.SCALE_SMALL * Vector2.ONE
	add_child(main_character, true)
	
func instantiate_enemy(position):
	var enemy = enemies[randi()%2].instance()
	enemy.position = position
	instanciated_enemies.append(enemy)
	

func instantiate_room(room_scene , coord : Vector2, rotation : float):
	var room = room_scene.instance()
	add_child(room)
	room.position.y = coord.y * scenes_tiles_size
	room.position.x = coord.x * scenes_tiles_size
	if randf() < 0.08:
		instantiate_enemy(room.position)
	room.set_rotation_degrees(rotation)
	room_count+=1

#put room into an available spot
func spawn_fitting_room_on(open_rooms, one_pref):
	#pop an available coordinate
	var coord = pop_from_array(open_rooms)
	#figure out which kin rooms fit that postion based on his neighbours
	var valid_rooms = find_valid_rooms(coord)
	#choose one kind of room based on preferences
	var id = pick_id(valid_rooms,one_pref)
	var data = rooms_dictionary.get(id)
	
	#add room to database
	current_rooms_id_dictionary[coord] = id

	#add availables spot based on his doors
	for dir in get_directions(id):
#		print("dir: " ,dir)
		if current_rooms_id_dictionary.get(coord + dir) == null and not open_rooms.has(coord+dir):
			open_rooms.append(coord+dir)
	
	#instantiate it into the world
	instantiate_room(pick_from_array(data[0]), coord ,data[1])

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
