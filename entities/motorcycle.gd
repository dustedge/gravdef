extends RigidBody2D

@onready var wheel_front : RigidBody2D = $WheelFront
@onready var wheel_back : RigidBody2D = $WheelBack

var last_wheel_velocty_front
var last_wheel_velocty_back
var in_air = false

func _physics_process(delta: float) -> void:
	if wheel_front and wheel_back:
		last_wheel_velocty_back = wheel_back.linear_velocity.length()
		last_wheel_velocty_front = wheel_front.linear_velocity.length()
		
	if not in_air\
	and wheel_front.get_colliding_bodies().is_empty() \
	and wheel_back.get_colliding_bodies().is_empty():
		in_air = true
	else: in_air = false


func _on_wheel_front_body_entered(body: Node) -> void:
	if last_wheel_velocty_front > 200 and in_air:
		SoundManager.playSFXAtPosition("res://sounds/retrosfxpack/General Sounds/Simple Damage Sounds/sfx_damage_hit6.wav",\
		wheel_front.global_position, -5.0)
		in_air = false


func _on_wheel_back_body_entered(body: Node) -> void:
	if last_wheel_velocty_back > 200 and in_air:
		SoundManager.playSFXAtPosition("res://sounds/retrosfxpack/General Sounds/Simple Damage Sounds/sfx_damage_hit6.wav",\
		wheel_back.global_position, -5.0)
		in_air = false
