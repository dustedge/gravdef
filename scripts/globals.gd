extends Node

var player_name : String = "NONAME"

static func map_range(value: float, in_min: float, in_max: float, out_min: float, out_max: float) -> float:
	return out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min)

enum Difficulty {
	BREEZE,
	EASY,
	NORMAL,
	HARD,
	STRESSFUL,
	EXPERT
}

var difficulty_colors : Dictionary = {
	Difficulty.BREEZE 		: Color.LIGHT_GREEN,
	Difficulty.EASY 		: Color.GREEN,
	Difficulty.NORMAL 		: Color.CYAN,
	Difficulty.HARD 		: Color.BLUE,
	Difficulty.STRESSFUL 	: Color.PURPLE,
	Difficulty.EXPERT 		: Color.RED,
}

var difficulty_prefix : Dictionary = {
	Difficulty.BREEZE 		: "☆☆☆☆☆",
	Difficulty.EASY 		: "★☆☆☆☆",
	Difficulty.NORMAL 		: "★★☆☆☆",
	Difficulty.HARD 		: "★★★☆☆",
	Difficulty.STRESSFUL 	: "★★★★☆",
	Difficulty.EXPERT 		: "★★★★★"
}
