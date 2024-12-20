extends Node

# so the replays will work like this:
### Record
# when player started level it captures every [capture_interval] seconds:
#	player.global_position
#	player.rotation
#	player.anim_player.current_animation
#	player.vehicle.position 	# relative to player
#	player.front_wheel.position # relative to vehicle
#	player.back_wheeel.position	# relative to vehicle
#	time_stamp
#
# After is_finished or is_dead, recording stops and saves.
### Save
# Store last replay, and best replay [Optionally add ability to save current]
#	replay file: 
#	last_*levelstring*.replay
#	best_*levelstring*.replay
#	
#	Saving INI:
#		Section [Replay]
#		total_time : replay_time
#		frames	   : Array [ReplayFrame]
#	
#	if fetch_best_time(level) > total_time and player.is_finished:
#		save_best_replay(level)
#	
#	save_replay(level)
### Replay
# When player starts the level:
# for replay in loaded_replays:
#	var new_ghost = spawn_ghost(replay)
#	ghosts.append(new_ghost)
# 
# every frame -> update_ghosts()
# 


class ReplayFrame:
	var ghost_position 	: Vector2 	= Vector2.ZERO
	var ghost_rotation 	: float		= 0.0
	var time_stamp 		: float		= 0.0
	var ghost_animation : String	= "RESET"
	var vehicle_position: Vector2	= Vector2.ZERO
	var vehicle_rotation: float		= 0.0
	var front_wheel_pos	: Vector2	= Vector2.ZERO
	var back_wheel_pos	: Vector2	= Vector2.ZERO

class Replay:
	var total_time		: float		= 0.0
	var player_name		: String	= ""
	var frames: Array[ReplayFrame] 	= []

var capture_interval : float = 0.05
var total_elapsed : float = 0.0

var ghost_scene := preload("res://entities/ghost.tscn")
var is_recording := false
var recorded_frames : Array[ReplayFrame] = []
var current_replay : Replay = Replay.new()
var new_replay_name : String = ""
var capture_player : Player
var last_capture_time : float = 0.0
var started_at : float

var ghosts : Array[Ghost] = []

func _ready() -> void:
	# create replay directory if it does not exist
	var dir = DirAccess.open("user://")
	if !dir.dir_exists("replays/"):
		dir.make_dir("replays/")
		print("ReplayManager: Replay directory created")

func start_recording(player : Player, level : LevelManager.GameLevel = LevelManager.current_level):
	if player and level:
		capture_player = player
		current_replay = Replay.new()
		new_replay_name = level.owner_pack.packname + "_" + str(level.id)
		current_replay.player_name = Globals.player_name
		is_recording = true
		started_at = Time.get_ticks_msec() / 1000.0
		print("ReplayManager: Started recording")

func _process(delta: float) -> void:
	
	if is_recording and capture_player is Player:
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_capture_time >= capture_interval:
			current_replay.frames.append(capture_frame(capture_player))
			last_capture_time = current_time
		if capture_player.is_dead or capture_player.is_finished:
			stop_recording(capture_player)
		
func capture_frame(ply : Player) -> ReplayFrame:
	var new_frame : ReplayFrame = ReplayFrame.new()
	
	new_frame.ghost_position	= ply.global_position
	new_frame.ghost_rotation	= ply.rotation
	new_frame.ghost_animation	= ply.last_played_animation
	
	new_frame.vehicle_position 	= ply.vehicle.position
	new_frame.vehicle_rotation	= ply.vehicle.rotation
	new_frame.back_wheel_pos	= ply.back_wheel.position
	new_frame.front_wheel_pos	= ply.front_wheel.position
	
	new_frame.time_stamp = (Time.get_ticks_msec() / 1000.0) - started_at
	
	return new_frame

func spawn_ghost(replay : Replay, world : Level, color : Color = Color.GRAY):
	
	if replay.frames.is_empty():
		print("ReplayManager: Error: Spawn ghost: Replay frames is empty")
		return
	
	print("ReplayManager: Spawning ghost")
	var new_ghost : Ghost = ghost_scene.instantiate()
	color.a = 0.2
	new_ghost.modulate_to = color
	world.add_child(new_ghost)
	new_ghost.global_position = replay.frames[0].ghost_position
	new_ghost.call_deferred("start_replay", replay)
	ghosts.append(new_ghost)

