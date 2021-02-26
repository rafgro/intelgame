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
	var ActiveOpsAgainstHomeland = 0  # counter to avoid browsing the array below
	var OpsAgainstHomeland = []  # objects of AnExternalOperation
	var IntelDescription = []  # just for user display, for many authomatically filled
	var IntelDescType = ""  # just for user display, showed over list of gathered intels
	var IntelIdentified = 0  # number of identified members for possible recruitment
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
		AMethod.new({ "Name": "general surveillance", "Cost": 2, "Quality": 10, "Risk": 2, "OfficersRequired": 1, "MinimalSkill": 0, "Available": false, "MinimalIntel": -100, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "street observation on foot", "Cost": 1, "Quality": 15, "Risk": 15, "OfficersRequired": 1, "MinimalSkill": 0, "Available": false, "MinimalIntel": 2, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "street observation by car", "Cost": 2, "Quality": 20, "Risk": 7, "OfficersRequired": 2, "MinimalSkill": 0, "Available": false, "MinimalIntel": 2, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "install and operate external cameras", "Cost": 5, "Quality": 30, "Risk": 12, "OfficersRequired": 1, "MinimalSkill": 11, "Available": false, "MinimalIntel": 8, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "rent house for observation", "Cost": 20, "Quality": 45, "Risk": 4, "OfficersRequired": 2, "MinimalSkill": 5, "Available": false, "MinimalIntel": 5, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "attempt physical breach", "Cost": 20, "Quality": 70, "Risk": 55, "OfficersRequired": 5, "MinimalSkill": 25, "Available": false, "MinimalIntel": 50, "MinimalTrust": 30, }),
		AMethod.new({ "Name": "eavesdropping", "Cost": 60, "Quality": 80, "Risk": 15, "OfficersRequired": 4, "MinimalSkill": 40, "Available": false, "MinimalIntel": 5, "MinimalTrust": 30, }),
		AMethod.new({ "Name": "pose as undercover local company", "Cost": 100, "Quality": 60, "Risk": 20, "OfficersRequired": 8, "MinimalSkill": 40, "Available": false, "MinimalIntel": -50, "MinimalTrust": 40, }),
		AMethod.new({ "Name": "pose as undercover government organization", "Cost": 300, "Quality": 85, "Risk": 25, "OfficersRequired": 16, "MinimalSkill": 50, "Available": false, "MinimalIntel": -100, "MinimalTrust": 75, }),
	],
	# RECRUIT_SOURCE methods
	[
		AMethod.new({ "Name": "basic observation of potential assets", "Cost": 4, "Quality": 10, "Risk": 3, "OfficersRequired": 2, "MinimalSkill": 0, "Available": false, "MinimalIntel": 5, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "background check", "Cost": 6, "Quality": 20, "Risk": 10, "OfficersRequired": 3, "MinimalSkill": 10, "Available": false, "MinimalIntel": 10, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "arrange natural meetings with potential assets", "Cost": 10, "Quality": 30, "Risk": 20, "OfficersRequired": 2, "MinimalSkill": 15, "Available": false, "MinimalIntel": 15, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "collect blackmail material", "Cost": 12, "Quality": 60, "Risk": 15, "OfficersRequired": 8, "MinimalSkill": 35, "Available": false, "MinimalIntel": 25, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "construct network of close contacts", "Cost": 15, "Quality": 55, "Risk": 20, "OfficersRequired": 6, "MinimalSkill": 45, "Available": false, "MinimalIntel": 30, "MinimalTrust": 0, }),
		AMethod.new({ "Name": "identify potential defectors", "Cost": 25, "Quality": 80, "Risk": 40, "OfficersRequired": 12, "MinimalSkill": 55, "Available": false, "MinimalIntel": 45, "MinimalTrust": 0, }),
	]
]

enum ExtOpType {
	TERRORIST_ATTACK,
}

