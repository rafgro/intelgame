extends Node

func GenerateHostileName():
	var wordsA = ["Leftist", "Right", "Proud", "Revolutionary", "Republican", "Combat", "Black", "Democratic", "Real"]
	var wordsB = ["Tobiah","Yseut","Esther","Iphigenia","Yemima","Rexana","Amaterasu","Joslyn","Mattityahu","Karl","Izanami","Jemma","Lorinda","Avram","Ned","Trophimus","Isolde","Harvey","Marsha","Lyn","Shani","Anu","Marilyn","Montgomery","Davey","Leland","Crescens","Jordana","Vern","Bradford","Marianne","Adamu","Manahem","Earleen","Peronel","Enosh","Ryker","Adelle","Myrddin","Carver","Jody","Anat","Atarah","Capricia","Sidney","Cindra","Nik","Jehoash","Atarah","Iahel"]
	var wordsC = ["Movement", "Brotherhood", "Force", "Action", "Militants", "Extremists"]
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
	var wordsA = ["University", "Institute", "College", "Technological University", "National Colllege", "Institute of Technology", "School of Science", "Polytechnic", "Academy of Sciences", "Institute for Advanced Study", "National Laboratory"]
	return adjective + " " + wordsA[randi() % wordsA.size()]

func NewGenerate():
	GameLogic.random.randomize()
	randomize()
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
		WorldData.DiplomaticRelations.append(
			[0,0,0,0,0,0,0,0,0,0,0,0,0,0]
		)
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
	# governments
	for i in range(1, len(WorldData.Countries)):
		WorldData.Organizations.append(
			WorldData.AnOrganization.new({ "Type": WorldData.OrgType.GOVERNMENT, "Name": WorldData.Countries[i].Adjective + " Government", "Fixed": true, "Known": true, "Staff": WorldData.Countries[i].Size*300, "Budget": WorldData.Countries[i].Size*10000, "Counterintelligence": GameLogic.random.randi_range(45,65), "Aggression": GameLogic.random.randi_range(20,55), "Countries": [i], "IntelValue": 10, })
		)
		WorldData.Organizations[-1].IntelIdentified = GameLogic.random.randi_range(20,100)  # officials
	# few general terror orgs
	for i in range(0,5):
		var size = GameLogic.random.randi_range(10,500)
		var places = []
		for h in range(0, GameLogic.random.randi_range(1,4)):
			var trying = GameLogic.random.randi_range(0,len(WorldData.Countries)-1)
			if !(trying in places):
				places.append(trying)
		var name = GenerateHostileName()
		if name in doNotDuplicate: continue
		doNotDuplicate.append(name)
		WorldData.Organizations.append(
			WorldData.AnOrganization.new({ "Type": WorldData.OrgType.GENERALTERROR, "Name": name, "Fixed": false, "Known": true, "Staff": size, "Budget": size*100+GameLogic.random.randi_range(-100,100), "Counterintelligence": GameLogic.random.randi_range(10,60), "Aggression": GameLogic.random.randi_range(30,95), "Countries": places, "IntelValue": GameLogic.random.randi_range(-50,10), })
		)
	# hidden or emerging terror orgs
	for i in range(0,2):
		var size = GameLogic.random.randi_range(2,10)
		var places = GameLogic.random.randi_range(0,len(WorldData.Countries)-1)
		var name = GenerateHostileName()
		if name in doNotDuplicate: continue
		doNotDuplicate.append(name)
		WorldData.Organizations.append(
			WorldData.AnOrganization.new({ "Type": WorldData.OrgType.GENERALTERROR, "Name": name, "Fixed": false, "Known": false, "Staff": size, "Budget": size*100+GameLogic.random.randi_range(-50,150), "Counterintelligence": GameLogic.random.randi_range(5,50), "Aggression": GameLogic.random.randi_range(45,95), "Countries": [places], "IntelValue": GameLogic.random.randi_range(-50,-5), })
		)
		WorldData.Organizations[-1].UndercoverCounter = GameLogic.random.randi_range(30,130)
	# lone wolves
	for i in range(0,2):
		var size = 1
		var places = GameLogic.random.randi_range(0,len(WorldData.Countries)-1)
		var name = GenerateHostileName()
		if name in doNotDuplicate: continue
		doNotDuplicate.append(name)
		WorldData.Organizations.append(
			WorldData.AnOrganization.new({ "Type": WorldData.OrgType.GENERALTERROR, "Name": name, "Fixed": false, "Known": false, "Staff": size, "Budget": GameLogic.random.randi_range(25,150), "Counterintelligence": GameLogic.random.randi_range(20,80), "Aggression": GameLogic.random.randi_range(15,65), "Countries": [places], "IntelValue": GameLogic.random.randi_range(-10,0), })
		)
		WorldData.Organizations[-1].UndercoverCounter = GameLogic.random.randi_range(60,180)
	# companies
	for i in range(0,10):
		var size = GameLogic.random.randi_range(10,5000)
		var places = GameLogic.random.randi_range(0,len(WorldData.Countries)-1)
		var name = GenerateCompanyName()
		if name in doNotDuplicate: continue
		doNotDuplicate.append(name)
		WorldData.Organizations.append(
			WorldData.AnOrganization.new({ "Type": WorldData.OrgType.COMPANY, "Name": name, "Fixed": false, "Known": true, "Staff": size, "Budget": size*100+GameLogic.random.randi_range(-100,100), "Counterintelligence": GameLogic.random.randi_range(0,30), "Aggression": GameLogic.random.randi_range(0,10), "Countries": [places], "IntelValue": GameLogic.random.randi_range(-10,10), })
		)
		WorldData.Organizations[-1].IntelIdentified = GameLogic.random.randi_range(1,10)  # officials
		WorldData.Organizations[-1].Technology = GameLogic.random.randi_range(1, WorldData.Countries[places].SoftPower)
	# universities
	for i in range(0,10):
		var size = GameLogic.random.randi_range(200,2000)
		var places = GameLogic.random.randi_range(0,len(WorldData.Countries)-1)
		var name = GenerateUniversityName(WorldData.Countries[places].Adjective)
		if name in doNotDuplicate: continue
		doNotDuplicate.append(name)
		WorldData.Organizations.append(
			WorldData.AnOrganization.new({ "Type": WorldData.OrgType.UNIVERSITY, "Name": name, "Fixed": false, "Known": true, "Staff": size, "Budget": size*100+GameLogic.random.randi_range(-100,100), "Counterintelligence": GameLogic.random.randi_range(0,10), "Aggression": GameLogic.random.randi_range(0,5), "Countries": [places], "IntelValue": GameLogic.random.randi_range(-10,10), })
		)
		WorldData.Organizations[-1].IntelIdentified = GameLogic.random.randi_range(1,10)  # officials
		WorldData.Organizations[-1].Technology = GameLogic.random.randi_range(1, WorldData.Countries[places].SoftPower)
	############################################################################
	# filling in some organizatiions
	for o in range(0, len(WorldData.Organizations)):
		if WorldData.Organizations[o].Type == WorldData.OrgType.INTEL:
			WorldData.Organizations[o].Technology = WorldData.Organizations[o].Counterintelligence + GameLogic.random.randi_range(-15,15)
			WorldIntel.GatherOnOrg(o, 0, "01/01/2021")
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
		localDate += str(pastDay) + "/"
		if pastMonth < 10: localDate += "0"
		localDate += str(pastMonth) + "/" + str(pastYear)
		# actual next week
		WorldNextWeek.Execute(localDate)

