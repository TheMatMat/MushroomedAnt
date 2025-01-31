extends Node
class_name Parser

static var Instance : Parser

const intro1_path = "res://Resources/Texts/Intro.json"
const intro2_path = "res://Resources/Texts/Intro2.json"
const intro3_path = "res://Resources/Texts/Intro3.json"
const invalid_path = "res://Resources/Texts/Invalid.json"
const invalid2_path = "res://Resources/Texts/Invalid2.json"

const quest_kill1_path = "res://Resources/Texts/Quest_Kill1.json"
const quest_kill1_valid_path = "res://Resources/Texts/Quest_Kill_Valid.json"
const quest_kill2_path = "res://Resources/Texts/Quest_Kill2.json"
const quest_kill2_valid_path = "res://Resources/Texts/Quest_Kill2_Valid.json"

const quest_valid3_path = "res://Resources/Texts/Quest_Valid3.json"

const quest_special1_path = "res://Resources/Texts/Quest_special1.json"
const quest_special2_path = "res://Resources/Texts/Quest_Special2.json"
const quest_special_valid_path = "res://Resources/Texts/Quest_Special_Valid.json"

const quest_fetch_path = "res://Resources/Texts/Quest_fetch.json"
const quest_fetch3_path = "res://Resources/Texts/Quest_fetch3.json"
const quest_fetch_valid_path = "res://Resources/Texts/Quest_fetch_Valid.json"

var intro1_parsed_text
var intro2_parsed_text
var intro3_parsed_text
var invalid_parsed_text
var invalid2_parsed_text
var quest_kill1_parsed_text
var quest_kill1_valid_parsed_text
var quest_kill2_parsed_text
var quest_kill2_valid_parsed_text
var quest_valid3_parsed_text
var quest_special1_parsed_text
var quest_special2_parsed_text
var quest_special_valid_parsed_text
var quest_fetch_parsed_text
var quest_fetch3_parsed_text
var quest_fetch_valid_parsed_text

var nbr_fourmi


func _init() -> void:
	Instance = self


func _ready() -> void:
	var file = FileAccess.open(intro1_path, FileAccess.READ)
	var text = file.get_as_text()
	intro1_parsed_text = JSON.parse_string(text)
	
	file = FileAccess.open(intro2_path, FileAccess.READ)
	text = file.get_as_text()
	intro2_parsed_text = JSON.parse_string(text)
	
	file = FileAccess.open(intro3_path, FileAccess.READ)
	text = file.get_as_text()
	intro3_parsed_text = JSON.parse_string(text)
	
	file = FileAccess.open(invalid_path, FileAccess.READ)
	text = file.get_as_text()
	invalid_parsed_text = JSON.parse_string(text)
	
	file = FileAccess.open(invalid2_path, FileAccess.READ)
	text = file.get_as_text()
	invalid2_parsed_text = JSON.parse_string(text)
	
	file = FileAccess.open(quest_kill1_path, FileAccess.READ)
	text = file.get_as_text()
	quest_kill1_parsed_text = JSON.parse_string(text)
	
	file = FileAccess.open(quest_kill1_valid_path, FileAccess.READ)
	text = file.get_as_text()
	quest_kill1_valid_parsed_text = JSON.parse_string(text)
	
	file = FileAccess.open(quest_kill2_path, FileAccess.READ)
	text = file.get_as_text()
	quest_kill2_parsed_text = JSON.parse_string(text)
	
	file = FileAccess.open(quest_kill2_valid_path, FileAccess.READ)
	text = file.get_as_text()
	quest_kill2_valid_parsed_text = JSON.parse_string(text)
	
	file = FileAccess.open(quest_valid3_path, FileAccess.READ)
	text = file.get_as_text()
	quest_valid3_parsed_text = JSON.parse_string(text)
	
	file = FileAccess.open(quest_special1_path, FileAccess.READ)
	text = file.get_as_text()
	quest_special1_parsed_text = JSON.parse_string(text)
	
	file = FileAccess.open(quest_special2_path, FileAccess.READ)
	text = file.get_as_text()
	quest_special2_parsed_text = JSON.parse_string(text)
	
	file = FileAccess.open(quest_special_valid_path, FileAccess.READ)
	text = file.get_as_text()
	quest_special_valid_parsed_text = JSON.parse_string(text)
	
	file = FileAccess.open(quest_fetch_path, FileAccess.READ)
	text = file.get_as_text()
	quest_fetch_parsed_text = JSON.parse_string(text)
	
	file = FileAccess.open(quest_fetch3_path, FileAccess.READ)
	text = file.get_as_text()
	quest_fetch3_parsed_text = JSON.parse_string(text)
	
	file = FileAccess.open(quest_fetch_valid_path, FileAccess.READ)
	text = file.get_as_text()
	quest_fetch_valid_parsed_text = JSON.parse_string(text)


