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
