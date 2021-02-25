extends Node

class ACountry:
	var Name = null
	var Adjective = null
	var TravelCost = 0  # cost of getting there for one person
	var LocalCost = 0  # weekly base cost of one person operation
	var IntelFriendliness = 100  # towards all operations, 0 to 100
	var Size = 2 # population in millions
	var ElectionPeriod = 52*4  # almost-fixed weeks of governance
	# generated below
	var ElectionProgress = 52*4  # counter to the next election
	var PoliticsIntel = 50  # attitude towards own intel agency, 0 to 100
	var PoliticsAggression = 0  # attitude towards other countries, 0 to 100
	var PoliticsStability = 50  # risk of wrong decisions or earlier elections, 0 to 100
	var Expelled = 0  # how many officers are persona non grata
	
	func _init(aDictionary):
		Name = aDictionary.Name
		Adjective = aDictionary.Adjective
		TravelCost = aDictionary.TravelCost
		LocalCost = aDictionary.LocalCost
		IntelFriendliness = aDictionary.IntelFriendliness
		Size = aDictionary.Size
		ElectionPeriod = aDictionary.ElectionPeriod
		ElectionProgress = aDictionary.ElectionProgress

# All rough locations, usually countries, separated by costs and difficulty
var Countries = [
	ACountry.new({
		"Name": "Homeland",
		"Adjective": "Our",
		"TravelCost": 0,  # cost of getting there for one person
		"LocalCost": 0,  # weekly base cost of one person operation
		"IntelFriendliness": 100,  # towards all operations, 0 to 100
		"Size": 2, # population in millions
		"ElectionPeriod": 52*4,  # almost-fixed weeks of governance
		"ElectionProgress": 52*4,  # counter to the next election
	}),
	ACountry.new({ "Name": "Ireland", "Adjective": "Irish", "TravelCost": 1, "LocalCost": 1, "IntelFriendliness": 90, "Size": 5, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), }),
	ACountry.new({ "Name": "United Kingdom", "Adjective": "English", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 60, "Size": 67, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), }),
	ACountry.new({ "Name": "Belgium", "Adjective": "Belgian", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 80, "Size": 11, "ElectionPeriod": 52*4,  "ElectionProgress": GameLogic.random.randi_range(1,50*4), }),
	ACountry.new({ "Name": "Germany", "Adjective": "German", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 50, "Size": 83, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), }),
	ACountry.new({ "Name": "United States", "Adjective": "American", "TravelCost": 3, "LocalCost": 2, "IntelFriendliness": 40, "Size": 328, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), }),
	ACountry.new({ "Name": "Poland", "Adjective": "Polish", "TravelCost": 1, "LocalCost": 1, "IntelFriendliness": 70, "Size": 38, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), }),
	ACountry.new({ "Name": "France", "Adjective": "French", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 40, "Size": 67, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), }),
	ACountry.new({ "Name": "Russia", "Adjective": "Russian", "TravelCost": 3, "LocalCost": 1, "IntelFriendliness": 30, "Size": 144, "ElectionPeriod": 52*10, "ElectionProgress": GameLogic.random.randi_range(50*5,50*10), }),
	ACountry.new({ "Name": "China", "Adjective": "Chinese", "TravelCost": 5, "LocalCost": 2, "IntelFriendliness": 20, "Size": 1398, "ElectionPeriod": 52*20, "ElectionProgress": GameLogic.random.randi_range(50*10,50*20), }),
	ACountry.new({ "Name": "Israel", "Adjective": "Israeli", "TravelCost": 3, "LocalCost": 2, "IntelFriendliness": 30, "Size": 9, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), }),
	ACountry.new({ "Name": "Turkey", "Adjective": "Turkish", "TravelCost": 2, "LocalCost": 1, "IntelFriendliness": 50, "Size": 84, "ElectionPeriod": 52*10, "ElectionProgress": GameLogic.random.randi_range(1,50*10), }),
	ACountry.new({ "Name": "Iraq", "Adjective": "Iraqi", "TravelCost": 3, "LocalCost": 1, "IntelFriendliness": 40, "Size": 40, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), }),
	ACountry.new({ "Name": "Afghanistan", "Adjective": "Afghan", "TravelCost": 3, "LocalCost": 1, "IntelFriendliness": 60, "Size": 38, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), }),
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

