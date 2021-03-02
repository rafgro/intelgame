extends Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	# bars
	$M/R/CTrust/Bar.value = GameLogic.Trust
	var diff = int(GameLogic.Trust - GameLogic.TrustMonthsAgo[0])
	if diff > 0: $M/R/TrustChange.text = "+" + str(diff) + "% in the last six months"
	else: $M/R/TrustChange.text = str(diff) + "% in the last three months"
	$M/R/CUse/Bar.value = GameLogic.Use
	diff = int(GameLogic.Use - GameLogic.UseMonthsAgo[0])
	if diff > 0: $M/R/UseChange.text = "+" + str(diff) + "% in the last six months"
	else: $M/R/UseChange.text = str(diff) + "% in the last three months"
	$M/R/CPower/Bar.value = WorldData.Countries[0].SoftPower
	diff = int(WorldData.Countries[0].SoftPower - GameLogic.SoftPowerMonthsAgo[0])
	if diff > 0: $M/R/PowerChange.text = "+" + str(diff) + "% in the last six months"
	else: $M/R/PowerChange.text = str(diff) + "% in the last three months"
	# text
	var approach = "unfavourable"
	if WorldData.Countries[0].PoliticsIntel > 60: approach = "friendly"
	elif WorldData.Countries[0].PoliticsIntel > 30: approach = "neutral"
	var desc = "Government Politics:\n"
	desc += approach + " towards intelligence services\n"
	if WorldData.Countries[0].PoliticsStability > 40: desc += "stable"
	elif WorldData.Countries[0].PoliticsStability > 20: desc += "unstable"
	else: desc += "very unstable"
	desc += ", "+str(WorldData.Countries[0].ElectionProgress) \
		+" weeks to the next election\n\nGovernment Foreign Policy:"
	desc += "\n\npositive relations with\n"
	var c = 0
	var counted = 0
	while c < len(WorldData.DiplomaticRelations[0]):
		if WorldData.DiplomaticRelations[0][c] > 30:
			desc += WorldData.Countries[c].Name + "\n"
			counted += 1
		c += 1
	if counted == 0: desc += "-\n"
	desc += "\nnegative relations with\n"
	c = 0
	counted = 0
	while c < len(WorldData.DiplomaticRelations[0]):
		if WorldData.DiplomaticRelations[0][c] < -30:
			desc += WorldData.Countries[c].Name + "\n"
			counted += 1
		c += 1
	if counted == 0: desc += "-\n"
	$M/R/Politics.text = desc

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")
