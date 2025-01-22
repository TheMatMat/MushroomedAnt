extends CanvasLayer

@export var heart_scene : PackedScene

@export var enemy_sprite : Array[Texture2D]
@export var enemies_sprite : Texture2D
@export var object_sprite : Texture2D

var previous_life : int

@onready var life_container : BoxContainer = $"LifeContainer"
@onready var dialogue_panel : Panel = $"DialoguePanel"
@onready var dialogue_text : Label = $"DialoguePanel/Text"
@onready var dialogue_npc_name : Label = $"DialoguePanel/CharacterName"
@onready var quest_icon : TextureRect = $"QuestIcon"
@onready var quest_count : Label = $"QuestIcon/Text"

var rng = RandomNumberGenerator.new()

signal next_line

func _ready() -> void:
	previous_life = Player.Instance.life
	Player.Instance.life_changed.connect(_on_life_changed)
	dialogue_panel.visible = false
	quest_icon.visible = false
	for heart in previous_life:
		_add_heart()


func _on_life_changed(new_life : int) -> void:
	if new_life < previous_life:
		_remove_heart()
	elif new_life > previous_life:
		_add_heart()


func _add_heart() -> void:
	var heart = heart_scene.instantiate()
	life_container.add_child(heart)


func _remove_heart() -> void:
	if life_container.get_child_count() == 0:
		return

	var heart =	life_container.get_child(0)
	life_container.remove_child(heart)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Attack"):
		next_line.emit()


func display_dialogue(lines : Array[String], npc_name : String) -> void:
	Player.Instance.ui_opened = true
	Player.Instance.can_interact_with_npc = false
	dialogue_panel.visible = true
	dialogue_npc_name.text = npc_name
	
	for index in lines.size():
		dialogue_text.text = lines[index]
		
		await get_tree().create_timer(0.25).timeout
		await next_line
	
	Player.Instance.ui_opened = false
	
	await get_tree().create_timer(0.20).timeout
	
	dialogue_panel.visible = false
	Player.Instance.can_interact_with_npc = true


func display_random_dialogue(lines : Array[String], npc_name : String) -> void:
	Player.Instance.ui_opened = true
	Player.Instance.can_interact_with_npc = false
	dialogue_panel.visible = true
	dialogue_npc_name.text = npc_name
	
	dialogue_text.text = lines[rng.randi_range(0, lines.size()-1)]
		
	await get_tree().create_timer(0.25).timeout
	await next_line
	
	Player.Instance.ui_opened = false
	
	await get_tree().create_timer(0.20).timeout
	
	dialogue_panel.visible = false
	Player.Instance.can_interact_with_npc = true
