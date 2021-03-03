extends Control

var mapOfCountries = []
var lastMapOfOrgs = []
var lastSelectedCountry = -1
var lastSelectedOrg = -1
var selectedTab = 0

func _ready():
	$C/M/R/Tabs.set_tab_title(0, "Amount of Intel")
	$C/M/R/Tabs.set_tab_title(1, "Organization Type")
	$C/M/R/Tabs.set_tab_title(2, "Host Country")
	# basic list setup
	$C/M/R/Tabs/Amount/List.clear()
	$C/M/R/Tabs/Amount/List.add_item("No Intel")
	$C/M/R/Tabs/Amount/List.add_item("Minimal Knowledge")
	$C/M/R/Tabs/Amount/List.add_item("Known Organizations")
	$C/M/R/Tabs/Amount/List.add_item("Organizations with Sources Inside")
	$C/M/R/Tabs/Type/List.clear()
	$C/M/R/Tabs/Type/List.add_item("Governments")
	$C/M/R/Tabs/Type/List.add_item("Intelligence Agencies")
	$C/M/R/Tabs/Type/List.add_item("Scientific Institutions")
	$C/M/R/Tabs/Type/List.add_item("Corporations")
	$C/M/R/Tabs/Type/List.add_item("Movements")
	$C/M/R/Tabs/Type/List.add_item("Criminal Organizations")
	mapOfCountries.clear()
	var descs = []
	for c in range(1, len(WorldData.Countries)):
		var desc = WorldData.Countries[c].Name
		if WorldData.DiplomaticRelations[0][c] < -30:
			desc += " (hostile country)"
			descs.push_front(desc)
			mapOfCountries.push_front(c)
		elif WorldData.DiplomaticRelations[0][c] > 30:
			desc += " (friendly country)"
			descs.append(desc)
			mapOfCountries.append(c)
		else:
			descs.append(desc)
			mapOfCountries.append(c)
	for d in descs:
		$C/M/R/Tabs/Countries/List.add_item(d)

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")

func _on_Tabs_tab_changed(tab):
	$C/M/R/Organizations.clear()

func _on_AmountList_item_selected(index):
	lastMapOfOrgs.clear()
	$C/M/R/Organizations.clear()
	for o in range(0, len(WorldData.Organizations)):
		if WorldData.Organizations[o].Known == true and WorldData.Organizations[o].Active == true:
			if index == 0:  # no intel
				if len(WorldData.Organizations[o].IntelDescription) == 0:
					lastMapOfOrgs.append(o)
					$C/M/R/Organizations.add_item(WorldData.Organizations[o].Name)
			elif index == 1:  # minimal knowledge
				if len(WorldData.Organizations[o].IntelDescription) > 0 and  WorldData.Organizations[o].IntelValue < 10 and len(WorldData.Organizations[o].IntelSources) == 0:
					lastMapOfOrgs.append(o)
					$C/M/R/Organizations.add_item(WorldData.Organizations[o].Name)
			elif index == 2:  # known organizations
				if len(WorldData.Organizations[o].IntelDescription) > 0 and  WorldData.Organizations[o].IntelValue >= 10 and len(WorldData.Organizations[o].IntelSources) == 0:
					lastMapOfOrgs.append(o)
					$C/M/R/Organizations.add_item(WorldData.Organizations[o].Name)
			elif index == 3:  # sources inside
				if len(WorldData.Organizations[o].IntelDescription) > 0 and len(WorldData.Organizations[o].IntelSources) > 0:
					lastMapOfOrgs.append(o)
					$C/M/R/Organizations.add_item(WorldData.Organizations[o].Name)

func _on_TypeList_item_selected(index):
	lastMapOfOrgs.clear()
	$C/M/R/Organizations.clear()
	var whichType = [WorldData.OrgType.GOVERNMENT]
	if index == 1: whichType = [WorldData.OrgType.INTEL]
	elif index == 2: whichType = [WorldData.OrgType.UNIVERSITY, WorldData.OrgType.UNIVERSITY_OFFENSIVE]
	elif index == 3: whichType = [WorldData.OrgType.COMPANY]
	elif index == 4: whichType = [WorldData.OrgType.MOVEMENT]
	elif index == 5: whichType = [WorldData.OrgType.GENERALTERROR, WorldData.OrgType.ARMTRADER]
	for o in range(0, len(WorldData.Organizations)):
		if WorldData.Organizations[o].Type in whichType and WorldData.Organizations[o].Known == true and WorldData.Organizations[o].Active == true:
			lastMapOfOrgs.append(o)
			$C/M/R/Organizations.add_item(WorldData.Organizations[o].Name)

