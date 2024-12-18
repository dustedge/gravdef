extends Node


class TimeEntry:
	var player_name : String
	var elapsed_time : float

var level_times_file : ConfigFile = ConfigFile.new()

var level_times : Dictionary = {
	### "levelname" : [scoreentries]
}

var allowed_entries_per_level := 20

func _ready() -> void:
	load_levels_times()

func get_level_times(level_name : String) -> Array:
	if not level_name in level_times.keys():
		level_times[level_name] = []
	return level_times[level_name]

func add_level_time(elapsed_time : float, level_name : String = LevelManager.current_level, player_name : String = Globals.player_name):
	var entry = []
	entry.append(player_name) 
	entry.append(elapsed_time)
	
	if not level_name in level_times.keys():
		level_times[level_name] = []
		
	level_times[level_name].append(entry)
	level_times[level_name].sort()
	#level_times[level_name].reverse()
	
	if level_times[level_name].size() > allowed_entries_per_level:
		while level_times[level_name].size() > allowed_entries_per_level:
			level_times[level_name].pop_back()
	save_level_times()

func load_levels_times():
	var err = level_times_file.load("user://savedata.sav")
	if err != OK:
		return
	# section is level name
	for section in level_times_file.get_sections():
		level_times[section] = level_times_file.get_value(section, "times")
	return

func save_level_times():
	for key in level_times.keys():
		level_times_file.set_value(key, "times", level_times[key])
	level_times_file.save("user://savedata.sav")
	
