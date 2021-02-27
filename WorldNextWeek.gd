extends Node

func Execute(past):
	var doesItEndWithCall = false
	############################################################################
	# progressing to elections
	for c in range(0, len(WorldData.Countries)):
		WorldData.Countries[c].ElectionProgress -= 1
		if WorldData.Countries[c].ElectionProgress <= 0:
			# election
			var eventualDesc = ""
			var won = GameLogic.random.randi_range(29,55)
			if GameLogic.random.randi_range(0,1) == 0:
				GameLogic.AddWorldEvent("Elections in " + WorldData.Countries[c].Name + ": Incumbent won, achieving "+str(won)+"%", past)
				WorldData.Countries[c].ElectionProgress = WorldData.Countries[c].ElectionPeriod
				WorldData.Countries[c].PoliticsAggression += GameLogic.random.randi_range(-5,5)
				WorldData.Countries[c].PoliticsStability += GameLogic.random.randi_range(10,won)
				if c == 0:
					eventualDesc = "Incumbent won, achieving "+str(won)+"%. Government will largely stay in the same shape, continuing similar foreign policy, and preserving existing approach to intelligence services."
			else:
				GameLogic.AddWorldEvent("Elections in " + WorldData.Countries[c].Name + ": New government formed, achieving "+str(won)+"%", past)
				WorldData.Countries[c].ElectionProgress = WorldData.Countries[c].ElectionPeriod
				WorldData.Countries[c].PoliticsIntel = GameLogic.random.randi_range(10,90)
				WorldData.Countries[c].PoliticsAggression += GameLogic.random.randi_range(-15,15)
				WorldData.Countries[c].PoliticsStability += GameLogic.random.randi_range(won,90)
				for d in range(0, len(WorldData.Countries)):
					WorldData.DiplomaticRelations[c][d] += GameLogic.random.randi_range(-10,10)
				if c == 0:
					var newApproach = "adverse"
					var eventualIncrease = ""
					if WorldData.Countries[c].PoliticsIntel > 60:
						newApproach = "friendly"
						eventualIncrease = "As a mark of a new start, bureau's budget is increased by €" + str(int(GameLogic.BudgetFull*0.3)) + ",000."
						GameLogic.BudgetFull *= 1.3
					elif WorldData.Countries[c].PoliticsIntel > 30: newApproach = "neutral"
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
	for c in range(0, len(WorldData.Countries)):
		# parameter fluctations
		if GameLogic.random.randi_range(1,4) == 2:  # ~one per month
			WorldData.Countries[c].Size *= (1.0+GameLogic.random.randi_range(-1,1)*0.01)
			WorldData.Countries[c].IntelFriendliness += GameLogic.random.randi_range(-1,1)
		# stability
		var choice = GameLogic.random.randi_range(0,70)
		if WorldData.Countries[c].PoliticsStability < 20:
			choice = GameLogic.random.randi_range(0,20)
			if choice > WorldData.Countries[c].PoliticsStability and GameLogic.random.randi_range(0,10) == 1:
				GameLogic.AddWorldEvent("Government resigned in " + WorldData.Countries[c].Name, past)
				WorldData.Countries[c].ElectionProgress = 0
		elif choice > WorldData.Countries[c].PoliticsStability and GameLogic.random.randi_range(0,20) == 2:
			if GameLogic.random.randi_range(1,3) == 2:
				GameLogic.AddWorldEvent("Protests against government in " + WorldData.Countries[c].Name, past)
			else:
				GameLogic.AddWorldEvent("Internal tensions in " + WorldData.Countries[c].Name, past)
			WorldData.Countries[c].PoliticsStability -= GameLogic.random.randi_range(5,15)
	# individual diplomatic events
	for c in range(0, len(WorldData.Countries)):
		if GameLogic.random.randi_range(0,2) == 0:
			var affected = GameLogic.random.randi_range(0, len(WorldData.Countries)-1)
			if c == affected:
				continue  # don't act on itself
			var change = GameLogic.random.randi_range((WorldData.DiplomaticRelations[c][affected]-30.0)/10, (WorldData.DiplomaticRelations[c][affected]+30.0)/10)
			if GameLogic.random.randi_range(0,15) == 9:  # rare larger change
				change = GameLogic.random.randi_range((WorldData.DiplomaticRelations[c][affected]-30.0)/4, (WorldData.DiplomaticRelations[c][affected]+30.0)/4)
			WorldData.DiplomaticRelations[c][affected] += change
			if GameLogic.random.randi_range(0,20) == 7:  # publicly known
				if change < 0 and WorldData.DiplomaticRelations[c][affected] > -30:
					GameLogic.AddWorldEvent(WorldData.Countries[c].Name + WorldData.DiplomaticPhrasesNegative[randi() % WorldData.DiplomaticPhrasesNegative.size()] + WorldData.Countries[affected].Name, past)
				elif change < 0 and WorldData.DiplomaticRelations[c][affected] <= -30:
					GameLogic.AddWorldEvent(WorldData.Countries[c].Name + WorldData.DiplomaticPhrasesVeryNegative[randi() % WorldData.DiplomaticPhrasesNegative.size()] + WorldData.Countries[affected].Name, past)
				elif change > 0 and WorldData.DiplomaticRelations[c][affected] < 30:
					GameLogic.AddWorldEvent(WorldData.Countries[c].Name + WorldData.DiplomaticPhrasesPositive[randi() % WorldData.DiplomaticPhrasesPositive.size()] + WorldData.Countries[affected].Name, past)
				elif change > 0 and WorldData.DiplomaticRelations[c][affected] >= 30:
					GameLogic.AddWorldEvent(WorldData.Countries[c].Name + WorldData.DiplomaticPhrasesVeryPositive[randi() % WorldData.DiplomaticPhrasesPositive.size()] + WorldData.Countries[affected].Name, past)
	# country summits
	if GameLogic.random.randi_range(0,20) == 12:
		# getting participants
		var howmany = GameLogic.random.randi_range(3,6)
		var participants = []
		while len(participants) < howmany:
			var try = GameLogic.random.randi_range(0, len(WorldData.Countries)-1)
			if !(try in participants):
				participants.append(try)
		# results, mostly depending on sum of internal relations
		var theSum = 0
		for p in participants:
			for p2 in participants:
				theSum += WorldData.DiplomaticRelations[p][p2]
		theSum += GameLogic.random.randf_range(theSum*(-0.2),theSum*(0.2))
		var result = 15
		if theSum < 0: result = -15
		# updating relations
		var message = ""
		for p in participants:
			message += WorldData.Countries[p].Name + ", "
			for p2 in participants:
				WorldData.DiplomaticRelations[p][p2] += result
		# public information
		message = "Summit of " + message.substr(0, len(message)-2) + ": "
		if theSum > 0: message += "governments issued a joint statement"
		else: message += "governments could not reach consensus"
		GameLogic.AddWorldEvent(message, past)
	# organization proceedings
	for w in range(0,len(WorldData.Organizations)):
		# intel decay
		WorldData.Organizations[w].IntelValue *= 0.99  # ~4%/month, ~40%/year
		# change of visibility
		if WorldData.Organizations[w].Known == false:
			WorldData.Organizations[w].UndercoverCounter -= 1
			if WorldData.Organizations[w].UndercoverCounter <= 0 and GameLogic.random.randi_range(1,5) == 3:
				WorldData.Organizations[w].Known = true
				WorldData.Organizations[w].IntelValue += 10
				if WorldData.Organizations[w].Type == WorldData.OrgType.GENERALTERROR:
					GameLogic.AddWorldEvent("New suspected terrorist organization, " + WorldData.Organizations[w].Name + ", discovered in " + WorldData.Countries[WorldData.Organizations[w].Countries[0]].Name, past)
		# staff and budget changes
		if GameLogic.random.randi_range(1,4) == 2:  # ~one per month
			WorldData.Organizations[w].Budget *= (1.0+GameLogic.random.randi_range(-1,1)*0.01)
			if WorldData.Organizations[w].Staff > 100:  # large orgs
				WorldData.Organizations[w].Staff *= (1.0+GameLogic.random.randi_range(-1,1)*0.01)
			else:  # small orgs
				WorldData.Organizations[w].Staff += GameLogic.random.randi_range(-1,1)
				if WorldData.Organizations[w].Staff < 1: WorldData.Organizations[w].Staff = 1
		# continuing existing operations
		for u in range(0,len(WorldData.Organizations[w].OpsAgainstHomeland)):
			if WorldData.Organizations[w].OpsAgainstHomeland[u].Active == false:
				continue
			WorldData.Organizations[w].OpsAgainstHomeland[u].FinishCounter -= 1
			if WorldData.Organizations[w].OpsAgainstHomeland[u].FinishCounter <= 0:
				if WorldData.Organizations[w].OpsAgainstHomeland[u].Type == WorldData.ExtOpType.TERRORIST_ATTACK:
					# decide if it's happenning: prevented or not
					var knownInvolvedValue = WorldData.Organizations[w].OpsAgainstHomeland[u].Persons * (WorldData.Organizations[w].IntelIdentified*1.0 / WorldData.Organizations[w].Staff)
					if int(knownInvolvedValue) >= int(WorldData.Organizations[w].OpsAgainstHomeland[u].Persons*0.6) or GameLogic.random.randi_range(1,100) < WorldData.Organizations[w].OpsAgainstHomeland[u].IntelValue:
						var reason = ""
						if knownInvolvedValue > 0 and knownInvolvedValue < 20:
							reason += "Law enforcement caught " + str(knownInvolvedValue) + " terrorists. "
						elif knownInvolvedValue > 0 and knownInvolvedValue < 20:
							reason += str(knownInvolvedValue) + " terrorists were refused entry to the country. "
						if WorldData.Organizations[w].OpsAgainstHomeland[u].IntelValue > 80:
							reason += "Extremely detailed plans of the attack, obtained by Bureau, helped to secure all potential targets. "
						elif WorldData.Organizations[w].OpsAgainstHomeland[u].IntelValue > 50:
							reason += "Detailed plans of the attack, obtained by Bureau, helped to secure all potential targets. "
						elif WorldData.Organizations[w].OpsAgainstHomeland[u].IntelValue > 25:
							reason += "Plans of the attack, obtained by Bureau, helped to secure potential targets. "
						WorldData.Organizations[w].OpsAgainstHomeland[u].Active = false
						WorldData.Organizations[w].ActiveOpsAgainstHomeland -= 1
						var trustIncrease = WorldData.Organizations[w].OpsAgainstHomeland[u].Damage
						if trustIncrease < 20: trustIncrease = GameLogic.random.randi_range(21,25)
						if (trustIncrease+GameLogic.Trust) > 100: trustIncrease = 100-GameLogic.Trust
						GameLogic.Trust += trustIncrease
						var budgetIncrease = GameLogic.BudgetFull*(0.01*GameLogic.Trust)
						GameLogic.BudgetFull += budgetIncrease
						CallManager.CallQueue.append(
							{
								"Header": "Important Information",
								"Level": "Classified",
								"Operation": "-//-",
								"Content": "[b]Congratulations.[/b]\n\nBased on Bureau's intel on " + WorldData.Organizations[w].Name + ", Homeland authorities prevented terrorist attack from happening."+reason + "\n\nBureau gained "+str(int(trustIncrease))+"% of trust. As a confirmation, government increases bureau's budget by €"+str(int(budgetIncrease))+",000.\n",
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
						continue  # prevented
					# it's happenning
					var shortDesc = ""
					var longDesc = ""
					var casualties = 0
					var trustLoss = 0
					var responsibility = ""
					# defining details
					if WorldData.Organizations[w].Known == false and GameLogic.random.randi_range(1,2) == 1:
						WorldData.Organizations[w].Known = true
						WorldData.Organizations[w].IntelValue += 10
						responsibility = "Officers attribute the attack to a new, previously unknown organization: " + WorldData.Organizations[w].Name + "."
					elif WorldData.Organizations[w].Aggression > 70 and GameLogic.random.randi_range(1,2) == 2:
						responsibility = WorldData.Organizations[w].Name + " claimed responsibility. "
						if WorldData.Organizations[w].Known == false:
							WorldData.Organizations[w].Known = true
							WorldData.Organizations[w].IntelValue += 10
						if WorldData.Organizations[w].OpsAgainstHomeland[u].IntelValue <= 0:
							responsibility += "Officers could not confirm this association."
						elif WorldData.Organizations[w].OpsAgainstHomeland[u].IntelValue < 30:
							responsibility += "Officers estimate this association as probable."
						else:
							responsibility += "Officers confirm this association."
					else:
						if WorldData.Organizations[w].OpsAgainstHomeland[u].IntelValue <= 0:
							responsibility = "Officers do not know who perpetuated the attack."
						elif WorldData.Organizations[w].OpsAgainstHomeland[u].IntelValue < 30:
							responsibility = "Officers point to " + WorldData.Organizations[w].Name + " as a probable perpetrator."
						else:
							responsibility = "Officers identified " + WorldData.Organizations[w].Name + " as the perpetrator."
					if WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 98:
						shortDesc = "Large terrorist attack with many casualties"
						casualties = GameLogic.random.randi_range(5000,100000)
						trustLoss = GameLogic.Trust
						# generate a detailed story about specifics later
						longDesc = "a largest terrorist attack in the world history"
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 90:
						shortDesc = "Large terrorist attack with many casualties"
						casualties = GameLogic.random.randi_range(1000,5000)
						trustLoss = GameLogic.Trust*0.95
						if trustLoss < 25: trustLoss = 25
						longDesc = "a large terrorist attack"
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 75:
						shortDesc = "Large terrorist attack with many casualties"
						casualties = GameLogic.random.randi_range(200,1000)
						trustLoss = GameLogic.Trust*0.9
						if trustLoss < 25: trustLoss = 25
						longDesc = "a large terrorist attack"
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 55:
						shortDesc = "Terrorist attack"
						casualties = GameLogic.random.randi_range(100,200)
						trustLoss = GameLogic.Trust*0.9
						if trustLoss < 25: trustLoss = 25
						longDesc = "a terrorist attack"
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 40:
						shortDesc = "Terrorist attack"
						casualties = GameLogic.random.randi_range(50,100)
						trustLoss = GameLogic.Trust*0.9
						if trustLoss < 25: trustLoss = 25
						longDesc = "a terrorist attack"
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 30:
						shortDesc = "Terrorist attack"
						casualties = GameLogic.random.randi_range(10,50)
						trustLoss = GameLogic.Trust*0.9
						if trustLoss < 25: trustLoss = 25
						longDesc = "a terrorist attack"
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 20:
						shortDesc = "Minor terrorist incident"
						casualties = GameLogic.random.randi_range(5,10)
						trustLoss = GameLogic.Trust*0.8
						if trustLoss < 15: trustLoss = 15
						longDesc = "a minor terrorist incident"
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 10:
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
					WorldData.Organizations[w].OpsAgainstHomeland[u].Active = false
					WorldData.Organizations[w].ActiveOpsAgainstHomeland -= 1
					GameLogic.AddWorldEvent(shortDesc+" in Homeland", past)
					CallManager.CallQueue.append(
						{
							"Header": "Important Information",
							"Level": "Unclassified",
							"Operation": "-//-",
							"Content": "[b]The worst has happened.[/b]\n\nHomeland suffered from "+longDesc+". There were "+str(casualties)+" casualties. " + responsibility + "\n\nBureau lost "+str(int(trustLoss))+"% of trust.",
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
		if WorldData.Organizations[w].Type == WorldData.OrgType.GENERALTERROR:
			# number of attacks relies on budget*aggression
			var opFrequency = WorldData.Organizations[w].Aggression
			if WorldData.Organizations[w].Budget < 100: opFrequency *= 0.1
			elif WorldData.Organizations[w].Budget < 1000: opFrequency *= 0.2
			elif WorldData.Organizations[w].Budget < 10000: opFrequency *= 0.4
			elif WorldData.Organizations[w].Budget < 50000: opFrequency *= 0.6
			elif WorldData.Organizations[w].Budget < 100000: opFrequency *= 0.8
			var randFrequency = 120 - opFrequency  # max aggr->20, min aggr->120
			randFrequency *= 0.3  # three times higher frequency, balancing
			if GameLogic.random.randi_range(0,randFrequency) == int(randFrequency*0.5):
				var whichCountry = randi() % WorldData.Countries.size()
				# against other countries: executing right now
				if whichCountry != 0:
					if GameLogic.random.randi_range(1,4) == 3:  # ~3/4 are prevented
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
						desc += WorldData.Countries[whichCountry].Name
						if WorldData.Organizations[w].Known == false and GameLogic.random.randi_range(1,4) == 1:
							WorldData.Organizations[w].Known = true
							WorldData.Organizations[w].IntelValue += 10
							desc += ", local authorities traced back attack to a new organization: " + WorldData.Organizations[w].Name
						elif WorldData.Organizations[w].Aggression > 70 and GameLogic.random.randi_range(1,2) == 2:
							desc += ", " + WorldData.Organizations[w].Name + " claimed responsibility"
							if WorldData.Organizations[w].Known == false:
								WorldData.Organizations[w].Known = true
								WorldData.Organizations[w].IntelValue += 10
						else:
							if GameLogic.random.randi_range(0,100) > WorldData.Countries[whichCountry].IntelFriendliness and WorldData.Organizations[w].Known == true:
								desc += ", local authorities point to " + WorldData.Organizations[w].Name + " as the perpetrator"
							else:
								desc += ", local authorities do not know the perpetrator"
						GameLogic.AddWorldEvent(desc, past)
				# against homeland: just planning for the future
				elif past == null:  # not in the past
					var opSize = GameLogic.random.randi_range(1,10) * 0.1  # 0.0-1.0 of org resources
					var opSecrecy = GameLogic.random.randi_range(WorldData.Organizations[w].Counterintelligence*0.7,100)
					var opDamage = GameLogic.random.randi_range(WorldData.Organizations[w].Aggression*0.2, WorldData.Organizations[w].Aggression)
					var opLength = opDamage*opSize
					if WorldData.Organizations[w].Staff > 10000: opLength += GameLogic.random.randi_range(-30,30)
					elif WorldData.Organizations[w].Staff > 1000: opLength += GameLogic.random.randi_range(-20,20)
					elif WorldData.Organizations[w].Staff > 100: opLength += GameLogic.random.randi_range(-10,10)
					else: opLength += GameLogic.random.randi_range(-5,5)
					if opLength < 4: opLength = 4
					opLength = int(opLength)
					WorldData.Organizations[w].OpsAgainstHomeland.append(WorldData.AnExternalOperation.new(
						{
							"Type": WorldData.ExtOpType.TERRORIST_ATTACK,
							"Budget": int(WorldData.Organizations[w].Budget * opSize),
							"Persons": int(WorldData.Organizations[w].Staff * 0.5 * opSize),
							"Secrecy": int(opSecrecy),
							"Damage": int(opDamage),
							"FinishCounter": opLength,
						}
					))
					WorldData.Organizations[w].ActiveOpsAgainstHomeland += 1
					print("new op against homeland: "+str(opLength))
					# most (but not all!) operations are vaguely communicated to the player
					if GameLogic.random.randi_range(1,10) < 8:
						GameLogic.AttackTicker = opLength  # main screen ticker
						GameLogic.AttackTickerOp.Org = w
						GameLogic.AttackTickerOp.Op = len(WorldData.Organizations[w].OpsAgainstHomeland)-1
						CallManager.CallQueue.append(
							{
								"Header": "Important Information",
								"Level": "Top Secret",
								"Operation": "-//-",
								"Content": "General signal surveillance picked up chatter involving possible terrorist attacks and Homeland. After careful investigation, officers deduced that the attack can happen in "+str(opLength)+" weeks. Bureau has to do everything it can to stop that from happening.",
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
		# sources
		if len(WorldData.Organizations[w].IntelSources) > 0:
			# modifying every source
			var sumOfLevels = 0.0
			var highestLevel = 0
			var sourceLoss = -1
			for s in range(0,len(WorldData.Organizations[w].IntelSources)):
				# fluctuate trust
				WorldData.Organizations[w].IntelSources[s].Trust += GameLogic.random.randi_range(-1,1)
				if WorldData.Organizations[w].IntelSources[s].Trust < 1:
					sourceLoss = w
					continue
				# fluctuate level
				if GameLogic.random.randi_range(1,3) == 2:
					WorldData.Organizations[w].IntelSources[s].Level += GameLogic.random.randi_range(-1,1)
				# noting levels for joint intel
				sumOfLevels += WorldData.Organizations[w].IntelSources[s].Level
				if highestLevel < WorldData.Organizations[w].IntelSources[s].Level:
					highestLevel = WorldData.Organizations[w].IntelSources[s].Level
			# eventual source loss
			if sourceLoss != -1:
				WorldData.Organizations[w].IntelSources.remove(sourceLoss)
				GameLogic.AddEvent('Bureau lost source in ' + WorldData.Organizations[w].Name)
			# providing joint intel from all sources, every 8 weeks on average
			if GameLogic.random.randi_range(1,8) == 4:
				var localCall = WorldIntel.GatherOnOrg(w, highestLevel*(0.9+len(WorldData.Organizations[w].IntelSources)*0.1), GameLogic.GiveDateWithYear())
				if localCall == true: doesItEndWithCall = true
	return doesItEndWithCall
