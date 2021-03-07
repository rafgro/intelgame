extends Control

# slider constraints, 0-100 translated to min-max
var sizeMin = 1
var sizeMax = 150
var countriesMin = 1
var countriesMax = 10
var criminalMin = 2
var criminalMax = 30

func translate(theValue, theMin, theMax):
	if theValue == 0: return theMin
	if theValue == 100: return theMax
	return 0.01*theValue*(theMax-theMin)

func _ready():
	$C/V/M/R/Size/Label.text = "Country size: " + str(int(translate($C/V/M/R/Size/Slider.value, sizeMin, sizeMax))) + " mln"
	$C/V/M/R/Countries/Label.text = "Countries: " + str(int(translate($C/V/M/R/Countries/Slider.value, countriesMin, countriesMax)))
	$C/V/M/R/Criminal/Label.text = "Criminal Organizations: " + str(int(translate($C/V/M/R/Criminal/Slider.value, criminalMin, criminalMax)))

func _on_Back_pressed():
	get_tree().change_scene("res://mainmenu_1.tscn")

func _on_Start_pressed():
	WorldData.Countries[0].Size = int(translate($C/V/M/R/Size/Slider.value, sizeMin, sizeMax))
	WorldGenerator.howManyCountries = int(translate($C/V/M/R/Countries/Slider.value, countriesMin, countriesMax))
	WorldGenerator.howManyCriminal = int(translate($C/V/M/R/Criminal/Slider.value, criminalMin, criminalMax))
	GameLogic.TurnOnTerrorist = $C/V/M/R/ChTerror.pressed
	GameLogic.TurnOnWars = $C/V/M/R/ChWars.pressed
	GameLogic.TurnOnWMD = $C/V/M/R/ChWMD.pressed
	GameLogic.TurnOnInfiltration = $C/V/M/R/ChInfiltrate.pressed
	get_tree().change_scene("res://startplay.tscn")

func _on_SizeSlider_value_changed(value):
	$C/V/M/R/Size/Label.text = "Country size: " + str(int(translate(value, sizeMin, sizeMax))) + " mln"

func _on_CountriesSlider_value_changed(value):
	$C/V/M/R/Countries/Label.text = "Countries: " + str(int(translate(value, countriesMin, countriesMax)))

func _on_CriminalSlider_value_changed(value):
	$C/V/M/R/Criminal/Label.text = "Criminal Organizations: " + str(int(translate(value, criminalMin, criminalMax)))
