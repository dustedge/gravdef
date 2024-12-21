extends Node2D
class_name Ghost

@onready var skeleton = $Skeleton2D
@onready var anim_player = $AnimationPlayer
@onready var vehicle = $VehicleRoot
@onready var wheel_back = $VehicleRoot/WheelBackSprite
@onready var wheel_front = $VehicleRoot/WheelFrontSprite

@onready var sprite_head : Sprite2D = $Skeleton2D/pelvis/head/sprite
@onready var sprite_torso : Sprite2D = $Skeleton2D/pelvis/sprite
@onready var sprite_upperarm : Sprite2D = $Skeleton2D/pelvis/upperarm/sprite
@onready var sprite_forearm : Sprite2D = $Skeleton2D/pelvis/upperarm/forearm/sprite
@onready var sprite_thigh : Sprite2D = $Skeleton2D/pelvis/thigh/sprite
@onready var sprite_leg : Sprite2D = $Skeleton2D/pelvis/thigh/leg/sprite

var modulate_to : Color
var last_played_anim = ""

var is_playing 		:= false
var start_time 		:= 0.0
var is_ended   		:= false
var current_replay 	: ReplayManager.Replay
var target_frame	: ReplayManager.ReplayFrame
var replay_timer	:= 0.0
var last_position	:= Vector2.ZERO

func apply_frame(frame : ReplayManager.ReplayFrame):
	self.global_position 	= frame.ghost_position
	self.global_rotation 	= frame.ghost_rotation
	
	if anim_player and not last_played_anim == frame.ghost_animation:
		anim_player.play(frame.ghost_animation)
		
	vehicle.position 		= frame.vehicle_position
	vehicle.rotation 		= frame.vehicle_rotation
	wheel_back.position 	= frame.back_wheel_pos
	wheel_front.position 	= frame.front_wheel_pos

func start_replay(replay : ReplayManager.Replay):
	if replay.frames.is_empty():
		return
	self.set_appearance(replay.appearance)
	self.modulate = modulate_to
	current_replay = replay
	target_frame = replay.frames[0]
	$Label.set_deferred("text", replay.player_name)
	$Label.set_deferred("top_level", true)
	$Label.set_deferred("modulate", Color(modulate_to, 1.0))
	self.apply_frame(target_frame)
	is_playing = true
	start_time = Time.get_ticks_msec() / 1000.0
	
func _process(delta: float) -> void:
	if is_playing:
		play_replay(delta)

func play_replay(delta):
	if current_replay.frames.is_empty():
		is_playing = false
		is_ended = true
		return
	
	# remove played frames
	while replay_timer > current_replay.frames[0].time_stamp:
		current_replay.frames.pop_front()
		if current_replay.frames.size() <= 1:
			is_playing = false
			is_ended = true
			return
	
	var current_frame = current_replay.frames[0]
	var next_frame = \
	current_replay.frames[1] if current_replay.frames.size() > 1 else current_frame
	
	var alpha = (replay_timer - current_frame.time_stamp) / (next_frame.time_stamp - current_frame.time_stamp)
	
	global_position = current_frame.ghost_position.lerp(next_frame.ghost_position, alpha)
	rotation = lerp_angle(current_frame.ghost_rotation, next_frame.ghost_rotation, alpha)
	
	vehicle.position = current_frame.vehicle_position.lerp(next_frame.vehicle_position, alpha)
	
	wheel_back.position = current_frame.back_wheel_pos
	wheel_front.position = current_frame.front_wheel_pos
	
	wheel_back.rotation += last_position.distance_to(global_position) / 20
	wheel_front.rotation += last_position.distance_to(global_position) / 20
	
	if last_played_anim != current_frame.ghost_animation and anim_player:
		anim_player.play(current_frame.ghost_animation)
		last_played_anim = current_frame.ghost_animation
	
	replay_timer += delta
	
	last_position = global_position
	$Label.global_position = global_position + Vector2(-50.0, -60.0) 

func set_appearance(appearance : CharacterCustomizer.Appearance):
	sprite_head.frame 		= appearance.head
	sprite_torso.frame 		= appearance.torso
	sprite_forearm.frame 	= appearance.forearm
	sprite_upperarm.frame 	= appearance.upperarm
	sprite_thigh.frame 		= appearance.thigh
	sprite_leg.frame 		= appearance.leg
	#sprite_vehicle.frame 	= appearance.vehicle
	#sprite_wheel.frame		= appearance.wheel
