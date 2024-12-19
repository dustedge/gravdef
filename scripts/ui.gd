extends CanvasLayer
class_name PlayerUI

@onready var player : Player = get_parent()
@onready var time_label : Label = $TimeLabel
@onready var finish_time_label : Label = $EndScreen/VBoxContainer/FinishTimeLabel
@onready var medal_sprite : Sprite2D = $EndScreen/VBoxContainer/MedalContainer/MedalProxy/MedalSprite

@onready var score_template : Label = $ScoresContainer/_ScoreTemplate
@onready var speedometer_arrow : Sprite2D = $SpeedometerContainer/SpeedometerRoot/ArrowSprite
@onready var speedometer_speed_label : Label = $SpeedometerContainer/SpeedometerRoot/SpeedLabel
@onready var rpm_arrow : Sprite2D = $SpeedometerContainer/SpeedometerRoot/BodySprite/RpmRoot/RpmArrowSprite
@onready var rpm_label : Label = $SpeedometerContainer/SpeedometerRoot/BodySprite/RpmRoot/RpmLabel

var display_score_lines := 9
var arrow_root_rotation : float

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
	update_leaderboards()
	arrow_root_rotation = speedometer_arrow.rotation_degrees
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $LevelNameLabel.text != LevelManager.current_level:
		$LevelNameLabel.text = LevelManager.current_level
	if not is_instance_valid(player) or\
	not is_instance_valid(time_label):
		return
	time_label.text = get_time_str(player.elapsed_time)
	
	update_speed(delta)
	
	
func get_time_str(time : float):
	
	var milis = int((time - int(time)) * 100)
	var seconds = int(time) % 60
	var minutes = int(time) / 60
	
	return "TIME: " + ( "%02d:%02d.%02d" % [minutes, seconds, milis] ) 
	
func end_screen():
	if $EndScreen.visible:
		return
	update_leaderboards()
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
	scores.sort_custom(func(a, b) : return a[1] < b[1])
	for entry in scores:
		if counter >= display_score_lines:
			break
		var new_label : Label = score_template.duplicate()
		
		match counter:
			1:
				new_label.self_modulate = Color.GOLD
			2:
				new_label.self_modulate = Color.WHITE
			3:
				new_label.self_modulate = Color.WHITE
			_:
				new_label.self_modulate = Color.DARK_GRAY
		
		new_label.text = "{0}. {1} : {2}".format([counter, str(entry[0]).rpad(6, " "), get_time_str(entry[1]).trim_prefix("TIME: ")])
		counter += 1 
		$ScoresContainer.add_child(new_label)
		new_label.show()
	pass

func update_speed(delta):
	var ply_speed = int(player.linear_velocity.length()/5)
	var ply_rpm = int(abs(player.back_wheel.angular_velocity))
	
	if player.is_dead: ply_speed = 0
	if int(speedometer_speed_label.text) != ply_speed:
		speedometer_speed_label.text = str(ply_speed)
		speedometer_arrow.rotation_degrees = lerp(speedometer_arrow.rotation_degrees, Globals.map_range(ply_speed, 0, 150, -45, 235), delta * 10)
	
	if rpm_label.text != str(ply_rpm):
		rpm_label.text = str(ply_rpm)
		rpm_arrow.rotation_degrees = lerp(rpm_arrow.rotation_degrees, Globals.map_range(ply_rpm, 0, 130, -45, 235), delta * 10)
