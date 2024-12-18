extends CanvasLayer
class_name PlayerUI

@onready var player : Player = get_parent()
@onready var time_label : Label = $TimeLabel
@onready var finish_time_label : Label = $EndScreen/VBoxContainer/FinishTimeLabel
@onready var medal_sprite : Sprite2D = $EndScreen/VBoxContainer/MedalContainer/MedalProxy/MedalSprite

@onready var score_template : Label = $ScoresContainer/_ScoreTemplate

enum Medal {
	GOLD,
	SILVER,
	COPPER,
	NONE
}

var medal_sprite_frames : Dictionary = {
	Medal.GOLD : 0,
	Medal.SILVER : 1,
	Medal.COPPER : 2,
	Medal.NONE : 3
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$EndScreen.hide()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $LevelNameLabel.text != LevelManager.current_level:
		$LevelNameLabel.text = LevelManager.current_level
	if not is_instance_valid(player) or\
	not is_instance_valid(time_label):
		return
	time_label.text = get_time_str(player.elapsed_time)
	
	update_leaderboards()
	
func get_time_str(time : float):
	
	var milis = int((time - int(time)) * 100)
	var seconds = int(time) % 60
	var minutes = int(time) / 60
	
	return "TIME: " + ( "%02d:%02d.%02d" % [minutes, seconds, milis] ) 
	
func end_screen():
	if $EndScreen.visible:
		return
		
	$EndScreen.show()
	if player.is_dead:
		finish_time_label.text = "TIME: DNF"
		medal_sprite.frame = medal_sprite_frames[Medal.NONE]
		return
	else: 
		finish_time_label.text = get_time_str(player.elapsed_time)
	
	var times = player.fetch_level_times()
	
	# 0 - gold 1 - silver 2 - copper
	
	if player.elapsed_time <= times[0]:
		medal_sprite.frame = medal_sprite_frames[Medal.GOLD]
		
	elif player.elapsed_time <= times[1]:
		medal_sprite.frame = medal_sprite_frames[Medal.SILVER]
		
	elif player.elapsed_time <= times[2]:
		medal_sprite.frame = medal_sprite_frames[Medal.COPPER]
		
	else: 
		medal_sprite.frame = medal_sprite_frames[Medal.NONE]
	
	

func _on_exit_button_pressed() -> void:
	# goto main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	pass # Replace with function body.


func _on_retry_button_pressed() -> void:
	# reload level scene
	get_tree().reload_current_scene()
	pass # Replace with function body.


func _on_next_button_pressed() -> void:
	# load next level
	LevelManager.load_next_level()
	pass # Replace with function body.

func update_leaderboards():
	## fix this retarded stuff
	
	var scores = ScoreManager.get_level_times(LevelManager.current_level)
	## cleanup
	for child : Label in $ScoresContainer.get_children():
		if not child.name.begins_with("_"):
			child.name = "_removed_" + child.name
			child.queue_free()
	
	var counter := 1
	for entry in scores:
		var new_label = score_template.duplicate()
		new_label.text = "{0}. {1}: {2}".format([counter, entry[0], get_time_str(entry[1]).trim_prefix("TIME: ")])
		counter += 1 
		$ScoresContainer.add_child(new_label)
		new_label.show()
	pass
