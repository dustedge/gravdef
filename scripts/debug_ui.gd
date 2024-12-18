extends CanvasLayer

@onready var stiffness_label = $VBoxContainer/StifLabel
@onready var stiffness_hslider = $VBoxContainer/StifHSlider
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_stif_h_slider_value_changed(value: float) -> void:
	var frontspring : DampedSpringJoint2D = get_parent().get_node("Motorcycle/FrontSpringJoint2D")
	var backspring : DampedSpringJoint2D = get_parent().get_node("Motorcycle/BackSpringJoint2D")
	
	stiffness_label.text = "Stiffness: " + str(value)
	frontspring.stiffness = value
	backspring.stiffness = value
	
