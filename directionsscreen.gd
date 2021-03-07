extends Control

var mapOfCountries = [[],[],[]]  # hostile, neutral, friendly
var lastSelectedCategory = 0
var lastSelectedCountry = -1

func _ready():
	# list setup
	mapOfCountries.clear()
	mapOfCountries = [[],[],[]]
	for c in range(1, len(WorldData.Countries)):
		if WorldData.DiplomaticRelations[0][c] < -30:
			$C/M/R/Tabs/Hostile/List.add_item(WorldData.Countries[c].Name)
			mapOfCountries[0].append(c)
		elif WorldData.DiplomaticRelations[0][c] > 30:
			$C/M/R/Tabs/Friendly/List.add_item(WorldData.Countries[c].Name)
			mapOfCountries[2].append(c)
		else:
			$C/M/R/Tabs/Neutral/List.add_item(WorldData.Countries[c].Name)
			mapOfCountries[1].append(c)
	if len(mapOfCountries[0]) == 0:
		$C/M/R/Tabs.set_current_tab(1)

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")

func _on_Tabs_tab_changed(tab):
	lastSelectedCategory = tab

func _on_List_item_selected(index):
	if index >= len(mapOfCountries[lastSelectedCategory]): return false
	lastSelectedCountry = mapOfCountries[lastSelectedCategory][index]
	var c = lastSelectedCountry  # shortcut for readability
	var desc = "[b]" + WorldData.Countries[c].Name + "[/b]\npopulation of " + str(int(WorldData.Countries[c].Size)) + " millions | "
	if WorldData.Countries[c].SoftPower > 90: desc += "huge"
	elif WorldData.Countries[c].SoftPower > 70: desc += "large"
	elif WorldData.Countries[c].SoftPower > 40: desc += "average"
	elif WorldData.Countries[c].SoftPower > 20: desc += "low"
	else: desc += "minimal"
	desc += " soft power\n\n"
	if WorldData.Countries[c].InStateOfWar == true: desc += "[b]In state of war[/b]\n"
	desc += "Diplomatic relations with Homeland: "
	if WorldData.DiplomaticRelations[0][c] < -60: desc += "[b]very hostile[/b]\n"
	elif WorldData.DiplomaticRelations[0][c] < -30: desc += "[b]hostile[/b]\n"
	elif WorldData.DiplomaticRelations[0][c] < -10: desc += "slightly negative\n"
	elif WorldData.DiplomaticRelations[0][c] < 10: desc += "neutral\n"
	elif WorldData.DiplomaticRelations[0][c] < 30: desc += "slightly positive\n"
	elif WorldData.DiplomaticRelations[0][c] < 60: desc += "friendly\n"
	else: desc += "very friendly\n"
	if WorldData.Countries[c].DiplomaticTravel == true: desc += "Embassy present, "
	else: desc += "Diplomatic travel unavailable, "
	if WorldData.Countries[c].CovertTravel < 5: desc += "covert travel unavailable"
	elif WorldData.Countries[c].CovertTravel < 20: desc += "covert travel highly risky"
	elif WorldData.Countries[c].CovertTravel < 40: desc += "covert travel risky"
	elif WorldData.Countries[c].CovertTravel < 70: desc += "covert travel available"
	else: desc += "covert travel always available"
	if WorldData.Countries[c].Network > 0:
		desc += "\n[b]Network of " + str(int(WorldData.Countries[c].Network)) + " local agents present[/b] (supports operations when possible)"
	if WorldData.Countries[c].Station > 0:
		desc += "\n[b]Intelligence station with " + str(int(WorldData.Countries[c].Station)) + " employees present[/b] (regularly gathers intel on all local organizations)"
	desc += "\nAverage travel cost per officer: €" + str(int(WorldData.Countries[c].TravelCost)) + ",000\n"
	desc += "Average cost of living per officer per week: €" + str(int(WorldData.Countries[c].LocalCost)) + ",000\n\n"
	desc += str(WorldData.Countries[c].OperationStats) + " operations inside performed to date\n"
	desc += "Familiarity with local language: " + str(int(WorldData.Countries[c].KnowhowLanguage)) + "%\n"
	desc += "Familiarity with local customs: " + str(int(WorldData.Countries[c].KnowhowCustoms)) + "%\n"
	if WorldData.Countries[c].Expelled > 0:
		desc += "\n" + str(int(WorldData.Countries[c].Expelled)) + " officers were expelled and are persona non grata"
	if WorldData.Countries[c].NetworkWork == true:
		desc += "\nCurrently, Bureau expands network in the country"
	if WorldData.Countries[c].StationWork == true:
		desc += "\nCurrently, Bureau expands station in the country"
	$C/M/R/Details.bbcode_text = desc
	$C/M/R/H/Develop.disabled = false
	if WorldData.Countries[c].KnowhowLanguage > 25 and WorldData.Countries[c].KnowhowCustoms > 25 and WorldData.Countries[c].NetworkWork == false:
		$C/M/R/H/Network.disabled = false
		if WorldData.Countries[c].Network > 0:
			$C/M/R/H/Network.text = "Expand Network"
		else:
			$C/M/R/H/Network.text = "Establish Network"
	else:
		$C/M/R/H/Network.disabled = true
	if WorldData.Countries[c].KnowhowLanguage > 50 and WorldData.Countries[c].KnowhowCustoms > 50 and WorldData.Countries[c].DiplomaticTravel == true and WorldData.Countries[c].StationWork == false:
		$C/M/R/H/Station.disabled = false
		if WorldData.Countries[c].Station > 0:
			$C/M/R/H/Station.text = "Expand Station"
		else:
			$C/M/R/H/Station.text = "Establish Station"
	else:
		$C/M/R/H/Station.disabled = true

