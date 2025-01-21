extends Area2D

@onready var sprite = $"Sprite2D"
@export var spikes_out_rect : Rect2

var original_rect : Rect2

func _ready() -> void:
	original_rect = sprite.region_rect

func _on_body_entered(body:Node2D) -> void:
	if Player.Instance == null:
		return
	
	if body != Player.Instance:
		return

	Player.Instance.apply_hit(null)
	sprite.region_rect = spikes_out_rect


func _on_body_exited(body: Node2D) -> void:
	if Player.Instance == null:
		return
	
	if body != Player.Instance:
		return
		
	sprite.region_rect = original_rect
