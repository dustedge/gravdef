extends HBoxContainer
class_name CustomizeOption
var curvalue = 0
var max_value = 1

@export var customized_part : CharacterCustomizer.AppearancePart
@onready var selected_label : Label = $SelectedLabel

signal changed

func _ready() -> void:
	get_node("ButtonPrev").pressed.connect(_on_pressed_button_previous)
	get_node("ButtonNext").pressed.connect(_on_pressed_button_next)
	
func _on_pressed_button_next():
	if curvalue < max_value:
		curvalue += 1
		emit_signal("changed", self)
		selected_label.text = str(curvalue).lpad(2)

func _on_pressed_button_previous():
	if curvalue > 0:
		curvalue -= 1
		emit_signal("changed", self)
		selected_label.text = str(curvalue).lpad(2)

func set_val(value : int):
	curvalue = value
	emit_signal("changed", self)
	selected_label.text = str(curvalue).lpad(2)

func set_max_val(value : int):
	max_value = value
