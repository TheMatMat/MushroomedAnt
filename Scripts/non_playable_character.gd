extends StaticBody2D

@export var properties : NPC
@export var sprite : Sprite2D
 
signal interact

func _ready() -> void:
	sprite.region_rect = properties.sprite_region


func _on_interact() -> void:
	var hud = get_tree().get_root().get_node("MainScene/hud")
	var player = Player.Instance
	var texts : Array[String]
	var quest_done = false
	
	if !Player.Instance.has_quest:
		texts.push_back("Voilà une quête.")
		texts.push_back("Bonne chance !")
		player.generate_quest()
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
			texts.push_back("Termine ta mission !")
			hud.display_dialogue(texts, properties.name)
		else:
			texts.push_back("Bien joué, voici une autre mission.")
			player.reset_enemies_killed()
			player.reset_objects_collected()
			player.generate_quest()
			hud.display_dialogue(texts, properties.name)
