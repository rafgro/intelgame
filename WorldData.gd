extends Node

# All rough locations, usually countries, separated by costs and difficulty
var Countries = [
	{
		# real world hardcoded below
		"Name": "Homeland",
		"Adjective": "Our",
		"TravelCost": 0,  # cost of getting there for one person
		"LocalCost": 0,  # weekly base cost of one person operation
		"IntelFriendliness": 100,  # towards all operations, 0 to 100
		"Size": 2, # population in millions
		"ElectionPeriod": 52*4,  # almost-fixed weeks of governance
		# generated below
		"ElectionProgress": 52*4,  # counter to the next election
		"PoliticsIntel": 50,  # attitude towards own intel agency, 0 to 100
		"PoliticsAggression": 0,  # attitude towards other countries, 0 to 100
		"PoliticsStability": 50,  # risk of wrong decisions or earlier elections, 0 to 100
	},
	{ "Name": "Ireland", "Adjective": "Irish", "TravelCost": 1, "LocalCost": 1, "IntelFriendliness": 90, "Size": 5, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, "PoliticsStability": 50, },
	{ "Name": "United Kingdom", "Adjective": "English", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 60, "Size": 67, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, "PoliticsStability": 50, },
	{ "Name": "Belgium", "Adjective": "Belgian", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 80, "Size": 11, "ElectionPeriod": 52*4,  "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, "PoliticsStability": 50, },
	{ "Name": "Germany", "Adjective": "German", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 50, "Size": 83, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, "PoliticsStability": 50, },
	{ "Name": "United States", "Adjective": "American", "TravelCost": 3, "LocalCost": 2, "IntelFriendliness": 40, "Size": 328, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, "PoliticsStability": 50, },
	{ "Name": "Poland", "Adjective": "Polish", "TravelCost": 1, "LocalCost": 1, "IntelFriendliness": 70, "Size": 38, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, "PoliticsStability": 50, },
	{ "Name": "France", "Adjective": "French", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 40, "Size": 67, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, "PoliticsStability": 50, },
	{ "Name": "Russia", "Adjective": "Russian", "TravelCost": 3, "LocalCost": 1, "IntelFriendliness": 30, "Size": 144, "ElectionPeriod": 52*10, "ElectionProgress": GameLogic.random.randi_range(50*5,50*10), "PoliticsIntel": 50, "PoliticsAggression": 0, "PoliticsStability": 50, },
	{ "Name": "China", "Adjective": "Chinese", "TravelCost": 5, "LocalCost": 2, "IntelFriendliness": 20, "Size": 1398, "ElectionPeriod": 52*20, "ElectionProgress": GameLogic.random.randi_range(50*10,50*20), "PoliticsIntel": 50, "PoliticsAggression": 0, "PoliticsStability": 50, },
	{ "Name": "Israel", "Adjective": "Israeli", "TravelCost": 3, "LocalCost": 2, "IntelFriendliness": 30, "Size": 9, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, "PoliticsStability": 50, },
	{ "Name": "Turkey", "Adjective": "Turkish", "TravelCost": 2, "LocalCost": 1, "IntelFriendliness": 50, "Size": 84, "ElectionPeriod": 52*10, "ElectionProgress": GameLogic.random.randi_range(1,50*10), "PoliticsIntel": 50, "PoliticsAggression": 0, "PoliticsStability": 50, },
	{ "Name": "Iraq", "Adjective": "Iraqi", "TravelCost": 3, "LocalCost": 1, "IntelFriendliness": 40, "Size": 40, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, "PoliticsStability": 50, },
	{ "Name": "Afghanistan", "Adjective": "Afghan", "TravelCost": 3, "LocalCost": 1, "IntelFriendliness": 60, "Size": 38, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, "PoliticsStability": 50, },
]

# Intercountry relations, 2d array
var DiplomaticRelations = []

# Basic list of organizations, modified and generated additionally later
enum OrgType {
	GOVERNMENT,
	INTEL,
	GENERALTERROR,
	ARMTRADER,
	PARAMILITARY,
	MAFIA,
}
var Organizations = [
	{
		# real world hardcoded below
		"Type": OrgType.INTEL,
		"Name": "MI5",
		"Fixed": true,  # cannot delete if true, mainly for intel agencies
		"Known": true,  # false for hidden criminal organizations
		"Staff": 4400,  # number of human members
		"Budget": 260000,  # monthly in thousands
		"Counterintelligence": 90,  # from 0 (get in from the street) to 100 (impossible to infiltrate)
		"Countries": [2],  # ids of host countries
		# generated and/or frequently modified
		"OpsAgainstHomeland": [],  # future possibility
		"IntelDescription": [],  # just for user display, for many authomatically filled
	},
	{ "Type": OrgType.INTEL, "Name": "BND", "Fixed": true, "Known": true, "Staff": 6500, "Budget": 85000, "Counterintelligence": 80, "Countries": [4], "OpsAgainstHomeland": [], "IntelDescription": [], },
	{ "Type": OrgType.INTEL, "Name": "CIA", "Fixed": true, "Known": true, "Staff": 22000, "Budget": 1250000, "Counterintelligence": 85, "Countries": [5], "OpsAgainstHomeland": [], "IntelDescription": [], },
	{ "Type": OrgType.INTEL, "Name": "AW (Agencja Wywiadu)", "Fixed": true, "Known": true, "Staff": 1000, "Budget": 20800, "Counterintelligence": 70, "Countries": [6], "OpsAgainstHomeland": [], "IntelDescription": [], },
	{ "Type": OrgType.INTEL, "Name": "DGSE", "Fixed": true, "Known": true, "Staff": 6100, "Budget": 42000, "Counterintelligence": 85, "Countries": [7], "OpsAgainstHomeland": [], "IntelDescription": [], },
	{ "Type": OrgType.INTEL, "Name": "ФСБ (FSB)", "Fixed": true, "Known": true, "Staff": 66200, "Budget": 1000000, "Counterintelligence": 85, "Countries": [8], "OpsAgainstHomeland": [], "IntelDescription": [], },
	{ "Type": OrgType.INTEL, "Name": "Guoanbu", "Fixed": true, "Known": true, "Staff": 100000, "Budget": 2000000, "Counterintelligence": 95, "Countries": [9], "OpsAgainstHomeland": [], "IntelDescription": [], },
	{ "Type": OrgType.INTEL, "Name": "Mossad", "Fixed": true, "Known": true, "Staff": 7000, "Budget": 228000, "Counterintelligence": 95, "Countries": [10], "OpsAgainstHomeland": [], "IntelDescription": [], },
	{ "Type": OrgType.INTEL, "Name": "MIT (Milli Istihbarat Teskilati)", "Fixed": true, "Known": true, "Staff": 8000, "Budget": 180000, "Counterintelligence": 90, "Countries": [11], "OpsAgainstHomeland": [], "IntelDescription": [], },
	{ "Type": OrgType.INTEL, "Name": "Mukhabarat", "Fixed": true, "Known": true, "Staff": 4000, "Budget": 20000, "Counterintelligence": 75, "Countries": [12], "OpsAgainstHomeland": [], "IntelDescription": [], },
	{ "Type": OrgType.INTEL, "Name": "NDS", "Fixed": true, "Known": true, "Staff": 3000, "Budget": 10000, "Counterintelligence": 70, "Countries": [13], "OpsAgainstHomeland": [], "IntelDescription": [], },
	{ "Type": OrgType.GENERALTERROR, "Name": "Al-Qaeda", "Fixed": false, "Known": true, "Staff": 45000, "Budget": 25000, "Counterintelligence": 60, "Countries": [12,13], "OpsAgainstHomeland": [], "IntelDescription": [], }
]

# Methods on the ground
# 2D array: first row for MORE_INTEL, second row for RECRUIT_SOURCE etc
var Methods = [
	[
		{
			"Name": "street observation on foot",
			"Cost": 1,  # weekly
			"Quality": 10,  # from 0 (useless) to 100 (perfect theft)
			"Risk": 40,  # from 0 (hacking) to 100 (shooting), given well working counterintelligence
			"OfficersRequired": 1,  # how many must be involved in operation
			"Available": false,  # automatically controlled and set by the game
		},
		{ "Name": "street observation by car", "Cost": 2, "Quality": 15, "Risk": 20, "OfficersRequired": 2, "Available": false, },
		{ "Name": "rent house for observation", "Cost": 20, "Quality": 40, "Risk": 5, "OfficersRequired": 2, "Available": false, },
		{ "Name": "install and operate hidden cameras", "Cost": 5, "Quality": 30, "Risk": 20, "OfficersRequired": 1, "Available": false, },
		{ "Name": "attempt physical breach", "Cost": 20, "Quality": 70, "Risk": 60, "OfficersRequired": 5, "Available": false, },
	]
]

# <countryA> phrase <countryB>
var DiplomaticPhrasesPositive = ["'s officials visited ", " signed a treaty with "]
var DiplomaticPhrasesNegative = [" condemned actions of ", " withdraw from a treaty with ", " expressed concern about changes in "]

# Next week function like in game logic
func WorldNextWeek(past):
	# progressing to elections
	for c in range(0, len(Countries)):
		Countries[c].ElectionProgress -= 1
		if Countries[c].ElectionProgress <= 0:
			# election
			var won = GameLogic.random.randi_range(29,55)
			if GameLogic.random.randi_range(0,1) == 0:
				GameLogic.AddWorldEvent("Elections in " + Countries[c].Name + ": Incumbent won, achieving "+str(won)+"%", past)
				Countries[c].ElectionProgress = Countries[c].ElectionPeriod
				Countries[c].PoliticsAggression += GameLogic.random.randi_range(-5,5)
				Countries[c].PoliticsStability += GameLogic.random.randi_range(10,won)
			else:
				GameLogic.AddWorldEvent("Elections in " + Countries[c].Name + ": New government formed, achieving "+str(won)+"%", past)
				Countries[c].ElectionProgress = Countries[c].ElectionPeriod
				Countries[c].PoliticsIntel = GameLogic.random.randi_range(10,90)
				Countries[c].PoliticsAggression += GameLogic.random.randi_range(-15,15)
				Countries[c].PoliticsStability += GameLogic.random.randi_range(won,90)
				for d in range(0, len(Countries)):
					DiplomaticRelations[c][d] += GameLogic.random.randi_range(-10,10)
	# dealing with government stability
	for c in range(0, len(Countries)):
		var choice = GameLogic.random.randi_range(0,70)
		if Countries[c].PoliticsStability < 20:
			choice = GameLogic.random.randi_range(0,20)
			if choice > Countries[c].PoliticsStability and GameLogic.random.randi_range(0,10) == 1:
				GameLogic.AddWorldEvent("Government dissoluted in " + Countries[c].Name, past)
				Countries[c].ElectionProgress = 0
		elif choice > Countries[c].PoliticsStability and GameLogic.random.randi_range(0,20) == 2:
			GameLogic.AddWorldEvent("Scandal affected government in " + Countries[c].Name, past)
			Countries[c].PoliticsStability -= GameLogic.random.randi_range(5,15)
	# individual diplomatic events
	for c in range(0, len(Countries)):
		if GameLogic.random.randi_range(0,2) == 0:
			var affected = GameLogic.random.randi_range(0, len(Countries)-1)
			if c == affected:
				continue  # don't act on itself
			var change = GameLogic.random.randi_range((DiplomaticRelations[c][affected]-30.0)/10, (DiplomaticRelations[c][affected]+30.0)/10)
			if GameLogic.random.randi_range(0,15) == 9:  # rare larger change
				change = GameLogic.random.randi_range((DiplomaticRelations[c][affected]-30.0)/4, (DiplomaticRelations[c][affected]+30.0)/4)
			DiplomaticRelations[c][affected] += change
			if GameLogic.random.randi_range(0,20) == 7:  # publicly known
				if change < 0:
					GameLogic.AddWorldEvent(Countries[c].Name + DiplomaticPhrasesNegative[randi() % DiplomaticPhrasesNegative.size()] + Countries[affected].Name, past)
				elif change > 0:
					GameLogic.AddWorldEvent(Countries[c].Name + DiplomaticPhrasesPositive[randi() % DiplomaticPhrasesPositive.size()] + Countries[affected].Name, past)
	# country summits
	if GameLogic.random.randi_range(0,20) == 12:
		# getting participants
		var howmany = GameLogic.random.randi_range(3,6)
		var participants = []
		while len(participants) < howmany:
			var try = GameLogic.random.randi_range(0, len(Countries)-1)
			if !(try in participants):
				participants.append(try)
		# results, mostly depending on sum of internal relations
		var theSum = 0
		for p in participants:
			for p2 in participants:
				theSum += DiplomaticRelations[p][p2]
		theSum += GameLogic.random.randf_range(theSum*(-0.2),theSum*(0.2))
		var result = 15
		if theSum < 0: result = -15
		# updating relations
		var message = ""
		for p in participants:
			message += Countries[p].Name + ", "
			for p2 in participants:
				DiplomaticRelations[p][p2] += result
		# public information
		message = "Summit of " + message.substr(0, len(message)-2) + ": "
		if theSum > 0: message += "governments issued a joint statement"
		else: message += "governments could not reach consensus"
		GameLogic.AddWorldEvent(message, past)