class AnOrganization:
	var Type = OrgType.INTEL
	var Name = null
	var Fixed = true  # cannot delete if true, mainly for intel agencies
	var Known = true  # false for hidden criminal organizations
	var Staff = 0  # number of human members
	var Budget = 0  # monthly in thousands
	var Counterintelligence = 0  # from 0 (get in from the street) to 100 (impossible to infiltrate)
	var Aggression = 0  # from 0 (university) to 100 (isis), when officers caught or ops performed
	var Countries = null  # ids of host countries
	# generated and/or frequently modified
	var OpsAgainstHomeland = []  # future possibility
	var IntelDescription = []  # just for user display, for many authomatically filled
	var IntelDescType = ""  # just for user display, showed over list of gathered intels
	#var IntelIdentified = 0  # number of identified members for possible recruitment
	var IntelIdentified = 3  # DEBUG
	var IntelValue = 0  # -100 (long search) to 100 (own), determines available methods
	var IntelSources = []  # arr of dicts {"Level","Trust"}
	
	func _init(adictionary):
		Type = adictionary.Type
		Name = adictionary.Name
		Fixed = adictionary.Fixed
		Known = adictionary.Known
		Staff = adictionary.Staff
		Budget = adictionary.Budget
		Counterintelligence = adictionary.Counterintelligence
		Aggression = adictionary.Aggression
		Countries = adictionary.Countries.duplicate(true)
		IntelValue = adictionary.IntelValue

var Organizations = [
	AnOrganization.new({
		"Type": OrgType.INTEL,
		"Name": "MI5",
		"Fixed": true,  # cannot delete if true, mainly for intel agencies
		"Known": true,  # false for hidden criminal organizations
		"Staff": 4400,  # number of human members
		"Budget": 260000,  # monthly in thousands
		"Counterintelligence": 90,  # from 0 (get in from the street) to 100 (impossible to infiltrate)
		"Aggression": 65,
		"Countries": [2],  # ids of host countries
		"IntelValue": 5,  # -100 (long search) to 100 (own), determines available methods
	}),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "BND", "Fixed": true, "Known": true, "Staff": 6500, "Budget": 85000, "Counterintelligence": 80, "Aggression": 70, "Countries": [4], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "CIA", "Fixed": true, "Known": true, "Staff": 22000, "Budget": 1250000, "Counterintelligence": 85, "Aggression": 75, "Countries": [5], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "AW (Agencja Wywiadu)", "Fixed": true, "Known": true, "Staff": 1000, "Budget": 20800, "Counterintelligence": 70, "Aggression": 70, "Countries": [6], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "DGSE", "Fixed": true, "Known": true, "Staff": 6100, "Budget": 42000, "Counterintelligence": 85, "Aggression": 75, "Countries": [7], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "ФСБ (FSB)", "Fixed": true, "Known": true, "Staff": 66200, "Budget": 1000000, "Counterintelligence": 85, "Aggression": 80, "Countries": [8], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "Guoanbu", "Fixed": true, "Known": true, "Staff": 100000, "Budget": 2000000, "Counterintelligence": 95, "Aggression": 80, "Countries": [9],  "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "Mossad", "Fixed": true, "Known": true, "Staff": 7000, "Budget": 228000, "Counterintelligence": 95, "Aggression": 85, "Countries": [10], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "MIT (Milli Istihbarat Teskilati)", "Fixed": true, "Known": true, "Staff": 8000, "Budget": 180000, "Counterintelligence": 90, "Aggression": 80, "Countries": [11], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "Mukhabarat", "Fixed": true, "Known": true, "Staff": 4000, "Budget": 20000, "Counterintelligence": 75, "Aggression": 80, "Countries": [12], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "NDS", "Fixed": true, "Known": true, "Staff": 3000, "Budget": 10000, "Counterintelligence": 70, "Aggression": 70, "Countries": [13], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.GENERALTERROR, "Name": "Al-Qaeda", "Fixed": false, "Known": true, "Staff": 45000, "Budget": 25000, "Counterintelligence": 60, "Aggression": 90, "Countries": [12,13], "IntelValue": 0, }),
]

