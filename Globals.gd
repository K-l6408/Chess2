extends Node
class_name G

enum TileStatus {
	ok, move, capture, gender, explode
}
enum TilePieces {
	empty, pawn, colonel, general,
	imposter, skeleton, bomb,
	knight, bishop, rook, electron,
	knight2, knishop, knook, plane,
	monarchX, monarchF, monarchM
}
const StrPieces = " pcgisunbreńƃŕaxfmṕćǵ"
const PromoteTo = "isnbreńƃŕa"
const Orþ = [Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0), Vector2i(0,-1)]
const Diag = [Vector2i(1,1), Vector2i(-1,1), Vector2i(-1,-1), Vector2i(1,-1)]

enum Colours {
	empty, blue, red, END
}

var turn : Colours = Colours.blue
var boardStatus : bool = true # true = no move, false = move
var can_passant : Dictionary = {}
var rand : bool
var predict : bool = false
var moves : PackedStringArray = []
var end := false

func get_moves(status:PackedStringArray, whom:bool):
	var _moves : Array[PackedStringArray]
	for  column in 12:
		for row in 12:
			var nm = status.duplicate()
			var ps = Vector2i(row, column)
			var sq = status[column][row]
			var pc = sq.to_lower()
			var skp = false
			if pc == sq and whom:
				for d in Orþ: # check for enemy skeletons
					if check_square(status, ps+d) == "S" or check_square(status, ps+d*2) == "S":
						skp = true
						break
				if skp: continue
				match pc:
					"u":
						_moves.append([
							"            ",
							"            ",
							"            ",
							"            ",
							"            ",
							"            ",
							"            ",
							"            ",
							"            ",
							"            ",
							"            ",
							"            "
						]) # kaboom
					

func check_square(status:PackedStringArray, position:Vector2i):
	if position.y > status.size() or position.y < 0:
		return "_" # invalid
	position.x %= 12
	return status[position.y][position.x]
