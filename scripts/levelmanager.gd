extends Node

var level_scenes: Array[PackedScene] = []

# "levelname : packedscene"
var levels : Dictionary = {}

var current_level : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_all_levels("res://worlds/")

func load_all_levels(from_path : String):
	var dir = DirAccess.open(from_path)
	if dir == null:
		print("Not found: ", from_path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tscn"):
			var file_path = from_path + "/" + file_name
			var scene = load_scene(file_path)
			if scene:
				var level : Level = scene.instantiate()
				levels[level.level_name] = scene
				level.queue_free()
				level_scenes.append(scene)
		file_name = dir.get_next()
	pass

func load_scene(path : String):
	var scene = ResourceLoader.load(path)
	if scene and scene is PackedScene:
		print("Loaded: ", path)
		return scene
	print ("Failed to load", path)
	return null

func load_next_level():
	if current_level in levels.keys():
		var load_next = false
		for key in levels.keys():
			if key == current_level:
				load_next = true
			elif load_next:
				get_tree().change_scene_to_packed(levels[key])
				return
	#fallback to menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
