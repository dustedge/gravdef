extends Node

var level_scenes: Array[PackedScene] = []

# "levelname : packedscene"
var level_packs : Array[LevelPack] = []

class LevelPack:
	var packname : String = "Unnamed Pack"
	var packicon : Texture = preload("res://sprites/pack_main.png")
	var levels : Array[GameLevel] = []
	
	func add_level(level : GameLevel) -> bool:
		if not level in self.levels:
			self.levels.append(level)
			level.owner_pack = self
			return true
		return false
	
	func get_next_level(curlevel : GameLevel) -> GameLevel:
		if curlevel in self.levels:
			var ix = levels.find(curlevel)
			if ix + 1 >= levels.size():
				return null
			print("Next Level: ", levels[ix + 1].levelname)
			return levels[ix + 1]
		return null
	
	func sort_levels():
		self.levels.sort_custom(func(a, b): return a.id < b.id)
		

class GameLevel:
	var id : int = 0
	var levelname : String = "Unnamed Level"
	var owner_pack : LevelPack
	var scene : PackedScene

var current_level : GameLevel
var current_level_pack : LevelPack

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("LevelManager: Loading Packs & Levels")
	load_all_levels_recursive("res://worlds/")
	
	print("LevelManager: Sorting Packs")
	for pack in level_packs:
		pack.sort_levels()

func load_all_levels_recursive(from_path : String):
	print("Loading from ", from_path)
	var dir = DirAccess.open(from_path)
	if dir == null:
		print("Not found: ", from_path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var ext = ".tscn"
	var icon_file_name = "icon"
	var files = []
	
	while file_name != "":
		print("Processing file ", file_name)
		file_name = file_name.replace(".remap", '')
		if dir.current_is_dir() and not file_name.begins_with("."):
			load_all_levels_recursive(from_path + "/" + file_name)
		
		elif file_name.trim_suffix("." + file_name.get_extension()) == "icon":
			var levelpack_name = get_last_dir_name(from_path)
			load_levelpack_icon(from_path + "/" + file_name, levelpack_name)
		
		elif file_name.ends_with(ext):
			var file_path = from_path + "/" + file_name
			var levelpack_name = get_last_dir_name(from_path)
			load_new_game_level(file_path, levelpack_name)
		file_name = dir.get_next()
		

func load_levelpack_icon(path : String, levelpack_name: String) -> bool:
	
	var loaded_icon = ResourceLoader.load(path)
	if not loaded_icon:
		print("Icon load: Failed to load: " + path)
	
	for pack in level_packs:
		if pack.packname == levelpack_name:
			pack.packicon = loaded_icon
			return true
	
	print("Icon load: Levelpack " + levelpack_name + " not found. Adding new...")
	var new_pack : LevelPack = LevelPack.new()
	new_pack.packname = levelpack_name
	new_pack.packicon = loaded_icon
	level_packs.append(new_pack)
	return true

func load_new_game_level(path : String, packname : String) -> bool:
	var level_scene = ResourceLoader.load(path)
	if level_scene and level_scene is PackedScene:
		print("Loading: ", path)
		
		# create level instance and setup
		var level_inst : Level = level_scene.instantiate()
		var packfound = false
		
		var new_level : GameLevel = GameLevel.new()
		new_level.levelname = level_inst.level_name
		new_level.id = level_inst.id
		new_level.scene = level_scene
		
		for pack : LevelPack in level_packs:
			if pack.packname == packname:
				print(
				"Levelpack {0} exists. Adding level:\n    ID: {1}\n    Name: {2}"\
				.format([packname, new_level.id, new_level.levelname])
				)
				packfound = true
				pack.add_level(new_level)
				return true
		
		if not packfound:
			# create new pack and add level to it
			print(
				"Levelpack {0} not found. Adding as new.\nAdding level:\n    ID: {1}\n    Name: {2}"\
				.format([packname, new_level.id, new_level.levelname])
			)
			var new_pack : LevelPack = LevelPack.new()
			new_pack.packname = packname
			new_pack.add_level(new_level)
			level_packs.append(new_pack)
			return true
	print ("Failed to load", path)
	return false

func load_next_level():
	current_level = current_level.owner_pack.get_next_level(current_level)
	if is_instance_valid(current_level):
		get_tree().change_scene_to_packed(current_level.scene)
		return
	#fallback to menu if current_level is null
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func get_last_dir_name(path : String) -> String:
	var parts : Array = path.split("/")
	if parts.size() > 0:
		return parts.back()
	else: 
		return "Error: get_last_dir_name() -> Directory Missing"
		
func load_scene(path : String):
	var scene = ResourceLoader.load(path)
	if scene and scene is PackedScene:
		print("Loaded: ", path)
		return scene
	print ("Failed to load", path)
	return null
