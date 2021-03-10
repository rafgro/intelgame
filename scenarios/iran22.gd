extends Node

var Description = "[b]Iran developing WMD in 2020s[/b]\n\n- Homeland similar to Israel\n- On the brink of conflict with Iran\n- Iran returns to WMD program\n- Unstable neighbouring countries with terrorist organizations"

# one year simulation from 2021 and then starts in 2022
var PossibleCountries = [
	WorldData.aNewCountry({ "Name": "Iran", "Adjective": "Iranian", "TravelCost": 3, "LocalCost": 2, "IntelFriendliness": 10, "Size": 83, "ElectionPeriod": 52*4, "ElectionProgress": 7*4*6.5, "SoftPower": 80, }),
	WorldData.aNewCountry({ "Name": "Gaza Strip", "Adjective": "Palestinian", "TravelCost": 2, "LocalCost": 1, "IntelFriendliness": 5, "Size": 2, "ElectionPeriod": 52*15, "ElectionProgress": 7*4*5, "SoftPower": 5, }),
	WorldData.aNewCountry({ "Name": "Syria", "Adjective": "Syrian", "TravelCost": 2, "LocalCost": 1, "IntelFriendliness": 10, "Size": 17, "ElectionPeriod": 52*20, "ElectionProgress": 52*10, "SoftPower": 5, }),
	WorldData.aNewCountry({ "Name": "Iraq", "Adjective": "Iraqi", "TravelCost": 2, "LocalCost": 1, "IntelFriendliness": 20, "Size": 39, "ElectionPeriod": 52*3, "ElectionProgress": 7*4*10.6, "SoftPower": 15, }),
	WorldData.aNewCountry({ "Name": "Lebanon", "Adjective": "Lebanese", "TravelCost": 2, "LocalCost": 1, "IntelFriendliness": 15, "Size": 7, "ElectionPeriod": 52*4, "ElectionProgress": 52*1.5, "SoftPower": 25, }),
	WorldData.aNewCountry({ "Name": "Saudi Arabia", "Adjective": "Saudi", "TravelCost": 3, "LocalCost": 3, "IntelFriendliness": 10, "Size": 34, "ElectionPeriod": 52*20, "ElectionProgress": 52*15, "SoftPower": 70, }),
]

