extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if !Player.Instance.has_quest:
		return
		
	LevelGenerator.Instance.spawn_rooms()
	Player.Instance.global_transform.origin = Vector2(0, 0)
