@tool
extends Panel

@export var Colr := Color("0005")
@export var Text := "Everyone\n loses "

func _process(delta):
	get_theme_stylebox("panel").bg_color = Colr
	$Label.text = Text
