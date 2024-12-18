extends Control
class_name MainMenu

@onready var level_item_list : ItemList = $LevelSelectorMenu/VBoxContainer/SelectorContainer/LevelItemList

func _ready() -> void:
	# fetch levels and populate item list
	fill_level_list(level_item_list)
	
func fill_level_list(item_list : ItemList):
	var counter := 1
	for levelname in LevelManager.levels.keys():
		item_list.add_item(str(counter) + ". " + levelname)
		counter += 1

func _on_level_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if not mouse_button_index == MOUSE_BUTTON_LEFT:
		return
	var lvl_name = level_item_list.get_item_text(index)
	lvl_name = trim_number_prefix(lvl_name)
	print("Loading level: ", lvl_name)
	LevelManager.current_level = lvl_name
	get_tree().change_scene_to_packed(LevelManager.levels[lvl_name])

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
