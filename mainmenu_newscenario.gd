extends Control

var lastSelected = -1

func _ready():
	$C/V/M/R/Scenarios.add_item("Europe and Superpowers in 2021")

func _on_Scenarios_item_selected(index):
	lastSelected = index
	if index == 0:
		$C/V/M/R/Details.bbcode_text = ScenarioEurope21.Description

func _on_Decision3_pressed():
	get_tree().change_scene("res://mainmenu_1.tscn")

func _on_Decision4_pressed():
	if lastSelected == 0:
		$C/V/M/R/Large.text = "Loading..."
		ScenarioEurope21.StartAll()
		get_tree().change_scene("res://call.tscn")
