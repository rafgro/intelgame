extends Node

func _ready():
	GameLogic.StartAll()
	get_tree().change_scene("res://main.tscn")
