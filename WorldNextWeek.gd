extends Node

func Execute(past):
	var doesItEndWithCall = false
	############################################################################
	# progressing to elections
	for c in range(0, len(WorldData.Countries)):
		if WorldData.Countries[c].Size == 0: continue  # no country
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
					GameLogic.SetUpNewPriorities(false)
					eventualDesc = "Incumbent won, achieving "+str(won)+"%. Government will largely stay in the same shape, continuing similar foreign policy, and preserving existing approach to intelligence services.\n\nUpdated list of priorities given by the government:\n- " + GameLogic.ListPriorities("\n- ")
			else:
				GameLogic.AddWorldEvent("Elections in " + WorldData.Countries[c].Name + ": New government formed, achieving "+str(won)+"%", past)
				WorldData.Countries[c].ElectionProgress = WorldData.Countries[c].ElectionPeriod
				WorldData.Countries[c].PoliticsIntel = GameLogic.random.randi_range(10,90)
				WorldData.Countries[c].PoliticsAggression += GameLogic.random.randi_range(-15,15)
				WorldData.Countries[c].PoliticsStability += GameLogic.random.randi_range(won,90)
				for d in range(0, len(WorldData.Countries)):
					WorldData.DiplomaticRelations[c][d] += GameLogic.random.randi_range(-10,10)
				if c == 0:
					GameLogic.SetUpNewPriorities(true)
					var newApproach = "unfavourable"
					var eventualIncrease = ""
					if WorldData.Countries[c].PoliticsIntel > 60:
						newApproach = "friendly"
						eventualIncrease = "As a mark of a new start, bureau's budget is increased by €" + str(int(GameLogic.BudgetFull*0.2)) + ",000."
						GameLogic.BudgetFull *= 1.2
					elif WorldData.Countries[c].PoliticsIntel > 30: newApproach = "neutral"
					eventualDesc = "New government formed, achieving "+str(won)+"%. Its approach towards intelligence services can be described as " + newApproach + ". " + eventualIncrease + "\n\nNew list of priorities given by the government:\n- " + GameLogic.ListPriorities("\n- ")
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
	############################################################################
	# eventual wars
	for v in range(0, len(WorldData.Wars)):
		if WorldData.Wars[v].Active == false: continue
		var c = WorldData.Wars[v].CountryA
		var c2 = WorldData.Wars[v].CountryB
		# progress
		WorldData.Wars[v].WeeksPassed += 1
		# first week could resolve the war if any of powers have wmd
		# externally, because anti-homeland wmd is dealt further below
		if WorldData.Wars[v].WeeksPassed == 1 and c != 0 and c2 != 0 and GameLogic.TurnOnWMD == true:
			var firstHasWMD = false
			var secondHasWMD = false
			if GameLogic.random.randi_range(60,95) < WorldData.Countries[c].WMDProgress:
				firstHasWMD = true
			if GameLogic.random.randi_range(60,95) < WorldData.Countries[c2].WMDProgress:
				secondHasWMD = true
			var arrOfLost = []
			if firstHasWMD == true and secondHasWMD == true:
				arrOfLost.append(c)
				arrOfLost.append(c2)
				WorldData.Wars[v].Active = false
				GameLogic.AddWorldEvent("In nuclear conflict, " + WorldData.Countries[c].Name + " and " + WorldData.Countries[c2].Name + " mutually annihiliated themselves", past)
			elif firstHasWMD == true and secondHasWMD == false:
				arrOfLost.append(c2)
				WorldData.Countries[c].SoftPower *= 1.3
				WorldData.Countries[c].InStateOfWar = false
				WorldData.Wars[v].Active = false
				GameLogic.AddWorldEvent(WorldData.Countries[c].Name + " annihiliated " + WorldData.Countries[c2].Name + " using weapons of mass destruction", past)
			elif firstHasWMD == false and secondHasWMD == true:
				arrOfLost.append(c)
				WorldData.Countries[c2].SoftPower *= 1.3
				WorldData.Countries[c2].InStateOfWar = false
				WorldData.Wars[v].Active = false
				GameLogic.AddWorldEvent(WorldData.Countries[c2].Name + " annihiliated " + WorldData.Countries[c].Name + " using weapons of mass destruction", past)
			for k in arrOfLost:
				WorldData.Countries[k].Size = 0
				WorldData.Countries[k].SoftPower = 0
				WorldData.Countries[k].InStateOfWar = false
			# destroy all organizations inside
			if len(arrOfLost) > 0:
				for g in range(0, len(WorldData.Organizations)):
					if WorldData.Organizations[g].Active == false: continue
					if len(WorldData.Organizations[g].Countries) == 1:
						if WorldData.Organizations[g].Countries[0] in arrOfLost:
							WorldData.Organizations[g].Active = false
					else:
						for u in arrOfLost:
							if u in WorldData.Organizations[g].Countries:
								WorldData.Organizations[g].Countries.remove(WorldData.Organizations[g].Countries.find(u))
			# plus lose officers assisting evacuation if there are any
			if c != 0 and c2 != 0 and past == null and GameLogic.OfficersAbroad > 0 and len(arrOfLost) > 0:
				var whereNames = []
				for j in arrOfLost: whereNames.append(WorldData.Countries[j].Name)
				GameLogic.AddEvent(str(int(GameLogic.OfficersAbroad*(0.5*len(arrOfLost)))) + " died in nuclear war, during evacuation in " + PoolStringArray(whereNames).join(" and "))
				GameLogic.ActiveOfficers -= int(GameLogic.OfficersAbroad*(0.5*len(arrOfLost)))
				GameLogic.OfficersAbroad -= int(GameLogic.OfficersAbroad*(0.5*len(arrOfLost)))
				GameLogic.StaffExperience -= GameLogic.StaffExperience*(0.5*len(arrOfLost))
				GameLogic.StaffSkill -= GameLogic.StaffSkill*(0.5*len(arrOfLost))
				GameLogic.StaffTrust -= GameLogic.StaffTrust*(0.5*len(arrOfLost))
			# war finished
			if len(arrOfLost) > 0:
				continue
		# after first week of external war, officers should return
		if WorldData.Wars[v].WeeksPassed == 1 and c != 0 and c2 != 0 and past == null:
			if GameLogic.OfficersAbroad > 0:
				GameLogic.OfficersInHQ = GameLogic.OfficersAbroad
				GameLogic.OfficersAbroad = 0
				GameLogic.AddEvent(str(GameLogic.OfficersInHQ) + " officers returned to Homeland")
		# the usual ordeal
		var communicated = false  # to a void two world events in a week
		var warFinished = false
		var howWarFinished = -1  # for user, 0=peace, 1=c won, 2=c2 won
		var power1 = WorldData.Countries[c].SoftPower + GameLogic.random.randi_range(-20,20) + WorldData.Countries[c].Size*0.3
		var power2 = WorldData.Countries[c2].SoftPower + GameLogic.random.randi_range(-20,20) + WorldData.Countries[c].Size*0.3
		var diff = WorldData.Countries[c].SoftPower - WorldData.Countries[c2].SoftPower
		var pastResult = WorldData.Wars[v].Result
		if power1 > power2:
			if diff > 0: WorldData.Wars[v].Result += diff*(0.1*GameLogic.random.randi_range(5,10))
			else: WorldData.Wars[v].Result += GameLogic.random.randi_range(1,15)
		else:
			if diff < 0: WorldData.Wars[v].Result += diff*(0.1*GameLogic.random.randi_range(5,10))
			else: WorldData.Wars[v].Result += GameLogic.random.randi_range(-15,-1)
		var newResult = WorldData.Wars[v].Result
		if (newResult-pastResult) > 20:
			GameLogic.AddWorldEvent(WorldData.Countries[c].Name + WorldData.WarPhrases[randi() % WorldData.WarPhrases.size()] + WorldData.Countries[c2].Name, past)
			communicated = true
		elif (newResult-pastResult) < -20:
			GameLogic.AddWorldEvent(WorldData.Countries[c2].Name + WorldData.WarPhrases[randi() % WorldData.WarPhrases.size()] + WorldData.Countries[c].Name, past)
			communicated = true
		# eventual peace treaty
		var sumOfAggression = WorldData.Countries[c].PoliticsAggression + WorldData.Countries[c2].PoliticsAggression  # max 200
		if GameLogic.random.randi_range(1,200) > sumOfAggression and GameLogic.random.randi_range(1,5)==3:
			WorldData.Wars[v].Active = false
			communicated = true
			warFinished = true
			howWarFinished = 0
			# even
			if WorldData.Wars[v].Result < 20 and WorldData.Wars[v].Result > -20:
				GameLogic.AddWorldEvent(WorldData.Countries[c].Name + " signed peace treaty with " + WorldData.Countries[c2].Name, past)
				WorldData.Countries[c].SoftPower *= 1.1
				WorldData.Countries[c2].SoftPower *= 1.1
				WorldData.Countries[c].InStateOfWar = false
				WorldData.Countries[c2].InStateOfWar = false
				WorldData.DiplomaticRelations[c][c2] = 0
				WorldData.DiplomaticRelations[c2][c] = 0
			# uneven ones
			elif WorldData.Wars[v].Result >= 20:
				GameLogic.AddWorldEvent(WorldData.Countries[c2].Name + " signed peace agreement dictated by " + WorldData.Countries[c].Name, past)
				WorldData.Countries[c].SoftPower *= 1.2
				WorldData.Countries[c2].SoftPower *= 0.8
				WorldData.Countries[c].InStateOfWar = false
				WorldData.Countries[c2].InStateOfWar = false
				WorldData.DiplomaticRelations[c][c2] = -10
				WorldData.DiplomaticRelations[c2][c] = -10
			else:  # equivalent to elif WorldData.Wars[v].Result <= -20:
				GameLogic.AddWorldEvent(WorldData.Countries[c].Name + " signed peace agreement dictated by " + WorldData.Countries[c2].Name, past)
				WorldData.Countries[c].SoftPower *= 0.8
				WorldData.Countries[c2].SoftPower *= 1.2
				WorldData.Countries[c].InStateOfWar = false
				WorldData.Countries[c2].InStateOfWar = false
				WorldData.DiplomaticRelations[c][c2] = -10
				WorldData.DiplomaticRelations[c2][c] = -10
		# conventional finish
		if WorldData.Wars[v].Result >= 100 or WorldData.Wars[v].Result <= -100:
			communicated = true
			warFinished = true
			var won = c
			howWarFinished = 1
			var lost = c2
			if WorldData.Wars[v].Result <= -100:
				won = c2
				howWarFinished = 2
				lost = c
			GameLogic.AddWorldEvent(WorldData.Countries[won].Name + " won war with " + WorldData.Countries[lost].Name, past)
			WorldData.Wars[v].Active = false
			WorldData.Countries[won].Size *= 1.2
			WorldData.Countries[lost].Size *= 0.5
			WorldData.Countries[won].SoftPower *= 1.3
			WorldData.Countries[lost].SoftPower *= 0.6
			WorldData.Countries[won].InStateOfWar = false
			WorldData.Countries[lost].InStateOfWar = false
			WorldData.DiplomaticRelations[won][lost] = -20
			WorldData.DiplomaticRelations[lost][won] = -20
		# eventual communicates
		if communicated == false and GameLogic.random.randi_range(1,3) <= 2:
			if (newResult-pastResult) > 5:
				GameLogic.AddWorldEvent("War between " + WorldData.Countries[c].Name + " and " + WorldData.Countries[c2].Name + ": slight progress of " + WorldData.Countries[c].Name, past)
			elif (newResult-pastResult) < -5:
				GameLogic.AddWorldEvent("War between " + WorldData.Countries[c].Name + " and " + WorldData.Countries[c2].Name + ": slight progress of " + WorldData.Countries[c2].Name, past)
			else:
				GameLogic.AddWorldEvent("War between " + WorldData.Countries[c].Name + " and " + WorldData.Countries[c2].Name + ": stalemate", past)
		# homeland wmd war finish
		if GameLogic.TurnOnWMD == true and WorldData.Wars[v].WeeksPassed == 1 and (c == 0 or c2 == 0):
			var against = c
			if c == 0: against = c2
			if GameLogic.random.randi_range(50,90) < WorldData.Countries[against].WMDProgress:
				# nuclear loss, game over
				CallManager.CallQueue.append(
					{
						"Header": "Important Information",
						"Level": "Unclassified",
						"Operation": "-//-",
						"Content": "[b]Homeland was annihilated by " + WorldData.Countries[against].Name + " with weapons of mass destruction.[/b]\n\nBureau did not foresee the danger and did not provide useful, reliable enough intel to inform decision about engaging in the war.",
						"Show1": false,
						"Show2": false,
						"Show3": false,
						"Show4": true,
						"Text1": "",
						"Text2": "",
						"Text3": "",
						"Text4": "Game Over",
						"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision1Argument": null,
						"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision2Argument": null,
						"Decision3Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision3Argument": null,
						"Decision4Callback": funcref(GameLogic, "FinalQuit"),
						"Decision4Argument": null,
					}
				)
				doesItEndWithCall = true
		# homeland conventional war finish
		elif warFinished == true:
			if c == 0 or c2 == 0:
				var against = c
				if c == 0: against = c2
				WorldData.Countries[against].DiplomaticTravel = true
				for x in range(0,len(WorldData.Organizations)):
					if WorldData.Organizations[x].Countries[0] == against:
						WorldData.Organizations[x].OffensiveClearance = false
				var content = ""
				if howWarFinished == 0:
					# peace
					content = "[b]Homeland reached peace agreement with " + WorldData.Countries[against].Name + ", finishing the war.[/b]\n\nDiplomatic ties were reestablished. Offensive clearance against all " + WorldData.Countries[against].Adjective + " targets was revoked."
				elif (c == 0 and howWarFinished == 1) or (c2 == 0 and howWarFinished == 2):
					# win
					GameLogic.Trust += 10
					WorldData.Countries[0].Size *= 1.2
					WorldData.Countries[against].Size *= 0.5
					for x in range(0,len(WorldData.Organizations)):
						if WorldData.Organizations[x].Countries[0] == against:
							if WorldData.Organizations[x].Type == WorldData.OrgType.GOVERNMENT or WorldData.Organizations[x].Type == WorldData.OrgType.INTEL or WorldData.Organizations[x].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE or WorldData.Organizations[x].Type == WorldData.OrgType.UNIVERSITY:
								WorldIntel.GatherOnOrg(x, 100, GameLogic.GiveDateWithYear(), true)
					content = "[b]Homeland won war with " + WorldData.Countries[against].Name + ".[/b]\n\n" + WorldData.Countries[against].Name + " continues existence as a smaller, independent country. Homeland authorities captured wealth of intel from all " + WorldData.Countries[against].Adjective + " institutions, increasing our technological capabilities and knowledge about other organizations existing in the world."
					WorldData.Countries[against].Size *= 0.5
					GameLogic.Achievements.append("supported Homeland in war with " + WorldData.Countries[against].Name)
				else:
					# loss
					GameLogic.BudgetFull *= 0.3
					var half = int(GameLogic.ActiveOfficers*0.5)
					GameLogic.ActiveOfficers -= half
					GameLogic.OfficersInHQ -= half
					GameLogic.Trust -= 10
					WorldData.Countries[against].Size *= 1.2
					WorldData.Countries[0].Size *= 0.5
					content = "[b]Homeland lost war with " + WorldData.Countries[against].Name + ".[/b]\n\nOur country will continue existence as a smaller, independent state. " + WorldData.Countries[against].Adjective + " authorities captured all Bureau's intel, leading to loss of all networks and sources. In addition, budget was severely restricted and half of the staff was lost due to wartime turmoil, resignations, fleeing from the country, and other reasons."
					WorldData.Countries[0].Size *= 0.5
				CallManager.CallQueue.append(
					{
						"Header": "Important Information",
						"Level": "Classified",
						"Operation": "-//-",
						"Content": content,
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
	############################################################################
	# countries
	for c in range(0, len(WorldData.Countries)):
		# variable constraints
		if WorldData.Countries[c].KnowhowLanguage > 100: WorldData.Countries[c].KnowhowLanguage = 100
		if WorldData.Countries[c].KnowhowCustoms > 100: WorldData.Countries[c].KnowhowCustoms = 100
		# parameter fluctations
		if GameLogic.random.randi_range(1,5) == 2:  # ~one per month
			WorldData.Countries[c].Size *= (1.0+GameLogic.random.randi_range(-1,1)*0.01)
			WorldData.Countries[c].IntelFriendliness += GameLogic.random.randi_range(-1,1)
			WorldData.Countries[c].SoftPower += GameLogic.random.randi_range(-1,1)
		if WorldData.Countries[c].Network > 0:
			if GameLogic.random.randi_range(1,20) == 6: WorldData.Countries[c].Network -= 1
			if WorldData.Countries[c].Network == 0:
				GameLogic.AddEvent("Bureau lost agent network in " + WorldData.Countries[c].Name)
				GameLogic.BudgetExtras *= 0.95
		# stability
		var choice = GameLogic.random.randi_range(0,70)
		if WorldData.Countries[c].PoliticsStability < 20:
			choice = GameLogic.random.randi_range(0,20)
			if choice > WorldData.Countries[c].PoliticsStability and GameLogic.random.randi_range(0,20) == 1:
				GameLogic.AddWorldEvent("Government resigned in " + WorldData.Countries[c].Name, past)
				WorldData.Countries[c].ElectionProgress = 0
				WorldData.Countries[c].SoftPower -= 1
		elif choice > WorldData.Countries[c].PoliticsStability and GameLogic.random.randi_range(0,40) == 2:
			if GameLogic.random.randi_range(1,3) == 2:
				GameLogic.AddWorldEvent("Protests against government in " + WorldData.Countries[c].Name, past)
			else:
				GameLogic.AddWorldEvent("Decrease of government stability in " + WorldData.Countries[c].Name, past)
			WorldData.Countries[c].PoliticsStability -= GameLogic.random.randi_range(5,15)
			WorldData.Countries[c].SoftPower -= 0.5
		# individual diplomatic events
		if GameLogic.random.randi_range(0,4) == 0:
			var affected = GameLogic.random.randi_range(0, len(WorldData.Countries)-1)
			if c == affected:
				continue  # don't act on itself
			var change = GameLogic.random.randi_range((WorldData.DiplomaticRelations[c][affected]-30.0)/10, (WorldData.DiplomaticRelations[c][affected]+30.0)/10)
			if GameLogic.random.randi_range(0,15) == 9:  # rare larger change
				change = GameLogic.random.randi_range((WorldData.DiplomaticRelations[c][affected]-30.0)/4, (WorldData.DiplomaticRelations[c][affected]+30.0)/4)
			WorldData.DiplomaticRelations[c][affected] += change
			WorldData.DiplomaticRelations[affected][c] += change
			if GameLogic.random.randi_range(0,30) == 7:  # publicly known
				if change < 0 and WorldData.DiplomaticRelations[c][affected] > -30:
					GameLogic.AddWorldEvent(WorldData.Countries[c].Name + WorldData.DiplomaticPhrasesNegative[randi() % WorldData.DiplomaticPhrasesNegative.size()] + WorldData.Countries[affected].Name, past)
				elif change < 0 and WorldData.DiplomaticRelations[c][affected] <= -30:
					GameLogic.AddWorldEvent(WorldData.Countries[c].Name + WorldData.DiplomaticPhrasesVeryNegative[randi() % WorldData.DiplomaticPhrasesNegative.size()] + WorldData.Countries[affected].Name, past)
				elif change > 0 and WorldData.DiplomaticRelations[c][affected] < 30:
					GameLogic.AddWorldEvent(WorldData.Countries[c].Name + WorldData.DiplomaticPhrasesPositive[randi() % WorldData.DiplomaticPhrasesPositive.size()] + WorldData.Countries[affected].Name, past)
				elif change > 0 and WorldData.DiplomaticRelations[c][affected] >= 30:
					GameLogic.AddWorldEvent(WorldData.Countries[c].Name + WorldData.DiplomaticPhrasesVeryPositive[randi() % WorldData.DiplomaticPhrasesPositive.size()] + WorldData.Countries[affected].Name, past)
		# conflict situations
		if GameLogic.random.randi_range(0,4) == 3:
			var c2 = GameLogic.random.randi_range(0, len(WorldData.Countries)-1)
			if c == c2:
				continue  # don't act on itself
			if GameLogic.TurnOnWars == true and WorldData.DiplomaticRelations[c][c2] <= -85:
				# war
				# only one external war per year
				if GameLogic.YearlyWars != 0 and c != 0 and c2 != 0:
					continue
				GameLogic.YearlyWars += 1
				# before engaging homeland, risk of war is defined by wmd
				if GameLogic.TurnOnWMD == true and (c == 0 or c2 == 0):
					if past != null: continue  # no wars in the past
					var against = c
					if c == 0: against = c2
					if WorldData.Countries[against].WMDProgress < 50:
						continue  # no real wmd
					if WorldData.Countries[against].WMDIntel > 50:
						WorldData.DiplomaticRelations[c][c2] += 15
						WorldData.DiplomaticRelations[c2][c] += 15
						continue  # never enter a war
					elif WorldData.Countries[against].WMDIntel > 25:
						WorldData.DiplomaticRelations[c][c2] += 10
						WorldData.DiplomaticRelations[c2][c] += 10
						if GameLogic.random.randi_range(1,5) == 2: continue  # rarely enter the war
					elif WorldData.Countries[against].WMDIntel > 0:
						WorldData.DiplomaticRelations[c][c2] += 5
						WorldData.DiplomaticRelations[c2][c] += 5
						if GameLogic.random.randi_range(1,2) == 1: continue  # sometimes enter the war
				# actual war
				if GameLogic.random.randi_range(1,5) == 4:
					# homeland involved
					if (c == 0 or c2 == 0) and past == null:
						WorldData.Wars.append(WorldData.aNewWar({"CountryA": c, "CountryB": c2}))
						GameLogic.AddWorldEvent("War began between " + WorldData.Countries[c].Name + " and " + WorldData.Countries[c2].Name, past)
						WorldData.Countries[c].InStateOfWar = true
						WorldData.Countries[c2].InStateOfWar = true
						var against = c
						if c == 0: against = c2
						WorldData.Countries[against].DiplomaticTravel = false
						if WorldData.Countries[against].Station > 0:
							GameLogic.AddEvent(WorldData.Countries[against].Adjective + " intelligence station was evacuated, " + str(int(WorldData.Countries[against].Station)) + " officers returned")
							GameLogic.ActiveOfficers += WorldData.Countries[against].Station
							GameLogic.OfficersInHQ += WorldData.Countries[against].Station
							WorldData.Countries[against].Station = 0
						for x in range(0,len(WorldData.Organizations)):
							if WorldData.Organizations[x].Countries[0] == against:
								WorldData.Organizations[x].OffensiveClearance = true
						CallManager.CallQueue.append(
							{
								"Header": "Important Information",
								"Level": "Classified",
								"Operation": "-//-",
								"Content": "[b]Homeland entered war with " + WorldData.Countries[against].Name + ".[/b]\n\nDiplomatic ties were severed, travel to embassy is no longer possible.\n\nBureau received offensive clearance against all " + WorldData.Countries[against].Adjective + " targets. Any damage inflicted on their organizations will be extremely valuable in war effort. Bureau should focus on civilian targets, such as the government or high-technology organizations.\n\nBe aware that operations inside war theater are extraordinarily risky.",
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
					# external war
					elif c != 0 and c2 != 0 and past == null:
						WorldData.Wars.append(WorldData.aNewWar({"CountryA": c, "CountryB": c2}))
						GameLogic.AddWorldEvent("War began between " + WorldData.Countries[c].Name + " and " + WorldData.Countries[c2].Name, past)
						WorldData.Countries[c].InStateOfWar = true
						WorldData.Countries[c2].InStateOfWar = true
						# calling ff operations
						for q in range(0, len(GameLogic.Operations)):
							if GameLogic.Operations[q].Stage <= 2:
								GameLogic.Operations[q].Stage = OperationGenerator.Stage.CALLED_OFF
								GameLogic.Operations[q].Result = "CALLED OFF"
								if GameLogic.Operations[q].AbroadPlan != null:
									GameLogic.OfficersInHQ += GameLogic.Operations[q].AbroadPlan.Officers
									GameLogic.OfficersAbroad -= GameLogic.Operations[q].AbroadPlan.Officers
									GameLogic.BudgetOngoingOperations -= GameLogic.Operations[q].AbroadPlan.Cost
								GameLogic.PursuedOperations -= 1
						if GameLogic.OfficersInHQ > 0:
							GameLogic.AddEvent("All operations were called off")
							GameLogic.AddEvent(str(GameLogic.OfficersInHQ) + " officer(s) departed to assist in wartime evacuation")
							GameLogic.OfficersAbroad = GameLogic.OfficersInHQ
							GameLogic.OfficersInHQ = 0
							for d in range(0, len(GameLogic.Directions)):
								if GameLogic.Directions[d].Active == false: continue
								GameLogic.Directions[d].LengthCounter += 2
						# ensuring that calls related to ops are not presented
						if len(CallManager.CallQueue) > 0:
							var toRemove = -1
							for q in range(0, len(CallManager.CallQueue)):
								if len(CallManager.CallQueue[q].Operation) > 4:  # not -//-
									toRemove = q
							if toRemove != -1: CallManager.CallQueue.remove(toRemove)
						# debriefing
						CallManager.CallQueue.append(
							{
								"Header": "Important Information",
								"Level": "Classified",
								"Operation": "-//-",
								"Content": WorldData.Countries[c].Name + " and " + WorldData.Countries[c2].Name + " began military conflict.\n\nAll ongoing operations were called off and the officers were send for a week to assist the evacuation of our personnel.\n\nAvoid further operations in this theater until the end of war.",
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
			elif WorldData.DiplomaticRelations[c][c2] < -30:
				# pre-war
				if GameLogic.TurnOnWars == true and WorldData.DiplomaticRelations[c][c2] <= -80 and GameLogic.random.randi_range(1,3)==2:
					GameLogic.AddWorldEvent(WorldData.Countries[c].Name + " and " + WorldData.Countries[c2].Name + " are on the brink of war", past)
				# hostile
				if GameLogic.random.randi_range(1,4) == 1:
					var power1 = WorldData.Countries[c].SoftPower + GameLogic.random.randi_range(-10,10)
					var power2 = WorldData.Countries[c2].SoftPower + GameLogic.random.randi_range(-10,10)
					# features of gov with more soft power decide
					var d = c
					if power1 < power2: d = c2
					if GameLogic.random.randi_range(0,100) > WorldData.Countries[d].PoliticsStability and GameLogic.random.randi_range(0,100) < WorldData.Countries[d].PoliticsAggression:
						WorldData.DiplomaticRelations[c][c2] -= 5
						WorldData.DiplomaticRelations[c2][c] -= 5
						if GameLogic.random.randi_range(1,2) == 2 or c == 0 or c2 == 0:
							GameLogic.AddWorldEvent("Tensions rise between " + WorldData.Countries[c].Name + " and " + WorldData.Countries[c2].Name, past)
					else:
						WorldData.DiplomaticRelations[c][c2] += 5
						WorldData.DiplomaticRelations[c2][c] += 5
			else:
				# normal relations: negotiations etc
				var power1 = WorldData.Countries[c].SoftPower + GameLogic.random.randi_range(-10,10)
				var power2 = WorldData.Countries[c2].SoftPower + GameLogic.random.randi_range(-10,10)
				var toLower = c
				var toIncrease = c2
				if power1 > power2:
					toLower = c2
					toIncrease = c
					WorldData.Countries[c].SoftPower += 1
				for y in range(0, len(WorldData.Countries)):
					WorldData.DiplomaticRelations[toLower][y] -= 1
					WorldData.DiplomaticRelations[y][toLower] -= 1
					WorldData.DiplomaticRelations[toIncrease][y] += 1
					WorldData.DiplomaticRelations[y][toIncrease] += 1
	############################################################################
	# country summits
	if GameLogic.random.randi_range(0,40) == 12:
		# getting participants
		var howmany = GameLogic.random.randi_range(2,6)
		var participants = []
		var safetyCounter = 0
		while len(participants) < howmany and safetyCounter < howmany*5:
			safetyCounter += 1
			var try = GameLogic.random.randi_range(0, len(WorldData.Countries)-1)
			if !(try in participants):
				participants.append(try)
		if len(participants) > 1:
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
			if theSum > 0:
				message += "governments issued a joint statement"
				for p in participants:
					WorldData.Countries[p].SoftPower += 3
			else:
				message += "governments could not reach consensus"
				for p in participants:
					WorldData.Countries[p].SoftPower -= 1.5
			GameLogic.AddWorldEvent(message, past)
	############################################################################
	# organization proceedings
	for w in range(0,len(WorldData.Organizations)):
		if WorldData.Organizations[w].Active == false:
			continue
		# intel decay
		if WorldData.Organizations[w].IntelValue > 0:
			WorldData.Organizations[w].IntelValue *= 0.99  # ~4%/month, ~40%/year
		# technology decay
		if WorldData.Organizations[w].Technology > 0:
			WorldData.Organizations[w].Technology *= 0.999  # ~0.4%/month, ~4%/year
		# change of visibility
		if WorldData.Organizations[w].Known == false:
			WorldData.Organizations[w].UndercoverCounter -= 1
			if WorldData.Organizations[w].UndercoverCounter <= 0 and GameLogic.random.randi_range(1,5) == 3:
				WorldData.Organizations[w].Known = true
				WorldData.Organizations[w].IntelValue += 10
				if WorldData.Organizations[w].Type == WorldData.OrgType.GENERALTERROR:
					GameLogic.AddWorldEvent("New suspected terrorist organization, " + WorldData.Organizations[w].Name + ", discovered in " + WorldData.Countries[WorldData.Organizations[w].Countries[0]].Name, past)
				elif WorldData.Organizations[w].Type == WorldData.OrgType.ARMTRADER:
					GameLogic.AddWorldEvent("New suspected arms dealer, " + WorldData.Organizations[w].Name + ", discovered in " + WorldData.Countries[WorldData.Organizations[w].Countries[0]].Name, past)
		# staff and budget and aggression changes
		if GameLogic.random.randi_range(1,4) == 2:  # ~one per month
			WorldData.Organizations[w].Budget *= (1.0+GameLogic.random.randi_range(-1,1)*0.01)
			WorldData.Organizations[w].Aggression += GameLogic.random.randi_range(-2,2)*0.5
			if WorldData.Organizations[w].Staff > 100:  # large orgs
				WorldData.Organizations[w].Staff *= (1.0+GameLogic.random.randi_range(-1,1)*0.01)
			else:  # small orgs
				WorldData.Organizations[w].Staff += GameLogic.random.randi_range(-1,1)
				if WorldData.Organizations[w].Staff < 1: WorldData.Organizations[w].Staff = 1
		# technology changes
		if WorldData.Organizations[w].Type == WorldData.OrgType.COMPANY or WorldData.Organizations[w].Type == WorldData.OrgType.UNIVERSITY:
			if GameLogic.random.randi_range(1,150) == 123:  # seems rare but p*20
				if GameLogic.random.randi_range(20,100) < WorldData.Organizations[w].Technology:
					# better technology leads to more frequent discoveries
					WorldData.Organizations[w].Technology += GameLogic.random.randi_range(15,35)
					GameLogic.AddWorldEvent(WorldData.TechnologicalPhrases[ randi() % WorldData.TechnologicalPhrases.size() ] + " in " + WorldData.Countries[WorldData.Organizations[w].Countries[0]].Name, past)
		elif WorldData.Organizations[w].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE:
			# in addition to own tech changes, it also changes country's wmd capabilities
			if GameLogic.TurnOnWMD == true:
				# plus ~26% over a year when factor is 1.0
				WorldData.Countries[WorldData.Organizations[w].Countries[0]].WMDProgress += WorldData.Organizations[w].Technology*0.008 * WorldData.Countries[WorldData.Organizations[w].Countries[0]].WMDProgressFactor
				if WorldData.Countries[WorldData.Organizations[w].Countries[0]].WMDProgress > 100:
					WorldData.Countries[WorldData.Organizations[w].Countries[0]].WMDProgress = 100
			if GameLogic.random.randi_range(1,70) == 25:
				WorldData.Organizations[w].Technology += GameLogic.random.randi_range(1,7)
		elif WorldData.Organizations[w].Type == WorldData.OrgType.INTEL:
			if GameLogic.random.randi_range(1,100) < WorldData.Countries[WorldData.Organizations[w].Countries[0]].SoftPower and GameLogic.random.randi_range(1,9) == 3:
				WorldData.Organizations[w].Technology += 1
		# rare place changes
		if WorldData.Organizations[w].Type == WorldData.OrgType.GENERALTERROR or WorldData.Organizations[w].Type == WorldData.OrgType.ARMTRADER:
			if GameLogic.random.randi_range(1,55) == 25 and WorldData.Organizations[w].Budget > 1000:
				var trying = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
				if !(trying in WorldData.Organizations[w].Countries):
					WorldData.Organizations[w].Countries.append(trying)
		########################################################################
		# continuing existing operations
		for u in range(0,len(WorldData.Organizations[w].OpsAgainstHomeland)):
			if WorldData.Organizations[w].Type != WorldData.OrgType.GENERALTERROR:
				continue  # deal with non-terror in other places
			if GameLogic.TurnOnTerrorist == false:
				continue
			if WorldData.Organizations[w].OpsAgainstHomeland[u].Active == false:
				continue
			WorldData.Organizations[w].OpsAgainstHomeland[u].FinishCounter -= 1
			if WorldData.Organizations[w].OpsAgainstHomeland[u].FinishCounter <= 0:
				var typeDesc = "terrorist attack inside our country"
				if WorldData.Organizations[w].OpsAgainstHomeland[u].Type == WorldData.ExtOpType.EMBASSY_TERRORIST_ATTACK:
					typeDesc = "terrorist attack against our embassy"
				elif WorldData.Organizations[w].OpsAgainstHomeland[u].Type == WorldData.ExtOpType.PLANE_HIJACKING:
					typeDesc = "hijacking airplane with our citizens"
				elif WorldData.Organizations[w].OpsAgainstHomeland[u].Type == WorldData.ExtOpType.LEADER_ASSASSINATION:
					typeDesc = "terrorist attack targeting our leaders"
				elif WorldData.Organizations[w].OpsAgainstHomeland[u].Type == WorldData.ExtOpType.LEADER_ASSASSINATION:
					typeDesc = "murder of our kidnapped citizen"
				# clearing up mess with many attacks at the same time
				var tickerDesc = ""
				if GameLogic.AttackTicker != 0 and (GameLogic.AttackTickerOp.Org != w or GameLogic.AttackTickerOp.Op != u):
					tickerDesc = "\n\nNote that this is a different plot than reported in dashboard. Homeland is facing more than one attack, possibly happenning in " + str(GameLogic.AttackTicker) + " weeks."
				# decide if it's happenning: prevented or not
				var knownInvolvedValue = WorldData.Organizations[w].OpsAgainstHomeland[u].Persons * (WorldData.Organizations[w].IntelIdentified*1.0 / WorldData.Organizations[w].Staff)
				if ((int(knownInvolvedValue) >= int(WorldData.Organizations[w].OpsAgainstHomeland[u].Persons*0.6) or GameLogic.random.randi_range(10,100) < WorldData.Organizations[w].OpsAgainstHomeland[u].IntelValue)) and WorldData.Organizations[w].Known == true and WorldData.Organizations[w].OpsAgainstHomeland[u].Type != WorldData.ExtOpType.KIDNAPPING_AND_MURDER:
					var reason = ""
					if knownInvolvedValue > 0 and knownInvolvedValue < 20:
						reason += "Law enforcement caught " + str(int(knownInvolvedValue)) + " terrorists. "
						WorldData.Organizations[w].Staff -= knownInvolvedValue
						if WorldData.Organizations[w].Staff < 1: WorldData.Organizations[w].Staff = 1
					elif knownInvolvedValue > 0 and knownInvolvedValue < 20:
						reason += str(knownInvolvedValue) + " terrorists were prevented from approaching the targets. "
					if WorldData.Organizations[w].OpsAgainstHomeland[u].IntelValue > 80:
						reason += "Extremely detailed plans of the attack, obtained by Bureau, helped to secure all potential targets. "
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].IntelValue > 50:
						reason += "Detailed plans of the attack, obtained by Bureau, helped to secure all potential targets. "
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].IntelValue > 25:
						reason += "Plans of the attack, obtained by Bureau, helped to secure potential targets. "
					WorldData.Organizations[w].OpsAgainstHomeland[u].Active = false
					WorldData.Organizations[w].ActiveOpsAgainstHomeland -= 1
					var trustIncrease = WorldData.Organizations[w].OpsAgainstHomeland[u].Damage * GameLogic.PriorityTerrorism*0.01
					if trustIncrease < (20 * GameLogic.PriorityTerrorism*0.01): trustIncrease = GameLogic.random.randi_range(21,25) * GameLogic.PriorityTerrorism*0.01
					trustIncrease *= 1.0 * GameLogic.PriorityPublic*0.01
					if (trustIncrease+GameLogic.Trust) > 100: trustIncrease = 100-GameLogic.Trust
					GameLogic.Trust += trustIncrease
					var budgetIncrease = GameLogic.BudgetFull*(0.01*GameLogic.Trust*0.35)
					if budgetIncrease > 50: budgetIncrease = 50
					GameLogic.BudgetFull += budgetIncrease
					CallManager.CallQueue.append(
						{
							"Header": "Important Information",
							"Level": "Classified",
							"Operation": "-//-",
							"Content": "[b]Congratulations.[/b]\n\nBased on Bureau's intel on " + WorldData.Organizations[w].Name + ", Homeland authorities prevented " + typeDesc + " from happening. "+reason + "\n\nBureau gained "+str(int(trustIncrease))+"% of trust. As a confirmation, government increases bureau's budget by €"+str(int(budgetIncrease))+",000." + tickerDesc,
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
					GameLogic.AddEvent("Bureau prevented a terrorist attack on Homeland")
					doesItEndWithCall = true
					continue  # prevented
				# it's happenning
				GameLogic.CurrentOpsAgainstHomeland -= 1
				var shortDesc = ""
				var longDesc = ""
				var casualties = 0
				var trustLoss = 0
				var responsibility = ""
				var theCountry = "Homeland"
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
						responsibility += "Officers confirm this association. Despite substantial knowledge about the organization, gathered intel was not enough to prevent the attack from happenning."
				else:
					if WorldData.Organizations[w].OpsAgainstHomeland[u].IntelValue <= 1:
						responsibility = "Officers do not know who perpetuated the attack."
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].IntelValue < 30:
						responsibility = "Officers point to " + WorldData.Organizations[w].Name + " as a probable perpetrator. Despite knowledge about the organization, gathered intel was not enough to prevent the attack from happenning."
					else:
						responsibility = "Officers identified " + WorldData.Organizations[w].Name + " as the perpetrator. Despite substantial knowledge about the organization, gathered intel was not enough to prevent the attack from happenning."
				################################################################
				# mundane ifs but had to be done
				if WorldData.Organizations[w].OpsAgainstHomeland[u].Type == WorldData.ExtOpType.HOME_TERRORIST_ATTACK:
					if WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 98:
						shortDesc = "Large terrorist attack with many casualties"
						casualties = GameLogic.random.randi_range(5000,100000)
						trustLoss = GameLogic.Trust * GameLogic.PriorityTerrorism*0.01
						# generate a detailed story about specifics later
						longDesc = "Homeland suffered from a largest terrorist attack in the world history, executed inside our country. There were "+str(casualties)+" casualties. "
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 90:
						shortDesc = "Large terrorist attack with many casualties"
						casualties = GameLogic.random.randi_range(1000,5000)
						trustLoss = GameLogic.Trust*0.95 * GameLogic.PriorityTerrorism*0.01
						if trustLoss < (25 * GameLogic.PriorityTerrorism*0.01): trustLoss = 25 * GameLogic.PriorityTerrorism*0.01
						longDesc = "Homeland suffered from a large terrorist attack inside our country. There were "+str(casualties)+" casualties. "
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 75:
						shortDesc = "Large terrorist attack with many casualties"
						casualties = GameLogic.random.randi_range(200,1000)
						trustLoss = GameLogic.Trust*0.9 * GameLogic.PriorityTerrorism*0.01
						if trustLoss < (25 * GameLogic.PriorityTerrorism*0.01): trustLoss = 25 * GameLogic.PriorityTerrorism*0.01
						longDesc = "Homeland suffered from a large terrorist attack inside our country. There were "+str(casualties)+" casualties. "
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 55:
						shortDesc = "Terrorist attack"
						casualties = GameLogic.random.randi_range(100,200)
						trustLoss = GameLogic.Trust*0.9 * GameLogic.PriorityTerrorism*0.01
						if trustLoss < (25 * GameLogic.PriorityTerrorism*0.01): trustLoss = 25 * GameLogic.PriorityTerrorism*0.01
						longDesc = "Homeland suffered from a terrorist attack inside our country. There were "+str(casualties)+" casualties. "
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 40:
						shortDesc = "Terrorist attack"
						casualties = GameLogic.random.randi_range(50,100)
						trustLoss = GameLogic.Trust*0.9 * GameLogic.PriorityTerrorism*0.01
						if trustLoss < (25 * GameLogic.PriorityTerrorism*0.01): trustLoss = 25 * GameLogic.PriorityTerrorism*0.01
						longDesc = "Homeland suffered from a terrorist attack inside our country. There were "+str(casualties)+" casualties. "
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 30:
						shortDesc = "Terrorist attack"
						casualties = GameLogic.random.randi_range(10,50)
						trustLoss = GameLogic.Trust*0.9 * GameLogic.PriorityTerrorism*0.01
						if trustLoss < (25 * GameLogic.PriorityTerrorism*0.01): trustLoss = 25 * GameLogic.PriorityTerrorism*0.01
						longDesc = "Homeland suffered from a terrorist attack inside our country. There were "+str(casualties)+" casualties. "
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 20:
						shortDesc = "Minor terrorist incident"
						casualties = GameLogic.random.randi_range(5,10)
						trustLoss = GameLogic.Trust*0.8 * GameLogic.PriorityTerrorism*0.01
						if trustLoss < (15 * GameLogic.PriorityTerrorism*0.01): trustLoss = 15 * GameLogic.PriorityTerrorism*0.01
						longDesc = "Homeland suffered from a terrorist attack inside our country. There were "+str(casualties)+" casualties. "
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 10:
						shortDesc = "Minor terrorist incident"
						casualties = GameLogic.random.randi_range(2,5)
						trustLoss = GameLogic.Trust*0.6 * GameLogic.PriorityTerrorism*0.01
						if trustLoss < (15 * GameLogic.PriorityTerrorism*0.01): trustLoss = 15 * GameLogic.PriorityTerrorism*0.01
						longDesc = "Homeland suffered from a minor terrorist incident inside our country. There were "+str(casualties)+" casualties. "
					else:
						shortDesc = "Minor terrorist incident"
						var cas = "was 1 casualty"
						if GameLogic.random.randi_range(0,1) == 0: cas = "were no casualties"
						trustLoss = GameLogic.Trust*0.5 * GameLogic.PriorityTerrorism*0.01
						if trustLoss < (15 * GameLogic.PriorityTerrorism*0.01): trustLoss = 15 * GameLogic.PriorityTerrorism*0.01
						longDesc = "Homeland suffered from a minor terrorist incident inside our country. There "+cas+". "
				################################################################
				# mundane ifs but had to be done
				elif WorldData.Organizations[w].OpsAgainstHomeland[u].Type == WorldData.ExtOpType.EMBASSY_TERRORIST_ATTACK:
					theCountry = WorldData.Countries[GameLogic.random.randi_range(1, len(WorldData.Countries)-1)].Name
					if WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 90:
						shortDesc = "Large terrorist attack with many casualties"
						casualties = GameLogic.random.randi_range(500,1000)
						trustLoss = GameLogic.Trust*0.9 * GameLogic.PriorityTerrorism*0.01
						if trustLoss < (25 * GameLogic.PriorityTerrorism*0.01): trustLoss = 25 * GameLogic.PriorityTerrorism*0.01
						# generate a detailed story about specifics later
						longDesc = "Homeland suffered from a large terrorist attack, which wiped out our embassy in " + theCountry + ". There were "+str(casualties)+" casualties. "
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 75:
						shortDesc = "Large terrorist attack with many casualties"
						casualties = GameLogic.random.randi_range(100,500)
						trustLoss = GameLogic.Trust*0.7 * GameLogic.PriorityTerrorism*0.01
						if trustLoss < (25 * GameLogic.PriorityTerrorism*0.01): trustLoss = 25 * GameLogic.PriorityTerrorism*0.01
						longDesc = "Homeland suffered from a large terrorist attack, which destroyed our embassy in " + theCountry + ". There were "+str(casualties)+" casualties. "
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 40:
						shortDesc = "Terrorist attack"
						casualties = GameLogic.random.randi_range(10,100)
						trustLoss = GameLogic.Trust*0.6 * GameLogic.PriorityTerrorism*0.01
						if trustLoss < (25 * GameLogic.PriorityTerrorism*0.01): trustLoss = 25 * GameLogic.PriorityTerrorism*0.01
						longDesc = "Homeland suffered from a terrorist attack on our embassy in " + theCountry + ". There were "+str(casualties)+" casualties. "
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 20:
						shortDesc = "Minor terrorist incident"
						casualties = GameLogic.random.randi_range(1,10)
						trustLoss = GameLogic.Trust*0.5 * GameLogic.PriorityTerrorism*0.01
						if trustLoss < (15 * GameLogic.PriorityTerrorism*0.01): trustLoss = 15 * GameLogic.PriorityTerrorism*0.01
						longDesc = "Homeland suffered from a terrorist attack on our embassy in " + theCountry + ". There were "+str(casualties)+" casualties. "
					else:
						shortDesc = "Minor terrorist incident"
						var cas = "was 1 casualty"
						if GameLogic.random.randi_range(0,1) == 0: cas = "were no casualties"
						trustLoss = GameLogic.Trust*0.5 * GameLogic.PriorityTerrorism*0.01
						if trustLoss < (15 * GameLogic.PriorityTerrorism*0.01): trustLoss = 15 * GameLogic.PriorityTerrorism*0.01
						longDesc = "Homeland suffered from a minor terrorist incident near our embassy in " + theCountry + ". There "+cas+". "
				################################################################
				# mundane ifs but had to be done
				elif WorldData.Organizations[w].OpsAgainstHomeland[u].Type == WorldData.ExtOpType.PLANE_HIJACKING:
					theCountry = WorldData.Countries[GameLogic.random.randi_range(1, len(WorldData.Countries)-1)].Name
					if WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 90:
						shortDesc = "Large terrorist attack with many casualties"
						casualties = GameLogic.random.randi_range(400,1500)
						trustLoss = GameLogic.Trust * GameLogic.PriorityTerrorism*0.01
						theCountry = "Homeland"
						longDesc = "Passenger plane with our citizens was hijacked and crashed into a building in Homeland. There were "+str(casualties)+" casualties. "
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 50:
						shortDesc = "Large terrorist attack with many casualties"
						casualties = GameLogic.random.randi_range(125,400)
						trustLoss = GameLogic.Trust*0.9 * GameLogic.PriorityTerrorism*0.01
						if trustLoss < (25 * GameLogic.PriorityTerrorism*0.01): trustLoss = 25 * GameLogic.PriorityTerrorism*0.01
						longDesc = "Passenger plane with Homeland citizens was hijacked and crashed in " + theCountry + ". There were "+str(casualties)+" casualties. "
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 30:
						shortDesc = "Terrorist attack"
						casualties = GameLogic.random.randi_range(25,125)
						trustLoss = GameLogic.Trust*0.8 * GameLogic.PriorityTerrorism*0.01
						if trustLoss < (25 * GameLogic.PriorityTerrorism*0.01): trustLoss = 25 * GameLogic.PriorityTerrorism*0.01
						longDesc = "Passenger plane with Homeland citizens was hijacked and crashed in " + theCountry + ". There were "+str(casualties)+" casualties. "
					else:
						shortDesc = "Minor terrorist incident"
						casualties = GameLogic.random.randi_range(3,25)
						trustLoss = GameLogic.Trust*0.7 * GameLogic.PriorityTerrorism*0.01
						if trustLoss < (15 * GameLogic.PriorityTerrorism*0.01): trustLoss = 15 * GameLogic.PriorityTerrorism*0.01
						longDesc = "Small airplane with Homeland citizens was hijacked and crashed in " + theCountry + ". There were "+str(casualties)+" casualties. "
				################################################################
				# mundane ifs but had to be done
				elif WorldData.Organizations[w].OpsAgainstHomeland[u].Type == WorldData.ExtOpType.LEADER_ASSASSINATION:
					shortDesc = "Terrorist attack"
					trustLoss = GameLogic.Trust
					if WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 90:
						longDesc = "Homeland's President was assassinated in a terrorist attack. "
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 70:
						shortDesc = "Minor terrorist incident"
						longDesc = "Homeland's President was wounded in a terrorist attack. "
					elif WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 40:
						longDesc = "One of political leaders in Homeland was assassinated by terrorists. "
					else:
						shortDesc = "Minor terrorist incident"
						longDesc = "One of political leaders in Homeland was wounded in a terrorist attack. "
				################################################################
				# mundane ifs but had to be done
				elif WorldData.Organizations[w].OpsAgainstHomeland[u].Type == WorldData.ExtOpType.KIDNAPPING_AND_MURDER:
					trustLoss = GameLogic.Trust*0.3
					shortDesc = "Minor terrorist incident"
					longDesc = "Kidnapped Homeland citizen was murdered. "
					# debrief any ongoing operations against this
					for j in range(0, len(GameLogic.Operations)):
						if GameLogic.Operations[j].Type != OperationGenerator.Type.RESCUE: continue
						if GameLogic.Operations[j].Stage == OperationGenerator.Stage.FINISHED or GameLogic.Operations[j].Stage == OperationGenerator.Stage.CALLED_OFF or GameLogic.Operations[j].Stage == OperationGenerator.Stage.FAILED: continue
						if GameLogic.Operations[j].Target != w: continue
						GameLogic.Operations[j].Stage = OperationGenerator.Stage.FAILED
						if GameLogic.Operations[j].AbroadPlan != null:
							GameLogic.OfficersInHQ += GameLogic.Operations[j].AbroadPlan.Officers
							GameLogic.OfficersAbroad -= GameLogic.Operations[j].AbroadPlan.Officers
							GameLogic.BudgetOngoingOperations -= GameLogic.Operations[j].AbroadPlan.Cost
							GameLogic.PursuedOperations -= 1
							GameLogic.AddEvent(WorldData.Countries[GameLogic.Operations[j].Country].Name + " (" + GameLogic.Operations[j].Name + "): "+str(GameLogic.Operations[j].AbroadPlan.Officers)+" officer(s) returned to Homeland")
						GameLogic.AddEvent("Bureau finished operation "+GameLogic.Operations[j].Name)
						GameLogic.Operations[j].Result = "FAILURE"
						GameLogic.Trust -= 5
				# executing details and communicating them
				trustLoss *= (1.2*GameLogic.PriorityPublic*0.01)+(1.2*GameLogic.PriorityTerrorism*0.01)
				if trustLoss > GameLogic.Trust: trustLoss = GameLogic.Trust
				if WorldData.Organizations[w].OpsAgainstHomeland[u].Damage >= 75:
					trustLoss = GameLogic.Trust
				GameLogic.Trust -= trustLoss
				WorldData.Countries[0].SoftPower -= 5
				WorldData.Organizations[w].OpsAgainstHomeland[u].Active = false
				WorldData.Organizations[w].ActiveOpsAgainstHomeland -= 1
				WorldData.Organizations[w].Aggression += GameLogic.random.randi_range(5,30)
				if WorldData.Organizations[w].Aggression > 100:
					WorldData.Organizations[w].Aggression = 100
				GameLogic.AddWorldEvent(shortDesc+" in " + theCountry, past)
				var trustLossDesc = "Bureau lost "+str(int(trustLoss))+"% of trust."
				if trustLoss < 1: trustLossDesc = ""
				CallManager.CallQueue.append(
					{
						"Header": "Important Information",
						"Level": "Unclassified",
						"Operation": "-//-",
						"Content": "[b]The worst has happened.[/b]\n\n" +longDesc + responsibility + "\n\n"+trustLossDesc+tickerDesc,
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
				if casualties > 1:
					GameLogic.AddEvent("Bureau did not prevent terrorist attack with "+str(casualties)+" casualties on Homeland")
				else:
					GameLogic.AddEvent("Bureau did not prevent terrorist attack on Homeland")
				doesItEndWithCall = true
		########################################################################
		# new operations against countries
		if WorldData.Organizations[w].Type == WorldData.OrgType.GENERALTERROR:
			# number of attacks relies on budget*aggression
			var opFrequency = WorldData.Organizations[w].Aggression
			if WorldData.Organizations[w].Budget < 100: opFrequency *= 0.3
			elif WorldData.Organizations[w].Budget < 1000: opFrequency *= 0.5
			elif WorldData.Organizations[w].Budget < 10000: opFrequency *= 0.7
			elif WorldData.Organizations[w].Budget < 50000: opFrequency *= 0.95
			# max aggr->p=1/10, min aggr->p=1/110
			var randFrequency = 110 - opFrequency*GameLogic.FrequencyAttacks
			if GameLogic.TurnOnTerrorist == true and GameLogic.random.randi_range(0,randFrequency) == int(randFrequency*0.5):
				var whichCountry = randi() % WorldData.Countries.size()
				if GameLogic.YearlyOpsAgainstHomeland < GameLogic.OpsLimit and GameLogic.random.randi_range(0,2) == 2:
					whichCountry = 0
				# target consistency
				if GameLogic.random.randi_range(0,110) < WorldData.Organizations[w].TargetConsistency:
					whichCountry = WorldData.Organizations[w].TargetCountries[randi() % WorldData.Organizations[w].TargetCountries.size()]
				# against other countries: executing right now
				if whichCountry != 0:
					if GameLogic.random.randi_range(1,7) > 4:  # ~4/7 are prevented
						opFrequency *= 0.6
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
								WorldData.Countries[whichCountry].SoftPower -= 2
						GameLogic.AddWorldEvent(desc, past)
				################################################################
				# against homeland: just planning for the future
				elif past == null and GameLogic.CurrentOpsAgainstHomeland <= GameLogic.random.randi_range(1,2) and GameLogic.YearlyOpsAgainstHomeland < GameLogic.OpsLimit:
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
					var opType = GameLogic.random.randi_range(0,4)
					WorldData.Organizations[w].OpsAgainstHomeland.append(WorldData.aNewExtOp(
						{
							"Type": opType,
							"Budget": int(WorldData.Organizations[w].Budget * opSize),
							"Persons": int(WorldData.Organizations[w].Staff * 0.5 * opSize),
							"Secrecy": int(opSecrecy),
							"Damage": int(opDamage),
							"FinishCounter": opLength,
						}
					))
					GameLogic.CurrentOpsAgainstHomeland += 1
					GameLogic.YearlyOpsAgainstHomeland += 1
					WorldData.Organizations[w].ActiveOpsAgainstHomeland += 1
					# kidnapping is differently treated
					if opType == WorldData.ExtOpType.KIDNAPPING_AND_MURDER:
						opLength = GameLogic.random.randi_range(10,26)
						if GameLogic.AttackTicker == 0:
							GameLogic.AttackTicker = opLength  # main screen ticker
							GameLogic.AttackTickerOp.Org = w
							GameLogic.AttackTickerOp.Op = len(WorldData.Organizations[w].OpsAgainstHomeland)-1
							GameLogic.AttackTickerText = " weeks to rescue a citizen"
						var where = WorldData.Countries[WorldData.Organizations[w].Countries[0]].Name
						CallManager.CallQueue.append(
							{
								"Header": "Important Information",
								"Level": "Top Secret",
								"Operation": "-//-",
								"Content": "Homeland citizen was kidnapped in " + where + ". Officers do not know yet who is behind this attack. According to our general signal surveillance, Bureau should have "+str(opLength)+" weeks to rescue the person. Find the perpetrator and execute rescue action.",
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
						GameLogic.AddEvent("Bureau tasked with rescue attempt in " + where)
						doesItEndWithCall = true
					# most (but not all!) operations are vaguely communicated to the player
					elif GameLogic.random.randi_range(1,10) < 8:
						var tickerDesc = ""
						if GameLogic.AttackTicker == 0:
							GameLogic.AttackTicker = opLength  # main screen ticker
							GameLogic.AttackTickerOp.Org = w
							GameLogic.AttackTickerOp.Op = len(WorldData.Organizations[w].OpsAgainstHomeland)-1
							GameLogic.AttackTickerText = " weeks to possible attack"
						else:
							tickerDesc = "\n\nNote that this is a different plot than previously detected. Homeland is facing more than one attack."
						CallManager.CallQueue.append(
							{
								"Header": "Important Information",
								"Level": "Top Secret",
								"Operation": "-//-",
								"Content": "General signal surveillance picked up chatter involving possible terrorist attacks and Homeland. After careful investigation, officers deduced that the attack can happen in "+str(opLength)+" weeks. Bureau has to do everything it can to stop that from happening. "+tickerDesc,
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
						GameLogic.AddEvent("Bureau detected possibility of terrorist attack in "+str(opLength)+" weeks")
						doesItEndWithCall = true
		########################################################################
		elif WorldData.Organizations[w].Type == WorldData.OrgType.INTEL and past == null and GameLogic.TurnOnInfiltration == true:
			# continuing existing intel operations
			for u in range(0,len(WorldData.Organizations[w].OpsAgainstHomeland)):
				if WorldData.Organizations[w].OpsAgainstHomeland[u].Active == false:
					continue
				WorldData.Organizations[w].OpsAgainstHomeland[u].InvestigationData.Length += 1
				if GameLogic.random.randi_range(1,6) == 5:
					WorldIntel.LeakBureauInfo(WorldData.Organizations[w].Countries[0], WorldData.Organizations[w].OpsAgainstHomeland[u].Damage, w, u)
			# possible new intel operations
			if GameLogic.random.randi_range(1,20) == 15:
				var opFrequency = WorldData.Organizations[w].Aggression
				if WorldData.Organizations[w].Staff < 100: opFrequency *= 0.1
				elif WorldData.Organizations[w].Staff < 1000: opFrequency *= 0.2
				elif WorldData.Organizations[w].Staff < 10000: opFrequency *= 0.4
				elif WorldData.Organizations[w].Staff < 50000: opFrequency *= 0.6
				elif WorldData.Organizations[w].Staff < 100000: opFrequency *= 0.8
				var randFrequency = 240 - opFrequency  # max aggr->p=1/140, min aggr->p=1/240
				if GameLogic.random.randi_range(0,randFrequency) == int(randFrequency*0.5):
					# actual source acquisition happens here
					# if successful, then operation of keeping it up begins
					# if not, nothing happens
					var successProb = WorldData.Organizations[w].Counterintelligence - GameLogic.StaffTrust*0.5 - GameLogic.StaffSkill*0.2 - WorldData.Organizations[w].IntelValue*0.3
					if GameLogic.random.randi_range(1,100) < successProb:
						WorldData.Countries[0].SoftPower -= 3
						WorldData.Countries[WorldData.Organizations[w].Countries[0]].SoftPower += 3
						WorldData.Organizations[w].OpsAgainstHomeland.append(WorldData.aNewExtOp(
							{
								"Type": WorldData.ExtOpType.COUNTERINTEL,
								"Budget": int(WorldData.Organizations[w].Budget * 0.01),
								"Persons": GameLogic.random.randi_range(3,10),
								"Secrecy": int(WorldData.Organizations[w].Counterintelligence + GameLogic.random.randi_range(-20,2)),
								"Damage": GameLogic.random.randi_range(WorldData.Organizations[w].Counterintelligence*0.3, WorldData.Organizations[w].Counterintelligence),
								"FinishCounter": 120,
							}
						))
						WorldData.Organizations[w].OpsAgainstHomeland[-1].InvestigationData = {
							"Length": 0,
							"CovertTravelDamage": 0,
							"NetworkDamage": 0,
							"TurnedSources": 0,
						}
						WorldData.Organizations[w].ActiveOpsAgainstHomeland += 1
						GameLogic.InternalMoles += 1
			####################################################################
			# detecting moles
			if GameLogic.InternalMoles > 0 and GameLogic.random.randi_range(1,8) == 4:
				if (WorldData.Organizations[w].ActiveOpsAgainstHomeland > 0 or GameLogic.random.randi_range(1,80) == 12) and GameLogic.DistMolesearchCounter <= 0:
					GameLogic.DistMolesearchCounter = GameLogic.DistMolesearchMin
					var successProb = GameLogic.StaffExperience*0.1 + GameLogic.StaffSkill*0.3 + WorldData.Organizations[w].IntelValue*0.6
					var whichOp = 0
					for f in range(0, len(WorldData.Organizations[w].OpsAgainstHomeland)):
						if WorldData.Organizations[w].OpsAgainstHomeland[f].Active == true:
							whichOp = f
							break
					var content = ""
					if GameLogic.random.randi_range(1,100) < successProb:
						if WorldData.Organizations[w].ActiveOpsAgainstHomeland > 0:
							content = "guilty"
						else:
							content = "innocent"
					else:
						if GameLogic.random.randi_range(1,2) == 2:
							content = "guilty"
						else:
							content = "innocent"
					CallManager.CallQueue.append(
						{
							"Header": "Urgent Decision",
							"Level": "Secret",
							"Operation": "-//-",
							"Content": "There is possibility that we have a mole inside Bureau. Some officers suggest that a single officer is leaking classified information to " + WorldData.Organizations[w].Name + " from " + WorldData.Countries[WorldData.Organizations[w].Countries[0]].Name + ". Internal investigation, relying on skills and intel gather on that organization, suggests that the officers is probably " + content + ".\n\nDecide about their future fate.",
							"Show1": false,
							"Show2": false,
							"Show3": true,
							"Show4": true,
							"Text1": "",
							"Text2": "",
							"Text3": "Lay off and Arrest",
							"Text4": "Keep the Officer",
							"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
							"Decision1Argument": null,
							"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
							"Decision2Argument": null,
							"Decision3Callback": funcref(GameLogic, "ImplementMoleTermination"),
							"Decision3Argument": {"Org":w,"Op":whichOp},
							"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
							"Decision4Argument": null,
						}
					)
					doesItEndWithCall = true
		########################################################################
		# sources
		if len(WorldData.Organizations[w].IntelSources) > 0:
			# modifying every source
			var sumOfLevels = 0.0
			var highestLevel = 0
			var sourceLoss = -1
			for s in range(0,len(WorldData.Organizations[w].IntelSources)):
				# note double source data
				if WorldData.Organizations[w].IntelSources[s].TurnedHowLong > 0:
					WorldData.Organizations[w].IntelSources[s].TurnedHowLong += 1
				# fluctuate trust
				WorldData.Organizations[w].IntelSources[s].Trust += GameLogic.random.randi_range(-1,1)
				if WorldData.Organizations[w].IntelSources[s].Trust < 1:
					sourceLoss = s
					continue
				# fluctuate level
				if GameLogic.random.randi_range(1,3) == 2:
					WorldData.Organizations[w].IntelSources[s].Level += GameLogic.random.randi_range(-1,1)
				# flip by high enough counterintelligence
				if GameLogic.random.randi_range(1,6) == 3 and WorldData.Organizations[w].Counterintelligence > GameLogic.random.randi_range(50,150) and WorldData.Organizations[w].IntelSources[s].Level > 0:
					WorldData.Organizations[w].IntelSources[s].Level *= -1
				# noting levels for joint intel
				sumOfLevels += WorldData.Organizations[w].IntelSources[s].Level
				if abs(highestLevel) < abs(WorldData.Organizations[w].IntelSources[s].Level):
					highestLevel = WorldData.Organizations[w].IntelSources[s].Level
			# eventual source loss
			if sourceLoss != -1:
				WorldData.Organizations[w].IntelSources.remove(sourceLoss)
				GameLogic.AddEvent('Bureau lost source in ' + WorldData.Organizations[w].Name)
			if len(WorldData.Organizations[w].IntelSources) > 0:
				# providing joint intel from all sources, every 8 weeks on average
				if GameLogic.random.randi_range(1,8) == 4:
					var localCall = WorldIntel.GatherOnOrg(w, highestLevel*(0.8+len(WorldData.Organizations[w].IntelSources)*0.2), GameLogic.GiveDateWithYear(), false)
					if localCall == true: doesItEndWithCall = true
				# reversal check
				var whichS = randi() % WorldData.Organizations[w].IntelSources.size()
				var proxyQual = WorldData.Organizations[w].IntelSources[whichS].Level
				if GameLogic.random.randi_range(1,6) == 2: proxyQual *= (-1)
				if proxyQual < 0 and GameLogic.random.randi_range(1,12) == 6 and GameLogic.DistSourcecheckCounter < 0:
					GameLogic.DistSourcecheckCounter = GameLogic.DistSourcecheckMin
					var content = ""
					var detectionProb = GameLogic.StaffSkill*0.6 + GameLogic.StaffExperience*0.4 + WorldData.Organizations[w].IntelValue*0.3 - (100-WorldData.Countries[WorldData.Organizations[w].Countries[0]].KnowhowCustoms)*0.2
					if len(WorldData.Organizations[w].IntelSources) > 10: detectionProb += 50
					elif len(WorldData.Organizations[w].IntelSources) > 5: detectionProb += 35
					elif len(WorldData.Organizations[w].IntelSources) > 1: detectionProb += 20
					var investigationDetails = "Investigation team concluded that the source "
					if WorldData.Organizations[w].IntelSources[whichS].Level < 0:
						investigationDetails += "provided false intel for approximately " + str(int(WorldData.Organizations[w].IntelSources[whichS].TurnedHowLong)) + " weeks. Officers suspect that " + WorldData.Organizations[w].IntelSources[whichS].TurnedByWho + " was responsible for compromising the asset. Termination of cooperation was good decision."
					else:
						investigationDetails += "have not been compromised. Termination of cooperation was unnecessary."
					if GameLogic.random.randi_range(1,100) < detectionProb:
						if WorldData.Organizations[w].IntelSources[whichS].Level < 0:
							content = "in fact unreliable"
						else:
							content = "still reliable"
					else:
						if GameLogic.random.randi_range(1,2) == 2:
							content = "in fact unreliable"
						else:
							content = "still reliable"
					CallManager.CallQueue.append(
						{
							"Header": "Urgent Decision",
							"Level": "Secret",
							"Operation": "-//-",
							"Content": "Some officers voiced their concerns over a single source inside " + WorldData.Organizations[w].Name + " (" + str(int(100.0/ len(WorldData.Organizations[w].IntelSources))) + "% of sources in this organization). Crosschecking and internal analysis, using skills and experience available in Bureau, suggests that the source is " + content + ".\n\nDecide if we terminate or continue the cooperation.",
							"Show1": false,
							"Show2": false,
							"Show3": true,
							"Show4": true,
							"Text1": "",
							"Text2": "",
							"Text3": "Terminate\nCooperation",
							"Text4": "Continue\nCooperation",
							"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
							"Decision1Argument": null,
							"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
							"Decision2Argument": null,
							"Decision3Callback": funcref(GameLogic, "ImplementSourceTermination"),
							"Decision3Argument": {"Org":w, "Source":whichS, "InvestigationDetails": investigationDetails},
							"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
							"Decision4Argument": null,
						}
					)
					doesItEndWithCall = true
		########################################################################
		# intel stations
		if WorldData.Countries[WorldData.Organizations[w].Countries[0]].Station > 0:
			var prob = 100  # one time in 100 weeks
			if WorldData.Countries[WorldData.Organizations[w].Countries[0]].Station > 5:
				prob = 50 - (WorldData.Countries[WorldData.Organizations[w].Countries[0]].Station*0.2)
			elif WorldData.Countries[WorldData.Organizations[w].Countries[0]].Station > 4: prob = 60
			elif WorldData.Countries[WorldData.Organizations[w].Countries[0]].Station > 3: prob = 70
			elif WorldData.Countries[WorldData.Organizations[w].Countries[0]].Station > 2: prob = 80
			elif WorldData.Countries[WorldData.Organizations[w].Countries[0]].Station > 1: prob = 90
			if GameLogic.random.randi_range(0, prob) == int(prob*0.5):
				var qual = GameLogic.StaffSkill*0.2 + WorldData.Countries[WorldData.Organizations[w].Countries[0]].KnowhowLanguage*0.1 + WorldData.Countries[WorldData.Organizations[w].Countries[0]].KnowhowCustoms*0.1 + GameLogic.random.randi_range(-15,15) + min(WorldData.Countries[WorldData.Organizations[w].Countries[0]].Station,10)*0.6
				var ifSignificant = WorldIntel.GatherOnOrg(w, qual, GameLogic.GiveDateWithYear(), false)
				if ifSignificant == true: doesItEndWithCall = true
		########################################################################
		# changing relations between arms dealers and terror orgs
		if WorldData.Organizations[w].Type == WorldData.OrgType.ARMTRADER:
			if GameLogic.random.randi_range(1,20) == 4:
				if GameLogic.random.randi_range(1,2) == 1:
					# connection loss
					if len(WorldData.Organizations[w].ConnectedTo) > 0:
						WorldData.Organizations[w].ConnectedTo.remove(GameLogic.random.randi_range(0, len(WorldData.Organizations[w].ConnectedTo)-1))
				else:
					# new connection
					for f in range(0, len(WorldData.Organizations)):
						if WorldData.Organizations[f].Type != WorldData.OrgType.GENERALTERROR: continue
						if f in WorldData.Organizations[w].ConnectedTo: continue
						if GameLogic.random.randi_range(1,4) != 2: continue
						WorldData.Organizations[w].ConnectedTo.append(f)
						break
		########################################################################
		# movements vs terror
		if WorldData.Organizations[w].Type == WorldData.OrgType.MOVEMENT:
			# terror org spun out from the movement
			if GameLogic.random.randi_range(40,100) < WorldData.Organizations[w].Aggression:
				if GameLogic.random.randi_range(1,52) == 15:
					WorldData.Organizations.append(
						WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": WorldGenerator.GenerateHostileName(), "Fixed": false, "Known": false, "Staff": GameLogic.random.randi_range(10,100), "Budget": GameLogic.random.randi_range(50,1000), "Counterintelligence": GameLogic.random.randi_range(20,60), "Aggression": WorldData.Organizations[w].Aggression+GameLogic.random.randi_range(-5,5), "Countries": WorldData.Organizations[w].Countries.duplicate(), "IntelValue": 0, "TargetConsistency": GameLogic.random.randi_range(50,100), "TargetCountries": WorldData.Organizations[w].Countries.duplicate(), })
					)
					WorldData.Organizations[-1].UndercoverCounter = GameLogic.random.randi_range(4,26)
					# target homeland more often
					if !(0 in WorldData.Organizations[-1].TargetCountries):
						if GameLogic.random.randi_range(1,9) == 7:
							WorldData.Organizations[-1].TargetCountries.append(0)
					WorldData.Organizations[-1].ConnectedTo.append(w)
			# louder event initiated by the movement
			if GameLogic.random.randi_range(20,120) < WorldData.Organizations[w].Aggression and WorldData.Organizations[w].Staff > 5000:
				if GameLogic.random.randi_range(1,46) == 25:
					var whichE = GameLogic.random.randi_range(1,3)
					if whichE == 1:
						GameLogic.AddWorldEvent(WorldData.Organizations[w].Name + " protests in " + WorldData.Countries[WorldData.Organizations[w].Countries[randi() % WorldData.Organizations[w].Countries.size()]].Name, past)
					elif whichE == 2:
						GameLogic.AddWorldEvent(WorldData.Organizations[w].Name + " march on streets of " + WorldData.Countries[WorldData.Organizations[w].Countries[randi() % WorldData.Organizations[w].Countries.size()]].Name, past)
					else:
						GameLogic.AddWorldEvent("Riots sparked by " + WorldData.Organizations[w].Name + " in " + WorldData.Countries[WorldData.Organizations[w].Countries[randi() % WorldData.Organizations[w].Countries.size()]].Name, past)
			# affecting orgs tied to the movement
			if GameLogic.random.randi_range(1,4) == 3:
				for p in WorldData.Organizations[w].ConnectedTo:
					WorldData.Organizations[p].Aggression += (WorldData.Organizations[w].Aggression-50)*0.01
					if GameLogic.random.randi_range(1,2) == 2:
						var sizeChange = 0
						if WorldData.Organizations[w].Staff > 100000:
							sizeChange = GameLogic.random.randi_range(10,100)
						elif WorldData.Organizations[w].Staff > 10000:
							sizeChange = GameLogic.random.randi_range(1,10)
						else:
							sizeChange = GameLogic.random.randi_range(1,3)
						WorldData.Organizations[p].Staff += sizeChange
	############################################################################
	# rare new organizations, no more than one per year
	if GameLogic.random.randi_range(1,100) == 45:
		var size = GameLogic.random.randi_range(2,100)
		var places = GameLogic.random.randi_range(0,len(WorldData.Countries)-1)
		WorldData.Organizations.append(
			WorldData.aNewOrganization({ "Type": WorldData.OrgType.GENERALTERROR, "Name": WorldGenerator.GenerateHostileName(), "Fixed": false, "Known": false, "Staff": size, "Budget": size*100+GameLogic.random.randi_range(-50,150), "Counterintelligence": GameLogic.random.randi_range(5,70), "Aggression": GameLogic.random.randi_range(10,80), "Countries": [places], "IntelValue": GameLogic.random.randi_range(-10,-5), "TargetConsistency": 0, "TargetCountries": [], })
		)
		WorldData.Organizations[-1].UndercoverCounter = GameLogic.random.randi_range(30,150)
		# usual targets
		WorldData.Organizations[-1].TargetConsistency = GameLogic.random.randi_range(0,100)
		for h in range(0, GameLogic.random.randi_range(1,5)):
			var trying = GameLogic.random.randi_range(0,len(WorldData.Countries)-1)
			if !(trying in WorldData.Organizations[-1].TargetCountries):
				WorldData.Organizations[-1].TargetCountries.append(trying)
		# target homeland more often
		if !(0 in WorldData.Organizations[-1].TargetCountries):
			if GameLogic.random.randi_range(1,3) == 3:
				WorldData.Organizations[-1].TargetCountries.append(0)
		# tying to a movement
		for j in range(0,len(WorldData.Organizations)):
			if WorldData.Organizations[j].Type != WorldData.OrgType.MOVEMENT: continue
			if WorldData.Organizations[j].Countries[0] != places: continue
			if GameLogic.random.randi_range(1,2) == 1:
				WorldData.Organizations[j].ConnectedTo.append(len(WorldData.Organizations)-1)
	############################################################################
	# very rare new movements
	if GameLogic.random.randi_range(0,200) == 155:
		var movNames = ["Extremists", "Nationalists", "Anarchists", "Resistance"]
		var size = GameLogic.random.randi_range(100,15000)
		var place = GameLogic.random.randi_range(1,len(WorldData.Countries)-1)
		WorldData.Organizations.append(
			WorldData.aNewOrganization({ "Type": WorldData.OrgType.MOVEMENT, "Name": WorldData.Countries[place].Adjective + " " + movNames[randi() % movNames.size()], "Fixed": false, "Known": true, "Staff": size, "Budget": 0, "Counterintelligence": 0, "Aggression": GameLogic.random.randi_range(10,90), "Countries": [place], "IntelValue": 5, "TargetConsistency": 0, "TargetCountries": [], })
		)
		GameLogic.AddWorldEvent("New movement emerged: " + WorldData.Organizations[-1].Name, past)
	############################################################################
	return doesItEndWithCall
