extends Node

var Description = "[b]Europe and Superpowers in 2021[/b]\n\n- Homeland as a new small country\n- Complex relations between US, China, and Russia\n- Very active Russian and Chinese intelligence services\n- Multiple turbulent social movements\n- Weakened Islamic State desperate to rebuild its power\n- Expensive travel and empty streets due to the pandemic\n- Governments hungry for coronavirus technology, ordering intelligence services to steal vaccines and efficient treatments"

# one year simulation from 2020 and then starts in 2021
var PossibleCountries = [
	WorldData.aNewCountry({ "Name": "Ireland", "Adjective": "Irish", "TravelCost": 1, "LocalCost": 1, "IntelFriendliness": 90, "Size": 5, "ElectionPeriod": 52*5, "ElectionProgress": 52+52*4.1, "SoftPower": 40, }),
	WorldData.aNewCountry({ "Name": "United Kingdom", "Adjective": "British", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 40, "Size": 67, "ElectionPeriod": 52*5, "ElectionProgress": 52+52*3.4, "SoftPower": 90, }),
	WorldData.aNewCountry({ "Name": "Belgium", "Adjective": "Belgian", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 80, "Size": 11, "ElectionPeriod": 52*5,  "ElectionProgress": 52+52*3.5, "SoftPower": 50, }),
	WorldData.aNewCountry({ "Name": "Germany", "Adjective": "German", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 60, "Size": 83, "ElectionPeriod": 52*4, "ElectionProgress": 52+7*4*10, "SoftPower": 80, }),
	WorldData.aNewCountry({ "Name": "United States", "Adjective": "American", "TravelCost": 3, "LocalCost": 2, "IntelFriendliness": 30, "Size": 328, "ElectionPeriod": 52*5, "ElectionProgress": 52+52*4.8, "SoftPower": 95, }),
	WorldData.aNewCountry({ "Name": "France", "Adjective": "French", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 40, "Size": 67, "ElectionPeriod": 52*5, "ElectionProgress": 52+52*1.4, "SoftPower": 75, }),
	WorldData.aNewCountry({ "Name": "Russia", "Adjective": "Russian", "TravelCost": 3, "LocalCost": 1, "IntelFriendliness": 30, "Size": 144, "ElectionPeriod": 52*20, "ElectionProgress": 52+52*15, "SoftPower": 80, }),
	WorldData.aNewCountry({ "Name": "China", "Adjective": "Chinese", "TravelCost": 5, "LocalCost": 2, "IntelFriendliness": 20, "Size": 1398, "ElectionPeriod": 52*20, "ElectionProgress": 52+52*19, "SoftPower": 95, }),
	WorldData.aNewCountry({ "Name": "Israel", "Adjective": "Israeli", "TravelCost": 3, "LocalCost": 2, "IntelFriendliness": 30, "Size": 9, "ElectionPeriod": 52*4, "ElectionProgress": 52+7*4*3, "SoftPower": 80, }),
	WorldData.aNewCountry({ "Name": "Spain", "Adjective": "Spanish", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 60, "Size": 47, "ElectionPeriod": 52*4, "ElectionProgress": 52+52*2.4, "SoftPower": 60, }),
	WorldData.aNewCountry({ "Name": "Italy", "Adjective": "Italian", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 55, "Size": 60, "ElectionPeriod": 52*5, "ElectionProgress": 52+52*2.5, "SoftPower": 60, }),
	WorldData.aNewCountry({ "Name": "Switzerland", "Adjective": "Swiss", "TravelCost": 2, "LocalCost": 3, "IntelFriendliness": 65, "Size": 9, "ElectionPeriod": 52*4, "ElectionProgress": 52+52*2.8, "SoftPower": 70, }),
]

