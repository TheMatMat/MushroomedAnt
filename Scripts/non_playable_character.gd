extends StaticBody2D
class_name InGame_NPC

static var Instance : InGame_NPC

@export var properties : NPC
@export var sprite : Sprite2D
 
signal interact
signal quest_finished


func _init() -> void:
	Instance = self


func _ready() -> void:
	sprite.region_rect = properties.sprite_region


func _on_interact() -> void:
	var hud = get_tree().get_root().get_node("MainScene/hud")
	var player = Player.Instance
	var texts : Array[String]
	var quest_done = false
	
	if !Player.Instance.has_quest:
		texts.push_back(Parser.Instance.generate_intro_sentence())
		player.generate_quest()
		
		match player.current_quest_type:
			player.QuestType.ENEMIES:
				texts.push_back(Parser.Instance.generate_quest_kill_sentence())
				player.enemies_to_kill_count = Parser.Instance.nbr_fourmi
				hud.quest_count.text = "0/" + str(player.enemies_to_kill_count)
			player.QuestType.SPECIFIC_ENEMIES:
				texts.push_back(Parser.Instance.generate_quest_special_sentence())
				player.enemies_to_kill_count = Parser.Instance.nbr_fourmi
				hud.quest_count.text = "0/" + str(player.enemies_to_kill_count)
			player.QuestType.OBJECT:
				texts.push_back(Parser.Instance.generate_quest_fetch_sentence())
		
		hud.display_dialogue(texts, properties.name)
		
	else:
		match player.current_quest_type:
			player.QuestType.ENEMIES:
				quest_done = player.enemies_killed_count >= player.enemies_to_kill_count
			player.QuestType.SPECIFIC_ENEMIES:
				quest_done = player.enemies_killed[player.enemies_to_kill_index] >= player.enemies_to_kill_count
			player.QuestType.OBJECT:
				quest_done = player.current_object_quest_count >= player.current_object_quest_needed
		
		if !quest_done:
			texts.push_back(Parser.Instance.generate_invalid_sentence())
			hud.display_dialogue(texts, properties.name)
		else:
			texts.push_back(Parser.Instance.generate_quest_kill_valid_sentence())
			quest_finished.emit()
			player.reset_enemies_killed()
			player.reset_objects_collected()
			player.has_quest = false
			player.has_started = false
			Game_Manager.Instance.infection_level += 1 
			LevelGenerator.Instance.unspawn_rooms()
			hud.display_dialogue(texts, properties.name)
