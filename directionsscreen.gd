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

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")

func _on_Tabs_tab_changed(tab):
	lastSelectedCategory = tab

func _on_List_item_selected(index):
	lastSelectedCountry = mapOfCountries[lastSelectedCategory][index]
	var desc = WorldData.Countries[lastSelectedCountry].Name
	$M/R/Details.bbcode_text = desc
