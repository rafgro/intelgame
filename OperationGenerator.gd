extends Node

var PossibleNames = [
	"Pilgrim’s Progress",
	"Robinson Crusoe",
	"Gulliver’s Travel",
	"Clarissa",
	"Tom Jones",
	"Tristram Shandy",
	"Emma",
	"Frankenstein",
	"Nightmare Abbey",
	"Narrative",
	"Sybil",
	"Jane Eyre",
	"Wuthering Heights",
	"Vanity Fair",
	"David Copperfield",
	"Scarlet Letter",
	"Moby Dick",
	"Wonderland",
	"Moonstone",
	"Little Women",
	"Middlemarch",
	"Huckleberry Finn",
	"Three Men in a Boat",
	"Sign of Four",
	"Dorian Gray",
	"Grub Street",
	"Jude the Obscure",
	"Red Badge of Courage",
	"Dracula",
	"Heart of Darkness",
	"Sister Carrie",
	"Kim",
	"Call of the Wild",
	"Golden Bowl",
	"Hadrian the Seventh",
	"Wind in the Willow",
	"History of Mr Polly",
	"Zuleika Dobson",
	"Good Soldier",
	"Thirty-Nine Steps",
	"Rainbow",
	"Of Human Bondage",
	"Age of Innocence",
	"Ulysses",
	"Babbitt",
	"Passage to India",
	"Gentlemen Prefer Blondes",
	"Mrs Dalloway",
	"Great Gatsby",
	"Lolly Willowes",
	"Sun Also Rises",
	"Maltese Falcon",
	"Lay Dying",
	"Brave New World",
	"Cold Comfort Farm",
	"Nineteen Nineteen",
	"Tropic of Cancer",
	"Scoop",
	"Murphy",
	"Big Sleep",
	"Party Going",
	"Swim-Two-Birds",
	"Grapes of Wrath",
	"Joy in the Morning",
	"All the King’s Men",
	"Under the Volcano",
	"Heat of the Day",
	"Nineteen Eighty-Four",
	"End of the Affair",
	"Catcher in the Rye",
	"Adventures of Augie",
	"Lord of the Flies",
	"Lolita",
	"On the Road",
	"Voss",
	"Mockingbird",
	"Miss Jean Brodie",
	"Catch-22",
	"Golden Notebook",
	"Clockwork Orange",
	"Single Man",
	"Cold Blood",
	"Bell Jar",
	"Portnoy’s Complaint",
	"Mrs Palfrey",
	"Rabbit Redux",
	"Song of Solomon",
	"Bend in the River",
	"Midnight’s Children",
	"Housekeeping",
	"Suicide Note",
	"Beginning of Spring",
	"Breathing Lesson",
	"Amongst Women",
	"Underworld",
	"True History"
]

enum Approach {
	PASSIVE,
	DEFENSIVE,
	OFFENSIVE,
}

enum Type {
	MORE_INTEL = 0,
	RECRUIT_SOURCE = 1,
	OFFENSIVE = 2,
}

enum Stage {
	NOT_STARTED,
	PLANNING_OPERATION,
	ABROAD_OPERATION,
	FINISHED,
	CALLED_OFF,
	FAILED,
}

func NewOperation(source, againstOrg, whatType):
	GameLogic.PursuedOperations += 1
	# name
	var whichName = randi() % PossibleNames.size()
	var theName = PossibleNames[whichName]
	PossibleNames.remove(whichName)  # to avoid using the same name again
	# place
	var countryId = WorldData.Organizations[againstOrg].Countries[randi() % WorldData.Organizations[againstOrg].Countries.size()]
	WorldData.Countries[countryId].OperationStats += 1
	# type
	var alevel = "Confidential"
	var desc = ""
	if whatType == Type.MORE_INTEL and (WorldData.Organizations[againstOrg].Type == WorldData.OrgType.COMPANY or WorldData.Organizations[againstOrg].Type == WorldData.OrgType.UNIVERSITY):
		desc = "Gather technological intel from " + WorldData.Organizations[againstOrg].Name
	elif whatType == Type.MORE_INTEL and WorldData.Organizations[againstOrg].Type == WorldData.OrgType.GOVERNMENT:
		desc = "Gather diplomatic intel in " + WorldData.Organizations[againstOrg].Name
	elif whatType == Type.MORE_INTEL:
		desc = "Gather intel on " + WorldData.Organizations[againstOrg].Name
	elif whatType == Type.RECRUIT_SOURCE:
		desc = "Recruit source in " + WorldData.Organizations[againstOrg].Name
		alevel = "Secret"
	elif whatType == Type.OFFENSIVE:
		desc = "Damage " + WorldData.Organizations[againstOrg].Name
		alevel = "Top Secret"
	# local communicate
	if source == 0:
		GameLogic.AddEvent("Bureau started a new operation: " + theName)
	else:
		GameLogic.AddEvent("Government designated a new operation: " + theName)
	# actual operation addition
	GameLogic.Operations.append(
		{
			"Source": source,
			"Name": theName,
			"Type": whatType,
			"GoalDescription": desc,
			"Level": alevel,  # level displayed in calls
			"Target": againstOrg,
			"Country": countryId,
			"AnalyticalOfficers": 0,
			"OperationalOfficers": 0,
			"Stage": Stage.NOT_STARTED,
			"AbroadPlan": null,
			"AbroadRateOfProgress": 10,
			"AbroadProgress": 100,
			"WeeksPassed": 0,
			"ExpectedWeeks": GameLogic.random.randi_range(2,6),
			"ExpectedQuality": GameLogic.random.randi_range(20,90),
			"Started": "-//-",
			"Result": "NOT STARTED",
		}
	)
