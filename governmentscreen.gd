extends Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	$M/R/Trust.text = "Current Trust: " + str(GameLogic.Trust) + "%"
	var desc = "Government Politics:\n"
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
