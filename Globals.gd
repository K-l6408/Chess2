extends Node
class_name G

enum TileStatus {
	ok, move, capture, gender
}
enum TilePieces {
	empty, pawn, colonel, general,
	imposter, skeleton, bomb,
	knight, bishop, rook, electron,
	knight2, knishop, knook, plane,
	monarchX, monarchF, monarchM
}
const StrPieces = " pcgisunbreńƃŕaxfm"

enum Colours {
	empty, blue, red, END
}

var turn : Colours = Colours.blue
var boardStatus : bool = true # true = no move, false = move
var can_passant : Dictionary = {}
var rand : bool
var predict : bool = false
var moves : PackedStringArray = []
