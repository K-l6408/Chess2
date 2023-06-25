extends Panel

var Pieces = preload("res://Assets/Pieces.png")

func _input(event):
	if (event is InputEventMouseButton) and event.pressed:
		var evLocal = make_input_local(event)
		if not Rect2(Vector2(0,0), size).has_point(evLocal.position):
			hide()

func _ready():
	for c in get_children():
		var k = c.texture_normal.region.position.x / 50
		c.connect("pressed", func(): emit_signal("promote", k as G.TilePieces))

signal promote(piece : G.TilePieces)