func _on_Develop_pressed():
	if lastSelectedCountry > 0:
		var content = "Officers designed following plans concerning skill development into the direction of " + WorldData.Countries[lastSelectedCountry].Name + ".\n\n"
		# plan a
		var planAofficers = GameLogic.random.randi_range(1, min(GameLogic.OfficersInHQ, 6))
		var planAlength = GameLogic.random.randi_range(1,8)
		var planAcost = planAofficers*5*planAlength
		var planAshow = true
		var planAdesc = ""
		if (planAcost*1.0/planAlength) > GameLogic.FreeFundsWeeklyWithoutOngoing():
			planAshow = false
			planAdesc = " (financially unavailable)"
		content += "[b]Plan A[/b]"+planAdesc+"\n€" + str(int(planAcost)) + ",000 | " + str(int(planAofficers)) + " officers | " + str(int(planAlength)) + " weeks\nlanguage training"
		# plan b
		var planBofficers = GameLogic.random.randi_range(1, min(GameLogic.OfficersInHQ, 6))
		var planBlength = GameLogic.random.randi_range(4,18)
		var planBcost = planBofficers*2*planBlength
		var planBshow = true
		var planBdesc = ""
		if WorldData.Countries[lastSelectedCountry].DiplomaticTravel == true:
			if (planBcost*1.0/planBlength) > GameLogic.FreeFundsWeeklyWithoutOngoing():
				planBshow = false
				planBdesc = " (financially unavailable)"
			content += "\n\n[b]Plan B[/b]"+planBdesc+"\n€" + str(int(planBcost)) + ",000 | " + str(int(planBofficers)) + " officers | " + str(int(planBlength)) + " weeks\nembassy residency\nlanguage immersion\nengagement with local culture"
		else:
			planBofficers = GameLogic.random.randi_range(1, min(GameLogic.OfficersInHQ, 6))
			planBlength = GameLogic.random.randi_range(6,26)
			planBcost = planBofficers*6*planBlength
			if (planBcost*1.0/planBlength) > GameLogic.FreeFundsWeeklyWithoutOngoing():
				planBshow = false
				planBdesc = " (financially unavailable)"
			content += "\n\n[b]Plan B[/b]"+planBdesc+"\n€" + str(int(planBcost)) + ",000 | " + str(int(planBofficers)) + " officers | " + str(int(planBlength)) + " weeks\nresidency in closest possible country\nacquitance with local emmigrants from targeted country"
		# plan c
		var planCofficers = GameLogic.random.randi_range(1, min(GameLogic.OfficersInHQ, 6))
		var planClength = GameLogic.random.randi_range(4,8)
		var planCcost = planCofficers*10*planClength
		var planCshow = true
		var planCdesc = ""
		if WorldData.Countries[lastSelectedCountry].CovertTravel < 35:
			if (planCcost*1.0/planClength) > GameLogic.FreeFundsWeeklyWithoutOngoing():
				planCshow = false
				planCdesc = " (financially unavailable)"
			content += "\n\n[b]Plan C[/b]"+planCdesc+"\n€" + str(int(planCcost)) + ",000 | " + str(int(planCofficers)) + " officers | " + str(int(planClength)) + " weeks\ndevelop passport forging system\ntest and correct covert travel procedures"
		else:
			planCofficers = GameLogic.random.randi_range(1, min(GameLogic.OfficersInHQ, 6))
			planClength = GameLogic.random.randi_range(6,12)
			planCcost = planCofficers*5*planClength
			if (planCcost*1.0/planClength) > GameLogic.FreeFundsWeeklyWithoutOngoing():
				planCshow = false
				planCdesc = " (financially unavailable)"
			content += "\n\n[b]Plan C[/b]"+planCdesc+"\n€" + str(int(planCcost)) + ",000 | " + str(int(planCofficers)) + " officers | " + str(int(planClength)) + " weeks\ncorrect covert travel procedures\nlive as a covert local"
		content += "\n\nChoose appropriate plan or wait for new plans. Be aware that officers involved in these operations generally will not be in contact with the HQ, and therefore cannot be called off.\n"
		# call
		CallManager.CallQueue.append(
			{
				"Header": "Decision",
				"Level": "Confidential",
				"Operation": "-//-",
				"Content": content,
				"Show1": planAshow,
				"Show2": planBshow,
				"Show3": planCshow,
				"Show4": true,
				"Text1": "Plan A",
				"Text2": "Plan B",
				"Text3": "Plan C",
				"Text4": "Cancel",
				"Decision1Callback": funcref(GameLogic, "ImplementDirectionDevelopment"),
				"Decision1Argument": {"Choice":1, "Cost": planAcost, "Length": planAlength, "Officers": planAofficers, "Country": lastSelectedCountry},
				"Decision2Callback": funcref(GameLogic, "ImplementDirectionDevelopment"),
				"Decision2Argument": {"Choice":2, "Cost": planBcost, "Length": planBlength, "Officers": planBofficers, "Country": lastSelectedCountry},
				"Decision3Callback": funcref(GameLogic, "ImplementDirectionDevelopment"),
				"Decision3Argument": {"Choice":3, "Cost": planCcost, "Length": planClength, "Officers": planCofficers, "Country": lastSelectedCountry},
				"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision4Argument": null,
			}
		)
		get_tree().change_scene("res://call.tscn")
	
