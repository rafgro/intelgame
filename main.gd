extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Not only refreshing but also initiating all data on the main screen
func UpdateMainScreen():
	# date formatting
	$M/R/CDate/Date.text = GameLogic.GiveDateWithYear()
	# other
	$M/R/CDate/C/TrustChange.text = GameLogic.TrustChangeDesc
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

# Main event: moving a week forwad
func _on_NextWeek_pressed():
	$M/R/Buttons3/NextWeek.disabled = true
	GameLogic.NextWeek()
	UpdateMainScreen()
	$M/R/Buttons3/NextWeek.disabled = false

func _on_Budget_pressed():
	get_tree().change_scene("res://budget.tscn")

func _on_Staff_pressed():
	get_tree().change_scene("res://staff.tscn")

func _on_Government_pressed():
	get_tree().change_scene("res://government.tscn")

func _on_GatheredIntel_pressed():
	get_tree().change_scene("res://gatheredintel.tscn")

func _on_Operations_pressed():
	get_tree().change_scene("res://operations.tscn")

func _on_Craft_pressed():
	get_tree().change_scene("res://craft.tscn")