func GenerateWorld():
	# - Homeland as a new small country\n- Complex relations between US, China, and Russia\n- Very active Russian and Chinese intelligence services\n- Multiple turbulent social movements\n- Weakened Islamic State desperate to rebuild its power\n- Expensive travel and empty streets due to the pandemic
	GameLogic.random.randomize()
	randomize()
	var homelandSoftPowerLastMonths = []  # will be returned
	############################################################################
	# get countries
	for c in range(0, len(PossibleCountries)):
		WorldData.Countries.append(PossibleCountries[c])
	############################################################################
	# 2021 countries features
	WorldData.Countries[2].WMDProgress = 100
	WorldData.Countries[2].WMDIntel = 100
	WorldData.Countries[5].WMDProgress = 100
	WorldData.Countries[5].WMDIntel = 100
	WorldData.Countries[6].WMDProgress = 70
	WorldData.Countries[6].WMDIntel = 70
	WorldData.Countries[7].WMDProgress = 100
	WorldData.Countries[7].WMDIntel = 100
	WorldData.Countries[8].WMDProgress = 100
	WorldData.Countries[8].WMDIntel = 100
	############################################################################
	# relationships
	#    HO IR UK BE GE US FR RU CH IS SP IT SW
	WorldData.DiplomaticRelations = [
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],  # HO
		[0, 0, -30, 0, 0, 20, 40, -10, -10, -25, 10, 0, 0],  # IR
		[0, -30, 0, 10, -5, 40, 10, -40, -30, 0, 0, 0, 0],  # UK
		[0, 0, 10, 0, 0, 0, -10, 0, 0, 0, 0, 0, 0],  # BE
		[0, 0, -5, 10, 0, 10, 20, 10, 0, 10, 0, 0, 0],  # GE
		[0, 20, 40, 10, 10, 0, 10, -40, -60, 50, 0, 0, 10],  # US
		[0, 40, 10, -10, 10, 10, 0, 10, 0, 0, 20, 0, 20],  # FR
		[0, 0, -40, 0, 10, -40, 5, 0, 0, 10, -10, 0, 10],  # RU
		[0, 0, -20, 0, 0, -60, 0, 10, 0, -10, 0, 0, 10],  # CH
		[0, -20, 0, 0, 10, 50, 10, -5, 0, 0, 0, 0, 0],  # IS
		[0, 0, 10, 10, 10, 0, 0, 0, 0, 0, 0, 10, 0],  # SP
		[0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 10],  # IT
		[0, 0, 10, 0, 10, 10, 0, 10, 10, 10, 10, 10, 0],  # SW
	]
	############################################################################
	# other properties
	WorldData.Countries[1].PoliticsAggression = 10  # IR
	WorldData.Countries[1].PoliticsIntel = 30
	WorldData.Countries[1].PoliticsStability = 70
	WorldData.Countries[2].PoliticsAggression = 60  # UK
	WorldData.Countries[2].PoliticsIntel = 80
	WorldData.Countries[2].PoliticsStability = 60
	WorldData.Countries[3].PoliticsAggression = 20  # BE
	WorldData.Countries[3].PoliticsIntel = 10
	WorldData.Countries[3].PoliticsStability = 50
	WorldData.Countries[4].PoliticsAggression = 50  # GE
	WorldData.Countries[4].PoliticsIntel = 60
	WorldData.Countries[4].PoliticsStability = 60
	WorldData.Countries[5].PoliticsAggression = 90  # US
	WorldData.Countries[5].PoliticsIntel = 90
	WorldData.Countries[5].PoliticsStability = 90
	WorldData.Countries[6].PoliticsAggression = 50  # FR
	WorldData.Countries[6].PoliticsIntel = 80
	WorldData.Countries[6].PoliticsStability = 30
	WorldData.Countries[7].PoliticsAggression = 95  # RU
	WorldData.Countries[7].PoliticsIntel = 90
	WorldData.Countries[7].PoliticsStability = 90
	WorldData.Countries[8].PoliticsAggression = 85  # CH
	WorldData.Countries[8].PoliticsIntel = 70
	WorldData.Countries[8].PoliticsStability = 90
	WorldData.Countries[9].PoliticsAggression = 80  # IS
	WorldData.Countries[9].PoliticsIntel = 90
	WorldData.Countries[9].PoliticsStability = 20
	WorldData.Countries[10].PoliticsAggression = 40  # SP
	WorldData.Countries[10].PoliticsIntel = 50
	WorldData.Countries[10].PoliticsStability = 30
	WorldData.Countries[11].PoliticsAggression = 50  # IT
	WorldData.Countries[11].PoliticsIntel = 40
	WorldData.Countries[11].PoliticsStability = 20
	WorldData.Countries[12].PoliticsAggression = 50  # SW
	WorldData.Countries[12].PoliticsIntel = 50
	WorldData.Countries[12].PoliticsStability = 90
	############################################################################
	# setting initial direction parameters
	for e in range(1, len(WorldData.Countries)):
		# covert travel determination, later modified by eventual local intel agency
		if WorldData.DiplomaticRelations[e][0] > 30:
			WorldData.Countries[e].CovertTravel = WorldData.Countries[e].IntelFriendliness + GameLogic.random.randi_range(5,20)
		elif WorldData.DiplomaticRelations[e][0] < -30:
			WorldData.Countries[e].CovertTravel = WorldData.Countries[e].IntelFriendliness + GameLogic.random.randi_range(-20,-5)
		else:
			WorldData.Countries[e].CovertTravel = WorldData.Countries[e].IntelFriendliness + GameLogic.random.randi_range(-5,5)
		# english language plus popular culture
		if WorldData.Countries[e].Adjective == "Irish" or WorldData.Countries[e].Adjective == "British" or WorldData.Countries[e].Adjective == "American":
			WorldData.Countries[e].KnowhowLanguage = GameLogic.random.randi_range(75,85)
			WorldData.Countries[e].KnowhowCustoms = GameLogic.random.randi_range(40,75)
		else:
			WorldData.Countries[e].KnowhowCustoms = GameLogic.random.randi_range(0,15)
	# three directions provided by officers knowing their language and some customs
	for z in range(0,3):
		var whichC = GameLogic.random.randi_range(1, len(WorldData.Countries)-1)
		WorldData.Countries[whichC].KnowhowLanguage = GameLogic.random.randi_range(70,95)
		WorldData.Countries[whichC].KnowhowCustoms = GameLogic.random.randi_range(20,65)
	############################################################################
	# generating organizations
	var doNotDuplicate = []
	# governments, national orgs, orgs characteristic for countries
	for i in range(1, len(WorldData.Countries)):
		WorldData.Organizations.append(
			WorldData.aNewOrganization({ "Type": WorldData.OrgType.GOVERNMENT, "Name": WorldData.Countries[i].Adjective + " Government", "Fixed": true, "Known": true, "Staff": WorldData.Countries[i].Size*300, "Budget": WorldData.Countries[i].Size*10000, "Counterintelligence": GameLogic.random.randi_range(45,65), "Aggression": GameLogic.random.randi_range(20,55), "Countries": [i], "IntelValue": 10, "TargetConsistency": 0, "TargetCountries": [], })
		)
		WorldData.Organizations[-1].IntelIdentified = GameLogic.random.randi_range(20,100)  # officials
		WorldGenerator.GenerateIntelOrgs(WorldData.Countries[i].Name, i)
	############################################################################
	# organizations such as NATO or UN
	WorldGenerator.CreateAdHocOrgs()
	# 2021 things
	# movements
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": "Islamic Fundamentalists", "Fixed": false, "Known": true, "Staff": 1000000, "Budget": 0, "Counterintelligence": 0, "Aggression": 75, "Countries": [2,3,4,6,10,11], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	var islamicFundamentalists = len(WorldData.Organizations)-1
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": "Black Lives Matter", "Fixed": false, "Known": true, "Staff": 250000, "Budget": 0, "Counterintelligence": 0, "Aggression": 60, "Countries": [5], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": "QAnon", "Fixed": false, "Known": true, "Staff": 10000, "Budget": 0, "Counterintelligence": 0, "Aggression": 60, "Countries": [5], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	var qanons = len(WorldData.Organizations)-1
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": "Anti-Lockdown Movement", "Fixed": false, "Known": true, "Staff": 1000000, "Budget": 0, "Counterintelligence": 0, "Aggression": 40, "Countries": [1,2,3,4,5,6,10,11], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": "Climate Strike", "Fixed": false, "Known": true, "Staff": 100000, "Budget": 0, "Counterintelligence": 0, "Aggression": 20, "Countries": [2,5], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": "Hong Kong Protesters", "Fixed": false, "Known": true, "Staff": 100000, "Budget": 0, "Counterintelligence": 0, "Aggression": 50, "Countries": [8], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": "Yellow Vests", "Fixed": false, "Known": true, "Staff": 300000, "Budget": 0, "Counterintelligence": 0, "Aggression": 60, "Countries": [6], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	# terror
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "Proud Boys", "Fixed": false, "Known": true, "Staff": 500, "Budget": 100, "Counterintelligence": 50, "Aggression": 40, "Countries": [5], "IntelValue": 0, "TargetConsistency": 100, "TargetCountries": [5], })
	)
	WorldData.Organizations[-1].ConnectedTo.append(qanons)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "Islamic Separatists", "Fixed": false, "Known": true, "Staff": 20000, "Budget": 1000, "Counterintelligence": 30, "Aggression": 70, "Countries": [6,7], "IntelValue": -10, "TargetConsistency": 80, "TargetCountries": [6], })
	)
	WorldData.Organizations[-1].ConnectedTo.append(islamicFundamentalists)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "ISIS Sympathizers", "Fixed": false, "Known": true, "Staff": 5000, "Budget": 500, "Counterintelligence": 50, "Aggression": 90, "Countries": [2,3,4,6,10,11], "IntelValue": -5, "TargetConsistency": 40, "TargetCountries": [2,3,4,6,10,11], })
	)
	WorldData.Organizations[-1].ConnectedTo.append(islamicFundamentalists)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "Al-Muhajiroun", "Fixed": false, "Known": true, "Staff": 200, "Budget": 500, "Counterintelligence": 30, "Aggression": 70, "Countries": [2], "IntelValue": -5, "TargetConsistency": 80, "TargetCountries": [2], })
	)
	WorldData.Organizations[-1].ConnectedTo.append(islamicFundamentalists)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "Real IRA", "Fixed": false, "Known": true, "Staff": 250, "Budget": 100, "Counterintelligence": 70, "Aggression": 70, "Countries": [1], "IntelValue": -5, "TargetConsistency": 90, "TargetCountries": [2], })
	)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "Reich Citizens", "Fixed": false, "Known": true, "Staff": 1000, "Budget": 100, "Counterintelligence": 60, "Aggression": 40, "Countries": [4], "IntelValue": -5, "TargetConsistency": 90, "TargetCountries": [4], })
	)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "Vilayat Kavkaz", "Fixed": false, "Known": true, "Staff": 1000, "Budget": 10000, "Counterintelligence": 80, "Aggression": 80, "Countries": [7], "IntelValue": -5, "TargetConsistency": 95, "TargetCountries": [7], })
	)
	# companies
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.COMPANY, "Name": "AstraZeneca", "Fixed": true, "Known": true, "Staff": 70600, "Budget": 6000000, "Counterintelligence": 50, "Aggression": 0, "Countries": [2], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].TechDescription = "coronavirus vaccine AZD1222"
	WorldData.Organizations[-1].Technology = 85
	WorldData.Organizations[-1].TradecraftTech = false
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.COMPANY, "Name": "BioNTech", "Fixed": true, "Known": true, "Staff": 1323, "Budget": 5000, "Counterintelligence": 40, "Aggression": 0, "Countries": [4], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].TechDescription = "coronavirus vaccine BNT162b2"
	WorldData.Organizations[-1].Technology = 95
	WorldData.Organizations[-1].TradecraftTech = false
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.COMPANY, "Name": "Pfizer", "Fixed": true, "Known": true, "Staff": 2500, "Budget": 50000, "Counterintelligence": 40, "Aggression": 0, "Countries": [1,5], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].TechDescription = "coronavirus vaccine BNT162b2"
	WorldData.Organizations[-1].Technology = 95
	WorldData.Organizations[-1].TradecraftTech = false
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.COMPANY, "Name": "Moderna", "Fixed": true, "Known": true, "Staff": 830, "Budget": 475000, "Counterintelligence": 60, "Aggression": 0, "Countries": [5], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].TechDescription = "coronavirus vaccine mRNA-1273"
	WorldData.Organizations[-1].Technology = 90
	WorldData.Organizations[-1].TradecraftTech = false
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.COMPANY, "Name": "J&J", "Fixed": true, "Known": true, "Staff": 13000, "Budget": 900000, "Counterintelligence": 60, "Aggression": 0, "Countries": [5], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].TechDescription = "coronavirus vaccine JNJ-78436735"
	WorldData.Organizations[-1].Technology = 80
	WorldData.Organizations[-1].TradecraftTech = false
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.COMPANY, "Name": "Sinovac Biotech", "Fixed": true, "Known": true, "Staff": 3000, "Budget": 50000, "Counterintelligence": 80, "Aggression": 0, "Countries": [8], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].TechDescription = "coronavirus vaccine CoronaVac"
	WorldData.Organizations[-1].Technology = 75
	WorldData.Organizations[-1].TradecraftTech = false
	# scientific institutes
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.UNIVERSITY, "Name": "Oxford University", "Fixed": true, "Known": true, "Staff": 14500, "Budget": 100000, "Counterintelligence": 30, "Aggression": 0, "Countries": [2], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].TechDescription = "coronavirus vaccine AZD1222"
	WorldData.Organizations[-1].Technology = 85
	WorldData.Organizations[-1].TradecraftTech = false
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.UNIVERSITY, "Name": "Gamaleya Institute", "Fixed": true, "Known": true, "Staff": 379, "Budget": 1000, "Counterintelligence": 70, "Aggression": 0, "Countries": [7], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].TechDescription = "coronavirus vaccine Sputnik-V"
	WorldData.Organizations[-1].Technology = 75
	WorldData.Organizations[-1].TradecraftTech = false
	# the pandemic
	############################################################################
	# generators
	# movements
	var movNames = ["Religious Movement", "Nationalists", "Anarchists", "Resistance"]
	for i in range(0,4):
		var doNotRepeat = []
		for k in range(0,GameLogic.random.randi_range(0,2)):
			var size = GameLogic.random.randi_range(100,15000)
			var place = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
			if place in doNotRepeat: continue
			doNotRepeat.append(place)
			WorldData.Organizations.append(
				WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": WorldData.Countries[place].Adjective + " " + movNames[i], "Fixed": false, "Known": true, "Staff": size, "Budget": 0, "Counterintelligence": 0, "Aggression": GameLogic.random.randi_range(10,70), "Countries": [place], "IntelValue": GameLogic.random.randi_range(-10,10), "TargetConsistency": 0, "TargetCountries": [], })
			)
	# few general terror orgs
	var howManyTerror = 2
	var howManyLone = 2
	for i in range(0,howManyTerror):
		var size = GameLogic.random.randi_range(10,500)
		var places = []
		for h in range(0, GameLogic.random.randi_range(1,4)):
			var trying = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
			if !(trying in places):
				places.append(trying)
		var name = WorldGenerator.GenerateHostileName()
		if name in doNotDuplicate: continue
		doNotDuplicate.append(name)
		WorldData.Organizations.append(
			WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": name, "Fixed": false, "Known": true, "Staff": size, "Budget": size*100+GameLogic.random.randi_range(-100,100), "Counterintelligence": GameLogic.random.randi_range(10,60), "Aggression": GameLogic.random.randi_range(30,95), "Countries": places, "IntelValue": GameLogic.random.randi_range(-10,0), "TargetConsistency": 0, "TargetCountries": [], })
		)
		# usual targets
		WorldData.Organizations[-1].TargetConsistency = GameLogic.random.randi_range(0,100)
		for h in range(0, GameLogic.random.randi_range(1,5)):
			var trying = GameLogic.random.randi_range(0,len(WorldData.Countries)-1)
			if !(trying in WorldData.Organizations[-1].TargetCountries):
				WorldData.Organizations[-1].TargetCountries.append(trying)
		# at least one dominant terror org
		if i == 0: WorldData.Organizations[-1].Aggression = GameLogic.random.randi_range(75,99)
		# tying some terror orgs to movements
		if GameLogic.random.randi_range(1,3) <= 2:
			for j in range(0,len(WorldData.Organizations)):
				if WorldData.Organizations[j].Type != WorldData.OrgType.MOVEMENT: continue
				if !(WorldData.Organizations[j].Countries[0] in places): continue
				if GameLogic.random.randi_range(1,2) == 1:
					WorldData.Organizations[j].ConnectedTo.append(len(WorldData.Organizations)-1)
		# target homeland more often
		if !(0 in WorldData.Organizations[-1].TargetCountries):
			if GameLogic.random.randi_range(1,4) == 3:
				WorldData.Organizations[-1].TargetCountries.append(0)
	# hidden or emerging terror orgs
	for i in range(0,1):
		var size = GameLogic.random.randi_range(2,10)
		var places = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		var name = WorldGenerator.GenerateHostileName()
		if name in doNotDuplicate: continue
		doNotDuplicate.append(name)
		WorldData.Organizations.append(
			WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": name, "Fixed": false, "Known": false, "Staff": size, "Budget": size*100+GameLogic.random.randi_range(-50,150), "Counterintelligence": GameLogic.random.randi_range(5,50), "Aggression": GameLogic.random.randi_range(45,95), "Countries": [places], "IntelValue": GameLogic.random.randi_range(-20,-5), "TargetConsistency": 0, "TargetCountries": [], })
		)
		# usual targets
		WorldData.Organizations[-1].TargetConsistency = GameLogic.random.randi_range(0,100)
		for h in range(0, GameLogic.random.randi_range(1,5)):
			var trying = GameLogic.random.randi_range(0,len(WorldData.Countries)-1)
			if !(trying in WorldData.Organizations[-1].TargetCountries):
				WorldData.Organizations[-1].TargetCountries.append(trying)
		# hidden
		WorldData.Organizations[-1].UndercoverCounter = GameLogic.random.randi_range(30,150)
		# tying some terror orgs to movements
		for j in range(0,len(WorldData.Organizations)):
			if WorldData.Organizations[j].Type != WorldData.OrgType.MOVEMENT: continue
			if WorldData.Organizations[j].Countries[0] != places: continue
			if GameLogic.random.randi_range(1,2) == 1:
				WorldData.Organizations[j].ConnectedTo.append(len(WorldData.Organizations)-1)
		# target homeland more often
		if !(0 in WorldData.Organizations[-1].TargetCountries):
			if GameLogic.random.randi_range(1,12) == 5:
				WorldData.Organizations[-1].TargetCountries.append(0)
	# lone wolves
	for i in range(0,howManyLone):
		var size = 1
		var places = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		var name = WorldGenerator.GenerateHostileName()
		if name in doNotDuplicate: continue
		doNotDuplicate.append(name)
		WorldData.Organizations.append(
			WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": name, "Fixed": false, "Known": false, "Staff": size, "Budget": GameLogic.random.randi_range(25,150), "Counterintelligence": GameLogic.random.randi_range(20,80), "Aggression": GameLogic.random.randi_range(15,65), "Countries": [places], "IntelValue": GameLogic.random.randi_range(-10,0), "TargetConsistency": 0, "TargetCountries": [], })
		)
		# usual targets
		WorldData.Organizations[-1].TargetConsistency = GameLogic.random.randi_range(0,100)
		for h in range(0, GameLogic.random.randi_range(1,5)):
			var trying = GameLogic.random.randi_range(0,len(WorldData.Countries)-1)
			if !(trying in WorldData.Organizations[-1].TargetCountries):
				WorldData.Organizations[-1].TargetCountries.append(trying)
		# too small to surface
		WorldData.Organizations[-1].UndercoverCounter = GameLogic.random.randi_range(60,180)
		# tying some terror orgs to movements
		for j in range(0,len(WorldData.Organizations)):
			if WorldData.Organizations[j].Type != WorldData.OrgType.MOVEMENT: continue
			if WorldData.Organizations[j].Countries[0] != places: continue
			if GameLogic.random.randi_range(1,2) == 1:
				WorldData.Organizations[j].ConnectedTo.append(len(WorldData.Organizations)-1)
		# target homeland more often
		if !(0 in WorldData.Organizations[-1].TargetCountries):
			if GameLogic.random.randi_range(1,10) == 2:
				WorldData.Organizations[-1].TargetCountries.append(0)
	# few arms traders
	for i in range(0,6):
		var places = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		var name = WorldGenerator.GenerateCompanyName()
		if name in doNotDuplicate: continue
		doNotDuplicate.append(name)
		var ifKnown = false
		if GameLogic.random.randi_range(1,3) == 2: ifKnown = true
		WorldData.Organizations.append(
			WorldData.aNewOrganization({ "Type": WorldData.OrgType.ARMTRADER, "Name": name, "Fixed": false, "Known": ifKnown, "Staff": GameLogic.random.randi_range(10,200), "Budget": GameLogic.random.randi_range(1000,100000), "Counterintelligence": GameLogic.random.randi_range(50,80), "Aggression": GameLogic.random.randi_range(55,95), "Countries": [places], "IntelValue": GameLogic.random.randi_range(-10,0), "TargetConsistency": 0, "TargetCountries": [], })
		)
		if ifKnown == false:
			WorldData.Organizations[-1].UndercoverCounter = GameLogic.random.randi_range(40,240)
		# tying some terror orgs to this arm trader
		var howManyToTie = GameLogic.random.randi_range(0,3)
		var tied = 0
		for j in range(0,len(WorldData.Organizations)):
			if tied >= howManyToTie: break
			if WorldData.Organizations[j].Type != WorldData.OrgType.GENERALTERROR: continue
			if !(places in WorldData.Organizations[j].Countries): continue
			if GameLogic.random.randi_range(1,4) == 2:
				WorldData.Organizations[-1].ConnectedTo.append(j)
				tied += 1
	# companies
	for i in range(0,5):
		var size = GameLogic.random.randi_range(10,5000)
		var places = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		var name = WorldGenerator.GenerateCompanyName()
		if name in doNotDuplicate: continue
		doNotDuplicate.append(name)
		WorldData.Organizations.append(
			WorldData.aNewOrganization({ "Type": WorldData.OrgType.COMPANY, "Name": name, "Fixed": false, "Known": true, "Staff": size, "Budget": size*100+GameLogic.random.randi_range(-100,100), "Counterintelligence": GameLogic.random.randi_range(10,50), "Aggression": GameLogic.random.randi_range(0,10), "Countries": [places], "IntelValue": GameLogic.random.randi_range(-10,10), "TargetConsistency": 0, "TargetCountries": [], })
		)
		WorldData.Organizations[-1].IntelIdentified = GameLogic.random.randi_range(1,10)  # officials
		WorldData.Organizations[-1].Technology = GameLogic.random.randi_range(1, WorldData.Countries[places].SoftPower)
		if GameLogic.random.randi_range(1,10) == 5:
			if GameLogic.random.randi_range(1,2) == 1:
				WorldData.Organizations[-1].TechDescription = "possible coronavirus cure"
				WorldData.Organizations[-1].Technology = 100
			else:
				WorldData.Organizations[-1].TechDescription = "new coronavirus treatment"
				WorldData.Organizations[-1].Technology = 60
			WorldData.Organizations[-1].TradecraftTech = false
	# universities
	for i in range(0,8):
		var size = GameLogic.random.randi_range(200,2000)
		var places = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		var name = WorldGenerator.GenerateUniversityName(WorldData.Countries[places].Adjective)
		if name in doNotDuplicate: continue
		doNotDuplicate.append(name)
		WorldData.Organizations.append(
			WorldData.aNewOrganization({ "Type": WorldData.OrgType.UNIVERSITY, "Name": name, "Fixed": false, "Known": true, "Staff": size, "Budget": size*100+GameLogic.random.randi_range(-100,100), "Counterintelligence": GameLogic.random.randi_range(10,50), "Aggression": GameLogic.random.randi_range(0,5), "Countries": [places], "IntelValue": GameLogic.random.randi_range(-10,10), "TargetConsistency": 0, "TargetCountries": [], })
		)
		WorldData.Organizations[-1].IntelIdentified = GameLogic.random.randi_range(1,10)  # officials
		WorldData.Organizations[-1].Technology = GameLogic.random.randi_range(1, WorldData.Countries[places].SoftPower)
		if GameLogic.random.randi_range(1,3) == 2:
			if GameLogic.random.randi_range(1,2) == 1:
				WorldData.Organizations[-1].TechDescription = "possible coronavirus cure"
				WorldData.Organizations[-1].Technology = 100
			else:
				WorldData.Organizations[-1].TechDescription = "new coronavirus treatment"
				WorldData.Organizations[-1].Technology = 60
			WorldData.Organizations[-1].TradecraftTech = false
	# offensive universities (wmd research etc)
	for i in range(0,3):
		var size = GameLogic.random.randi_range(200,2000)
		var places = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		if WorldData.Countries[places].SoftPower < 71: continue
		var name = WorldGenerator.GenerateUniversityName(WorldData.Countries[places].Adjective)
		if name in doNotDuplicate: continue
		doNotDuplicate.append(name)
		WorldData.Organizations.append(
			WorldData.aNewOrganization({ "Type": WorldData.OrgType.UNIVERSITY_OFFENSIVE, "Name": name, "Fixed": false, "Known": true, "Staff": size, "Budget": size*200+GameLogic.random.randi_range(-100,100), "Counterintelligence": GameLogic.random.randi_range(40,85), "Aggression": GameLogic.random.randi_range(15,50), "Countries": [places], "IntelValue": GameLogic.random.randi_range(-10,10), "TargetConsistency": 0, "TargetCountries": [], })
		)
		WorldData.Organizations[-1].IntelIdentified = GameLogic.random.randi_range(1,10)  # officials
		WorldData.Organizations[-1].Technology = GameLogic.random.randi_range(WorldData.Countries[places].SoftPower, WorldData.Countries[places].SoftPower*2)
	############################################################################
	# filling in some organizatiions
	for o in range(0, len(WorldData.Organizations)):
		if WorldData.Organizations[o].Type == WorldData.OrgType.INTEL:
			WorldData.Organizations[o].Technology = WorldData.Organizations[o].Counterintelligence + GameLogic.random.randi_range(-15,15)
			WorldIntel.GatherOnOrg(o, 0, "01/01/2021", false)
			# updating initial country characterization
			WorldData.Countries[WorldData.Organizations[o].Countries[0]].CovertTravel -= WorldData.Organizations[o].Counterintelligence * 0.3
			if WorldData.Countries[WorldData.Organizations[o].Countries[0]].CovertTravel < 0:
				WorldData.Countries[WorldData.Organizations[o].Countries[0]].CovertTravel = 0
	############################################################################
	# pandemic reality
	for c in range(0, len(WorldData.Countries)):
		WorldData.Countries[c].TravelCost = 1 + WorldData.Countries[c].TravelCost*2
		WorldData.Countries[c].LocalCost += 1
		WorldData.Countries[c].IntelFriendliness *= 0.6
		WorldData.Countries[c].CovertTravel *= 0.8
	############################################################################
	# simulating last few years
	var pastDay = 1
	var pastMonth = 1
	var pastYear = 2020
	for i in range(1,55):
		# moving seven days forward
		pastDay += 7
		if pastDay >= 28:
			var maxNumber = 31  # max number of days in a month
			if pastMonth == 2:
				maxNumber = 28
			elif pastMonth == 4 or pastMonth == 6 or pastMonth == 9 or pastMonth == 11:
				maxNumber = 30
			if pastDay > maxNumber:
				pastDay -= maxNumber  # eg 35-31=4th
				pastMonth += 1
				if pastMonth == 13:
					pastMonth = 1
					pastYear += 1
					if pastYear == 2021:
						break  # finish of the simulation
		# formatting date
		var localDate = ""
		if pastDay < 10: localDate += "0"
		localDate += str(int(pastDay)) + "/"
		if pastMonth < 10: localDate += "0"
		localDate += str(int(pastMonth)) + "/" + str(int(pastYear))
		# actual next week
		WorldNextWeek.Execute(localDate)
		# stats
		if i > 20:
			if len(homelandSoftPowerLastMonths) < 26:
				homelandSoftPowerLastMonths.append(WorldData.Countries[0].SoftPower)
			else:
				homelandSoftPowerLastMonths.remove(0)
				homelandSoftPowerLastMonths.append(WorldData.Countries[0].SoftPower)
	############################################################################
	# last government setups
	GameLogic.SetUpNewPriorities(true)
	GameLogic.PriorityTech = 100
	############################################################################
	return homelandSoftPowerLastMonths

func ModifyMethods():
	pass

func StartAll():
	WorldData.Countries[0].Size = 3
	GameLogic.TurnOnTerrorist = true
	GameLogic.TurnOnWars = true
	GameLogic.TurnOnWMD = true
	GameLogic.TurnOnInfiltration = true
	GameLogic.FrequencyAttacks = 0.5
	GameLogic.SoftPowerMonthsAgo = GenerateWorld()
	GameLogic.StartAll()
	CallManager.CallQueue.append(
		{
			"Header": "Important Information",
			"Level": "Unclassified",
			"Operation": "-//-",
			"Content": "Welcome,\n\nHomeland created a new foreign intelligence agency and appointed you as the director.\n\nGather information from around the world, support national efforts, secure our nation from external threats.\n\nActivities of bureau should be guided by and will evaluated according to the list of priorities given by the government:\n- " + GameLogic.ListPriorities("\n- ") + "\n\nGood luck!",
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
