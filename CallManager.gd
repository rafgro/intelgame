# Passes all data required by the call screen

extends Node

func EmptyFunc():
	pass

var Level = "Unspecified"
var Operation = "Test"
var Content = "Content."
var Decision1Callback = funcref(self, "EmptyFunc")
