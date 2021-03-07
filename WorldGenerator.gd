extends Node

func GenerateIntelOrgs(countryName, countryId):
	if countryName == "United Kingdom":
		WorldData.Organizations.append(WorldData.aNewOrganization({"Type": WorldData.OrgType.INTEL, "Name": "MI6", "Fixed": true, "Known": true, "Staff": 2600, "Budget": 260000, "Counterintelligence": 95, "Aggression": 65, "Countries": [countryId], "IntelValue": 5, "TargetConsistency": 0, "TargetCountries": [1], }))
	elif countryName == "Germany":
		WorldData.Organizations.append(WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTEL, "Name": "BND", "Fixed": true, "Known": true, "Staff": 6500, "Budget": 85000, "Counterintelligence": 90, "Aggression": 70, "Countries": [countryId], "IntelValue": 5, "TargetConsistency": 0, "TargetCountries": [1], }))
	elif countryName == "United States":
		WorldData.Organizations.append(WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTEL, "Name": "CIA", "Fixed": true, "Known": true, "Staff": 22000, "Budget": 1250000, "Counterintelligence": 95, "Aggression": 75, "Countries": [countryId], "IntelValue": 5, "TargetConsistency": 0, "TargetCountries": [1], }))
	elif countryName == "Poland":
		WorldData.Organizations.append(WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTEL, "Name": "Agencja Wywiadu", "Fixed": true, "Known": true, "Staff": 1000, "Budget": 20800, "Counterintelligence": 80, "Aggression": 70, "Countries": [countryId], "IntelValue": 5, "TargetConsistency": 0, "TargetCountries": [1], }))
	elif countryName == "France":
		WorldData.Organizations.append(WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTEL, "Name": "DGSE", "Fixed": true, "Known": true, "Staff": 6100, "Budget": 42000, "Counterintelligence": 95, "Aggression": 75, "Countries": [countryId], "IntelValue": 5, "TargetConsistency": 0, "TargetCountries": [1], }))
	elif countryName == "Russia":
		WorldData.Organizations.append(WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTEL, "Name": "FSB", "Fixed": true, "Known": true, "Staff": 66200, "Budget": 1000000, "Counterintelligence": 95, "Aggression": 80, "Countries": [countryId], "IntelValue": 5, "TargetConsistency": 0, "TargetCountries": [1], }))
	elif countryName == "China":
		WorldData.Organizations.append(WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTEL, "Name": "Guoanbu", "Fixed": true, "Known": true, "Staff": 100000, "Budget": 2000000, "Counterintelligence": 98, "Aggression": 80, "Countries": [countryId],  "IntelValue": 5, "TargetConsistency": 0, "TargetCountries": [1], }))
	elif countryName == "Israel":
		WorldData.Organizations.append(WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTEL, "Name": "Mossad", "Fixed": true, "Known": true, "Staff": 7000, "Budget": 228000, "Counterintelligence": 98, "Aggression": 85, "Countries": [countryId], "IntelValue": 5, "TargetConsistency": 0, "TargetCountries": [1], }))
	elif countryName == "Turkey":
		WorldData.Organizations.append(WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTEL, "Name": "MIT", "Fixed": true, "Known": true, "Staff": 8000, "Budget": 180000, "Counterintelligence": 90, "Aggression": 80, "Countries": [countryId], "IntelValue": 5, "TargetConsistency": 0, "TargetCountries": [1], }))
	elif countryName == "Iraq":
		WorldData.Organizations.append(WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTEL, "Name": "Mukhabarat", "Fixed": true, "Known": true, "Staff": 4000, "Budget": 20000, "Counterintelligence": 85, "Aggression": 80, "Countries": [countryId], "IntelValue": 5, "TargetConsistency": 0, "TargetCountries": [1], }))
	elif countryName == "Afghanistan":
		WorldData.Organizations.append(WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTEL, "Name": "NDS", "Fixed": true, "Known": true, "Staff": 3000, "Budget": 10000, "Counterintelligence": 80, "Aggression": 70, "Countries": [countryId], "IntelValue": 5, "TargetConsistency": 0, "TargetCountries": [1], }))

