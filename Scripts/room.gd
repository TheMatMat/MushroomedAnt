class_name Room extends Node2D

@export var is_start_room : bool
# Position of the room in index coordinates. Coordinates {0,0} are the coordinates of the central room. Room {1,0} is on the right side of room {0,0}.
@export var room_pos : Vector2i = Vector2i.ZERO
# Size of the room in index coordinates. By default : {1,1}.
@export var room_size : Vector2i = Vector2i.ONE
@export var tilemap_layers : Array[TileMapLayer]

static var all_rooms : Array[Room]

enum RoomType {ONE_DOOR, OPPOSITE_DOORS, ADJACENT_DOORS, THREE_DOORS, FOUR_DOORS, NARRATIVE, SPAWN}

enum InfectionLevel {HIGH, MEDIUM, LOW}
@export var tilemaplayer_high : TileMapLayer
@export var tilemaplayer_medium : TileMapLayer
@export var tilemaplayer_low : TileMapLayer

var doors : Array[Door]

@export var room_type : RoomType

@onready var _cam : CameraFollow = $/root/MainScene/Camera2D




func _ready() -> void:
	all_rooms.push_back(self)

func get_local_bounds() -> Rect2:
	var room_bounds = Rect2()
	if tilemap_layers == null || tilemap_layers.size() == 0:
		return room_bounds
	## Encapsulate all tilemap_layers
	for tilemap in tilemap_layers:
		var bounds = tilemap.get_used_rect() # Gives rect in nb of tiles not pixels
		var size_pixel = tilemap.tile_set.tile_size
		bounds.position = Vector2i(bounds.position.x * size_pixel.x, bounds.position.y * size_pixel.y)
		bounds.size = Vector2i(bounds.size.x * size_pixel.x, bounds.size.y * size_pixel.y)
		room_bounds = room_bounds.merge(bounds)
	return room_bounds
		
		
func set_infection_aspect(infection_level : InfectionLevel) -> void:
	match infection_level:
		InfectionLevel.HIGH:
			if tilemaplayer_high != null:
				tilemaplayer_high.show()
				tilemaplayer_medium.hide()
				tilemaplayer_low.hide()
		InfectionLevel.MEDIUM:
			if tilemaplayer_medium != null:
				tilemaplayer_high.hide()
				tilemaplayer_medium.show()
				tilemaplayer_low.hide()
		InfectionLevel.LOW:
			if tilemaplayer_low != null:
				tilemaplayer_high.hide()
				tilemaplayer_medium.hide()
				tilemaplayer_low.show()
		_:
			tilemaplayer_high.hide()
			tilemaplayer_medium.hide()
			tilemaplayer_low.show()
			

func get_world_bounds() -> Rect2:
	var result = get_local_bounds()
	result.position += position
	return result

func recenter_at(position : Vector2) -> void:
	self.transform.origin = position - (get_local_bounds().size * Vector2(0.5, -0.5))

func contains(point : Vector2) -> bool:
	var bounds = get_world_bounds()
	return bounds.has_point(point)


func on_enter_room(from : Room) -> void:
	var camera_bounds = get_world_bounds()
	_cam.set_bounds(camera_bounds)


func get_adjacent_room(orientation : Utils.ORIENTATION, from : Vector2) -> Room:
	var dir : Vector2i = Utils.OrientationToDir(orientation)
	var adjacent_pos : Vector2i = room_pos + dir + get_position_offset(from)

	for room in all_rooms:
		if is_room_adjacent(room, adjacent_pos):
			return room
			
	return null


func is_room_adjacent(room : Room, adjacent_pos : Vector2) -> bool:
	return (
		adjacent_pos.x >= room.room_pos.x
		&& adjacent_pos.y >= room.room_pos.y
		&& adjacent_pos.x < room.room_pos.x + room.room_size.x
		&& adjacent_pos.y < room.room_pos.y + room.room_size.y
	)


func get_door(orientation : Utils.ORIENTATION, from : Vector2) -> Door:
	var door_position : Vector2i = Vector2i(position) + get_position_offset(from)
	for door in doors:
		var offsetPos = Vector2i(position) + get_position_offset(door.position)
		if door_position == offsetPos && door.orientation == orientation:
			return door
	return null


func get_position_offset(world_point : Vector2) -> Vector2i:
	if room_size.x <= 1 && room_size.y <= 1:
		return Vector2i.ZERO

	var offset : Vector2i = Vector2i.ZERO
	var bounds : Rect2 = get_world_bounds()
	var local_point : Vector2 = world_point - bounds.position

	if room_size.x > 1:
		offset.x = clampi(int(local_point.x / (bounds.size.x / room_size.x)), 0, room_size.x - 1)
	if room_size.y > 1:
		offset.y = clampi(int(local_point.y / (bounds.size.y / room_size.y)), 0, room_size.y - 1)
	return offset

# Function to determine door directions based on room type
func get_doors_local_direction(room_type: Room.RoomType) -> Array[Utils.ORIENTATION]:
	match room_type:
		Room.RoomType.ONE_DOOR:
			return [Utils.ORIENTATION.SOUTH]
		Room.RoomType.OPPOSITE_DOORS:
			return [Utils.ORIENTATION.EAST, Utils.ORIENTATION.WEST]
		Room.RoomType.ADJACENT_DOORS:
			return [Utils.ORIENTATION.SOUTH, Utils.ORIENTATION.WEST]
		Room.RoomType.THREE_DOORS:
			return [Utils.ORIENTATION.WEST, Utils.ORIENTATION.EAST, Utils.ORIENTATION.SOUTH]
		Room.RoomType.FOUR_DOORS:
			return [Utils.ORIENTATION.NORTH, Utils.ORIENTATION.EAST, Utils.ORIENTATION.SOUTH, Utils.ORIENTATION.WEST]
		Room.RoomType.SPAWN:
			return [Utils.ORIENTATION.SOUTH]
		Room.RoomType.NARRATIVE:
			return [Utils.ORIENTATION.SOUTH]
		_:
			return []

func get_number_of_doors() -> int:
	match room_type:
		Room.RoomType.ONE_DOOR:
			return 1
		Room.RoomType.OPPOSITE_DOORS:
			return 2
		Room.RoomType.ADJACENT_DOORS:
			return 2
		Room.RoomType.THREE_DOORS:
			return 3
		Room.RoomType.FOUR_DOORS:
			return 4
		_:
			return 0

func _exit_tree() -> void:
	all_rooms.erase(self)
	
func spawn_enemy1() -> void:
	if Game_Manager.Instance != null and Game_Manager.Instance.enemy1_scene == null:
		return
	
	var enemy_instance = Game_Manager.Instance.enemy1_scene.instantiate()
	call_deferred("add_child", enemy_instance)
	enemy_instance.transform.origin = transform.origin


func spawn_enemy2() -> void:
	if Game_Manager.Instance != null and Game_Manager.Instance.enemy2_scene == null:
		return
	
	var enemy_instance = Game_Manager.Instance.enemy2_scene.instantiate()
	call_deferred("add_child", enemy_instance)
	enemy_instance.transform.origin = transform.origin


func spawn_object() -> void:
	if Game_Manager.Instance != null and Game_Manager.Instance.object_scene == null:
		return
	
	var object_instance = Game_Manager.Instance.object_scene.instantiate()
	call_deferred("add_child", object_instance)
	object_instance.transform.origin = transform.origin
	print(global_position)
