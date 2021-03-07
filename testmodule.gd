extends Node

# testing module
var maxSteps = 2000
var elapsedSteps = 0
signal timeout
const TIME_PERIOD = 0.1 # 1000ms
var time = 0
var availableButtons = []
var availableItemLists = []
var availableHSliders = []

func FinishSummary():
	print("Finished on " + str(int(GameLogic.DateDay)) + "/" + str(int(GameLogic.DateMonth)) + "/" + str(int(GameLogic.DateYear)) + " (" + str(int(GameLogic.AllWeeks)) + " weeks)")
	print("Trust " + str(int(GameLogic.Trust)) + " | Use " + str(int(GameLogic.Use)) + " | Budget " + str(int(GameLogic.BudgetFull)) + "\nTech " + str(int(GameLogic.Technology)) + " | Skill " + str(int(GameLogic.StaffSkill)) + " | Exp " + str(int(GameLogic.StaffExperience)) + " | Inner trust " + str(int(GameLogic.StaffTrust)))
	print(str(len(GameLogic.Operations)) + " operations | " + str(int(GameLogic.ActiveOfficers)) + " officers")
	var __my_file := File.new()
	__my_file.open("res://Test.txt", __my_file.WRITE)
	assert(__my_file.is_open())
	__my_file.store_string(PoolStringArray(GameLogic.BureauEvents).join("\n") + "\n\n" + PoolStringArray(GameLogic.WorldEvents).join("\n"))
	__my_file.close()

func RecursiveClickSearch(current):
	for x in current.get_children():
		if x is Button:
			if x.disabled == false:
				availableButtons.append(x)
		elif x is ItemList:
			availableItemLists.append(x)
		elif x is HSlider:
			availableHSliders.append(x)
		else: RecursiveClickSearch(x)

func TestStep():
	#print("step")
	# traversing the tree to find all the buttons
	availableButtons.clear()
	availableItemLists.clear()
	availableHSliders.clear()
	RecursiveClickSearch(get_tree().get_current_scene())
	# choosing action
	if len(availableItemLists) > 0 and GameLogic.random.randi_range(1,4) <= 3:
		var which = GameLogic.random.randi_range(0, len(availableItemLists)-1)
		if availableItemLists[-1].get_item_count() > 0: which = -1  # to always choose some org
		var maxItems = availableItemLists[which].get_item_count()
		if maxItems > 0:
			var chosen = GameLogic.random.randi_range(0, maxItems - 1)
			availableItemLists[which].emit_signal("item_selected", chosen)
	elif len(availableHSliders) > 0 and GameLogic.random.randi_range(1,3) == 2:
		availableHSliders[GameLogic.random.randi_range(0,2)].emit_signal("value_changed", GameLogic.random.randi_range(0,100)*1.0)
	else:
		var which = -1  # last button, usually return or next week, more probable
		if len(availableItemLists) == 4 and len(availableButtons) > 1:  # gather intel screen
			which = GameLogic.random.randi_range(0, len(availableButtons)-2) # any button except return
		elif len(availableItemLists) > 0:  # always random to stimulate actions
			which = GameLogic.random.randi_range(0, len(availableButtons)-1)
		elif GameLogic.random.randi_range(1,10) <= 6:
			which = GameLogic.random.randi_range(0, len(availableButtons)-1)
		availableButtons[which].emit_signal("pressed")
	# metacontrol
	elapsedSteps += 1
	if elapsedSteps >= maxSteps:
		FinishSummary()
		get_tree().quit()

func _process(delta):
	time += delta
	if time > TIME_PERIOD:
		time = 0
		TestStep()
