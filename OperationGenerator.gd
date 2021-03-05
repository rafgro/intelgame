extends Node

var PossibleNames = [
	"Pilgrim’s Progress", "Robinson Crusoe", "Gulliver’s Travel", "Clarissa", "Tom Jones", "Tristram Shandy", "Emma", "Frankenstein", "Nightmare Abbey", "Narrative", "Sybil", "Jane Eyre", "Wuthering Heights", "Vanity Fair", "David Copperfield", "Scarlet Letter", "Moby Dick", "Wonderland", "Moonstone", "Little Women", "Middlemarch", "Huckleberry Finn", "Three Men in a Boat", "Sign of Four", "Dorian Gray", "Grub Street", "Jude the Obscure", "Red Badge of Courage", "Dracula", "Heart of Darkness", "Sister Carrie", "Kim", "Call of the Wild", "Golden Bowl", "Hadrian the Seventh", "Wind in the Willow", "History of Mr Polly", "Zuleika Dobson", "Good Soldier", "Thirty-Nine Steps", "Rainbow", "Of Human Bondage", "Age of Innocence", "Ulysses", "Babbitt", "Passage to India", "Gentlemen Prefer Blondes", "Mrs Dalloway", "Great Gatsby", "Lolly Willowes", "Sun Also Rises", "Maltese Falcon", "Lay Dying", "Brave New World", "Cold Comfort Farm", "Nineteen Nineteen", "Tropic of Cancer", "Scoop", "Murphy", "Big Sleep", "Party Going", "Swim-Two-Birds", "Grapes of Wrath", "Joy in the Morning", "All the King’s Men", "Under the Volcano", "Heat of the Day", "Nineteen Eighty-Four", "End of the Affair", "Catcher in the Rye", "Adventures of Augie", "Lord of the Flies", "Lolita", "On the Road", "Voss", "Mockingbird", "Miss Jean Brodie", "Catch-22", "Golden Notebook", "Clockwork Orange", "Single Man", "Cold Blood", "Bell Jar", "Portnoy's Complaint", "Mrs Palfrey", "Rabbit Redux", "Song of Solomon", "Bend in the River", "Midnight’s Children", "Housekeeping", "Suicide Note", "Beginning of Spring", "Breathing Lesson", "Amongst Women", "Underworld", "True History", "Animal Farm", "Fahrenheit", "Galaxy Guide", "Ender's Game", "Martian", "Jurassic Park", "Dune", "Time Machine", "Cat's Craddle", "Electric Sheep", "Station Eleven", "Strange Land", "Space Odyssey", "Dark Matter", "Andromeda Strain", "Cloud Atlas", "Under the Sea", "Blindness", "Starship Trooper", "Hyperion", "High Castle", "Artemis", "Leviathan", "Three-Body Problem", "Left Hand", "Sirens of Titan", "Harsh Mistress", "Ringworld", "Cryptonomicon", "Sparrow", "Angry Planet", "God's Eye", "Canticle", "Altered Carbon", "Redshirts", "Dispossesed", "Recursion", "Ancillary Sword", "Illustrated Man", "Solaris", "All Systems Red", "Children of Time", "Long Earth", "Sleeping Giant", "Vox", "Paper Menagerie", "Collapsing Empire", "Calculating Stars", "Provenance", "Vanished Bird", "Network Effect", "Aeon", "Consider Phlebas", "Eternity Road", "Ancient Shore", "Engine of God", "Into the Flame", "Quantum Thief", "Tau Zero", "Ship Who Sang",
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
	RESCUE = 3,
}

enum Stage {
	NOT_STARTED = 0,
	PLANNING_OPERATION = 1,
	ABROAD_OPERATION = 2,
	FINISHED = 3,
	CALLED_OFF = 4,
	FAILED = 5,
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
	elif whatType == Type.RESCUE:
		desc = "Rescue Homeland citizen from " + WorldData.Organizations[againstOrg].Name
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
			"ExpectedWeeks": GameLogic.random.randi_range(2,9),
			"ExpectedQuality": GameLogic.random.randi_range(1,40),
			"Started": "-//-",
			"Result": "NOT STARTED",
		}
	)
