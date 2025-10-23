class_name PuzzleConst

enum Symbol {
	Pips = 0,
	Area = 1,
	Suit = 2,
	Eye = 3,
	Rook = 4,
	Bishop = 5,
	Queen = 6,
	Knight = 7,
	King = 8,
	Triangle = 9,
	Cross = 10,
	Key = 11,
	Arrow = 12
}
enum ColorID {
	Black = 0,
	Purple = 1,
	Red = 2,
	Blue = 3,
	Complement = 5 # Subtract Red or Blue from this to get the other color
}
enum Suit {
	Heart = 0,
	Spade = 1,
	Club = 2,
	Diamond = 3
}
enum ColorBlind {
	None = 0,
	Protanopia = 1,
	Tritanopia = 2
}

const ColorDict: Dictionary[String, int] ={
	"black": 0,
	"purple": 1,
	"red": 2,
	"blue": 3
}