func stop_recording(ply : Player, is_forced = false):
	if not is_recording:
		return
	
	print("ReplayManager: Stop recording")
		
	var filename_best = "best_{0}.replay".format([new_replay_name])
	var filename_last = "last_{0}.replay".format([new_replay_name])
	var beat_best = false
	
	var file_best : ConfigFile = ConfigFile.new()
	var err = file_best.load("user://replays/" + filename_best)
	
	# file best exists
	if err == OK:
		# check if current time is better than best time
		if file_best.get_value("Replay", "total_time", 9999999.0) > ply.elapsed_time:
			beat_best = true
	else: 
		# write new if cant load
		beat_best = true
	
	if ply.is_dead or is_forced:
		beat_best = false
	
	is_recording = false
	var newfile = ConfigFile.new()
	newfile.set_value("Replay", "total_time", ply.elapsed_time)
	newfile.set_value("Replay", "player_name", current_replay.player_name)
	newfile.set_value("Replay", "frames", serialize_frames(current_replay.frames))
	print("ReplayManager: Saved replay to ", filename_last)
	newfile.save("user://replays/" + filename_last)
	if beat_best:
		print("ReplayManager: Saved replay to ", filename_best)
		newfile.save("user://replays/" + filename_best)

func load_level_replays(world : Level, level : LevelManager.GameLevel = LevelManager.current_level, spawn_best = true, spawn_last = true):
	
	print("ReplayManager: Loading level replays for ", level.levelname)
	var levelstring = level.owner_pack.packname + "_" + str(level.id)
	var last_replay_filename = "best_{0}.replay".format([levelstring])
	var best_replay_filename = "last_{0}.replay".format([levelstring])
	# get replay files:
	var last_loaded = false
	var best_loaded = false
	
	var last_replay = ConfigFile.new()
	var err = last_replay.load("user://replays/" + last_replay_filename)
	if err == OK:
		print("ReplayManager: Loaded ", last_replay_filename)
		last_loaded = true
	
	var best_replay = ConfigFile.new()
	err = best_replay.load("user://replays/" + best_replay_filename)
	if err == OK:
		print("ReplayManager: Loaded ", best_replay_filename)
		best_loaded = true
		
	if last_loaded and spawn_last:
		var new_replay = Replay.new()
		new_replay.total_time = last_replay.get_value("Replay", "total_time")
		new_replay.player_name = last_replay.get_value("Replay", "player_name")
		new_replay.frames = deserialize_frames(last_replay.get_value("Replay", "frames"))
		spawn_ghost(new_replay, world, Color.YELLOW)
	
	if best_loaded and spawn_best:
		var new_replay = Replay.new()
		new_replay.total_time = best_replay.get_value("Replay", "total_time")
		new_replay.player_name = best_replay.get_value("Replay", "player_name")
		new_replay.frames = deserialize_frames(best_replay.get_value("Replay", "frames"))
		spawn_ghost(new_replay, world, Color.GREEN)


func serialize_frames(frames : Array[ReplayFrame]) -> Array[Dictionary]:
	var serialized : Array[Dictionary] = []
	for frame in frames:
		var frame_dict = {}
		frame_dict["ghost_position"] = frame.ghost_position   
		frame_dict["ghost_rotation"] = frame.ghost_rotation   
		frame_dict["ghost_animation"] = frame.ghost_animation  
		
		frame_dict["vehicle_position"] = frame.vehicle_position 
		frame_dict["vehicle_rotation"] = frame.vehicle_rotation 
		
		frame_dict["back_wheel_pos"] = frame.back_wheel_pos  
		frame_dict["front_wheel_pos"] = frame.front_wheel_pos 
		
		frame_dict["time_stamp"] = frame.time_stamp      
		
		serialized.append(frame_dict)
	return serialized
	
func deserialize_frames(data : Array[Dictionary]) -> Array[ReplayFrame]:
	var deserialized : Array[ReplayFrame] = []
	for frame_dict in data:
		var frame = ReplayFrame.new()
		frame.ghost_position   = frame_dict["ghost_position"] 
		frame.ghost_rotation   = frame_dict["ghost_rotation"] 
		frame.ghost_animation  = frame_dict["ghost_animation"]
		
		frame.vehicle_position = frame_dict["vehicle_position"]
		frame.vehicle_rotation = frame_dict["vehicle_rotation"]
		
		frame.back_wheel_pos   = frame_dict["back_wheel_pos"]
		frame.front_wheel_pos  = frame_dict["front_wheel_pos"]
		
		frame.time_stamp       = frame_dict["time_stamp"]
		deserialized.append(frame)
	return deserialized
