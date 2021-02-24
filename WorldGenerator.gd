extends Node

func GenerateHostileName():
	var words = ["Tobiah","Yseut","Esther","Iphigenia","Yemima","Rexana","Amaterasu","Joslyn","Mattityahu","Karl","Izanami","Jemma","Lorinda","Avram","Ned","Trophimus","Isolde","Harvey","Marsha","Lyn","Shani","Anu","Marilyn","Montgomery","Davey","Leland","Crescens","Jordana","Vern","Bradford","Marianne","Adamu","Manahem","Earleen","Peronel","Enosh","Ryker","Adelle","Myrddin","Carver","Jody","Anat","Atarah","Capricia","Sidney","Cindra","Nik","Jehoash","Atarah","Iahel"]
	var content = ""
	var length = GameLogic.random.randi_range(1,3)
	if length == 1:
		return words[randi() % words.size()]
	elif length == 2:
		content += words[randi() % words.size()]
		if GameLogic.random.randi_range(1,4) == 1: content += "-"
		else: content += " "
		content += words[randi() % words.size()]
		return content
	else:
		content += words[randi() % words.size()]
		if GameLogic.random.randi_range(1,4) == 1: content += "-"
		else: content += " "
		content += words[randi() % words.size()]
		if GameLogic.random.randi_range(1,4) == 1: content += "-"
		else: content += " "
		content += words[randi() % words.size()]
		return content

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
			WorldData.Countries[blockA[c]].PoliticsAggresion = GameLogic.random.randi_range(60,90)
			WorldData.Countries[blockA[c]].PoliticsIntel = GameLogic.random.randi_range(60,90)
		elif c <= 1:
			WorldData.Countries[blockA[c]].PoliticsAggresion = GameLogic.random.randi_range(40,60)
			WorldData.Countries[blockA[c]].PoliticsIntel = GameLogic.random.randi_range(40,60)
		else:
			WorldData.Countries[blockA[c]].PoliticsAggresion = GameLogic.random.randi_range(10,50)
			WorldData.Countries[blockA[c]].PoliticsIntel = GameLogic.random.randi_range(5,50)
		c += 1
	c = 0
	while c < len(blockB):
		if c == 0:
			WorldData.Countries[blockB[c]].PoliticsAggresion = GameLogic.random.randi_range(60,90)
			WorldData.Countries[blockB[c]].PoliticsIntel = GameLogic.random.randi_range(60,90)
		elif c <= 1:
			WorldData.Countries[blockB[c]].PoliticsAggresion = GameLogic.random.randi_range(40,60)
			WorldData.Countries[blockB[c]].PoliticsIntel = GameLogic.random.randi_range(40,60)
		else:
			WorldData.Countries[blockB[c]].PoliticsAggresion = GameLogic.random.randi_range(10,50)
			WorldData.Countries[blockB[c]].PoliticsIntel = GameLogic.random.randi_range(5,50)
		c += 1
	c = 0
	while c < len(blockC):
		if c == 0:
			WorldData.Countries[blockC[c]].PoliticsAggresion = GameLogic.random.randi_range(60,90)
			WorldData.Countries[blockC[c]].PoliticsIntel = GameLogic.random.randi_range(60,90)
		elif c <= 1:
			WorldData.Countries[blockC[c]].PoliticsAggresion = GameLogic.random.randi_range(40,60)
			WorldData.Countries[blockC[c]].PoliticsIntel = GameLogic.random.randi_range(40,60)
		else:
			WorldData.Countries[blockC[c]].PoliticsAggresion = GameLogic.random.randi_range(10,50)
			WorldData.Countries[blockC[c]].PoliticsIntel = GameLogic.random.randi_range(5,50)
		c += 1
	# more general generators
	c = 0
	while c < len(WorldData.Countries):
		WorldData.Countries[c].PoliticsStability = GameLogic.random.randi_range(10,90)
		c += 1
	############################################################################
	# generating organizations
	# governments
	for i in range(1, len(WorldData.Countries)):
		WorldData.Organizations.append(
			{ "Type": WorldData.OrgType.GOVERNMENT, "Name": WorldData.Countries[i].Adjective + " Government", "Fixed": true, "Known": true, "Staff": WorldData.Countries[i].Size*300, "Budget": WorldData.Countries[i].Size*10000, "Counterintelligence": 60, "Countries": [i], "OpsAgainstHomeland": [], "IntelDescription": [], "IntelValue": 10, }
		)
	# few general terror orgs
	for i in range(0,3):
		var size = GameLogic.random.randi_range(5,100)
		var places = []
		for h in range(0, GameLogic.random.randi_range(1,4)):
			var trying = GameLogic.random.randi_range(0,len(WorldData.Countries)-1)
			if !(trying in places):
				places.append(trying)
		WorldData.Organizations.append(
			{ "Type": WorldData.OrgType.GENERALTERROR, "Name": GenerateHostileName(), "Fixed": false, "Known": true, "Staff": size, "Budget": size*100+GameLogic.random.randi_range(-100,100), "Counterintelligence": GameLogic.random.randi_range(10,60), "Countries": places, "OpsAgainstHomeland": [], "IntelDescription": [], "IntelValue": 0, }
		)
	############################################################################
	# filling in some organizatiions
	for o in range(0, len(WorldData.Organizations)):
		if WorldData.Organizations[o].Type == WorldData.OrgType.INTEL:
			WorldIntel.GatherOnOrg(o, 0, "01/01/2021")
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
		WorldData.WorldNextWeek(localDate)