class AMethod:
	var Name = null
	var Cost = 0  # weekly
	var Quality = 0  # from 0 (useless) to 100 (perfect theft)
	var Risk = 0  # from 0 (hacking) to 100 (shooting), given well working counterintelligence
	var OfficersRequired = 0  # how many must be involved in operation
	var MinimalSkill = 0  # minimal average skill to permit this method
	var Available = false  # automatically controlled and set by the game
	var MinimalIntel = 0  # minimal intel level about a target to use this method
	var MinimalTrust = 0  # minimal government trust level to use this method
	
	func _init(aDictionary):
		Name = aDictionary.Name
		Cost = aDictionary.Cost
		Quality = aDictionary.Quality
		Risk = aDictionary.Risk
		OfficersRequired = aDictionary.OfficersRequired
		MinimalSkill = aDictionary.MinimalSkill
		Available = aDictionary.Available
		MinimalIntel = aDictionary.MinimalIntel
		MinimalTrust = aDictionary.MinimalTrust

# Methods on the ground
# 2D array: first row for MORE_INTEL, second row for RECRUIT_SOURCE etc
var Methods = [
	# MORE_INTEL methods
	[
		AMethod.new({ "Name": "general surveillance", "Cost": 2, "Quality": 5, "Risk": 5, "OfficersRequired": 1, "MinimalSkill": 0, "Available": false, "MinimalIntel": -100, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "street observation on foot", "Cost": 1, "Quality": 10, "Risk": 40, "OfficersRequired": 1, "MinimalSkill": 0, "Available": false, "MinimalIntel": 2, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "street observation by car", "Cost": 2, "Quality": 15, "Risk": 20, "OfficersRequired": 2, "MinimalSkill": 0, "Available": false, "MinimalIntel": 2, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "install and operate external cameras", "Cost": 5, "Quality": 30, "Risk": 20, "OfficersRequired": 1, "MinimalSkill": 11, "Available": false, "MinimalIntel": 8, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "rent house for observation", "Cost": 20, "Quality": 40, "Risk": 5, "OfficersRequired": 2, "MinimalSkill": 5, "Available": false, "MinimalIntel": 5, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "attempt physical breach", "Cost": 20, "Quality": 65, "Risk": 65, "OfficersRequired": 5, "MinimalSkill": 25, "Available": false, "MinimalIntel": 50, "MinimalTrust": 30, }),
		AMethod.new({ "Name": "eavesdropping", "Cost": 60, "Quality": 80, "Risk": 10, "OfficersRequired": 4, "MinimalSkill": 40, "Available": false, "MinimalIntel": 5, "MinimalTrust": 30, }),
		AMethod.new({ "Name": "pose as undercover local company", "Cost": 100, "Quality": 55, "Risk": 20, "OfficersRequired": 8, "MinimalSkill": 40, "Available": false, "MinimalIntel": -50, "MinimalTrust": 40, }),
		AMethod.new({ "Name": "pose as undercover government organization", "Cost": 300, "Quality": 70, "Risk": 20, "OfficersRequired": 16, "MinimalSkill": 50, "Available": false, "MinimalIntel": -100, "MinimalTrust": 75, }),
	],
	# RECRUIT_SOURCE methods
	[
		AMethod.new({ "Name": "basic observation of potential assets", "Cost": 4, "Quality": 10, "Risk": 15, "OfficersRequired": 2, "MinimalSkill": 0, "Available": false, "MinimalIntel": 5, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "background check", "Cost": 6, "Quality": 20, "Risk": 25, "OfficersRequired": 3, "MinimalSkill": 10, "Available": false, "MinimalIntel": 10, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "arrange natural meetings with potential assets", "Cost": 10, "Quality": 30, "Risk": 40, "OfficersRequired": 2, "MinimalSkill": 15, "Available": false, "MinimalIntel": 15, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "collect blackmail material", "Cost": 12, "Quality": 60, "Risk": 40, "OfficersRequired": 8, "MinimalSkill": 35, "Available": false, "MinimalIntel": 25, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "construct network of close contacts", "Cost": 15, "Quality": 50, "Risk": 45, "OfficersRequired": 6, "MinimalSkill": 45, "Available": false, "MinimalIntel": 30, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "identify potential defectors", "Cost": 25, "Quality": 80, "Risk": 55, "OfficersRequired": 12, "MinimalSkill": 55, "Available": false, "MinimalIntel": 45, "MinimalTrust": 0, }),
	]
]

