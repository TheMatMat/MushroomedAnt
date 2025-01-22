extends Node

class RoomData:
	var position_levelwise: Vector2
	var rotation : int #0, 90, 180, 270
	var distance_to_spawn : int
	var number_of_doors : int
	var doors_world_direction : Array[Utils.ORIENTATION]
	var room_scene : Room = null

var directions = [Utils.ORIENTATION.NONE, Utils.ORIENTATION.NORTH, Utils.ORIENTATION.EAST, Utils.ORIENTATION.SOUTH, Utils.ORIENTATION.WEST]

var placed_rooms : Dictionary
@export var all_rooms : Array[Room]
@export var all_rooms_sorted = {
		Room.RoomType.ONE_DOOR: [],
		Room.RoomType.OPPOSITE_DOORS: [],
		Room.RoomType.ADJACENT_DOORS: [],
		Room.RoomType.THREE_DOORS: [],
		Room.RoomType.FOUR_DOORS: []
	}

@export var max_distance_to_spawn : int = 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	all_rooms = dir_contents("res://Scenes/Rooms/OurRooms")
	all_rooms_sorted = {
		Room.RoomType.ONE_DOOR: [],
		Room.RoomType.OPPOSITE_DOORS: [],
		Room.RoomType.ADJACENT_DOORS: [],
		Room.RoomType.THREE_DOORS: [],
		Room.RoomType.FOUR_DOORS: []
	}
	
	for room in all_rooms:
		all_rooms_sorted[room.room_type].append(room)
		
	for room_type in all_rooms_sorted.keys():
		print("Room Type: ", room_type, " -> ", all_rooms_sorted[room_type])

		
	if all_rooms.size() <= 0:
		print("No room to spawn")
		return
	
	# Create the first room
	var first_room = all_rooms.pick_random()
	Player.Instance._room = first_room
	Player.Instance.transform.origin = first_room.transform.origin
	
	# Fill the dictionary with the first room
	var room_data = RoomData.new()
	room_data.position_levelwise = Vector2(0, 0)
	room_data.rotation = 0#randi() % 4 * 90
	room_data.distance_to_spawn = 0
	room_data.number_of_doors = first_room.get_number_of_doors()
	room_data.doors_world_direction = Utils.transform_directions(first_room.get_doors_local_direction(first_room.room_type), room_data.rotation)
	
	placed_rooms[room_data.position_levelwise] = room_data
	
	# Iterate over its doors to spawn rooms
	for direction in room_data.doors_world_direction:
		var new_room_data = RoomData.new()
		new_room_data.distance_to_spawn = 1
		
		new_room_data.doors_world_direction.append(Utils.get_opposite_direction(direction))
		
		match direction:
			Utils.ORIENTATION.NORTH:
				new_room_data.position_levelwise = Vector2(0, -1)
			Utils.ORIENTATION.WEST:
				new_room_data.position_levelwise = Vector2(-1, 0)
			Utils.ORIENTATION.SOUTH:
				new_room_data.position_levelwise = Vector2(0, 1)
			Utils.ORIENTATION.EAST:
				new_room_data.position_levelwise = Vector2(1, 0)
				
		place_rooms(new_room_data, direction, Utils.get_opposite_direction(direction))
	
	print_placed_rooms()
	
	add_doors_to_common_walls()
	ensure_all_rooms_connected()
	place_rooms_at_positions()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func place_rooms(current_room_data : RoomData, initial_direction : Utils.ORIENTATION, incoming_direction : Utils.ORIENTATION) -> void:
	placed_rooms[current_room_data.position_levelwise] = current_room_data
	
	if current_room_data.distance_to_spawn >= max_distance_to_spawn:
		return

	var possible_directions = directions.filter(
		func(direction):
			return direction != Utils.ORIENTATION.NONE and direction != incoming_direction
	)

	# Ensure at least one room spawns
	var spawned_directions = []
	var initial_spawned = false

	for direction in possible_directions:
		if direction == initial_direction:
			# 75% chance for the initial direction
			if randi() % 100 < 75:
				spawned_directions.append(direction)
				initial_spawned = true
		else:
			# Handle the two remaining directions
			if randi() % 100 < 50:
				spawned_directions.append(direction)

	# If no room was spawned, force at least one
	if not initial_spawned and spawned_directions.is_empty():
		spawned_directions.append(initial_direction)

	# Handle the 25% chance for both remaining directions
	if len(spawned_directions) == 1 and len(possible_directions) > 2:
		var other_directions = possible_directions.filter(func(d): return d not in spawned_directions)
		if randi() % 100 < 25:
			spawned_directions.append(other_directions[0])

	# Place rooms for each selected direction
	for direction in spawned_directions:
		var next_room_data = RoomData.new()
		next_room_data.distance_to_spawn = current_room_data.distance_to_spawn + 1

		match direction:
			Utils.ORIENTATION.NORTH:
				next_room_data.position_levelwise = current_room_data.position_levelwise - Vector2(0, 1)
			Utils.ORIENTATION.EAST:
				next_room_data.position_levelwise = current_room_data.position_levelwise + Vector2(1, 0)
			Utils.ORIENTATION.SOUTH:
				next_room_data.position_levelwise = current_room_data.position_levelwise + Vector2(0, 1)
			Utils.ORIENTATION.WEST:
				next_room_data.position_levelwise = current_room_data.position_levelwise - Vector2(1, 0)
			_:
				continue

		# Check if there's already a room at these coordinates
		if placed_rooms.has(next_room_data.position_levelwise):
			continue

		place_rooms(next_room_data, initial_direction, Utils.get_opposite_direction(direction))

