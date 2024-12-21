extends Control
class_name MainMenu

@onready var level_item_list : ItemList = $LevelSelectorMenu/VBoxContainer/SelectorContainer/LevelItemList
@onready var levelpack_item_list : ItemList = $LevelSelectorMenu/VBoxContainer/SelectorContainer/PackItemList
func _ready() -> void:
	# fetch levelpacks and populate packlist
	refresh_level_packs() 
	
	
func refresh_level_packs():
	for pack in LevelManager.level_packs:
		var item_ix = levelpack_item_list.add_item(pack.packname, pack.packicon)
		levelpack_item_list.set_item_metadata(item_ix, pack)

func _on_level_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if not mouse_button_index == MOUSE_BUTTON_LEFT:
		return
	var clicked_level : LevelManager.GameLevel = level_item_list.get_item_metadata(index)
	print("Loading level: ", clicked_level.levelname)
	LevelManager.current_level = clicked_level
	get_tree().change_scene_to_packed(clicked_level.scene)

func trim_number_prefix(string : String):
	var regex = RegEx.new()
	regex.compile(r"^\d+\.\s*")
	return regex.sub(string, "", 1)


func _on_play_button_pressed() -> void:
	$LevelSelectorMenu.show()
	pass # Replace with function body.


func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_hide_level_selector_button_pressed() -> void:
	$LevelSelectorMenu.hide()


func _on_name_line_edit_text_changed(new_text: String) -> void:
	if not new_text.is_empty():
		Globals.player_name = new_text.to_upper()
	else:
		Globals.player_name = "NONAME"


func _on_pack_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	# Pack selected ->
	#	clear level list
	#	fill level list from pack
	var pack : LevelManager.LevelPack = levelpack_item_list.get_item_metadata(index)
	fill_levels(pack)
	
func fill_levels(levelpack : LevelManager.LevelPack):
	level_item_list.clear()
	for level in levelpack.levels:
		var dif_prefix = Globals.difficulty_prefix[level.difficulty]
		var printstr = (str(level.id) + ". " + level.levelname).rpad(22)
		var item_ix = level_item_list.add_item(printstr + " " + dif_prefix)
		level_item_list.set_item_metadata(item_ix, level)
