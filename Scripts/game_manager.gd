extends Node
class_name Game_Manager

static var Instance : Game_Manager

@onready var hub : Room = $/root/MainScene/Hub

var enemy1_scene = preload("res://Scenes/enemy.tscn")
var enemy2_scene = preload("res://Scenes/enemy2.tscn")
var object_scene = preload("res://Scenes/quest_object.tscn")

var infection_level : int

func _init() -> void:
	Instance = self
