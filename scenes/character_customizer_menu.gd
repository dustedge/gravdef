extends Control
class_name CharacterCustomizer

enum AppearancePart {
	HEAD,
	TORSO,
	UPPERARM,
	FOREARM,
	THIGH,
	LEG,
	VEHICLE,
	WHEEL
}

class Appearance:
	var head 	:= 0
	var torso	:= 0
	var upperarm:= 0
	var forearm	:= 0
	var thigh	:= 0
	var leg		:= 0
	var vehicle	:= 0
	var wheel	:= 0

var current_appearance : Appearance = Appearance.new()

@onready var head_sprite : Sprite2D = $HBoxContainer/CharacterContainer/Character/CharacterRoot/Skeleton2D/pelvis/head/sprite
@onready var torso_sprite : Sprite2D = $HBoxContainer/CharacterContainer/Character/CharacterRoot/Skeleton2D/pelvis/sprite
@onready var upperarm_sprite : Sprite2D = $HBoxContainer/CharacterContainer/Character/CharacterRoot/Skeleton2D/pelvis/upperarm/sprite
@onready var forearm_sprite : Sprite2D = $HBoxContainer/CharacterContainer/Character/CharacterRoot/Skeleton2D/pelvis/upperarm/forearm/sprite
@onready var thigh_sprite : Sprite2D = $HBoxContainer/CharacterContainer/Character/CharacterRoot/Skeleton2D/pelvis/thigh/sprite
@onready var leg_sprite : Sprite2D = $HBoxContainer/CharacterContainer/Character/CharacterRoot/Skeleton2D/pelvis/thigh/leg/sprite

@onready var customize_options_container : VBoxContainer = $HBoxContainer/CustomizeOptions

func _ready() -> void:
	for option : CustomizeOption in customize_options_container.get_children():
		
		option.changed.connect(_on_customize_option_changed)
		
		if option.name.ends_with("Head"):
			option.set_max_val(head_sprite.hframes - 1)
			option.set_val(current_appearance.head)
		
		elif option.name.ends_with("UpperArms"):
			option.set_max_val(upperarm_sprite.hframes - 1)
			option.set_val(current_appearance.upperarm)
		
		elif option.name.ends_with("ForeArms"):
			option.set_max_val(forearm_sprite.hframes - 1)
			option.set_val(current_appearance.forearm)
			
		elif option.name.ends_with("Torso"):
			option.set_max_val(torso_sprite.hframes - 1)
			option.set_val(current_appearance.torso)
		
		elif option.name.ends_with("Thighs"):
			option.set_max_val(thigh_sprite.hframes - 1)
			option.set_val(current_appearance.thigh)
			
		elif option.name.ends_with("Feet"):
			option.set_max_val(leg_sprite.hframes - 1)
			option.set_val(current_appearance.leg)
	pass	

func _process(delta: float) -> void:
	set_frame_if_differs(head_sprite, 		current_appearance.head)
	set_frame_if_differs(torso_sprite, 		current_appearance.torso)
	set_frame_if_differs(upperarm_sprite, 	current_appearance.upperarm)
	set_frame_if_differs(forearm_sprite, 	current_appearance.forearm)
	set_frame_if_differs(thigh_sprite, 		current_appearance.thigh)
	set_frame_if_differs(leg_sprite, 		current_appearance.leg)
		
func set_frame_if_differs(sprite : Sprite2D, frame : int):
	if sprite.frame != frame and frame < sprite.hframes and frame >= 0:
		sprite.frame = frame

func _on_customize_option_changed(option : CustomizeOption):
	
	print("CharacterCustomizer: Option changed to: ", option.curvalue)
	match option.customized_part:
		AppearancePart.HEAD:
			current_appearance.head		= option.curvalue
		AppearancePart.TORSO:
			current_appearance.torso 	= option.curvalue
		AppearancePart.UPPERARM:
			current_appearance.upperarm = option.curvalue
		AppearancePart.FOREARM:
			current_appearance.forearm 	= option.curvalue
		AppearancePart.THIGH:
			current_appearance.thigh 	= option.curvalue
		AppearancePart.LEG:
			current_appearance.leg 		= option.curvalue
		AppearancePart.VEHICLE:
			pass
		AppearancePart.WHEEL:
			pass
