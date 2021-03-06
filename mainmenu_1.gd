extends Control

var quotes = [
	"\"Because something is not what it is said to be, Ma'am, does not mean it is a fake. It may just have been wrongly attributed\" // Alan Bennett",
	"\"I never quite believed that James Bond was a spy because everybody knew him, they all knew what he drank\" // Roger Moore",
	"\"His spies are seated round about\" // Rigveda",
	"\"No spy, however astute, is proof against relentless interrogation\" // Robin Stephens",
	"\"To MI5, if you steam this open you are dirty buggers\" // Letter framed on MI5 officer's office wall",
	"\"Nobody ever leaves the KGB\" // Rush Limbaugh",
	"\"He that has eyes to see and ears to hear may convince himself that no mortal can keep a secret\" // Sigmund Freud",
	"\"Not intelligent. Intelligence. Although it does help if your intelligence force was also intelligent\" // John Flanagan",
	"\"Operatives, as well as agents, typically fall into three categories - the idealists, the money-hungry and the afraid\" // Walter Talbot",
	"\"If you know neither the enemy nor yourself, you will succumb in every battle\" // Sun Tzu",
	"\"Regnum Defende - Defend the Realm\" // MI5 motto",
	"\"Semper Occultus (Always Secret)\" // MI6 motto",
	"\"And ye shall know the truth and the truth shall make you free.\" // unofficial CIA motto",
	"\"Faith, Unity, Discipline\" // ISI motto",
	"\"In every place where necessity makes law\" // DGSE motto",
	"\"Greatness of the Motherland in your glorious deeds\" // GRU motto",
	"\"Where there is no guidance, a nation falls, but in an abundance of counselors there is safety\" // Mossad motto",
]

func _ready():
	$C/V/M/R/Quote.text = quotes[randi() % quotes.size()]

func _on_NewRandom_pressed():
	get_tree().change_scene("res://mainmenu_newrandom.tscn")

func _on_NewScenario_pressed():
	pass # Replace with function body.

func _on_Load_pressed():
	pass # Replace with function body.

func _on_Quit_pressed():
	get_tree().quit()
