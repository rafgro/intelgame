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
		"Friends": [],  # ids of friendly countries
		"Foes": [],  # ids of hostile countries
		"Hostility": 0,  # towards homeland, 0 to 100
		"ElectionProgress": 52*4,  # counter to the next election
		"PoliticsIntel": 50,  # attitude towards own intel agency, 0 to 100
		"PoliticsAggression": 0,  # attitude towards other countries, 0 to 100
	},
	{ "Name": "Ireland", "Adjective": "Irish", "TravelCost": 1, "LocalCost": 1, "IntelFriendliness": 90, "Size": 5, "ElectionPeriod": 52*4, "Friends": [], "Foes": [], "Hostility": 0,  "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, },
	{ "Name": "United Kingdom", "Adjective": "English", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 60, "Size": 67, "ElectionPeriod": 52*4, "Friends": [], "Foes": [], "Hostility": 0,  "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, },
	{ "Name": "Belgium", "Adjective": "Belgian", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 80, "Size": 11, "ElectionPeriod": 52*4, "Friends": [], "Foes": [], "Hostility": 0,  "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, },
	{ "Name": "Germany", "Adjective": "German", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 50, "Size": 83, "ElectionPeriod": 52*4, "Friends": [], "Foes": [], "Hostility": 0,  "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, },
	{ "Name": "United States", "Adjective": "American", "TravelCost": 3, "LocalCost": 2, "IntelFriendliness": 40, "Size": 328, "ElectionPeriod": 52*4, "Friends": [], "Foes": [], "Hostility": 0,  "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, },
	{ "Name": "Poland", "Adjective": "Polish", "TravelCost": 1, "LocalCost": 1, "IntelFriendliness": 70, "Size": 38, "ElectionPeriod": 52*4, "Friends": [], "Foes": [], "Hostility": 0,  "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, },
	{ "Name": "France", "Adjective": "French", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 40, "Size": 67, "ElectionPeriod": 52*4, "Friends": [], "Foes": [], "Hostility": 0,  "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, },
	{ "Name": "Russia", "Adjective": "Russian", "TravelCost": 3, "LocalCost": 1, "IntelFriendliness": 30, "Size": 144, "ElectionPeriod": 52*10, "Friends": [], "Foes": [], "Hostility": 0,  "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, },
	{ "Name": "China", "Adjective": "Chinese", "TravelCost": 5, "LocalCost": 2, "IntelFriendliness": 20, "Size": 1398, "ElectionPeriod": 52*20, "Friends": [], "Foes": [], "Hostility": 0,  "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, },
	{ "Name": "Israel", "Adjective": "Israeli", "TravelCost": 3, "LocalCost": 2, "IntelFriendliness": 30, "Size": 9, "ElectionPeriod": 52*4, "Friends": [], "Foes": [], "Hostility": 0,  "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, },
	{ "Name": "Turkey", "Adjective": "Turkish", "TravelCost": 2, "LocalCost": 1, "IntelFriendliness": 50, "Size": 84, "ElectionPeriod": 52*10, "Friends": [], "Foes": [], "Hostility": 0,  "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, },
	{ "Name": "Iraq", "Adjective": "Iraqi", "TravelCost": 3, "LocalCost": 1, "IntelFriendliness": 40, "Size": 40, "ElectionPeriod": 52*4, "Friends": [], "Foes": [], "Hostility": 0,  "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, },
	{ "Name": "Afghanistan", "Adjective": "Afghan", "TravelCost": 3, "LocalCost": 1, "IntelFriendliness": 60, "Size": 38, "ElectionPeriod": 52*4, "Friends": [], "Foes": [], "Hostility": 0,  "ElectionProgress": GameLogic.random.randi_range(1,50*4), "PoliticsIntel": 50, "PoliticsAggression": 0, },
]

enum TargetType {
	PLACE,
	PERSON
}

# Methods on the ground
var Methods = [
	{
		"Name": "street observation on foot",
		"Cost": 0,  # weekly
		"Quality": 10,  # from 0 (useless) to 100 (perfect theft)
		"Risk": 40,  # from 0 (hacking) to 100 (shooting), given well working counterintelligence
		"OfficersRequired": 1,  # how many must be involved in operation
	},
	{
		"Name": "street observation by car",
		"Cost": 1,  # weekly
		"Quality": 15,  # from 0 (useless) to 100 (perfect theft)
		"Risk": 20,  # from 0 (hacking) to 100 (shooting), given well working counterintelligence
		"OfficersRequired": 2,  # how many must be involved in operation
	},
	{
		"Name": "rent house for observation",
		"Cost": 10,  # weekly
		"Quality": 30,  # from 0 (useless) to 100 (perfect theft)
		"Risk": 5,  # from 0 (hacking) to 100 (shooting), given well working counterintelligence
		"OfficersRequired": 2,  # how many must be involved in operation
	},
	{
		"Name": "install and operate hidden cameras",
		"Cost": 2,  # weekly
		"Quality": 30,  # from 0 (useless) to 100 (perfect theft)
		"Risk": 20,  # from 0 (hacking) to 100 (shooting), given well working counterintelligence
		"OfficersRequired": 1,  # how many must be involved in operation
	}
]

# Generated targets, first filled in to note an example
var Targets = [
	{
		"Type": TargetType.PLACE,
		"Name": "Russian Embassy in Ireland",
		"Country": 1,  # id from Countries, can change
		"LocationPrecise": "Dublin, Orwell Rd",  # for display only, can change
		"LocationOpenness": 100,  # from 100 (one google search) to 1 (bin laden)
		"LocationSecrecyProgress": 0,  # each week of work openness*officers subtracts from it, 0 reveals location
		"LocationIsKnown": false,
		"RiskOfCounterintelligence": 10,  # from 0 (no ci) to 100 (fsb in moscow)
		"RiskOfDeath": 2,  # from 0 (no armed guards) to 100 (isis)
		"DiffOfObservation": 5,  # from 0 (own backyard) to 100 (cia cellar)
		"AvailableDMethods": [0,1,2,3],  # ids from Methods
	}
]

# Generated adversaries, first filled in to note an example
var Adversaries = [
	{
		"Level": 0,  # 0 country, think about other later
		"Adjective": "Russian",  # used in names
		"Counterintelligence": 95,  # from 0 (absent) to 100 (cia)
		"Hostility": 70,  # from 0 (friend) to 100 (foe)
	},
	{
		"Level": 0,  # 0 country, think about other later
		"Adjective": "Chinese",  # used in names
		"Counterintelligence": 85,  # from 0 (absent) to 100 (cia)
		"Hostility": 80,  # from 0 (friend) to 100 (foe)
	},
	{
		"Level": 0,  # 0 country, think about other later
		"Adjective": "American",  # used in names
		"Counterintelligence": 100,  # from 0 (absent) to 100 (cia)
		"Hostility": 30,  # from 0 (friend) to 100 (foe)
	}
]

var Level0Places = ["Embassy", "Institute", "Palace"]
