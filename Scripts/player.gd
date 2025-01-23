class_name Player extends CharacterBase

static var Instance : Player

enum QuestType{OBJECT, ENEMIES, SPECIFIC_ENEMIES}

@export_group("Input")
@export_range (0.0, 1.0) var controller_dead_zone : float = 0.3

var ui_opened : bool = false
var can_interact_with_npc : bool = true

# Collectible
var key_count : int


# Quests
var rng = RandomNumberGenerator.new()

var has_quest : bool
var current_quest_type : int

var enemies_to_kill_count : int
var enemies_killed_count : int
var enemies_to_kill_index : int
var enemies_killed : Array[int] = [0, 0]

var current_object_quest_index : int
var current_object_quest_needed : int
var current_object_quest_count : int


func _init() -> void:
	Instance = self


func _ready() -> void:
	_set_state(STATE.IDLE)


func _process(delta: float) -> void:
	super(delta)
	_update_inputs()
	_update_room()


func enter_room(room : Room) -> void:
	var previous = _room
	_room = room
	_room.on_enter_room(previous)


func _update_room() -> void:
	if _room == null:
		return
		
	var room_bounds : Rect2 = _room.get_world_bounds()
	var next_room : Room = null
	if position.x > room_bounds.end.x:
		next_room = _room.get_adjacent_room(Utils.ORIENTATION.EAST, position)
	elif position.x < room_bounds.position.x:
		next_room = _room.get_adjacent_room(Utils.ORIENTATION.WEST, position)
	elif position.y < room_bounds.position.y:
		next_room = _room.get_adjacent_room(Utils.ORIENTATION.NORTH, position)
	elif position.y > room_bounds.end.y:
		next_room = _room.get_adjacent_room(Utils.ORIENTATION.SOUTH, position)

	if next_room != null:
		enter_room(next_room)


func _update_inputs() -> void:
	if ui_opened:
		return
	
	if _can_move():
		_direction = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))
		if _direction.length() < controller_dead_zone:
			_direction = Vector2.ZERO
		else:
			_direction = _direction.normalized()

		if Input.is_action_pressed("Attack"):
			_attack()
	else:
		_direction = Vector2.ZERO


func _set_state(state : STATE) -> void:
	super(state)
	match _state:
		STATE.STUNNED:
			_current_movement = stunned_movemement
		STATE.DEAD:
			_end_blink()
			_set_color(dead_color)
		_:
			_current_movement = default_movement

	if !_can_move():
		_direction = Vector2.ZERO


func _update_state(delta : float) -> void:
	super(delta)
	match _state:
		STATE.ATTACKING:
			_spawn_attack_scene()
			_set_state(STATE.IDLE)


func reset_enemies_killed() -> void:
	enemies_killed_count = 0
	for i in enemies_killed.size():
		enemies_killed[i] = 0


func reset_objects_collected() -> void:
	current_object_quest_count = 0


func check_if_item_needed(object_index : int) -> void:
	if !has_quest or current_quest_type != QuestType.OBJECT:
		return
		
	if object_index == current_object_quest_index:
		current_object_quest_count += 1
		get_tree().get_root().get_node("MainScene/hud").quest_count.text = str(current_object_quest_count) + "/" + str(current_object_quest_needed)


func generate_quest() -> void:
	var hud = get_tree().get_root().get_node("MainScene/hud")
	var random = rng.randi_range(0, 2)
	
	match random:
		QuestType.ENEMIES:
			current_quest_type = QuestType.ENEMIES
			enemies_to_kill_count = rng.randi_range(4, 8)
			hud.quest_icon.texture = hud.enemies_sprite
			hud.quest_count.text = "0/" + str(enemies_to_kill_count)
		QuestType.SPECIFIC_ENEMIES:
			current_quest_type = QuestType.SPECIFIC_ENEMIES
			enemies_to_kill_index = 1
			enemies_to_kill_count = rng.randi_range(4, 8)
			hud.quest_icon.texture = hud.enemy_sprite[enemies_to_kill_index]
			hud.quest_count.text = "0/" + str(enemies_to_kill_count)
		QuestType.OBJECT:
			current_quest_type = QuestType.OBJECT
			current_object_quest_needed = 1
			current_object_quest_index = 0
			hud.quest_icon.texture = hud.object_sprite
			hud.quest_count.text = "0/" + str(current_object_quest_needed)
	
	has_quest = true
	hud.quest_icon.visible = true
	
