extends Node

var Description = "[b]Al-Qaeda preparing WTC attacks in 2001[/b]\n\n- Homeland similar to United States\n- Bureau similar to CIA's Alec Station\n- Al-Qaeda already designed a huge attack\n- Race with time to delay or eliminate the danger\n- Missile strikes available, given enough intel and well-nurtured government trust"

# one year simulation from 1998.9 to 1999.9
var PossibleCountries = [
	WorldData.aNewCountry({ "Name": "Afghanistan", "Adjective": "Afghan", "TravelCost": 5, "LocalCost": 2, "IntelFriendliness": 30, "Size": 20, "ElectionPeriod": 52*10, "ElectionProgress": 52*9, "SoftPower": 20, }),
	WorldData.aNewCountry({ "Name": "Yemen", "Adjective": "Yemeni", "TravelCost": 5, "LocalCost": 1, "IntelFriendliness": 30, "Size": 29, "ElectionPeriod": 52*20, "ElectionProgress": 52*19, "SoftPower": 10, }),
	WorldData.aNewCountry({ "Name": "Iraq", "Adjective": "Iraqi", "TravelCost": 4, "LocalCost": 1, "IntelFriendliness": 10, "Size": 37, "ElectionPeriod": 52*20, "ElectionProgress": 52*19, "SoftPower": 30, }),
	WorldData.aNewCountry({ "Name": "Pakistan", "Adjective": "Pakistani", "TravelCost": 6, "LocalCost": 2, "IntelFriendliness": 20, "Size": 139, "ElectionPeriod": 52*20, "ElectionProgress": 52*19, "SoftPower": 50, }),
	WorldData.aNewCountry({ "Name": "United Kingdom", "Adjective": "English", "TravelCost": 3, "LocalCost": 5, "IntelFriendliness": 70, "Size": 59, "ElectionPeriod": 52*4, "ElectionProgress": 52*2.5, "SoftPower": 90, }),
	WorldData.aNewCountry({ "Name": "Malaysia", "Adjective": "Malaysian", "TravelCost": 3, "LocalCost": 5, "IntelFriendliness": 50, "Size": 23, "ElectionPeriod": 52*5, "ElectionProgress": 57, "SoftPower": 50, }),
]

