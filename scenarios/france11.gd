extends Node

var Description = "[b]ISIS growth and attacks in 2010s[/b]\n\n- Homeland similar to France\n- ISIS grows to proclaimed caliphate\n- European countries engaged in Syrian civil war are targeted by ISIS cells and lone wolves\n- Europe undergoes migrant crisis"

# one year simulation from 2010 and then starts in 2011
var PossibleCountries = [
	WorldData.aNewCountry({ "Name": "Belgium", "Adjective": "Belgian", "TravelCost": 2, "LocalCost": 2, "IntelFriendliness": 80, "Size": 11, "ElectionPeriod": 52*4, "ElectionProgress": 7*4*6.5, "SoftPower": 60, }),
	WorldData.aNewCountry({ "Name": "Italy", "Adjective": "Italian", "TravelCost": 3, "LocalCost": 2, "IntelFriendliness": 50, "Size": 59, "ElectionPeriod": 52*5, "ElectionProgress": 52*3.1, "SoftPower": 70, }),
	WorldData.aNewCountry({ "Name": "United Kingdom", "Adjective": "British", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 40, "Size": 67, "ElectionPeriod": 52*5, "ElectionProgress": 52+52*3.4, "SoftPower": 90, }),
	WorldData.aNewCountry({ "Name": "Yemen", "Adjective": "Yemeni", "TravelCost": 5, "LocalCost": 1, "IntelFriendliness": 30, "Size": 29, "ElectionPeriod": 52*20, "ElectionProgress": 52*19, "SoftPower": 10, }),
	WorldData.aNewCountry({ "Name": "Syria", "Adjective": "Syrian", "TravelCost": 2, "LocalCost": 1, "IntelFriendliness": 10, "Size": 17, "ElectionPeriod": 52*20, "ElectionProgress": 52*10, "SoftPower": 5, }),
	WorldData.aNewCountry({ "Name": "Iraq", "Adjective": "Iraqi", "TravelCost": 2, "LocalCost": 1, "IntelFriendliness": 20, "Size": 39, "ElectionPeriod": 52*3, "ElectionProgress": 7*4*10.6, "SoftPower": 15, }),
]

