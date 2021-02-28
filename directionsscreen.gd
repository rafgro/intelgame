extends Panel

var mapOfCountries = [[],[],[]]  # hostile, neutral, friendly
var lastSelectedCategory = 0
var lastSelectedCountry = -1

func _ready():
	# list setup
	mapOfCountries.clear()
	mapOfCountries = [[],[],[]]
	for c in range(1, len(WorldData.Countries)):
		if WorldData.DiplomaticRelations[0][c] < -30:
			$M/R/Tabs/Hostile/List.add_item(WorldData.Countries[c].Name)
			mapOfCountries[0].append(c)
		elif WorldData.DiplomaticRelations[0][c] > 30:
			$M/R/Tabs/Friendly/List.add_item(WorldData.Countries[c].Name)
			mapOfCountries[2].append(c)
		else:
			$M/R/Tabs/Neutral/List.add_item(WorldData.Countries[c].Name)
			mapOfCountries[1].append(c)
	if len(mapOfCountries[0]) == 0:
		$M/R/Tabs.set_current_tab(1)

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")

func _on_Tabs_tab_changed(tab):
	lastSelectedCategory = tab

func _on_List_item_selected(index):
	lastSelectedCountry = mapOfCountries[lastSelectedCategory][index]
	var c = lastSelectedCountry  # shortcut for readability
	var desc = "[b]" + WorldData.Countries[c].Name + "[/b]\npopulation of " + str(int(WorldData.Countries[c].Size)) + " millions | "
	if WorldData.Countries[c].SoftPower > 90: desc += "huge"
	elif WorldData.Countries[c].SoftPower > 70: desc += "large"
	elif WorldData.Countries[c].SoftPower > 40: desc += "average"
	elif WorldData.Countries[c].SoftPower > 20: desc += "low"
	else: desc += "minimal"
	desc += " soft power\n\n"
	if WorldData.Countries[c].DiplomaticTravel == true: desc += "Embassy present, "
	else: desc += "Diplomatic travel unavailable, "
	if WorldData.Countries[c].CovertTravel < 5: desc += "covert travel unavailable"
	elif WorldData.Countries[c].CovertTravel < 20: desc += "covert travel highly risky"
	elif WorldData.Countries[c].CovertTravel < 40: desc += "covert travel risky"
	elif WorldData.Countries[c].CovertTravel < 70: desc += "covert travel available"
	else: desc += "covert travel always available"
	desc += "\nAverage travel cost per officer: €" + str(int(WorldData.Countries[c].TravelCost)) + ",000\n"
	desc += "Average cost of living per officer per week: €" + str(int(WorldData.Countries[c].LocalCost)) + ",000\n\n"
	desc += str(WorldData.Countries[c].OperationStats) + " operations inside performed to date\n"
	desc += "Familiarity with local language: " + str(int(WorldData.Countries[c].KnowhowLanguage)) + "%\n"
	desc += "Familiarity with local customs: " + str(int(WorldData.Countries[c].KnowhowCustoms)) + "%\n"
	$M/R/Details.bbcode_text = desc
