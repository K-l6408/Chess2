extends Panel

func _input(event):
	if (event is InputEventMouseButton) and event.pressed:
		var evLocal = make_input_local(event)
		if not Rect2(Vector2(0,0), size).has_point(evLocal.position):
			hide()