func generate_intro_sentence() -> String:
	var text
	match Game_Manager.Instance.infection_level:
		0:
			text = intro1_parsed_text
		1: 
			text = intro2_parsed_text
		2: 
			text = intro3_parsed_text
	
	if text == null || !text is Dictionary:
		return ""
	var template = text["origin"].pick_random()
	for key in text.keys():
		if key != "origin":
			template = template.replace("#%s#" % key, text[key].pick_random())
	return template


func generate_invalid_sentence() -> String:
	var text
	match Game_Manager.Instance.infection_level:
		0:
			text = invalid_parsed_text
		1: 
			text = invalid2_parsed_text
			
	if text == null || !text is Dictionary:
		return ""
	var template = text["origin"].pick_random()
	for key in text.keys():
		if key != "origin":
			template = template.replace("#%s#" % key, text[key].pick_random())
	return template


func generate_quest_kill_sentence() -> String:
	var text
	match Game_Manager.Instance.infection_level:
		0:
			text = quest_kill1_parsed_text
		1: 
			text = quest_kill2_parsed_text
	
	if text == null || !text is Dictionary:
		return ""
	var template = text["origin"].pick_random()
	for key in text.keys():
		if key != "origin":
			var picked_text = text[key].pick_random()
			template = template.replace("#%s#" % key, picked_text)
			if key == "nbrFourmis":
				nbr_fourmi = int(picked_text)
	return template


func generate_quest_kill_valid_sentence() -> String:
	var text
	match Game_Manager.Instance.infection_level:
		0:
			text = quest_kill1_valid_parsed_text
		1: 
			text = quest_kill2_valid_parsed_text
		2: 
			text = quest_valid3_parsed_text
			
	if text == null || !text is Dictionary:
		return ""
	var template = text["origin"].pick_random()
	for key in text.keys():
		if key != "origin":
			template = template.replace("#%s#" % key, text[key].pick_random())
	return template


func generate_quest_special_sentence() -> String:
	var text
	match Game_Manager.Instance.infection_level:
		0:
			text = quest_special1_parsed_text
		1: 
			text = quest_special2_parsed_text
		2: 
			text = quest_special2_parsed_text
			
	if text == null || !text is Dictionary:
		return ""
	var template = text["origin"].pick_random()
	for key in text.keys():
		if key != "origin":
			var picked_text = text[key].pick_random()
			template = template.replace("#%s#" % key, picked_text)
			if key == "nbrFourmis":
				nbr_fourmi = int(picked_text)
	return template


func generate_quest_special_valid_sentence() -> String:
	var text = quest_special_valid_parsed_text
	if text == null || !text is Dictionary:
		return ""
	var template = text["origin"].pick_random()
	for key in text.keys():
		if key != "origin":
			var picked_text = text[key].pick_random()
			template = template.replace("#%s#" % key, picked_text)
	return template


func generate_quest_fetch_sentence() -> String:
	var text
	match Game_Manager.Instance.infection_level:
		0:
			text = quest_fetch_parsed_text
		1: 
			text = quest_fetch_parsed_text
		2: 
			text = quest_fetch3_parsed_text
			
	if text == null || !text is Dictionary:
		return ""
	var template = text["origin"].pick_random()
	for key in text.keys():
		if key != "origin":
			var picked_text = text[key].pick_random()
			template = template.replace("#%s#" % key, picked_text)
			if key == "nbrFourmis":
				nbr_fourmi = int(picked_text)
	return template


func generate_quest_fetch_valid_sentence() -> String:
	var text = quest_fetch_valid_parsed_text
	if text == null || !text is Dictionary:
		return ""
	var template = text["origin"].pick_random()
	for key in text.keys():
		if key != "origin":
			var picked_text = text[key].pick_random()
			template = template.replace("#%s#" % key, picked_text)
	return template