func GenerateWorld():
	WorldData.Countries[0].Size = 282
	WorldData.Countries[0].SoftPower = 95
	WorldData.Countries[0].ElectionPeriod = 52*5
	WorldData.Countries[0].ElectionProgress = 52*2.5
	GameLogic.BudgetFull = 500
	GameLogic.ActiveOfficers = 12
	GameLogic.OfficersInHQ = 12
	GameLogic.StaffSkill = 40
	GameLogic.StaffExperience = 40
	GameLogic.Technology = 50
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
	#    HO AF YE IR PA UK MA
	WorldData.DiplomaticRelations = [
		[0, -40, -10, -30, 0, 40, 0],  # HO
		[-40, 0, 0, 0, 0, 0, 0],  # AF
		[-10, 0, 0, 0, 0, 0, 0],  # YE
		[-40, 0, 0, 0, 0, 0, 0],  # IR
		[-30, 0, 0, 0, 0, 0, 0],  # PA
		[40, 0, 0, 0, 0, 0, 0],  # UK
		[0, 0, 0, 0, 0, 0, 0],  # MA
	]
	############################################################################
	# other properties
	WorldData.Countries[1].PoliticsAggression = 60  # AF
	WorldData.Countries[1].PoliticsIntel = 50
	WorldData.Countries[1].PoliticsStability = 70
	WorldData.Countries[1].DiplomaticTravel = false
	WorldData.Countries[2].PoliticsAggression = 50  # YE
	WorldData.Countries[2].PoliticsIntel = 50
	WorldData.Countries[2].PoliticsStability = 50
	WorldData.Countries[3].PoliticsAggression = 70  # IR
	WorldData.Countries[3].PoliticsIntel = 90
	WorldData.Countries[3].PoliticsStability = 90
	WorldData.Countries[4].PoliticsAggression = 60  # PA
	WorldData.Countries[4].PoliticsIntel = 50
	WorldData.Countries[4].PoliticsStability = 90
	WorldData.Countries[5].PoliticsAggression = 80  # UK
	WorldData.Countries[5].PoliticsIntel = 80
	WorldData.Countries[5].PoliticsStability = 90
	WorldData.Countries[6].PoliticsAggression = 50  # MA
	WorldData.Countries[6].PoliticsIntel = 40
	WorldData.Countries[6].PoliticsStability = 40
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
	var AF = 1
	var YE = 2
	var IR = 3
	var PA = 4
	var UK = 5
	var MA = 6
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": "Taliban", "Fixed": false, "Known": true, "Staff": 45000, "Budget": 0, "Counterintelligence": 0, "Aggression": 70, "Countries": [AF,YE,IR,PA], "IntelValue": -10, "TargetConsistency": 0, "TargetCountries": [], })
	)
	var taliban = len(WorldData.Organizations)-1
	# terror
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "Al-Qaeda", "Fixed": false, "Known": true, "Staff": 2500, "Budget": 10000, "Counterintelligence": 80, "Aggression": 95, "Countries": [AF], "IntelValue": -25, "TargetConsistency": 80, "TargetCountries": [0,AF,YE,IR,PA], })
	)
	var alqaeda = len(WorldData.Organizations)-1
	WorldData.Organizations[-1].ConnectedTo.append(taliban)
	WorldData.Organizations[taliban].ConnectedTo.append(len(WorldData.Organizations)-1)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "Jemaah Islamiyah", "Fixed": false, "Known": false, "Staff": 15, "Budget": 1000, "Counterintelligence": 50, "Aggression": 30, "Countries": [MA], "IntelValue": -10, "TargetConsistency": 0, "TargetCountries": [MA], })
	)
	WorldData.Organizations[-1].UndercoverCounter = 52+4*5
	WorldData.Organizations[-1].ConnectedTo.append(taliban)
	WorldData.Organizations[-1].ConnectedTo.append(alqaeda)
	WorldData.Organizations[taliban].ConnectedTo.append(len(WorldData.Organizations)-1)
	WorldData.Organizations[alqaeda].ConnectedTo.append(len(WorldData.Organizations)-1)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": "Haqqani Network", "Fixed": false, "Known": true, "Staff": 4000, "Budget": 100, "Counterintelligence": 60, "Aggression": 60, "Countries": [AF,PA], "IntelValue": -5, "TargetConsistency": 80, "TargetCountries": [0,AF,YE,IR], })
	)
	var haqqani = len(WorldData.Organizations)-1
	WorldData.Organizations[-1].ConnectedTo.append(taliban)
	WorldData.Organizations[taliban].ConnectedTo.append(len(WorldData.Organizations)-1)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.ARMTRADER, "Name": "Arms Black Market", "Fixed": false, "Known": true, "Staff": 1000, "Budget": 10000, "Counterintelligence": 65, "Aggression": 80, "Countries": [AF,YE,IR], "IntelValue": -5, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].ConnectedTo.append(alqaeda)
	WorldData.Organizations[alqaeda].ConnectedTo.append(len(WorldData.Organizations)-1)
	WorldData.Organizations.append(
		WorldData.aNewOrganization({ "Type": WorldData.OrgType.ARMTRADER, "Name": "Yemeni Rebels", "Fixed": false, "Known": true, "Staff": 5000, "Budget": 5000, "Counterintelligence": 55, "Aggression": 90, "Countries": [YE], "IntelValue": -5, "TargetConsistency": 0, "TargetCountries": [], })
	)
	WorldData.Organizations[-1].ConnectedTo.append(alqaeda)
	WorldData.Organizations[alqaeda].ConnectedTo.append(len(WorldData.Organizations)-1)
	############################################################################
	# generators
	# companies
	for i in range(0,4):
		var size = GameLogic.random.randi_range(10,5000)
		var places = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		var name = WorldGenerator.GenerateCompanyName()
		if name in doNotDuplicate: continue
		if WorldData.Countries[places].SoftPower < 30: continue
		doNotDuplicate.append(name)
		WorldData.Organizations.append(
			WorldData.aNewOrganization({ "Type": WorldData.OrgType.COMPANY, "Name": name, "Fixed": false, "Known": true, "Staff": size, "Budget": size*100+GameLogic.random.randi_range(-100,100), "Counterintelligence": GameLogic.random.randi_range(10,50), "Aggression": GameLogic.random.randi_range(0,10), "Countries": [places], "IntelValue": GameLogic.random.randi_range(-10,10), "TargetConsistency": 0, "TargetCountries": [], })
		)
		WorldData.Organizations[-1].IntelIdentified = GameLogic.random.randi_range(1,10)  # officials
		WorldData.Organizations[-1].Technology = GameLogic.random.randi_range(1, WorldData.Countries[places].SoftPower)
	# universities
	for i in range(0,3):
		var size = GameLogic.random.randi_range(200,2000)
		var places = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		var name = WorldGenerator.GenerateUniversityName(WorldData.Countries[places].Adjective)
		if name in doNotDuplicate: continue
		if WorldData.Countries[places].SoftPower < 30: continue
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
	var pastMonth = 9
	var pastYear = 1998
	for i in range(1,54):
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
	GameLogic.DateDay = pastDay
	GameLogic.DateMonth = pastMonth
	GameLogic.DateYear = pastYear
	############################################################################
	WorldData.Organizations[alqaeda].OpsAgainstHomeland.append(
		WorldData.aNewExtOp(
			{
				"Type": WorldData.ExtOpType.HOME_TERRORIST_ATTACK,
				"Budget": WorldData.Organizations[alqaeda].Budget * 0.5,
				"Persons": 100,
				"Secrecy": 70,
				"Damage": 90,
				"FinishCounter": 52*2+1,
			}
		)
	)
	GameLogic.CurrentOpsAgainstHomeland += 1
	GameLogic.YearlyOpsAgainstHomeland += 1
	WorldData.Organizations[alqaeda].ActiveOpsAgainstHomeland += 1
	GameLogic.AttackTicker = 52*2+1
	GameLogic.AttackTickerOp.Org = alqaeda
	GameLogic.AttackTickerOp.Op = len(WorldData.Organizations[alqaeda].OpsAgainstHomeland)-1
	GameLogic.AttackTickerText = " weeks to possible attack"
	############################################################################
	# last government setups
	GameLogic.SetUpNewPriorities(true)
	GameLogic.PriorityTerrorism = 100
	############################################################################
	return homelandSoftPowerLastMonths

