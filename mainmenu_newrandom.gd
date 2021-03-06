extends Control

func _ready():
	pass # Replace with function body.

func _on_Back_pressed():
	get_tree().change_scene("res://mainmenu_1.tscn")

func _on_Start_pressed():
	GameLogic.TurnOnTerrorist = $C/V/M/R/ChTerror.pressed
	GameLogic.TurnOnWars = $C/V/M/R/ChWars.pressed
	GameLogic.TurnOnWMD = $C/V/M/R/ChWMD.pressed
	GameLogic.TurnOnInfiltration = $C/V/M/R/ChInfiltrate.pressed
	get_tree().change_scene("res://startplay.tscn")