func _on_Network_pressed():
	if lastSelectedCountry > 0:
		var planOfficers = GameLogic.random.randi_range(1, min(GameLogic.OfficersInHQ, 9))
		var planLength = GameLogic.random.randi_range(8,26)
		var planCost = planOfficers*5*planLength
		var content = "Establishing"
		if WorldData.Countries[lastSelectedCountry].Network > 0: content = "Expanding"
		var planShow = true
		var planAvailability = ""
		if (planCost*1.0/planLength) > GameLogic.FreeFundsWeeklyWithoutOngoing():
			planShow = false
			planAvailability = " Currently, it is financially unavailable."
		elif GameLogic.YearlyNetworks >= 2:
			planShow = false
			planAvailability = " In this year, Bureau cannot work anymore on establishing or expanding network."
		else:
			planAvailability = " Remember that Bureau can work only on two networks in a year."
		content += " local agent network in " + WorldData.Countries[lastSelectedCountry].Name + " will require €" + str(int(planCost)) + ",000 and " + str(int(planOfficers)) + " officers. The operation will last " + str(int(planLength)) + " weeks."+planAvailability+"\n\nNote that its effects are strictly correlated with familiarity with the country."
		# call
		CallManager.CallQueue.append(
			{
				"Header": "Decision",
				"Level": "Secret",
				"Operation": "-//-",
				"Content": content,
				"Show1": false,
				"Show2": false,
				"Show3": planShow,
				"Show4": true,
				"Text1": "",
				"Text2": "",
				"Text3": "Approve",
				"Text4": "Cancel",
				"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision1Argument": null,
				"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision2Argument": null,
				"Decision3Callback": funcref(GameLogic, "ImplementDirectionDevelopment"),
				"Decision3Argument": {"Choice":4, "Cost": planCost, "Length": planLength, "Officers": planOfficers, "Country": lastSelectedCountry},
				"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision4Argument": null,
			}
		)
		get_tree().change_scene("res://call.tscn")

func _on_Station_pressed():
	if lastSelectedCountry > 0:
		var planOfficers = GameLogic.random.randi_range(1, min(GameLogic.OfficersInHQ, 9))
		var planLength = GameLogic.random.randi_range(8,26)
		var planCost = planOfficers*10*planLength
		var content = "Establishing"
		if WorldData.Countries[lastSelectedCountry].Station > 0: content = "Expanding"
		var planShow = true
		var planAvailability = ""
		if (planCost*1.0/planLength) > GameLogic.FreeFundsWeeklyWithoutOngoing():
			planShow = false
			planAvailability = " Currently, it is financially unavailable."
		elif GameLogic.YearlyStations >= 1:
			planShow = false
			planAvailability = " In this year, Bureau cannot work anymore on establishing or expanding stations."
		else:
			planAvailability = " Remember that Bureau can establish or expand only one station in a year."
		content += " intelligence station in " + WorldData.Countries[lastSelectedCountry].Name + " will require €" + str(int(planCost)) + ",000 and " + str(int(planOfficers)) + " officers. The operation will last " + str(int(planLength)) + " weeks."+planAvailability
		# call
		CallManager.CallQueue.append(
			{
				"Header": "Decision",
				"Level": "Top Secret",
				"Operation": "-//-",
				"Content": content,
				"Show1": false,
				"Show2": false,
				"Show3": planShow,
				"Show4": true,
				"Text1": "",
				"Text2": "",
				"Text3": "Approve",
				"Text4": "Cancel",
				"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision1Argument": null,
				"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision2Argument": null,
				"Decision3Callback": funcref(GameLogic, "ImplementDirectionDevelopment"),
				"Decision3Argument": {"Choice":5, "Cost": planCost, "Length": planLength, "Officers": planOfficers, "Country": lastSelectedCountry},
				"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision4Argument": null,
			}
		)
		get_tree().change_scene("res://call.tscn")
