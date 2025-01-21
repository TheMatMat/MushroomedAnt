extends CollectibleBase

@export var object_properties : Object_Quest
@export var sprite : Sprite2D

func _ready() -> void:
	sprite.region_rect = object_properties.sprite_region


func on_collect() -> void:
	Player.Instance.check_if_item_needed(object_properties.index)
