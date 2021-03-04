extends Node

# testing module
var maxSteps = 3
var elapsedSteps = 0

signal timeout
const TIME_PERIOD = 3.0 # 1000ms
var time = 0
var availableButtons = []
var availableTabChanges = []
var availableItemLists = []

func RecursiveClickSearch(current):
	for x in current.get_children():
		if x is Button:
			if x.disabled == false:
				availableButtons.append(x)
		#elif x is TabContainer:
		#	availableTabChanges.append(x)
		#	RecursiveClickSearch(x)
		elif x is ItemList:
			availableItemLists.append(x)
		else: RecursiveClickSearch(x)

func TestStep():
	print("Second!")
	# traversing the tree to find all the buttons
	availableButtons.clear()
	RecursiveClickSearch(get_tree().get_current_scene())
	if len(availableItemLists) > 0:
		var which = GameLogic.random.randi_range(0, len(availableItemLists)-1)
		var maxItems = availableItemLists[which].get_item_count()
		if maxItems > 0:
			availableItemLists[which].emit_signal("item_selected", GameLogic.random.randi_range(0, maxItems - 1))
	# metacontrol
	elapsedSteps += 1
	if elapsedSteps >= maxSteps:
		get_tree().quit()

func _process(delta):
	time += delta
	if time > TIME_PERIOD:
		time = 0
		TestStep()
