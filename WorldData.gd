extends Node

# All rough locations, usually countries, separated by costs and difficulty
var Countries = [
	{
		"Name": "Homeland",
		"IsEmbassyAvailable": true,
		"TravelCost": 0,  # cost of getting there for one person
		"LocalCost": 0  # weekly base cost of one person operation
	},
	{
		"Name": "Ireland",
		"IsEmbassyAvailable": true,
		"TravelCost": 2,  # cost of getting there for one person
		"LocalCost": 1  # weekly base cost of one person operation
	}
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

# Generated targets, usually attached to a specific country, but some can move
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