func add_doors_to_common_walls():
	for position_levelwise in placed_rooms.keys():
		var room_data = placed_rooms[position_levelwise]

		# Define neighbor directions and positions
		var neighbors = {
			Utils.ORIENTATION.NORTH: position_levelwise - Vector2(0, 1),
			Utils.ORIENTATION.EAST: position_levelwise + Vector2(1, 0),
			Utils.ORIENTATION.SOUTH: position_levelwise + Vector2(0, 1),
			Utils.ORIENTATION.WEST: position_levelwise - Vector2(1, 0)
		}

		var added_door = false  # Track if a door has been added

		for direction in neighbors.keys():
			var neighbor_position = neighbors[direction]

			# Check if neighbor exists
			if placed_rooms.has(neighbor_position):
				var neighbor_data = placed_rooms[neighbor_position]
				var opposite_direction = Utils.get_opposite_direction(direction)

				# Randomly decide to add a door for this common wall
				if direction not in room_data.doors_world_direction and randi() % 2 == 0:
					room_data.doors_world_direction.append(direction)
					if opposite_direction not in neighbor_data.doors_world_direction:
						neighbor_data.doors_world_direction.append(opposite_direction)
					added_door = true

		# Ensure the room has at least one door
		if not added_door and room_data.doors_world_direction.is_empty():
			for direction in neighbors.keys():
				var neighbor_position = neighbors[direction]
				if placed_rooms.has(neighbor_position):
					room_data.doors_world_direction.append(direction)
					var neighbor_data = placed_rooms[neighbor_position]
					var opposite_direction = Utils.get_opposite_direction(direction)
					if opposite_direction not in neighbor_data.doors_world_direction:
						neighbor_data.doors_world_direction.append(opposite_direction)
					break  # Ensure only one door is added to meet the requirement

	print("Updated placed_rooms with new doors (", placed_rooms.size() , "):")
	for pos in placed_rooms.keys():
		print("Room at ", pos, " has doors: ", placed_rooms[pos].doors_world_direction)
		
# Helper function to perform a depth-first search (DFS) to find all connected rooms
func dfs(start_position: Vector2, visited: Dictionary, placed_rooms: Dictionary):
	visited[start_position] = true
	var current_room = placed_rooms[start_position]
	for direction in current_room.doors_world_direction:
		var neighbor_position = start_position
		match direction:
			Utils.ORIENTATION.NORTH:
				neighbor_position -= Vector2(0, 1)
			Utils.ORIENTATION.EAST:
				neighbor_position += Vector2(1, 0)
			Utils.ORIENTATION.SOUTH:
				neighbor_position += Vector2(0, 1)
			Utils.ORIENTATION.WEST:
				neighbor_position -= Vector2(1, 0)
		if placed_rooms.has(neighbor_position) and not visited.has(neighbor_position):
			dfs(neighbor_position, visited, placed_rooms)
			
# Main function to ensure all rooms are connected
func ensure_all_rooms_connected():
	# Step 1: Find all connected rooms starting from (0, 0)
	var visited_rooms = {}
	dfs(Vector2(0, 0), visited_rooms, placed_rooms)

	# Step 2: Identify unconnected rooms
	var unconnected_rooms = []
	for position in placed_rooms.keys():
		if not visited_rooms.has(position):
			unconnected_rooms.append(position)

	# Step 3: Connect unconnected rooms to the closest connected room
	for unconnected_position in unconnected_rooms:
		# Find the closest connected room
		var closest_position = null
		var min_distance = INF
		for connected_position in visited_rooms.keys():
			var distance = unconnected_position.distance_to(connected_position)
			if distance < min_distance:
				min_distance = distance
				closest_position = connected_position

		if closest_position != null:
			# Determine the direction to connect the unconnected room to the closest connected room
			var direction_to_closest = Utils.get_direction(unconnected_position - closest_position)
			var opposite_direction = Utils.get_opposite_direction(direction_to_closest)

			# Add doors to link the rooms
			placed_rooms[unconnected_position].doors_world_direction.append(opposite_direction)
			placed_rooms[closest_position].doors_world_direction.append(direction_to_closest)

		# Update visited rooms
		visited_rooms[unconnected_position] = true

	print("All rooms are now connected to (0, 0).")
	
