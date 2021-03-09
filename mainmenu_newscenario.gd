extends Control

var ScenarioEurope21 = load("res://scenarios/europe21.gd").new()
var ScenarioIran22 = load("res://scenarios/iran22.gd").new()
var ScenarioFrance11 = load("res://scenarios/france11.gd").new()
var ScenarioUs00 = load("res://scenarios/us00.gd").new()
var lastSelected = -1

func _ready():
	$C/V/M/R/Scenarios.add_item("Europe and Superpowers in 2021")
	$C/V/M/R/Scenarios.add_item("Iran developing WMD in 2020s")
	$C/V/M/R/Scenarios.add_item("ISIS growth and attacks in 2010s")
	$C/V/M/R/Scenarios.add_item("Al-Qaeda preparing 2001 attacks")

func _on_Scenarios_item_selected(index):
	lastSelected = index
	if index == 0: $C/V/M/R/Details.bbcode_text = ScenarioEurope21.Description
	elif index == 1: $C/V/M/R/Details.bbcode_text = ScenarioIran22.Description
	elif index == 2: $C/V/M/R/Details.bbcode_text = ScenarioFrance11.Description
	elif index == 3: $C/V/M/R/Details.bbcode_text = ScenarioUs00.Description

func _on_Decision3_pressed():
	get_tree().change_scene("res://mainmenu_1.tscn")

func _on_Decision4_pressed():
	if lastSelected == 0:
		$C/V/M/R/Large.text = "Loading..."
		ScenarioEurope21.StartAll()
		if $C/V/M/R/Onboarding.pressed == true: GameLogic.OnboardingIsOn(0)
		get_tree().change_scene("res://call.tscn")
	elif lastSelected == 1:
		$C/V/M/R/Large.text = "Loading..."
		ScenarioIran22.StartAll()
		if $C/V/M/R/Onboarding.pressed == true: GameLogic.OnboardingIsOn(0)
		get_tree().change_scene("res://call.tscn")
	elif lastSelected == 2:
		$C/V/M/R/Large.text = "Loading..."
		ScenarioFrance11.StartAll()
		if $C/V/M/R/Onboarding.pressed == true: GameLogic.OnboardingIsOn(0)
		get_tree().change_scene("res://call.tscn")
	elif lastSelected == 3:
		$C/V/M/R/Large.text = "Loading..."
		ScenarioUs00.StartAll()
		if $C/V/M/R/Onboarding.pressed == true: GameLogic.OnboardingIsOn(0)
		get_tree().change_scene("res://call.tscn")
