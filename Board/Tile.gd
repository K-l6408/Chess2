@tool

extends TextureButton

class_name Tile

@export var Status : G.TileStatus
@export var Piece  : G.TilePieces
@export var Colour : G.Colours
@export var Position : Vector2i

@export var top : Tile
@export var right : Tile
@export var bottom : Tile
@export var left : Tile
var topright : Tile
var bottomright : Tile
var topleft : Tile
var bottomleft : Tile

var dirs := ["top", "topleft", "topright", "left", "right", "bottom", "bottomleft", "bottomright"]
var orþg := ["top", "left", "right", "bottom"]

var from : Tile
var Reverse : bool = false
var Moved : bool = false
var Monarchs := [
	G.TilePieces.monarchM, G.TilePieces.monarchF, G.TilePieces.monarchX
]

var Pieces = preload("res://Assets/Pieces.png")

func _ready():
	var AT = AtlasTexture.new()
	AT.atlas = Pieces
	AT.region.size = Vector2(50, 50)
	$Piece.texture = AT

func _process(_delta):
	if $Piece.texture is AtlasTexture:
		$Piece.texture.region.position = Vector2(Piece * 50, 0)
	
	if Piece == G.TilePieces.empty:
		var sk = G.TilePieces.skeleton
		if top:
			if top.top:
				if top.Piece == sk or top.top.Piece == sk:
					pass
	
	if Colour == G.Colours.red:
		$Piece.modulate = Color.RED
	if Colour == G.Colours.blue:
		$Piece.modulate = Color.DODGER_BLUE
	
	if Reverse:
		$Piece.rotation = PI
	else:
		$Piece.rotation = 0
	
	if top:
		topleft = top.left
	elif left:
		topleft = left.top
	
	if bottom:
		bottomleft = bottom.left
	elif left:
		bottomleft = left.bottom
	
	if top:
		topright = top.right
	elif right:
		topright = right.top
	
	if bottom:
		bottomright = bottom.right
	elif right:
		bottomright = right.bottom
	
	$St.animation = "-MXG"[Status]
	
	$Ice.hide()
	if Piece != G.TilePieces.empty and Piece != G.TilePieces.skeleton:
		for D in orþg:
			if get(D):
				var J = get(D)
				if J.Piece == G.TilePieces.skeleton and J.Colour != Colour:
					$Ice.show()
				if get(D).get(D):
					var j = get(D).get(D)
					if j.Piece == G.TilePieces.skeleton and j.Colour != Colour:
						$Ice.show()