func ModifyMethods():
	WorldData.Methods[0].remove(16)
	WorldData.Methods[0].remove(12)
	WorldData.Methods[0][10].Name = "intercept phone communication"
	WorldData.Methods[0].remove(9)
	WorldData.Methods[0].remove(8)
	WorldData.Methods[0].remove(5)
	WorldData.Methods[0].remove(0)
	WorldData.Methods[2].remove(15)
	WorldData.Methods[2].remove(12)
	WorldData.Methods[2].remove(9)
	WorldData.Methods[2].remove(6)
	WorldData.Methods[2].remove(4)
	WorldData.Methods[2].append(
		WorldData.aNewOffensiveMethod({ "Name": "missile strike", "Cost": 50, "Quality": 85, "Risk": 0, "OfficersRequired": 5, "MinimalSkill": 30, "Available": true, "MinimalIntel": 20, "MinimalTrust": 50, "MinLength": 1, "MaxLength": 2, "PossibleCasualties": 1000, "PossibleLosses": 0, "BudgetChange": 50, "DamageToOps": 50, "Attribution": 60, "MinimalTech": 20, "MinimalLocal": 0, "Remote": true, "StartYear": 1990, "EndYear": 3000, })
	)

func StartAll():
	GameLogic.TurnOnTerrorist = true
	GameLogic.TurnOnWars = false
	GameLogic.TurnOnWMD = false
	GameLogic.TurnOnInfiltration = false
	GameLogic.FrequencyAttacks = 0.2
	GameLogic.SoftPowerMonthsAgo = GenerateWorld()
	GameLogic.StartAll()
	ModifyMethods()
	CallManager.CallQueue.append(
		{
			"Header": "Important Information",
			"Level": "Unclassified",
			"Operation": "-//-",
			"Content": "Welcome,\n\nHomeland created a new branch in foreign intelligence agency and appointed you as the director.\n\nPreviously gathered intel suggests, that the attack will happen in two years from now. Bureau is tasked with delaying or eliminating threat of terrorist attack.\n\nGood luck!",
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
