extends Node
class_name Game_Manager

static var Instance : Game_Manager

var infection_level : int

func _init() -> void:
	Instance = self
