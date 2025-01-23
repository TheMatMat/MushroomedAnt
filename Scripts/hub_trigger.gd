extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if !Player.Instance.has_quest or Player.Instance.has_started:
		return
	
	var levelGenerator = LevelGenerator.Instance
	var player = Player.Instance
	
	levelGenerator.spawn_rooms()
	player.global_transform.origin = Vector2(0, 0)
	player.has_started = true
	
	match player.current_quest_type:
		Player.QuestType.ENEMIES:
			for room in levelGenerator.placed_rooms:
				levelGenerator.placed_rooms[room].room_scene.spawn_enemy1()
		Player.QuestType.SPECIFIC_ENEMIES:
			for room in levelGenerator.placed_rooms:
				levelGenerator.placed_rooms[room].room_scene.spawn_enemy2()