class AnExternalOperation:
	var Type = 0
	var Budget = 0  # weekly budget in thousands required for the operation to progress
	var Persons = 0  # number of persons involved, more -> easier to catch but also more damage
	var Secrecy = 0  # 0 (public knowledge) to 100 (bataclan)
	var Damage = 0  # done to the target, 0 (observation) to 100 (9/11)
	# state vars
	var Active = false  # operations are not removed, only deactivated, to allow investigations
	var FinishCounter = 0  # -1 every week until it is 0 and operation is launched
	var IntelValue = 0  # 0 (uknown) to 100 (perfectly known)
	
	func _init(adict):
		Active = true
		Type = adict.Type
		Budget = adict.Budget
		Persons = adict.Persons
		Secrecy = adict.Secrecy
		Damage = adict.Damage
		FinishCounter = adict.FinishCounter

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
						"Operation": "-//-",
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
				doesItEndWithCall = true
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
		# continuing existing operations
		for u in range(0,len(Organizations[w].OpsAgainstHomeland)):
			if Organizations[w].OpsAgainstHomeland[u].Active == false:
				continue
			Organizations[w].OpsAgainstHomeland[u].FinishCounter -= 1
			if Organizations[w].OpsAgainstHomeland[u].FinishCounter <= 0:
				if Organizations[w].OpsAgainstHomeland[u].Type == ExtOpType.TERRORIST_ATTACK:
					# it's happenning
					var shortDesc = ""
					var longDesc = ""
					var casualties = 0
					var trustLoss = 0
					var responsibility = "Officers do not know who perpetuated the attack."
					# defining details
					if Organizations[w].Aggression > 70 and GameLogic.random.randi_range(1,2) == 2:
						responsibility = Organizations[w].Name + " claimed responsibility. "
					if Organizations[w].OpsAgainstHomeland[u].Damage >= 98:
						shortDesc = "Large terrorist attack with many casualties"
						casualties = GameLogic.random.randi_range(5000,100000)
						trustLoss = GameLogic.Trust
						# generate a detailed story about specifics later
						longDesc = "a largest terrorist attack in the world history"
					elif Organizations[w].OpsAgainstHomeland[u].Damage >= 90:
						shortDesc = "Large terrorist attack with many casualties"
						casualties = GameLogic.random.randi_range(1000,5000)
						trustLoss = GameLogic.Trust*0.95
						if trustLoss < 25: trustLoss = 25
						longDesc = "a large terrorist attack"
					elif Organizations[w].OpsAgainstHomeland[u].Damage >= 75:
						shortDesc = "Large terrorist attack with many casualties"
						casualties = GameLogic.random.randi_range(200,1000)
						trustLoss = GameLogic.Trust*0.9
						if trustLoss < 25: trustLoss = 25
						longDesc = "a large terrorist attack"
					elif Organizations[w].OpsAgainstHomeland[u].Damage >= 55:
						shortDesc = "Terrorist attack"
						casualties = GameLogic.random.randi_range(100,200)
						trustLoss = GameLogic.Trust*0.9
						if trustLoss < 25: trustLoss = 25
						longDesc = "a terrorist attack"
					elif Organizations[w].OpsAgainstHomeland[u].Damage >= 40:
						shortDesc = "Terrorist attack"
						casualties = GameLogic.random.randi_range(50,100)
						trustLoss = GameLogic.Trust*0.9
						if trustLoss < 25: trustLoss = 25
						longDesc = "a terrorist attack"
					elif Organizations[w].OpsAgainstHomeland[u].Damage >= 30:
						shortDesc = "Terrorist attack"
						casualties = GameLogic.random.randi_range(10,50)
						trustLoss = GameLogic.Trust*0.9
						if trustLoss < 25: trustLoss = 25
						longDesc = "a terrorist attack"
					elif Organizations[w].OpsAgainstHomeland[u].Damage >= 20:
						shortDesc = "Minor terrorist incident"
						casualties = GameLogic.random.randi_range(5,10)
						trustLoss = GameLogic.Trust*0.8
						if trustLoss < 15: trustLoss = 15
						longDesc = "a minor terrorist incident"
					elif Organizations[w].OpsAgainstHomeland[u].Damage >= 10:
						shortDesc = "Minor terrorist incident"
						casualties = GameLogic.random.randi_range(1,5)
						trustLoss = GameLogic.Trust*0.8
						if trustLoss < 15: trustLoss = 15
						longDesc = "a minor terrorist incident"
					else:
						shortDesc = "Minor terrorist incident"
						casualties = GameLogic.random.randi_range(0,1)
						if casualties == 0: casualties = "no"
						trustLoss = GameLogic.Trust*0.8
						if trustLoss < 15: trustLoss = 15
						longDesc = "a minor terrorist incident"
					# executing details and communicating them
					if trustLoss > GameLogic.Trust: trustLoss = GameLogic.Trust
					GameLogic.Trust -= trustLoss
					Organizations[w].OpsAgainstHomeland[u].Active = false
					Organizations[w].ActiveOpsAgainstHomeland -= 1
					GameLogic.AddWorldEvent(shortDesc+" in Homeland", past)
					CallManager.CallQueue.append(
						{
							"Header": "Important Information",
							"Level": "Unclassified",
							"Operation": "-//-",
							"Content": "The worst has happened.\n\nHomeland suffered from "+longDesc+". There were "+str(casualties)+" casualties. " + responsibility + "\n\nBureau lost "+str(int(trustLoss))+"% of trust.",
							"Show1": false,
							"Show2": false,
							"Show3": false,
							"Show4": true,
							"Text1": "",
							"Text2": "",
							"Text3": "Launch investigation",
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
					doesItEndWithCall = true
		# new operations against countries
		if Organizations[w].Type == OrgType.GENERALTERROR:
			# number of attacks relies on budget*aggression
			var opFrequency = Organizations[w].Aggression
			if Organizations[w].Budget < 100: opFrequency *= 0.1
			elif Organizations[w].Budget < 1000: opFrequency *= 0.2
			elif Organizations[w].Budget < 10000: opFrequency *= 0.4
			elif Organizations[w].Budget < 50000: opFrequency *= 0.6
			elif Organizations[w].Budget < 100000: opFrequency *= 0.8
			var randFrequency = 120 - opFrequency  # max aggr->20, min aggr->120
			randFrequency *= 0.3  # three times higher frequency, balancing
			if GameLogic.random.randi_range(0,randFrequency) == int(randFrequency*0.5):
				# DEBUG
				var whichCountry = 0#randi() % Countries.size()
				# against other countries
				if whichCountry != 0:
					if GameLogic.random.randi_range(1,3) == 3:  # ~2/3 are prevented
						var desc = ""
						if opFrequency > 35:
							if GameLogic.random.randi_range(1,3) == 1:
								desc = "Large terrorist attack with many casualties in "
							else:
								desc = "Terrorist attack in "
						else:
							if GameLogic.random.randi_range(1,3) == 2:
								desc = "Terrorist attack in "
							else:
								desc = "Minor terrorist incident in "
						desc += Countries[whichCountry].Name
						if Organizations[w].Aggression > 70 and GameLogic.random.randi_range(1,2) == 2:
							desc += ", " + Organizations[w].Name + " claimed responsibility"
						else:
							if GameLogic.random.randi_range(0,100) > Countries[whichCountry].IntelFriendliness:
								desc += ", local authorities point to " + Organizations[w].Name + " as the perpetrator"
							else:
								desc += ", local authorities do not know the perpetrator"
						GameLogic.AddWorldEvent(desc, past)
				# against homeland
				elif past == null:  # not in the past
					var opSize = GameLogic.random.randi_range(1,10) * 0.1  # 0.0-1.0 of org resources
					var opSecrecy = GameLogic.random.randi_range(Organizations[w].Counterintelligence*0.7,100)
					var opDamage = GameLogic.random.randi_range(Organizations[w].Aggression*0.2, Organizations[w].Aggression)
					var opLength = opDamage*opSize
					if Organizations[w].Staff > 10000: opLength += GameLogic.random.randi_range(-30,30)
					elif Organizations[w].Staff > 1000: opLength += GameLogic.random.randi_range(-20,20)
					elif Organizations[w].Staff > 100: opLength += GameLogic.random.randi_range(-10,10)
					else: opLength += GameLogic.random.randi_range(-5,5)
					if opLength < 4: opLength = 4
					Organizations[w].OpsAgainstHomeland.append(AnExternalOperation.new(
						{
							"Type": ExtOpType.TERRORIST_ATTACK,
							"Budget": int(Organizations[w].Budget * opSize),
							"Persons": int(Organizations[w].Staff * 0.5 * opSize),
							"Secrecy": int(opSecrecy),
							"Damage": int(opDamage),
							"FinishCounter": int(opLength),
						}
					))
					Organizations[w].ActiveOpsAgainstHomeland += 1
					print("new op against homeland: "+str(opLength))
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