func GenerateWorld():
	# - Homeland similar to Israel\n- On the brink of conflict with Iran\n- Iran returns to WMD program\n- Unstable neighbouring countries with terrorist organizations
	WorldData.Countries[0].Size = 9
	WorldData.Countries[0].SoftPower = 90
	WorldData.Countries[0].ElectionPeriod = 52*4
	WorldData.Countries[0].ElectionProgress = 7*4*3
	GameLogic.BudgetFull = 800
	GameLogic.FrequencyGovOps = 0.8
	GameLogic.ActiveOfficers = 15
	GameLogic.OfficersInHQ = 15
	GameLogic.StaffSkill = 30
	GameLogic.StaffExperience = 40
	GameLogic.Technology = 50
	GameLogic.TurnOnWMD = true
	GameLogic.random.randomize()
	randomize()
	var homelandSoftPowerLastMonths = []  # will be returned
	############################################################################
	# get countries
	for c in range(0, len(PossibleCountries)):
		WorldData.Countries.append(PossibleCountries[c])
	############################################################################
	# 2021 countries features
	WorldData.Countries[1].WMDProgress = 15
	WorldData.Countries[1].WMDProgressFactor = 0.08
	WorldData.Countries[1].WMDIntel = 5
	############################################################################
	# relationships
	#    HO IR GA SY IQ LE SA
	WorldData.DiplomaticRelations = [
		[0, -55, -60, -20, 0, -20, -10],  # HO
		[-55, 0, 20, 30, -20, 30, -20],  # IR
		[-60, 20, 0, 10, 10, 10, 0],  # GA
		[-20, 10, 10, 0, 10, 10, -10],  # SY
		[0, 10, 10, 10, 0, 10, 0],  # IQ
		[-20, 10, 20, 10, 10, 0, -20],  # LE
		[-10, -20, 0, -10, 0, -20, 0],  # SA
	]
	############################################################################
	# other properties
	WorldData.Countries[1].PoliticsAggression = 60  # IR
	WorldData.Countries[1].PoliticsIntel = 80
	WorldData.Countries[1].PoliticsStability = 90
	WorldData.Countries[1].DiplomaticTravel = false
	WorldData.Countries[2].PoliticsAggression = 80  # GA
	WorldData.Countries[2].PoliticsIntel = 50
	WorldData.Countries[2].PoliticsStability = 50
	WorldData.Countries[2].DiplomaticTravel = false
	WorldData.Countries[3].PoliticsAggression = 20  # SY
	WorldData.Countries[3].PoliticsIntel = 20
	WorldData.Countries[3].PoliticsStability = 80
	WorldData.Countries[3].DiplomaticTravel = false
	WorldData.Countries[4].PoliticsAggression = 30  # IQ
	WorldData.Countries[4].PoliticsIntel = 30
	WorldData.Countries[4].PoliticsStability = 40
	WorldData.Countries[4].DiplomaticTravel = false
	WorldData.Countries[5].PoliticsAggression = 30  # LE
	WorldData.Countries[5].PoliticsIntel = 60
	WorldData.Countries[5].PoliticsStability = 90
	WorldData.Countries[5].DiplomaticTravel = false
	WorldData.Countries[6].PoliticsAggression = 50  # SA
	WorldData.Countries[6].PoliticsIntel = 90
	WorldData.Countries[6].PoliticsStability = 90
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
		WorldData.Countries[e].KnowhowCustoms = GameLogic.random.randi_range(0,15)
	# three directions provided by officers knowing their language and some customs
	for z in range(0,2):
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
	# movements
	var IR = 1
	var GA = 2
	var SY = 3
	var IQ = 4
	var LE = 5
	var SA = 6
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": "Salafists", "Fixed": false, "Known": true, "Staff": 100000, "Budget": 0, "Counterintelligence": 0, "Aggression": 55, "Countries": [SA], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].OffensiveClearance = true
	var salafists = len(WorldData.Organizations)-1
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": "Islamic Extremists", "Fixed": false, "Known": true, "Staff": 1000000, "Budget": 0, "Counterintelligence": 0, "Aggression": 70, "Countries": [IR,GA,SY,IQ,LE,SA], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].OffensiveClearance = true
	var extremists = len(WorldData.Organizations)-1
	# terror
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "Hamas", "Fixed": false, "Known": true, "Staff": 16000, "Budget": 1000, "Counterintelligence": 60, "Aggression": 80, "Countries": [GA], "IntelValue": 5, "TargetConsistency": 80, "TargetCountries": [0], })
	)
	WorldData.Organizations[-1].ConnectedTo.append(extremists)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "Islamic State", "Fixed": false, "Known": true, "Staff": 15000, "Budget": 5000, "Counterintelligence": 40, "Aggression": 70, "Countries": [SY,IQ], "IntelValue": 5, "TargetConsistency": 50, "TargetCountries": [0,SY,IQ,LE,SA], })
	)
	WorldData.Organizations[-1].ConnectedTo.append(extremists)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "Mojahedin-e-Khalq", "Fixed": false, "Known": true, "Staff": 10000, "Budget": 500, "Counterintelligence": 50, "Aggression": 40, "Countries": [IR], "IntelValue": 5, "TargetConsistency": 90, "TargetCountries": [IR], })
	)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "Hezbollah", "Fixed": false, "Known": true, "Staff": 1000, "Budget": 1000, "Counterintelligence": 80, "Aggression": 30, "Countries": [LE], "IntelValue": 5, "TargetConsistency": 70, "TargetCountries": [0], })
	)
	WorldData.Organizations[-1].ConnectedTo.append(extremists)
	# wmd
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.UNIVERSITY_OFFENSIVE, "Name": "Bushehr Plant", "Fixed": false, "Known": true, "Staff": 1000, "Budget": 100000, "Counterintelligence": 90, "Aggression": 0, "Countries": [IR], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].OffensiveClearance = true
	WorldData.Organizations[-1].Technology = 75
	WorldData.Organizations[-1].TradecraftTech = false
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.UNIVERSITY_OFFENSIVE, "Name": "Arak Plant", "Fixed": false, "Known": true, "Staff": 100, "Budget": 1000, "Counterintelligence": 90, "Aggression": 0, "Countries": [IR], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].OffensiveClearance = true
	WorldData.Organizations[-1].Technology = 45
	WorldData.Organizations[-1].TradecraftTech = false
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.UNIVERSITY_OFFENSIVE, "Name": "Darkhovin Plant", "Fixed": false, "Known": true, "Staff": 100, "Budget": 1000, "Counterintelligence": 90, "Aggression": 0, "Countries": [IR], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].OffensiveClearance = true
	WorldData.Organizations[-1].Technology = 15
	WorldData.Organizations[-1].TradecraftTech = false
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.UNIVERSITY_OFFENSIVE, "Name": "Fordow Plant", "Fixed": false, "Known": true, "Staff": 500, "Budget": 5000, "Counterintelligence": 95, "Aggression": 0, "Countries": [IR], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].OffensiveClearance = true
	WorldData.Organizations[-1].Technology = 90
	WorldData.Organizations[-1].TradecraftTech = false
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTEL, "Name": "Oghab 2", "Fixed": true, "Known": true, "Staff": 500, "Budget": 5000, "Counterintelligence": 95, "Aggression": 80, "Countries": [IR], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].OffensiveClearance = true
	WorldData.Organizations[-1].Technology = 80
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTEL, "Name": "Intel IRGC", "Fixed": true, "Known": true, "Staff": 1500, "Budget": 10000, "Counterintelligence": 85, "Aggression": 60, "Countries": [IR], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].OffensiveClearance = true
	WorldData.Organizations[-1].Technology = 50
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTEL, "Name": "Ministry of Intelligence", "Fixed": true, "Known": true, "Staff": 1500, "Budget": 10000, "Counterintelligence": 80, "Aggression": 50, "Countries": [IR], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].OffensiveClearance = true
	WorldData.Organizations[-1].Technology = 50
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.UNIVERSITY_OFFENSIVE, "Name": "University of Tehran", "Fixed": false, "Known": true, "Staff": 1000, "Budget": 1000, "Counterintelligence": 75, "Aggression": 0, "Countries": [IR], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].OffensiveClearance = true
	WorldData.Organizations[-1].Technology = 70
	WorldData.Organizations[-1].TradecraftTech = false
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.UNIVERSITY_OFFENSIVE, "Name": "Atomic Energy Org", "Fixed": false, "Known": true, "Staff": 1500, "Budget": 10000, "Counterintelligence": 80, "Aggression": 0, "Countries": [IR], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].OffensiveClearance = true
	WorldData.Organizations[-1].Technology = 75
	WorldData.Organizations[-1].TradecraftTech = false
	# the pandemic
	############################################################################
	# generators
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
	for i in range(0,1):
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
	for i in range(0,4):
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
	for i in range(0,4):
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
	# universities
	for i in range(0,4):
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
	############################################################################
	# filling in some organizatiions
	for o in range(0, len(WorldData.Organizations)):
		if WorldData.Organizations[o].Type == WorldData.OrgType.INTEL:
			WorldData.Organizations[o].Technology = WorldData.Organizations[o].Counterintelligence + GameLogic.random.randi_range(-15,15)
			WorldIntel.GatherOnOrg(o, 0, "01/01/2022", false)
			# updating initial country characterization
			WorldData.Countries[WorldData.Organizations[o].Countries[0]].CovertTravel -= WorldData.Organizations[o].Counterintelligence * 0.3
			if WorldData.Countries[WorldData.Organizations[o].Countries[0]].CovertTravel < 0:
				WorldData.Countries[WorldData.Organizations[o].Countries[0]].CovertTravel = 0
	############################################################################
	# simulating last few years
	var pastDay = 1
	var pastMonth = 1
	var pastYear = 2021
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
					if pastYear == 2022:
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
	GameLogic.PriorityWMD = 100
	GameLogic.PriorityTerrorism = GameLogic.random.randi_range(1,25)
	GameLogic.PriorityPublic = GameLogic.random.randi_range(1,25)
	############################################################################
	return homelandSoftPowerLastMonths

func ModifyMethods():
	pass

func StartAll():
	GameLogic.TurnOnTerrorist = true
	GameLogic.TurnOnWars = true
	GameLogic.TurnOnWMD = true
	GameLogic.TurnOnInfiltration = true
	GameLogic.FrequencyAttacks = 0.2
	GameLogic.SoftPowerMonthsAgo = GenerateWorld()
	GameLogic.DateYear = 2022
	GameLogic.StartAll()
	CallManager.CallQueue.append(
		{
			"Header": "Important Information",
			"Level": "Unclassified",
			"Operation": "-//-",
			"Content": "Welcome,\n\nHomeland created a new branch in foreign intelligence agency and appointed you as the director.\n\nGather information from around the world, support national efforts, secure our nation from external threats. Do not forget about terrorist threat, but place special focus on the development of weapons of mass destruction by Iran - from the beginning, you are cleared to aggresively target all organizations in this country. Delay or destroy their program.\n\nGood luck!",
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
			"EventualReturn": null,
		}
	)