func place_rooms_at_positions():
	for position_levelwise in placed_rooms.keys():
		var room_data = placed_rooms[position_levelwise]

		# Step 1: Select the appropriate room based on the number of doors
		var selected_room : Room = null
		match room_data.doors_world_direction.size():
			1:
				if all_rooms_sorted[Room.RoomType.ONE_DOOR] and all_rooms_sorted[Room.RoomType.ONE_DOOR].size() > 0:
					selected_room = all_rooms_sorted[Room.RoomType.ONE_DOOR].pick_random().duplicate()
			2:
				var door_difference = abs(room_data.doors_world_direction[0] - room_data.doors_world_direction[1])
				if door_difference == 1:
					if all_rooms_sorted[Room.RoomType.ADJACENT_DOORS] and all_rooms_sorted[Room.RoomType.ADJACENT_DOORS].size() > 0:
						selected_room = all_rooms_sorted[Room.RoomType.ADJACENT_DOORS].pick_random().duplicate()
				else:
					if all_rooms_sorted[Room.RoomType.OPPOSITE_DOORS] and all_rooms_sorted[Room.RoomType.OPPOSITE_DOORS].size() > 0:
						selected_room = all_rooms_sorted[Room.RoomType.OPPOSITE_DOORS].pick_random().duplicate()
			3:
				if all_rooms_sorted[Room.RoomType.THREE_DOORS] and all_rooms_sorted[Room.RoomType.THREE_DOORS].size() > 0:
					selected_room = all_rooms_sorted[Room.RoomType.THREE_DOORS].pick_random().duplicate()
			4:
				if all_rooms_sorted[Room.RoomType.FOUR_DOORS] and all_rooms_sorted[Room.RoomType.FOUR_DOORS].size() > 0:
					selected_room = all_rooms_sorted[Room.RoomType.FOUR_DOORS].pick_random().duplicate()
			_:
				print("No room type found for ", room_data.number_of_doors, " doors.")
				continue

		# Step 2: Attempt to match local and world directions by rotating
		var default_directions = selected_room.get_doors_local_direction(selected_room.room_type)
		var room_rotation = 0
		var matched = false

		while room_rotation < 360:
			# Transform local directions to world directions based on the current rotation
			var transformed_directions = Utils.transform_directions(default_directions, room_rotation)
			
			# Check if the transformed directions match the expected world directions
			if directions_match(transformed_directions, room_data.doors_world_direction):
				matched = true
				break  # Exit the loop if a match is found

			# Increment rotation by 90 degrees and try again
			room_rotation += 90

		# Step 3: If no match is found after a full turn, log and skip placement
		if not matched:
			print("Could not match local and world directions for room at ", position_levelwise)
			continue

		# Step 4: Apply the calculated rotation to the room
		#selected_room.rotation_degrees = room_rotation

		# Step 5: Add the room to the scene at the specified position
		selected_room.position = position_levelwise * 352
		selected_room.rotation_degrees = room_rotation
		add_child(selected_room)

		# Ensure the room is correctly placed in the placed_rooms dictionary
		placed_rooms[position_levelwise].room_scene = selected_room

		print("Placed room at ", selected_room.position, " with rotation ", room_rotation)

# Helper function to compare local and world directions
func directions_match(local_directions: Array, world_directions: Array) -> bool:
	# Ensure both arrays are sorted to eliminate order dependency
	local_directions.sort()
	world_directions.sort()

	# Check if the sizes match
	if local_directions.size() != world_directions.size():
		return false

	# Compare each element in the sorted arrays
	for i in range(local_directions.size()):
		if local_directions[i] != world_directions[i]:
			return false

	return true

func dir_contents(path) -> Array[Room]:
	var scene_loads: Array[Room]

	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				if file_name.get_extension() == "tscn":
					var full_path = path.path_join(file_name)
					scene_loads.append(load(full_path).instantiate())
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

	return scene_loads
	
func print_placed_rooms():
	print("Placed rooms (", placed_rooms.size() ,"):")
	for room in placed_rooms:
		print("Position: ", placed_rooms[room].position_levelwise,
			  " | Rotation: ", placed_rooms[room].rotation, 
			  " | Distance to spawn: ", placed_rooms[room].distance_to_spawn, 
			  " | Doors: ", placed_rooms[room].doors_world_direction)