func GenerateWorld():
	# - Homeland similar to Israel\n- On the brink of conflict with Iran\n- Iran returns to WMD program\n- Unstable neighbouring countries with terrorist organizations
	WorldData.Countries[0].Size = 65
	WorldData.Countries[0].SoftPower = 80
	WorldData.Countries[0].ElectionPeriod = 52*5
	WorldData.Countries[0].ElectionProgress = 52*2.3
	GameLogic.WhenAllowAttacks = 52
	GameLogic.BudgetFull = 500
	GameLogic.ActiveOfficers = 10
	GameLogic.OfficersInHQ = 10
	GameLogic.StaffSkill = 20
	GameLogic.StaffExperience = 20
	GameLogic.Technology = 10
	GameLogic.TurnOnWMD = false
	GameLogic.random.randomize()
	randomize()
	var homelandSoftPowerLastMonths = []  # will be returned
	############################################################################
	# get countries
	for c in range(0, len(PossibleCountries)):
		WorldData.Countries.append(PossibleCountries[c])
	############################################################################
	# relationships
	#    HO BE IT UK YE SY IR
	WorldData.DiplomaticRelations = [
		[0, 10, 10, 20, -10, -50, -10],  # HO
		[10, 0, 0, 0, -10, -20, -10],  # BE
		[10, 0, 0, 5, 0, 0, 0],  # IT
		[20, 0, 0, 0, -20, -30, -40],  # UK
		[-10, -10, 0, -20, 0, 30, 10],  # YE
		[-50, -20, 0, -20, 20, 0, 10],  # SY
		[-10, -10, 0, 0, 10, 20, 0],  # IR
	]
	############################################################################
	# other properties
	WorldData.Countries[1].PoliticsAggression = 20  # BE
	WorldData.Countries[1].PoliticsIntel = 40
	WorldData.Countries[1].PoliticsStability = 40
	WorldData.Countries[2].PoliticsAggression = 20  # IT
	WorldData.Countries[2].PoliticsIntel = 50
	WorldData.Countries[2].PoliticsStability = 30
	WorldData.Countries[3].PoliticsAggression = 80  # UK
	WorldData.Countries[3].PoliticsIntel = 80
	WorldData.Countries[3].PoliticsStability = 60
	WorldData.Countries[4].PoliticsAggression = 50  # YE
	WorldData.Countries[4].PoliticsIntel = 30
	WorldData.Countries[4].PoliticsStability = 90
	WorldData.Countries[5].PoliticsAggression = 60  # SY
	WorldData.Countries[5].PoliticsIntel = 50
	WorldData.Countries[5].PoliticsStability = 70
	WorldData.Countries[5].DiplomaticTravel = false
	WorldData.Countries[6].PoliticsAggression = 20  # IR
	WorldData.Countries[6].PoliticsIntel = 50
	WorldData.Countries[6].PoliticsStability = 20
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
	var BE = 1
	var IT = 2
	var UK = 3
	var YE = 4
	var SY = 5
	var IR = 6
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": "Islamic Extremists", "Fixed": false, "Known": true, "Staff": 1000000, "Budget": 0, "Counterintelligence": 0, "Aggression": 70, "Countries": [YE,SY,IR], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	var extremists = len(WorldData.Organizations)-1
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": "Moroccan Diaspora", "Fixed": false, "Known": true, "Staff": 429500, "Budget": 0, "Counterintelligence": 0, "Aggression": 60, "Countries": [BE], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	var moroccan = len(WorldData.Organizations)-1
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": "Salafists", "Fixed": false, "Known": true, "Staff": 700000, "Budget": 0, "Counterintelligence": 0, "Aggression": 60, "Countries": [BE,UK,SY], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	var salafists = len(WorldData.Organizations)-1
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": "Middle Eastern Migrants", "Fixed": false, "Known": true, "Staff": 1000000, "Budget": 0, "Counterintelligence": 0, "Aggression": 10, "Countries": [IT,BE,UK], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	var migrants = len(WorldData.Organizations)-1
	# terror
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "ISIS", "Fixed": false, "Known": true, "Staff": 45000, "Budget": 1000000, "Counterintelligence": 50, "Aggression": 95, "Countries": [YE,SY,IR], "IntelValue": 0, "TargetConsistency": 80, "TargetCountries": [0,BE,UK], })
	)
	WorldData.Organizations[-1].ConnectedTo.append(extremists)
	WorldData.Organizations[extremists].ConnectedTo.append(len(WorldData.Organizations)-1)
	var isis = len(WorldData.Organizations)-1
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "ISIS Sympathizers", "Fixed": false, "Known": true, "Staff": 5000, "Budget": 500, "Counterintelligence": 50, "Aggression": 80, "Countries": [BE,UK,IT], "IntelValue": 0, "TargetConsistency": 50, "TargetCountries": [0,BE,UK,IT], })
	)
	var isisSymp = len(WorldData.Organizations)-1
	WorldData.Organizations[-1].ConnectedTo.append(migrants)
	WorldData.Organizations[migrants].ConnectedTo.append(len(WorldData.Organizations)-1)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "Brussels Cell", "Fixed": false, "Known": true, "Staff": 20, "Budget": 500, "Counterintelligence": 65, "Aggression": 90, "Countries": [BE], "IntelValue": 0, "TargetConsistency": 90, "TargetCountries": [0,BE], })
	)
	WorldData.Organizations[-1].ConnectedTo.append(moroccan)
	WorldData.Organizations[moroccan].ConnectedTo.append(len(WorldData.Organizations)-1)
	WorldData.Organizations[-1].ConnectedTo.append(salafists)
	WorldData.Organizations[salafists].ConnectedTo.append(len(WorldData.Organizations)-1)
	var brusselsCell = len(WorldData.Organizations)-1
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.ARMTRADER, "Name": "Brussels Underworld", "Fixed": false, "Known": true, "Staff": 50, "Budget": 1000, "Counterintelligence": 85, "Aggression": 90, "Countries": [BE], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].ConnectedTo.append(brusselsCell)
	WorldData.Organizations[brusselsCell].ConnectedTo.append(len(WorldData.Organizations)-1)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.ARMTRADER, "Name": "Syrian Black Market", "Fixed": false, "Known": true, "Staff": 300, "Budget": 10000, "Counterintelligence": 75, "Aggression": 90, "Countries": [SY], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].ConnectedTo.append(isis)
	WorldData.Organizations[isis].ConnectedTo.append(len(WorldData.Organizations)-1)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.ARMTRADER, "Name": "Yemeni Rebels", "Fixed": false, "Known": true, "Staff": 5000, "Budget": 5000, "Counterintelligence": 55, "Aggression": 90, "Countries": [YE], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].ConnectedTo.append(isisSymp)
	WorldData.Organizations[isisSymp].ConnectedTo.append(len(WorldData.Organizations)-1)
	# the pandemic
	############################################################################
	# generators
	# many lone wolves
	for i in range(1,6):
		var size = 1
		var places = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		var name = "Lone Wolf " + str(i)
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
		WorldData.Organizations[-1].UndercoverCounter = GameLogic.random.randi_range(120,360)
		# tying some terror orgs to movements
		for j in range(0,len(WorldData.Organizations)):
			if WorldData.Organizations[j].Type != WorldData.OrgType.MOVEMENT: continue
			if WorldData.Organizations[j].Countries[0] != places: continue
			if GameLogic.random.randi_range(1,2) == 1:
				WorldData.Organizations[j].ConnectedTo.append(len(WorldData.Organizations)-1)
				WorldData.Organizations[-1].ConnectedTo.append(j)
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
	for i in range(0,6):
		var size = GameLogic.random.randi_range(10,5000)
		var places = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		var name = WorldGenerator.GenerateCompanyName()
		if name in doNotDuplicate: continue
		if WorldData.Countries[places].SoftPower < 50: continue
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
		if WorldData.Countries[places].SoftPower < 50: continue
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
			WorldIntel.GatherOnOrg(o, 0, "01/01/2011", false)
			# updating initial country characterization
			WorldData.Countries[WorldData.Organizations[o].Countries[0]].CovertTravel -= WorldData.Organizations[o].Counterintelligence * 0.3
			if WorldData.Countries[WorldData.Organizations[o].Countries[0]].CovertTravel < 0:
				WorldData.Countries[WorldData.Organizations[o].Countries[0]].CovertTravel = 0
	############################################################################
	# simulating last few years
	var pastDay = 1
	var pastMonth = 1
	var pastYear = 2010
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
					if pastYear == 2011:
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
	GameLogic.PriorityTerrorism = 100
	############################################################################
	return homelandSoftPowerLastMonths

func ModifyMethods():
	pass

func StartAll():
	GameLogic.TurnOnTerrorist = true
	GameLogic.TurnOnWars = true
	GameLogic.TurnOnWMD = false
	GameLogic.TurnOnInfiltration = false
	GameLogic.FrequencyAttacks = 1.0
	GameLogic.SoftPowerMonthsAgo = GenerateWorld()
	GameLogic.DateYear = 2011
	GameLogic.StartAll()
	CallManager.CallQueue.append(
		{
			"Header": "Important Information",
			"Level": "Unclassified",
			"Operation": "-//-",
			"Content": "Welcome,\n\nHomeland created a new branch in foreign intelligence agency and appointed you as the director.\n\nSyrian civil war, growth of Islamic State of Iraq and Syria creates, and european migrant crisis creates potentially dangerous situation. Bureau is tasked with tackling the upcoming wave of terrorist activity. Infiltrate criminal organizations, gather details on planned attacks, delay or eliminate their operations.\n\nGood luck!",
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