func _on_pressed():
	if Status == G.TileStatus.gender:
		Status = G.TileStatus.ok
		emit_signal("press", self)
	if Colour == G.Colours.empty:
		if Status != G.TileStatus.ok:
			if Globals.can_passant.has(self):
				var FR = Globals.can_passant[self]
				FR.Piece = G.TilePieces.empty
				FR.Colour = G.Colours.empty
				FR.Reverse = false
				FR.Moved = true
				Globals.can_passant = {}
			elif from.Piece == G.TilePieces.pawn or from.Piece == G.TilePieces.colonel or from.Piece == G.TilePieces.general:
				Globals.can_passant = {}
				if abs(Position.y - from.Position.y) > 1:
					var j = self
					if from.Reverse:
						while j != from:
							j = j.top
							Globals.can_passant[j] = self
					else:
						while j != from:
							j = j.bottom
							Globals.can_passant[j] = self
			else:
				Globals.can_passant = {}
			Piece = from.Piece
			Colour = from.Colour
			Reverse = from.Reverse
			Moved = true
			from.Piece = G.TilePieces.empty
			from.Colour = G.Colours.empty
			from.Reverse = false
			from.Moved = true
		emit_signal("press", self)
		return
	if Globals.turn != Colour:
		if Status == G.TileStatus.capture:
			Piece = from.Piece
			Colour = from.Colour
			Reverse = from.Reverse
			Moved = true
			from.Piece = G.TilePieces.empty
			from.Colour = G.Colours.empty
			from.Reverse = false
			from.Moved = true
			emit_signal("press", self)
		return
	if Globals.boardStatus: Globals.boardStatus = false
	else:
		Globals.boardStatus = true
		emit_signal("press", self)
	match Piece:
		G.TilePieces.empty:
			return
		G.TilePieces.pawn:
			pawn(1)
		G.TilePieces.colonel:
			pawn(2)
		G.TilePieces.general:
			pawn(3)
		G.TilePieces.imposter:
			for D in dirs:
				if goto(get(D)) and get(D).get(D):
					if get(D).get(D).Piece != G.TilePieces.empty and get(D).get(D).Colour != Colour:
						goto(get(D).get(D))
		G.TilePieces.skeleton:
			if goto(topleft):
				goto(topleft.get("top"))
				goto(topleft.get("left"))
			if goto(topright):
				goto(topright.get("top"))
				goto(topright.get("right"))
			if goto(bottomleft):
				goto(bottomleft.get("bottom"))
				goto(bottomleft.get("left"))
			if goto(bottomright):
				goto(bottomright.get("bottom"))
				goto(bottomright.get("right"))
		G.TilePieces.rook:
			move("top")
			move("left")
			move("right")
			move("bottom")
		G.TilePieces.bishop:
			move("topleft")
			move("topright")
			move("bottomright")
			move("bottomleft")
		G.TilePieces.knight:
			knight()
			goto(topleft.topleft)
			goto(topright.topright)
			goto(bottomleft.bottomleft)
			goto(bottomright.bottomright)
		G.TilePieces.knook:
			knight()
			move("top")
			move("left")
			move("right")
			move("bottom")
		G.TilePieces.knishop:
			knight()
			move("topleft")
			move("topright")
			move("bottomright")
			move("bottomleft")
		G.TilePieces.knight2:
			if topleft:
				if topleft.top.Piece == G.TilePieces.empty:
					topleft.top.knight(self)
				elif topleft.top.Colour != Colour:
					goto(topleft.top)
				if topleft.left.Piece == G.TilePieces.empty:
					topleft.left.knight(self)
				elif topleft.left.Colour != Colour:
					goto(topleft.left)
			if bottomleft:
				if bottomleft.bottom.Piece == G.TilePieces.empty:
					bottomleft.bottom.knight(self)
				elif bottomleft.bottom.Colour != Colour:
					goto(bottomleft.bottom)
				if bottomleft.left.Piece == G.TilePieces.empty:
					bottomleft.left.knight(self)
				elif bottomleft.left.Colour != Colour:
					goto(bottomleft.left)
			if topright:
				if topright.top.Piece == G.TilePieces.empty:
					topright.top.knight(self)
				elif topright.top.Colour != Colour:
					goto(topright.top)
				if topright.right.Piece == G.TilePieces.empty:
					topright.right.knight(self)
				elif topright.right.Colour != Colour:
					goto(topright.right)
			if bottomright:
				if bottomright.bottom.Piece == G.TilePieces.empty:
					bottomright.bottom.knight(self)
				elif bottomright.bottom.Colour != Colour:
					goto(bottomright.bottom)
				if bottomright.right.Piece == G.TilePieces.empty:
					bottomright.right.knight(self)
				elif bottomright.right.Colour != Colour:
					goto(bottomright.right)
		G.TilePieces.electron:
			if goto(top):
				if top.Piece == G.TilePieces.empty:
					goto(top.top)
					if Globals.rand == Reverse:
						goto(top.topleft)
					else:
						goto(top.topright)
			if goto(bottom):
				if bottom.Piece == G.TilePieces.empty:
					goto(bottom.bottom)
					if Globals.rand != Reverse:
						goto(bottom.bottomleft)
					else:
						goto(bottom.bottomright)
		G.TilePieces.plane:
			move("top", 3)
			move("left", 3)
			move("right", 3)
			move("bottom", 3)
			move("topleft", 2)
			move("topright", 2)
			move("bottomleft", 2)
			move("bottomright", 2)
		G.TilePieces.monarchM:
			goto(top)
			goto(left)
			goto(right)
			goto(bottom)
			move("topleft")
			move("topright")
			move("bottomleft")
			move("bottomright")
		G.TilePieces.monarchF:
			move("top")
			move("left")
			move("right")
			move("bottom")
			goto(topleft)
			goto(topright)
			goto(bottomleft)
			goto(bottomright)
		G.TilePieces.monarchX:
			knight()
			if top:
				goto(top.top)
				goto(topleft.topleft)
				goto(topright.topright)
			goto(left.left)
			goto(right.right)
			if bottom:
				goto(bottom.bottom)
				goto(bottomleft.bottomleft)
				goto(bottomright.bottomright)
	
	if Piece in Monarchs:
		Status = G.TileStatus.gender
		$"Gender/1".texture_normal.region.position.x = 750 if \
		Piece == G.TilePieces.monarchF else 800
		$"Gender/2".texture_normal.region.position.x = 750 if \
		Piece == G.TilePieces.monarchM else 850
		match Colour:
			G.Colours.blue:
				$Gender.position = Vector2(343, 689)
			G.Colours.red:
				$Gender.position = Vector2(343, 0)
		$Gender.show()
	
	Globals.boardStatus = false

func genderbend(gender):
	if not Piece in Monarchs:
		return
	if gender == 1:
		Piece = G.TilePieces.monarchX if \
		Piece == G.TilePieces.monarchF else G.TilePieces.monarchF
	else:
		Piece = G.TilePieces.monarchX if \
		Piece == G.TilePieces.monarchM else G.TilePieces.monarchM
	emit_signal("press", self)

func knight(T:Tile=self):
	if topleft:
		T.goto(topleft.top)
		T.goto(topleft.left)
	if bottomleft:
		T.goto(bottomleft.bottom)
		T.goto(bottomleft.left)
	if topright:
		T.goto(topright.top)
		T.goto(topright.right)
	if bottomright:
		T.goto(bottomright.bottom)
		T.goto(bottomright.right)

func pawn(pw:int):
	var Get = "top"
	if Reverse:
		Get = "bottom"
		goto(top)
	else:
		goto(bottom)
	var T : Tile = self
	for i in pw:
		T = T.get(Get)
		if T == null:
			return
		if T.left in Globals.can_passant or T.left.Colour != Colour and T.left.Piece != G.TilePieces.empty:
			goto(T.left)
		if T.left in Globals.can_passant:
			T.left.Status = G.TileStatus.capture
		if T.right in Globals.can_passant or T.right.Colour != Colour and T.right.Piece != G.TilePieces.empty:
			goto(T.right)
		if T.right in Globals.can_passant:
			T.right.Status = G.TileStatus.capture
		if T.Piece:
			T = null
			break
		goto(T)
	if T and not Moved and not T.get(Get).Piece:
		goto(T.get(Get))

func move(dir : String, num = -1):
	var T : Tile = get(dir)
	var TA = []
	var n = 0
	while T != null:
		n += 1
		if T in TA:
			break
		if not goto(T):
			break
		TA.append(T)
		T = T.get(dir)
		if num == n:
			break

func goto(T:Tile):
	if T == null or $Ice.visible: return false
	T.from = self
	if T.Piece == G.TilePieces.empty:
		T.Status = G.TileStatus.move
		return true
	elif T.Colour != Colour:
		T.Status = G.TileStatus.capture
	return false

signal press(slf)
