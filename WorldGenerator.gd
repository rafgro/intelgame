extends Node

func Generate():
	for a in WorldData.Adversaries:
		var i = 0
		while i < 3:
			i += 1
			var country = randi() % WorldData.Countries.size()
			WorldData.Targets.append(
				{
					"Type": WorldData.TargetType.PLACE,
					"Name": a.Adjective + " " + WorldData.Level0Places[randi() % WorldData.Level0Places.size()] + " in " + WorldData.Countries[country].Name,
					"Country": country,
					"LocationPrecise": "",
					"LocationOpenness": 100,
					"LocationSecrecyProgress": 0,
					"LocationIsKnown": false,
					"RiskOfCounterintelligence": a.Counterintelligence*(WorldData.Countries[country].Hostility/100.0),
					"RiskOfDeath": a.Hostility*(WorldData.Countries[country].Hostility/200.0),
					"DiffOfObservation": (100-WorldData.Countries[country].IntelFriendliness),
					"AvailableDMethods": [0,1,2,3],  # ids from Methods
				}
			)

func NewGenerate():
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
	var blockAtoB = GameLogic.random.randi_range(-70, 70)
	var blockAtoC = GameLogic.random.randi_range(-70, 70)
	var blockBtoC = GameLogic.random.randi_range(-70, 70)
	# translate block into individual relations
	for b in blockA:
		WorldData.Countries[b].Friends.append_array(blockA)
		WorldData.Countries[b].Friends.remove(blockA.bsearch(b))  # not friending itself
		for bb in blockB:
			if (blockAtoB+GameLogic.random.randi_range(-20,20)) < -40:
				WorldData.Countries[b].Foes.append(bb)
				if bb == 0:
					WorldData.Countries[b].Hostility = (-1)*blockAtoB+GameLogic.random.randi_range(-20,20)
			elif (blockAtoB+GameLogic.random.randi_range(-20,20)) > 40:
				WorldData.Countries[b].Friends.append(bb)
		for cc in blockC:
			if (blockAtoC+GameLogic.random.randi_range(-20,20)) < -40:
				WorldData.Countries[b].Foes.append(cc)
				if cc == 0:
					WorldData.Countries[b].Hostility = (-1)*blockAtoC+GameLogic.random.randi_range(-20,20)
			elif (blockAtoC+GameLogic.random.randi_range(-20,20)) > 40:
				WorldData.Countries[b].Friends.append(cc)
	for b in blockB:
		WorldData.Countries[b].Friends.append_array(blockB)
		WorldData.Countries[b].Friends.remove(blockB.bsearch(b))  # not friending itself
		for bb in blockA:
			if (blockAtoB+GameLogic.random.randi_range(-20,20)) < -40:
				WorldData.Countries[b].Foes.append(bb)
				if bb == 0:
					WorldData.Countries[b].Hostility = (-1)*blockAtoB+GameLogic.random.randi_range(-20,20)
			elif (blockAtoB+GameLogic.random.randi_range(-20,20)) > 40:
				WorldData.Countries[b].Friends.append(bb)
		for cc in blockC:
			if (blockBtoC+GameLogic.random.randi_range(-20,20)) < -40:
				WorldData.Countries[b].Foes.append(cc)
				if cc == 0:
					WorldData.Countries[b].Hostility = (-1)*blockBtoC+GameLogic.random.randi_range(-20,20)
			elif (blockBtoC+GameLogic.random.randi_range(-20,20)) > 40:
				WorldData.Countries[b].Friends.append(cc)
	for b in blockC:
		WorldData.Countries[b].Friends.append_array(blockC)
		WorldData.Countries[b].Friends.remove(blockC.bsearch(b))  # not friending itself
		for bb in blockA:
			if (blockAtoC+GameLogic.random.randi_range(-20,20)) < -40:
				WorldData.Countries[b].Foes.append(bb)
				if bb == 0:
					WorldData.Countries[b].Hostility = (-1)*blockAtoC+GameLogic.random.randi_range(-20,20)
			elif (blockAtoC+GameLogic.random.randi_range(-20,20)) > 40:
				WorldData.Countries[b].Friends.append(bb)
		for cc in blockB:
			if (blockBtoC+GameLogic.random.randi_range(-20,20)) < -40:
				WorldData.Countries[b].Foes.append(cc)
				if cc == 0:
					WorldData.Countries[b].Hostility = (-1)*blockBtoC+GameLogic.random.randi_range(-20,20)
			elif (blockBtoC+GameLogic.random.randi_range(-20,20)) > 40:
				WorldData.Countries[b].Friends.append(cc)
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
	############################################################################

