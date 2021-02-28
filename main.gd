extends Panel

# Not only refreshing but also initiating all data on the main screen
func UpdateMainScreen():
	# date formatting
	$M/R/CDate/Date.text = GameLogic.GiveDateWithYear()
	# other
	$M/R/CTrust/TrustPercent.value = GameLogic.Trust
	$M/R/COfficer/Active.text = "Active officers: " + str(GameLogic.ActiveOfficers)
	$M/R/COfficer/HQAbroad.text = str(GameLogic.OfficersInHQ) + " in HQ, " \
		+ str(GameLogic.OfficersAbroad) + " on the ground"
	$M/R/COperations/Pursued.text = "Active operations: " + str(GameLogic.PursuedOperations)
	if GameLogic.AttackTicker > 0:
		$M/R/COperations/Ticker.text = str(GameLogic.AttackTicker) + " weeks to possible attack"
	elif GameLogic.UltimatumTicker > 0:
		$M/R/COperations/Ticker.text = str(GameLogic.UltimatumTicker) + " weeks of ultimatum left"
	else: $M/R/COperations/Ticker.text = ""
	$M/R/CEvents2/RichTextLabel.bbcode_text = PoolStringArray(GameLogic.BureauEvents).join("\n")
	$M/R/CEvents4/RichTextLabel.bbcode_text = PoolStringArray(GameLogic.WorldEvents).join("\n")

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
	$M/R/CDate/C/TrustChange.text = trustDesc

# Main event: moving a week forwad
func _on_NextWeek_pressed():
	$M/R/Buttons3/NextWeek.disabled = true
	$M/R/CDate/C/TrustChange.text = ""
	GameLogic.NextWeek()
	UpdateMainScreen()
	$M/R/Buttons3/NextWeek.disabled = false

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
	get_tree().change_scene("res://staff.tscn")