# <countryA> phrase <countryB>
var DiplomaticPhrasesPositive = ["'s officials visited ", " expressed will to improve relations with "]
var DiplomaticPhrasesVeryPositive = [" signed a treaty with ", " held joint military exercise with ", " formed bilateral committee "]
var DiplomaticPhrasesNegative = [" condemned actions of ", " withdraw from a treaty with ", " expressed concern about changes in "]
var DiplomaticPhrasesVeryNegative = [" refused to meet with officials of ", " expelled some citizens of ", " attributed destabilization of the region to ", "'s military officials threatened "]

# Next week function like in game logic
func WorldNextWeek(past):
	var doesItEndWithCall = false
	# progressing to elections
	for c in range(0, len(Countries)):
		Countries[c].ElectionProgress -= 1
		if Countries[c].ElectionProgress <= 0:
			# election
			var eventualDesc = ""
			var won = GameLogic.random.randi_range(29,55)
			if GameLogic.random.randi_range(0,1) == 0:
				GameLogic.AddWorldEvent("Elections in " + Countries[c].Name + ": Incumbent won, achieving "+str(won)+"%", past)
				Countries[c].ElectionProgress = Countries[c].ElectionPeriod
				Countries[c].PoliticsAggression += GameLogic.random.randi_range(-5,5)
				Countries[c].PoliticsStability += GameLogic.random.randi_range(10,won)
				if c == 0:
					eventualDesc = "Incumbent won, achieving "+str(won)+"%. Government will largely stay in the same shape, continuing similar foreign policy, and preserving existing approach to intelligence services."
			else:
				GameLogic.AddWorldEvent("Elections in " + Countries[c].Name + ": New government formed, achieving "+str(won)+"%", past)
				Countries[c].ElectionProgress = Countries[c].ElectionPeriod
				Countries[c].PoliticsIntel = GameLogic.random.randi_range(10,90)
				Countries[c].PoliticsAggression += GameLogic.random.randi_range(-15,15)
				Countries[c].PoliticsStability += GameLogic.random.randi_range(won,90)
				for d in range(0, len(Countries)):
					DiplomaticRelations[c][d] += GameLogic.random.randi_range(-10,10)
				if c == 0:
					var newApproach = "adverse"
					var eventualIncrease = ""
					if Countries[c].PoliticsIntel > 60:
						newApproach = "friendly"
						eventualIncrease = "As a mark of a new start, bureau's budget is increased by €" + str(int(GameLogic.BudgetFull*0.3)) + ",000."
						GameLogic.BudgetFull *= 1.3
					elif Countries[c].PoliticsIntel > 30: newApproach = "neutral"
					eventualDesc = "New government formed, achieving "+str(won)+"%. Its approach towards intelligence services can be described as " + newApproach + ". " + eventualIncrease
			# notifying user if that's homeland
			if c == 0 and past == null:
				CallManager.CallQueue.append(
					{
						"Header": "Important Information",
						"Level": "Unclassified",
						"Operation": "",
						"Content": "Homeland election was held in the last week.\n\n" + eventualDesc,
						"Show1": false,
						"Show2": false,
						"Show3": false,
						"Show4": true,
						"Text1": "",
						"Text2": "",
						"Text3": "",
						"Text4": "Understood",
						"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision1Argument": null,
						"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision2Argument": null,
						"Decision3Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision3Argument": null,
						"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision4Argument": null,
					}
				)
	# dealing with country stats government stability
	for c in range(0, len(Countries)):
		# parameter fluctations
		if GameLogic.random.randi_range(1,4) == 2:  # ~one per month
			Countries[c].Size *= (1.0+GameLogic.random.randi_range(-1,1)*0.01)
			Countries[c].IntelFriendliness += GameLogic.random.randi_range(-1,1)
		# stability
		var choice = GameLogic.random.randi_range(0,70)
		if Countries[c].PoliticsStability < 20:
			choice = GameLogic.random.randi_range(0,20)
			if choice > Countries[c].PoliticsStability and GameLogic.random.randi_range(0,10) == 1:
				GameLogic.AddWorldEvent("Government resigned in " + Countries[c].Name, past)
				Countries[c].ElectionProgress = 0
		elif choice > Countries[c].PoliticsStability and GameLogic.random.randi_range(0,20) == 2:
			if GameLogic.random.randi_range(1,3) == 2:
				GameLogic.AddWorldEvent("Protests against government in " + Countries[c].Name, past)
			else:
				GameLogic.AddWorldEvent("Internal tensions affected government in " + Countries[c].Name, past)
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
				if change < 0 and DiplomaticRelations[c][affected] > -30:
					GameLogic.AddWorldEvent(Countries[c].Name + DiplomaticPhrasesNegative[randi() % DiplomaticPhrasesNegative.size()] + Countries[affected].Name, past)
				elif change < 0 and DiplomaticRelations[c][affected] <= -30:
					GameLogic.AddWorldEvent(Countries[c].Name + DiplomaticPhrasesVeryNegative[randi() % DiplomaticPhrasesNegative.size()] + Countries[affected].Name, past)
				elif change > 0 and DiplomaticRelations[c][affected] < 30:
					GameLogic.AddWorldEvent(Countries[c].Name + DiplomaticPhrasesPositive[randi() % DiplomaticPhrasesPositive.size()] + Countries[affected].Name, past)
				elif change > 0 and DiplomaticRelations[c][affected] >= 30:
					GameLogic.AddWorldEvent(Countries[c].Name + DiplomaticPhrasesVeryPositive[randi() % DiplomaticPhrasesPositive.size()] + Countries[affected].Name, past)
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
	# organization proceedings
	for w in range(0,len(Organizations)):
		# intel decay
		Organizations[w].IntelValue *= 0.99  # ~4%/month, ~40%/year
		# staff and budget changes
		if GameLogic.random.randi_range(1,4) == 2:  # ~one per month
			Organizations[w].Budget *= (1.0+GameLogic.random.randi_range(-1,1)*0.01)
			if Organizations[w].Staff > 100:  # large orgs
				Organizations[w].Staff *= (1.0+GameLogic.random.randi_range(-1,1)*0.01)
			else:  # small orgs
				Organizations[w].Staff += GameLogic.random.randi_range(-1,1)
		# sources
		if len(Organizations[w].IntelSources) > 0:
			# modifying every source
			var sumOfLevels = 0.0
			var highestLevel = 0
			var sourceLoss = -1
			for s in range(0,len(Organizations[w].IntelSources)):
				# fluctuate trust
				Organizations[w].IntelSources[s].Trust += GameLogic.random.randi_range(-1,1)
				if Organizations[w].IntelSources[s].Trust < 1:
					sourceLoss = w
					continue
				# fluctuate level
				if GameLogic.random.randi_range(1,3) == 2:
					Organizations[w].IntelSources[s].Level += GameLogic.random.randi_range(-1,1)
				# noting levels for joint intel
				sumOfLevels += Organizations[w].IntelSources[s].Level
				if highestLevel < Organizations[w].IntelSources[s].Level:
					highestLevel = Organizations[w].IntelSources[s].Level
			# eventual source loss
			if sourceLoss != -1:
				Organizations[w].IntelSources.remove(sourceLoss)
				GameLogic.AddEvent('Bureau lost source in ' + Organizations[w].Name)
			# providing joint intel from all sources, every 8 weeks on average
			if GameLogic.random.randi_range(1,8) == 4:
				WorldIntel.GatherOnOrg(w, highestLevel*(1.0+len(Organizations[w].IntelSources)*0.1), GameLogic.GiveDateWithYear())
	return doesItEndWithCall