func GenerateHostileName():
	var wordsA = ["Leftist", "Right", "Proud", "Revolutionary", "Republican", "Combat", "Black", "Democratic", "Real"]
	var wordsB = ["Tobiah","Yseut","Esther","Iphigenia","Yemima","Rexana","Amaterasu","Joslyn","Mattityahu","Karl","Izanami","Jemma","Lorinda","Avram","Ned","Trophimus","Isolde","Harvey","Marsha","Lyn","Shani","Anu","Marilyn","Montgomery","Davey","Leland","Crescens","Jordana","Vern","Bradford","Marianne","Adamu","Manahem","Earleen","Peronel","Enosh","Ryker","Adelle","Myrddin","Carver","Jody","Anat","Atarah","Capricia","Sidney","Cindra","Nik","Jehoash","Atarah","Iahel"]
	var wordsC = ["Group", "Brotherhood", "Force", "Action", "Militants", "Extremists", "Gang", "Separatists"]
	var content = ""
	var length = GameLogic.random.randi_range(1,3)
	if length == 1:
		return wordsB[randi() % wordsB.size()]
	elif length == 2:
		if GameLogic.random.randi_range(1,2) == 1:
			content += wordsA[randi() % wordsA.size()] + " " + wordsB[randi() % wordsB.size()]
		else:
			content += wordsB[randi() % wordsB.size()] + " " + wordsC[randi() % wordsC.size()]
		return content
	else:
		content += wordsA[randi() % wordsA.size()]
		content += " "
		content += wordsB[randi() % wordsB.size()]
		content += " "
		content += wordsC[randi() % wordsC.size()]
		return content

func GenerateCompanyName():
	var wordsA = ["Seed", "Pink Productions", "Lagoon Entertainment", "Surgesystems", "Golbrews", "Lucentertainment", "Ogreprises", "Quadtronics", "Gorillapoly", "Shadeshine", "Accent Intelligence", "Iceberg Corp", "Prophecy Intelligence", "Thorecords", "Nemotors", "Cliffoods", "Lagoonavigations", "Granitebeat", "Riddleman", "Woodshine", "Freak Solutions", "Brisk Coms", "Titanium Navigations", "Oceanavigations", "Cloverprises", "Shadoworks", "Icecaproductions", "Saildew", "Typhoonbank", "Ravenbite", "Cruise Enterprises", "Pyramid Security", "Phantasm Intelligence", "Bridgelectrics", "Ecstaticorps", "Soulightning", "Owlimited", "Globebooks", "Peachways", "Primepoint", "Red Technologies", "Glacier Acoustics", "Odinetworks", "Hatchworks", "Energence", "Spectertainment", "Dreamdew", "Shadowshack", "Freakshade", "Sapling Networks", "Dinosaur Intelligence", "Cruise Solutions", "Smilectronics", "Voyagetronics", "Ansoft", "Amazystems", "Zeuspoly", "Vortexwares", "Arcaneworks", "Apricot Acoustics", "Turtle Microsystems", "Smart Microsystems", "Mothechnologies", "Flukords", "Griffindustries", "Jewelectrics", "Motionhead", "Berrytales", "Wonderhouse", "Apple Solutions", "Joy Acoustics", "Ecstatic Industries", "Aces", "Starecords", "Elecoms", "Tucanterprises", "Bluebank", "Microtime", "Herbtales"]
	return wordsA[randi() % wordsA.size()]

func GenerateUniversityName(adjective):
	var wordsA = ["University", "Institute", "College", "Tech Uni", "Institute of Tech", "School of Science", "Polytechnic", "Academy of Sciences", "Advanced Study", "National Laboratory", "Research Center", "Scientific Society"]
	return adjective + " " + wordsA[randi() % wordsA.size()]

var howManyCountries = 5
var howManyCriminal = 8

