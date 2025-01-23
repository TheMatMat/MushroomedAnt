class_name CharacterBase extends RigidBody2D

signal life_changed(current_life : int)

enum ORIENTATION {FREE, DPAD_8, DPAD_4}
enum STATE {IDLE, ATTACKING, STUNNED, DEAD}

@export_group("Life")
@export var life : int = 3 :
	set(value) :
		life = value
		life_changed.emit(life)
@export var invincibility_duration : float = 1.0
@export var invincibility_blink_period : float = 0.2
@export var dead_color : Color = Color.GRAY
@export var sprites : Array[Sprite2D] = []

@export_group("Movement")
@export var default_movement : MovementParameters
@export var stunned_movemement : MovementParameters

@export_group("Attack")
@export var attack_scene : PackedScene
@export var attack_spawn_point : Node2D
@export var attack_cooldown : float = 0.3
@export var orientation : ORIENTATION = ORIENTATION.FREE

# Life
var _last_hit_time : float

# Movement
var _direction : Vector2
var _current_movement : MovementParameters

# Attack
var _last_attack_time : float
var _has_to_apply_knockback : bool
var _knockback_value : Vector2

# State
var _state : STATE = STATE.IDLE
var _is_blinking : bool

# Dungeon position
var _room #: Room

@onready var main_sprite : Sprite2D = $"BodySprite"


func _process(delta: float) -> void:
	_update_state(delta)


func apply_hit(attack : Attack) -> void:
	if Time.get_unix_time_from_system() - _last_hit_time < invincibility_duration:
		return
	_last_hit_time = Time.get_unix_time_from_system()
	
	var hud = get_tree().get_root().get_node("MainScene/hud")
	var player = Player.Instance

	life -= attack.damages if attack != null else 1
	if life <= 0:
		if is_in_group("Enemy") and player.has_quest and player.current_quest_type == Player.QuestType.ENEMIES:
			player.enemies_killed_count += 1
			hud.quest_count.text = str(player.enemies_killed_count) + "/" + str(player.enemies_to_kill_count)
			if player.enemies_killed_count >= player.enemies_to_kill_count:
				player.global_transform.origin = Vector2(-1000000, -1000000)
		if self is Enemy and player.has_quest and player.current_quest_type == Player.QuestType.SPECIFIC_ENEMIES:
			player.enemies_killed[(self as Enemy).index] += 1
			hud.quest_count.text = str(player.enemies_killed[(self as Enemy).index]) + "/" + str(player.enemies_to_kill_count)
			if player.enemies_killed[(self as Enemy).index] >= player.enemies_to_kill_count:
				player.global_transform.origin = Vector2(-1000000, -1000000)
		_set_state(STATE.DEAD)
	else:
		if attack != null && attack.knockback_duration > 0.0:
			apply_knockback(attack.knockback_duration, (attack.position - position).normalized() * attack.knockback_speed)
		_end_blink()
		blink()


func apply_knockback(duration : float, velocity : Vector2) -> void:
	_set_state(STATE.STUNNED)
	_has_to_apply_knockback = true
	_knockback_value = velocity
	await get_tree().create_timer(duration).timeout
	_set_state(STATE.IDLE)


func _update_state(delta : float) -> void:
	pass


func _set_state(state : STATE) -> void:
	_state = state


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _has_to_apply_knockback:
		state.linear_velocity = _knockback_value
		_has_to_apply_knockback = false

	if _direction.length() > 0.000001:
		state.linear_velocity += _direction * _current_movement.acceleration * get_physics_process_delta_time()
		state.linear_velocity = state.linear_velocity.limit_length(_current_movement.speed_max)
		main_sprite.rotation = _compute_orientation_angle(_direction)
	else:
		## If direction length == 0, Apply friction
		var friction_length = _current_movement.friction * get_physics_process_delta_time()
		if state.linear_velocity.length() > friction_length:
			state.linear_velocity -= state.linear_velocity.normalized() * friction_length
		else:
			state.linear_velocity = Vector2.ZERO


func blink() -> void:
	_is_blinking = true
	var invincibility_timer : float = 0.0
	while invincibility_timer < invincibility_duration:
		if !_is_blinking:
			return

		invincibility_timer += get_process_delta_time()
		var isVisible : bool = (int)(invincibility_timer/ invincibility_blink_period) % 2 == 1
		for sprite in sprites:
			sprite.visible = isVisible
		await get_tree().process_frame

	_end_blink()


func _end_blink() -> void:
	if !_is_blinking:
		return

	for sprite in sprites:
		sprite.visible = true

	_is_blinking = false


func _set_color(color : Color) -> void:
	for sprite in sprites:
		sprite.modulate = color


func _compute_orientation_angle(direction : Vector2) -> float:
	var angle = direction.angle()
	match orientation:
		ORIENTATION.DPAD_8:
			return Utils.DiscreteAngle(angle, 45)
		ORIENTATION.DPAD_4:
			return Utils.DiscreteAngle(angle, 90)
	return angle


func _attack() -> void:
	if Time.get_unix_time_from_system() - _last_attack_time < attack_cooldown:
		return

	_last_attack_time = Time.get_unix_time_from_system()
	_set_state(STATE.ATTACKING)


func _spawn_attack_scene() -> void:
	if attack_scene == null:
		return

	var spawn_position = attack_spawn_point.global_position if attack_spawn_point != null else global_position
	var spawn_rotation = attack_spawn_point.global_rotation if attack_spawn_point != null else global_rotation
	var spawned_attack = attack_scene.instantiate() as Attack
	get_tree().root.add_child(spawned_attack)
	spawned_attack.global_position = spawn_position
	spawned_attack.global_rotation = spawn_rotation
	spawned_attack.attack_owner = self

func _can_move() -> bool:
	return _state == STATE.IDLE
