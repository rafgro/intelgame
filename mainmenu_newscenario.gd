extends Control

var lastSelected = -1

func _ready():
	$C/V/M/R/Scenarios.add_item("Europe and Superpowers in 2021")

func _on_Scenarios_item_selected(index):
	lastSelected = index
	if index == 0:
		$C/V/M/R/Details.bbcode_text = "[b]Europe and Superpowers in 2021[/b]\n\n- Homeland as a new small country\n- Complex relations between US, China, and Russia\n- Very active Russian and Chinese intelligence services\n- Multiple turbulent social movements\n- Weakened Islamic State desperate to rebuild its power\n- Expensive travel and empty streets due to the pandemic"

func _on_Decision3_pressed():
	get_tree().change_scene("res://mainmenu_1.tscn")

func _on_Decision4_pressed():
	if lastSelected == 0:
		$C/V/M/R/Large.text = "Loading..."
		WorldData.Countries[0].Size = 3
		GameLogic.TurnOnTerrorist = true
		GameLogic.TurnOnWars = true
		GameLogic.TurnOnWMD = true
		GameLogic.TurnOnInfiltration = true
		GameLogic.FrequencyAttacks = 0.5
		GameLogic.SoftPowerMonthsAgo = ScenarioEurope21.GenerateWorld()
		GameLogic.StartAll()
		CallManager.CallQueue.append(
			{
				"Header": "Important Information",
				"Level": "Unclassified",
				"Operation": "-//-",
				"Content": "Welcome,\n\nHomeland created a new foreign intelligence agency and appointed you as the director.\n\nGather information from around the world, support national efforts, secure our nation from external threats.\n\nActivities of bureau should be guided by and will evaluated according to the list of priorities given by the government:\n- " + GameLogic.ListPriorities("\n- ") + "\n\nGood luck!",
				"Show1": false,
				"Show2": false,
				"Show3": false,
				"Show4": true,
				"Text1": "",
				"Text2": "",
				"Text3": "",
				"Text4": "Understood",
				"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision1Argument": null,
				"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision2Argument": null,
				"Decision3Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision3Argument": null,
				"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision4Argument": null,
			}
		)
		get_tree().change_scene("res://call.tscn")
