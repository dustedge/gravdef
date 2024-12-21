extends Node

var player_name : String = "NONAME"
var current_appearance : CharacterCustomizer.Appearance = CharacterCustomizer.Appearance.new()

static func map_range(value: float, in_min: float, in_max: float, out_min: float, out_max: float) -> float:
	return out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min)

var player_data : ConfigFile = ConfigFile.new()

func _ready() -> void:
	var err = player_data.load("user://settings.ini")
	if err == OK:
		load_player_config()


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

func save_player_config():
	player_data.set_value("Player", "player_name", player_name)
	player_data.set_value("Player", "appearance", CharacterCustomizer.serialize_appearance(current_appearance))
	player_data.save("user://settings.ini")
	
func load_player_config():
	player_name = player_data.get_value("Player", "player_name", "NONAME")
	current_appearance = CharacterCustomizer.deserialize_appearance(player_data.get_value("Player", "appearance", CharacterCustomizer.Appearance.new()))