func NewGenerate():
	GameLogic.random.randomize()
	randomize()
	var homelandSoftPowerLastMonths = []  # will be returned
	############################################################################
	# get countries
	var addedNames = []
	var safetyCounter = 0
	while len(WorldData.Countries) < howManyCountries+1 and safetyCounter < howManyCountries*10:
		safetyCounter += 1
		var pick = randi() % ScenarioEurope21.PossibleCountries.size()
		if ScenarioEurope21.PossibleCountries[pick].Name in addedNames: continue
		WorldData.Countries.append(ScenarioEurope21.PossibleCountries[pick])
		addedNames.append(ScenarioEurope21.PossibleCountries[pick].Name)
	############################################################################
	# divide countries into few blocks
	var blockA = []
	var blockB = []
	var blockC = []
	var c = 0
	while c < len(WorldData.Countries):
		var choice = GameLogic.random.randi_range(1,3)
		if choice == 1: blockA.append(c)
		elif choice == 2: blockB.append(c)
		else: blockC.append(c)
		c += 1
	# order is later used to decide few things
	blockA.shuffle()
	blockB.shuffle()
	blockC.shuffle()
	# randomly relate blocks
	var blockAtoB = GameLogic.random.randi_range(0, 1)
	var blockAtoC = GameLogic.random.randi_range(0, 1)
	var blockBtoC = GameLogic.random.randi_range(0, 1)
	# translate block into individual relations
	for i in range(0,len(WorldData.Countries)):
		var zeroArr = []
		for k in range(0, len(WorldData.Countries)): zeroArr.append(0)
		WorldData.DiplomaticRelations.append(zeroArr)
	for a in blockA:
		for b in blockB:
			if blockAtoB <= 0:
				WorldData.DiplomaticRelations[a][b] = GameLogic.random.randi_range(-5,-80)
			elif blockAtoB > 0:
				WorldData.DiplomaticRelations[a][b] = GameLogic.random.randi_range(5,80)
		for b in blockC:
			if blockAtoC <= 0:
				WorldData.DiplomaticRelations[a][b] = GameLogic.random.randi_range(-5,-80)
			elif blockAtoC > 0:
				WorldData.DiplomaticRelations[a][b] = GameLogic.random.randi_range(5,80)
	for a in blockB:
		for b in blockA:
			if blockAtoB <= 0:
				WorldData.DiplomaticRelations[a][b] = GameLogic.random.randi_range(-5,-80)
			elif blockAtoB > 0:
				WorldData.DiplomaticRelations[a][b] = GameLogic.random.randi_range(5,80)
		for b in blockC:
			if blockBtoC <= 0:
				WorldData.DiplomaticRelations[a][b] = GameLogic.random.randi_range(-5,-80)
			elif blockBtoC > 0:
				WorldData.DiplomaticRelations[a][b] = GameLogic.random.randi_range(5,80)
	for a in blockC:
		for b in blockA:
			if blockAtoC <= 0:
				WorldData.DiplomaticRelations[a][b] = GameLogic.random.randi_range(-5,-80)
			elif blockAtoC > 0:
				WorldData.DiplomaticRelations[a][b] = GameLogic.random.randi_range(5,80)
		for b in blockB:
			if blockBtoC <= 0:
				WorldData.DiplomaticRelations[a][b] = GameLogic.random.randi_range(-5,-80)
			elif blockBtoC > 0:
				WorldData.DiplomaticRelations[a][b] = GameLogic.random.randi_range(5,80)
	# each block usually has one aggressive leader, few satellite players, and lazier long tail
	# i know, dry, but don't care about that right now
	c = 0
	while c < len(blockA):
		if c == 0:
			WorldData.Countries[blockA[c]].PoliticsAggression = GameLogic.random.randi_range(60,90)
			WorldData.Countries[blockA[c]].PoliticsIntel = GameLogic.random.randi_range(60,90)
		elif c <= 1:
			WorldData.Countries[blockA[c]].PoliticsAggression = GameLogic.random.randi_range(40,60)
			WorldData.Countries[blockA[c]].PoliticsIntel = GameLogic.random.randi_range(40,60)
		else:
			WorldData.Countries[blockA[c]].PoliticsAggression = GameLogic.random.randi_range(10,50)
			WorldData.Countries[blockA[c]].PoliticsIntel = GameLogic.random.randi_range(5,50)
		c += 1
	c = 0
	while c < len(blockB):
		if c == 0:
			WorldData.Countries[blockB[c]].PoliticsAggression = GameLogic.random.randi_range(60,90)
			WorldData.Countries[blockB[c]].PoliticsIntel = GameLogic.random.randi_range(60,90)
		elif c <= 1:
			WorldData.Countries[blockB[c]].PoliticsAggression = GameLogic.random.randi_range(40,60)
			WorldData.Countries[blockB[c]].PoliticsIntel = GameLogic.random.randi_range(40,60)
		else:
			WorldData.Countries[blockB[c]].PoliticsAggression = GameLogic.random.randi_range(10,50)
			WorldData.Countries[blockB[c]].PoliticsIntel = GameLogic.random.randi_range(5,50)
		c += 1
	c = 0
	while c < len(blockC):
		if c == 0:
			WorldData.Countries[blockC[c]].PoliticsAggression = GameLogic.random.randi_range(60,90)
			WorldData.Countries[blockC[c]].PoliticsIntel = GameLogic.random.randi_range(60,90)
		elif c <= 1:
			WorldData.Countries[blockC[c]].PoliticsAggression = GameLogic.random.randi_range(40,60)
			WorldData.Countries[blockC[c]].PoliticsIntel = GameLogic.random.randi_range(40,60)
		else:
			WorldData.Countries[blockC[c]].PoliticsAggression = GameLogic.random.randi_range(10,50)
			WorldData.Countries[blockC[c]].PoliticsIntel = GameLogic.random.randi_range(5,50)
		c += 1
	# more general generators
	c = 0
	while c < len(WorldData.Countries):
		WorldData.Countries[c].PoliticsStability = GameLogic.random.randi_range(10,90)
		c += 1
	############################################################################
	# setting initial direction parameters
	for e in range(1, len(WorldData.Countries)):
		WorldData.Countries[e].IntelFriendliness += GameLogic.random.randi_range(-10,10)
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
		GenerateIntelOrgs(WorldData.Countries[i].Name, i)
	# organizations such as NATO or UN
	ScenarioEurope21.CreateAdHocOrgs()
	# movements
	var movNames = ["Religious", "Nationalist", "Anarchist", "Counter-culture"]
	for i in range(0,3):
		var doNotRepeat = []
		for k in range(0,GameLogic.random.randi_range(1,howManyCountries)):
			var size = GameLogic.random.randi_range(100,15000)
			var place = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
			if place in doNotRepeat: continue
			doNotRepeat.append(place)
			WorldData.Organizations.append(
				WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": WorldData.Countries[place].Adjective + " " + movNames[i] + " Movement", "Fixed": false, "Known": true, "Staff": size, "Budget": 0, "Counterintelligence": 0, "Aggression": GameLogic.random.randi_range(10,70), "Countries": [place], "IntelValue": GameLogic.random.randi_range(-10,10), "TargetConsistency": 0, "TargetCountries": [], })
			)
	# few general terror orgs
	var howManyTerror = int(howManyCriminal*0.6)
	if howManyTerror < 1: howManyTerror = 1
	var howManyLone = int(howManyCriminal*0.1)
	if howManyLone < 1: howManyLone = 1
	var howManyArm = int(howManyCriminal*0.3)
	if howManyArm < 1: howManyArm = 1
	for i in range(0,howManyTerror):
		var size = GameLogic.random.randi_range(10,500)
		var places = []
		for h in range(0, GameLogic.random.randi_range(1,4)):
			var trying = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
			if !(trying in places):
				places.append(trying)
		var name = GenerateHostileName()
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
			if GameLogic.random.randi_range(1,3) == 3:
				WorldData.Organizations[-1].TargetCountries.append(0)
	# hidden or emerging terror orgs
	for i in range(0,1):
		var size = GameLogic.random.randi_range(2,10)
		var places = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		var name = GenerateHostileName()
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
		WorldData.Organizations[-1].UndercoverCounter = GameLogic.random.randi_range(30,130)
		# tying some terror orgs to movements
		for j in range(0,len(WorldData.Organizations)):
			if WorldData.Organizations[j].Type != WorldData.OrgType.MOVEMENT: continue
			if WorldData.Organizations[j].Countries[0] != places: continue
			if GameLogic.random.randi_range(1,2) == 1:
				WorldData.Organizations[j].ConnectedTo.append(len(WorldData.Organizations)-1)
		# target homeland more often
		if !(0 in WorldData.Organizations[-1].TargetCountries):
			if GameLogic.random.randi_range(1,9) == 3:
				WorldData.Organizations[-1].TargetCountries.append(0)
	# lone wolves
	for i in range(0,howManyLone):
		var size = 1
		var places = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		var name = GenerateHostileName()
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
			if GameLogic.random.randi_range(1,6) == 3:
				WorldData.Organizations[-1].TargetCountries.append(0)
	# few arms traders
	for i in range(0,howManyArm):
		var places = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		var name = GenerateCompanyName()
		if name in doNotDuplicate: continue
		doNotDuplicate.append(name)
		var ifKnown = false
		if GameLogic.random.randi_range(1,3) == 2: ifKnown = true
		WorldData.Organizations.append(
			WorldData.aNewOrganization({ "Type": WorldData.OrgType.ARMTRADER, "Name": name, "Fixed": false, "Known": ifKnown, "Staff": GameLogic.random.randi_range(10,200), "Budget": GameLogic.random.randi_range(1000,100000), "Counterintelligence": GameLogic.random.randi_range(50,80), "Aggression": GameLogic.random.randi_range(55,95), "Countries": [places], "IntelValue": GameLogic.random.randi_range(-10,0), "TargetConsistency": 0, "TargetCountries": [], })
		)
		if ifKnown == false:
			WorldData.Organizations[-1].UndercoverCounter = GameLogic.random.randi_range(30,240)
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
	for i in range(0,howManyCountries):
		var size = GameLogic.random.randi_range(10,5000)
		var places = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		var name = GenerateCompanyName()
		if name in doNotDuplicate: continue
		doNotDuplicate.append(name)
		WorldData.Organizations.append(
			WorldData.aNewOrganization({ "Type": WorldData.OrgType.COMPANY, "Name": name, "Fixed": false, "Known": true, "Staff": size, "Budget": size*100+GameLogic.random.randi_range(-100,100), "Counterintelligence": GameLogic.random.randi_range(10,50), "Aggression": GameLogic.random.randi_range(0,10), "Countries": [places], "IntelValue": GameLogic.random.randi_range(-10,10), "TargetConsistency": 0, "TargetCountries": [], })
		)
		WorldData.Organizations[-1].IntelIdentified = GameLogic.random.randi_range(1,10)  # officials
		WorldData.Organizations[-1].Technology = GameLogic.random.randi_range(1, WorldData.Countries[places].SoftPower)
	# universities
	for i in range(0,howManyCountries):
		var size = GameLogic.random.randi_range(200,2000)
		var places = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		var name = GenerateUniversityName(WorldData.Countries[places].Adjective)
		if name in doNotDuplicate: continue
		doNotDuplicate.append(name)
		WorldData.Organizations.append(
			WorldData.aNewOrganization({ "Type": WorldData.OrgType.UNIVERSITY, "Name": name, "Fixed": false, "Known": true, "Staff": size, "Budget": size*100+GameLogic.random.randi_range(-100,100), "Counterintelligence": GameLogic.random.randi_range(10,50), "Aggression": GameLogic.random.randi_range(0,5), "Countries": [places], "IntelValue": GameLogic.random.randi_range(-10,10), "TargetConsistency": 0, "TargetCountries": [], })
		)
		WorldData.Organizations[-1].IntelIdentified = GameLogic.random.randi_range(1,10)  # officials
		WorldData.Organizations[-1].Technology = GameLogic.random.randi_range(1, WorldData.Countries[places].SoftPower)
	# offensive universities (wmd research etc)
	for i in range(0,int(howManyCountries*0.5)):
		var size = GameLogic.random.randi_range(200,2000)
		var places = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		var name = GenerateUniversityName(WorldData.Countries[places].Adjective)
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
	############################################################################
	return homelandSoftPowerLastMonths
