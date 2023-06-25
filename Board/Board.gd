extends GridContainer

const alph = "ABCDEFGHIKLM"
var squares = preload("res://Assets/Squares.png")
var tile = preload("res://Board/Tile.tscn")

var Tiles : Array[Tile]
var Status:
	get:
		var A : PackedStringArray
		var str : String = ""
		for I in 144:
			if Tiles[I].Colour == G.Colours.red:
				str += G.StrPieces[Tiles[I].Piece].to_upper()
			else:
				str += G.StrPieces[Tiles[I].Piece]
			if I % 12 == 11:
				A.append(str)
				str = ""
		return A

func _unhandled_input(event):
	if Globals.end:
		get_viewport().set_input_as_handled()

func _ready():
	for I in 144:
		var B = tile.instantiate()
		B.name = "%s%d" % [alph[I/12], I%12+1]
		var T = AtlasTexture.new()
		T.atlas = squares
		T.region.size = Vector2(50, 50)
		match I % 12:
			0:
				T.region.position.x = 100
			11:
				T.region.position.x = 50
			_:
				T.region.position.x = 0
		if (I + I / 12) % 2 == 0:
			T.region.position.y = 50
		else:
			T.region.position.y = 0
		B.texture_normal = T
		B.connect("press", _refresh)
		B.connect("boom", win.bind("Everyone\nLoses", Color("0005")))
		Tiles.append(B)
		add_child(B)
	
	for I in 144:
		var B : Tile = Tiles[I]
		var L = I / 12
		var N = I % 12
		
		B.Position = Vector2i(N, 12-L)
		
		if L != 0:
			B.top = Tiles[(L-1) * 12 + N]
		if L != 11:
			B.bottom = Tiles[(L+1) * 12 + N]
		
		if N != 11:
			B.right = Tiles[L * 12 + N+1]
		else:
			B.right = Tiles[L * 12]
		
		if N != 0:
			B.left = Tiles[L * 12 + N-1]
		else:
			B.left = Tiles[L * 12 + 11]
		
		if L == 0 or L == 11:
			match N:
				0, 6:
					B.Piece = G.TilePieces.monarchX
				1, 7:
					B.Piece = G.TilePieces.plane
				2, 8:
					B.Piece = G.TilePieces.knishop
				3, 9:
					B.Piece = G.TilePieces.knook
				4, 10:
					B.Piece = G.TilePieces.knight2
				5:
					B.Piece = G.TilePieces.electron
					B.Reverse = false
				11:
					B.Piece = G.TilePieces.electron
					B.Reverse = true
		if L == 1 or L == 10:
			match N:
				0, 6:
					B.Piece = G.TilePieces.rook
				1, 7:
					B.Piece = G.TilePieces.knight
				2, 8:
					B.Piece = G.TilePieces.skeleton
				3, 9:
					B.Piece = G.TilePieces.bomb
				4, 10:
					B.Piece = G.TilePieces.imposter
				5, 11:
					B.Piece = G.TilePieces.bishop
		if L == 2 or L == 9:
			match N:
				0, 1, 5, 6, 7, 11:
					B.Piece = G.TilePieces.pawn
				2, 4, 8, 10:
					B.Piece = G.TilePieces.colonel
				3, 9:
					B.Piece = G.TilePieces.general
		if L < 3:
			B.Colour = G.Colours.red
		if L > 8:
			B.Colour = G.Colours.blue
		if L == 2:
			B.Reverse = true

func _refresh(t:Tile):
	if t.Piece == G.TilePieces.pawn:
		if t.Position.y == 12 and not t.Reverse:
			t.Piece = G.TilePieces.colonel
			t.Reverse = true
			t.Moved = false
		if t.Position.y == 1 and t.Reverse:
			t.Piece = G.TilePieces.colonel
			t.Reverse = false
			t.Moved = false
	elif t.Piece == G.TilePieces.colonel:
		if t.Position.y == 12 and not t.Reverse:
			t.Piece = G.TilePieces.general
			t.Reverse = true
			t.Moved = false
		if t.Position.y == 1 and t.Reverse:
			t.Piece = G.TilePieces.general
			t.Reverse = false
			t.Moved = false
	elif t.Piece == G.TilePieces.general:
		if (t.Position.y == 12 and not t.Reverse) \
			or (t.Position.y == 1 and t.Reverse):
			$Idc/Panel.show()
			t.Piece = await $Idc/Panel.promote
			t.Reverse = false
			t.Moved = false
	else:
		Globals.can_passant = {}
	if t.Status:
		Globals.rand = (randi() % 2 == 0)
		Globals.turn += 1
		if Globals.turn == G.Colours.END:
			Globals.turn = 1
	var RM := false
	var BM := false
	for i in Tiles:
		i.Status = G.TileStatus.ok
		if i.Colour == G.Colours.blue and i.Piece in Tile.Monarchs:
			BM = true
		if i.Colour == G.Colours.red  and i.Piece in Tile.Monarchs:
			RM = true
	if not BM:
		win("Red Wins", Color("c005"))
	elif not RM:
		win("Blue Wins", Color("00c5"))

func win(T, C):
	Globals.end = true
	var W = load("res://Win.tscn").instantiate()
	W.Text = T
	W.Colr = C
	$Idc.add_child(W)
