extends Control

# Not only refreshing but also initiating all data on the main screen
func UpdateMainScreen():
	# date formatting
	$C/M/R/CDate/Date.text = GameLogic.GiveDateWithYear()
	# other
	$C/M/R/CTrust/TrustPercent.value = GameLogic.Trust
	$C/M/R/COfficer/Active.text = "Active officers: " + str(GameLogic.ActiveOfficers)
	var hqtext = ""
	if GameLogic.OfficersInHQ < 0: hqtext += "0"  # allowed in principle, because it sorts out itself
	else: hqtext += str(GameLogic.OfficersInHQ)
	$C/M/R/COfficer/HQAbroad.text = hqtext + " in HQ, " \
		+ str(GameLogic.OfficersAbroad) + " in action"
	$C/M/R/COperations/Pursued.text = "Active operations: " + str(GameLogic.PursuedOperations)
	if GameLogic.UltimatumTicker > 0:
		$C/M/R/COperations/Ticker.text = str(GameLogic.UltimatumTicker) + " weeks of ultimatum left"
	elif GameLogic.AttackTicker > 0:
		$C/M/R/COperations/Ticker.text = str(GameLogic.AttackTicker) + str(GameLogic.AttackTickerText)
	else: $C/M/R/COperations/Ticker.text = ""
	$C/M/R/CEvents2/RichTextLabel.bbcode_text = PoolStringArray(GameLogic.BureauEvents).join("\n")
	$C/M/R/CEvents4/RichTextLabel.bbcode_text = PoolStringArray(GameLogic.WorldEvents).join("\n")

# Called when the node enters the scene tree for the first time.
func _ready():
	UpdateMainScreen()

func _on_Panel_tree_entered():
	# trust, here to account for many possible screens before showing this one
	# a little bit of game logic happenning too, because thats the most logical place
	var trustDesc = ""
	if int(GameLogic.Trust-GameLogic.PreviousTrust) != 0:  # against zero to avoid reporting -0 for -0.235
		if GameLogic.Trust > GameLogic.PreviousTrust:
			trustDesc = "+" + str(int(GameLogic.Trust - GameLogic.PreviousTrust)) + "% change of government trust"
			if GameLogic.Trust >= 80 and GameLogic.PreviousTrust < 80:
				GameLogic.AddEvent("Thanks to increase of trust, bureau received universal clearance to perform all operations")
				GameLogic.UniversalClearance = true
		else:
			trustDesc = str(int(GameLogic.Trust - GameLogic.PreviousTrust)) + "% change of government trust"
			if GameLogic.Trust < 80 and GameLogic.PreviousTrust >= 80:
				GameLogic.AddEvent("Due to decrease of trust, bureau lost the universal clearance")
				GameLogic.UniversalClearance = false
		GameLogic.PreviousTrust = GameLogic.Trust
	$C/M/R/CDate/C/TrustChange.text = trustDesc

# Main event: moving a week forwad
func _on_NextWeek_pressed():
	$C/M/R/Buttons3/NextWeek.disabled = true
	$C/M/R/CDate/C/TrustChange.text = ""
	GameLogic.NextWeek()
	UpdateMainScreen()
	$C/M/R/Buttons3/NextWeek.disabled = false

func _on_Government_pressed():
	get_tree().change_scene("res://government.tscn")

func _on_GatheredIntel_pressed():
	get_tree().change_scene("res://gatheredintel.tscn")

func _on_Operations_pressed():
	get_tree().change_scene("res://operations.tscn")

func _on_Bureau_pressed():
	get_tree().change_scene("res://budget.tscn")

func _on_Tradecraft_pressed():
	get_tree().change_scene("res://craft.tscn")

func _on_Directions_pressed():
	get_tree().change_scene("res://directions.tscn")

func _on_SaveGame_pressed():
	pass # Replace with function body.
