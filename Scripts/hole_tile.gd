extends Area2D

@onready var collision_shape : CollisionShape2D = $"StaticBody2D/CollisionShape2D"
@onready var sprite : Sprite2D = $"Sprite2D"
@export var sprite_region_rect : Rect2


func _ready() -> void:
	collision_shape.disabled = true


func _on_body_exited(body: Node2D) -> void:
	collision_shape.set_deferred("disabled", false)
	sprite.region_rect = sprite_region_rect
