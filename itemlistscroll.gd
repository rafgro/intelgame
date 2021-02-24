extends ItemList

onready var Scroller: VScrollBar = self.get_v_scroll()

func _ready():
	self.connect("gui_input", self, "_on_gui_input")

func _on_gui_input(event: InputEvent):
	if event is InputEventScreenDrag:
		self.Scroller.value -= event.relative.y
