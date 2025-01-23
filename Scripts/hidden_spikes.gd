extends Area2D

@onready var sprite = $"Sprite2D"
@export var spikes_out_rect : Rect2

var original_rect : Rect2
var on_spike : bool

func _ready() -> void:
	original_rect = sprite.region_rect

func _on_body_entered(body:Node2D) -> void:
	if Player.Instance == null:
		return
	
	if body != Player.Instance:
		return
	
	on_spike = true
	await get_tree().create_timer(1).timeout
	sprite.region_rect = spikes_out_rect
	if on_spike:
		Player.Instance.apply_hit(null)


func _on_body_exited(body: Node2D) -> void:
	if Player.Instance == null:
		return
	
	if body != Player.Instance:
		return
		
	on_spike = false
	await get_tree().create_timer(1).timeout
	sprite.region_rect = original_rect
