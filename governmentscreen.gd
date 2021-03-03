extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	# bars
	$C/M/R/CTrust/Bar.value = GameLogic.Trust
	var diff = int(GameLogic.Trust - GameLogic.TrustMonthsAgo[0])
	if diff > 0: $C/M/R/TrustChange.text = "+" + str(diff) + "% in the last six months"
	else: $C/M/R/TrustChange.text = str(diff) + "% in the last six months"
	$C/M/R/CUse/Bar.value = GameLogic.Use
	diff = int(GameLogic.Use - GameLogic.UseMonthsAgo[0])
	if diff > 0: $C/M/R/UseChange.text = "+" + str(diff) + "% in the last six months"
	else: $C/M/R/UseChange.text = str(diff) + "% in the last six months"
	$C/M/R/CPower/Bar.value = WorldData.Countries[0].SoftPower
	diff = int(WorldData.Countries[0].SoftPower - GameLogic.SoftPowerMonthsAgo[0])
	if diff > 0: $C/M/R/PowerChange.text = "+" + str(diff) + "% in the last six months"
	else: $C/M/R/PowerChange.text = str(diff) + "% in the last six months"
	# text
	var approach = "unfavourable"
	if WorldData.Countries[0].PoliticsIntel > 60: approach = "friendly"
	elif WorldData.Countries[0].PoliticsIntel > 30: approach = "neutral"
	var desc = "Government stance towards intelligence services:\n"
	desc += approach + " approach\n"
	desc += "priorities: " + GameLogic.ListPriorities(", ") + "\n\n"
	desc += "Government Politics:\n"
	if WorldData.Countries[0].PoliticsStability > 40: desc += "stable"
	elif WorldData.Countries[0].PoliticsStability > 20: desc += "unstable"
	else: desc += "very unstable"
	desc += ", "+str(WorldData.Countries[0].ElectionProgress) \
		+" weeks to the next election\n"
	desc += "positive relations with: "
	var c = 0
	var positiveList = []
	while c < len(WorldData.DiplomaticRelations[0]):
		if WorldData.DiplomaticRelations[0][c] > 30:
			positiveList.append(WorldData.Countries[c].Name)
		c += 1
	if len(positiveList) == 0: desc += "-\n"
	else: desc += PoolStringArray(positiveList).join(", ") + "\n"
	desc += "negative relations with: "
	c = 0
	var negativeList = []
	while c < len(WorldData.DiplomaticRelations[0]):
		if WorldData.DiplomaticRelations[0][c] < -30:
			negativeList.append(WorldData.Countries[c].Name)
		c += 1
	if len(negativeList) == 0: desc += "-\n"
	else: desc += PoolStringArray(negativeList).join(", ") + "\n"
	$C/M/R/Politics.text = desc

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")
