extends Node

var player_name : String = "NONAME"

static func map_range(value: float, in_min: float, in_max: float, out_min: float, out_max: float) -> float:
	return out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min)