func _on_CountriesList_item_selected(index):
	lastMapOfOrgs.clear()
	$C/M/R/Organizations.clear()
	lastSelectedCountry = mapOfCountries[index]
	for o in range(0, len(WorldData.Organizations)):
		if mapOfCountries[index] in WorldData.Organizations[o].Countries and WorldData.Organizations[o].Known == true and WorldData.Organizations[o].Active == true:
			lastMapOfOrgs.append(o)
			var desc = WorldData.Organizations[o].Name
			$C/M/R/Organizations.add_item(desc)

func _on_Organizations_item_selected(index):
	if index <= len(lastMapOfOrgs):
		var o = lastMapOfOrgs[index]
		lastSelectedOrg = o
		var desc = "Details on " + WorldData.Organizations[o].Name + ":\n"
		if len(WorldData.Organizations[o].IntelDescription) == 0:
			desc += "No intel gathered."
		else:
			desc += WorldData.Organizations[o].IntelDescType + " | " + str(WorldData.Organizations[o].IntelIdentified) + " identified members"
			if len(WorldData.Organizations[o].IntelSources) > 0:
				desc += " | " + str(len(WorldData.Organizations[o].IntelSources)) + " sources inside"
			var orgCountries = []
			for c in WorldData.Organizations[o].Countries:
				orgCountries.append(WorldData.Countries[c].Name)
			desc += "\ncountries: " + PoolStringArray(orgCountries).join(", ")
			desc += "\n" + PoolStringArray(WorldData.Organizations[o].IntelDescription).join("\n")
		$C/M/R/Details.bbcode_text = desc
		$C/M/R/H/Gather.disabled = false
		if WorldData.Organizations[o].IntelIdentified > 0: $C/M/R/H/Recruit.disabled = false
		else: $C/M/R/H/Recruit.disabled = true
		if WorldData.Organizations[o].OffensiveClearance == true or GameLogic.UniversalClearance == true: $C/M/R/H/Offensive.disabled = false
		else: $C/M/R/H/Offensive.disabled = true

func _on_Gather_pressed():
	if lastSelectedOrg != -1:
		OperationGenerator.NewOperation(0, lastSelectedOrg, OperationGenerator.Type.MORE_INTEL)
		# if possible, start fast
		if GameLogic.OfficersInHQ > 0:
			GameLogic.Operations[-1].AnalyticalOfficers = GameLogic.OfficersInHQ
			GameLogic.Operations[-1].Stage = OperationGenerator.Stage.PLANNING_OPERATION
			GameLogic.Operations[-1].Started = GameLogic.GiveDateWithYear()
			GameLogic.Operations[-1].Result = "ONGOING (PLANNING)"
		get_tree().change_scene("res://main.tscn")

func _on_Recruit_pressed():
	if lastSelectedOrg != -1:
		OperationGenerator.NewOperation(0, lastSelectedOrg, OperationGenerator.Type.RECRUIT_SOURCE)
		# if possible, start fast
		if GameLogic.OfficersInHQ > 0:
			GameLogic.Operations[-1].AnalyticalOfficers = GameLogic.OfficersInHQ
			GameLogic.Operations[-1].Stage = OperationGenerator.Stage.PLANNING_OPERATION
			GameLogic.Operations[-1].Started = GameLogic.GiveDateWithYear()
			GameLogic.Operations[-1].Result = "ONGOING (PLANNING)"
		get_tree().change_scene("res://main.tscn")

func _on_Offensive_pressed():
	if lastSelectedOrg != -1:
		OperationGenerator.NewOperation(0, lastSelectedOrg, OperationGenerator.Type.OFFENSIVE)
		# if possible, start fast
		if GameLogic.OfficersInHQ > 0:
			GameLogic.Operations[-1].AnalyticalOfficers = GameLogic.OfficersInHQ
			GameLogic.Operations[-1].Stage = OperationGenerator.Stage.PLANNING_OPERATION
			GameLogic.Operations[-1].Started = GameLogic.GiveDateWithYear()
			GameLogic.Operations[-1].Result = "ONGOING (PLANNING)"
		get_tree().change_scene("res://main.tscn")
