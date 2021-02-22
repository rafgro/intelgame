# Passes all data required by the call screen

extends Node

func EmptyFunc():
	pass

var CallQueue = []

"""
# Expected call structure
{
	"Header": "Urgent Decision",
	"Level": "Unspecified",
	"Operation": "Test",
	"Content": "Content.",
	"Show1": true,
	"Show2": true,
	"Show3": true,
	"Show4": true,
	"Text1": "",
	"Text2": "",
	"Text3": "",
	"Text4": "",
	"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
	"Decision1Argument": null,
	"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
	"Decision2Argument": null,
	"Decision3Callback": funcref(GameLogic, "EmptyFunc"),
	"Decision3Argument": null,
	"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
	"Decision4Argument": null,
}
"""
