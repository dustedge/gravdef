extends RigidBody2D

class_name Player

@onready var front_spring := $Motorcycle/FrontSpringJoint2D
@onready var back_spring := $Motorcycle/BackSpringJoint2D
@onready var front_groove := $Motorcycle/GrooveJointFront
@onready var back_groove := $Motorcycle/GrooveJointBack
@onready var camera : Camera2D = $Camera2D


@onready var front_wheel : RigidBody2D = $Motorcycle/WheelFront
@onready var back_wheel : RigidBody2D = $Motorcycle/WheelBack
@onready var skeleton : Skeleton2D = $Skeleton2D

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var engine_sfx : AudioStreamPlayer2D = $Motorcycle/EngineSound
@onready var vehicle : RigidBody2D = $Motorcycle
var last_played_animation := "RESET"

var stiffness = 1000.0
var jump_stiffness = 200.0
var damping = 3

var elapsed_time = 0.0
var is_dead : bool = false
var wheel_torque = 22000.0
var player_torque = 40000.0
var is_finished = false
var is_started = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	front_spring.stiffness = stiffness
	back_spring.stiffness = stiffness
	
	front_spring.damping = damping
	back_spring.damping = damping
	
	engine_sfx.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_started and not is_finished:
		elapsed_time += delta
		
	elif not is_started:
		elapsed_time = 0.0
	
	engine_sfx.pitch_scale = Globals.map_range(abs(back_wheel.angular_velocity), 0, 100, 0.3, 1.2)
	pass

func _physics_process(delta: float) -> void:
	
	
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	if is_dead or is_finished:
		return
	
	if not anim_player.current_animation == "":
		last_played_animation = anim_player.current_animation
	
	if Input.is_action_pressed("jump"):
		front_spring.stiffness = jump_stiffness
		back_spring.stiffness = jump_stiffness
	else:
		if front_spring.stiffness != stiffness:
			front_spring.stiffness = stiffness
		if back_spring.stiffness != stiffness:
			back_spring.stiffness = stiffness
			
	if Input.is_action_pressed("left"):
		if not last_played_animation == "left":
			anim_player.play("left")
		self.apply_torque(-player_torque)
		pass
	elif Input.is_action_pressed("right"):
		if not last_played_animation == "right":
			anim_player.play("right")
		self.apply_torque(player_torque)
		pass
	
	elif not last_played_animation == "RESET":
		anim_player.play("RESET")
	
	if Input.is_action_pressed("throttle"):
		back_wheel.apply_torque(wheel_torque)
		front_wheel.apply_torque(wheel_torque)
	
	if Input.is_action_pressed("brake"):
		back_wheel.apply_torque(-wheel_torque)
		front_wheel.apply_torque(-wheel_torque)	
	
	
		
	
	
	if Input.is_action_just_pressed("die"):
		die()
	
	if front_wheel.position.distance_to(front_spring.position) <= 2.0 \
	or back_wheel.position.distance_to(back_spring.position) <= 2.0:
		break_vehicle()

func break_vehicle():
	back_groove.queue_free()
	front_groove.queue_free()
	front_spring.queue_free()
	back_spring.queue_free()
	SoundManager.playSFXAtPosition\
	("res://sounds/retrosfxpack/General Sounds/Impacts/sfx_sounds_impact6.wav", vehicle.global_position)
	die()
	pass

func die():
	if is_dead or is_finished : return
	SoundManager.playSFXAtPosition\
	("res://sounds/retrosfxpack/Death Screams/Human/sfx_deathscream_human10.wav", self.global_position)
	is_dead = true
	anim_player.active = false
	camera.reparent($Skeleton2D/pb_pelvis)
	$BodyToVehiclePin.queue_free()
	$BodyToVehiclePin2.queue_free()
	ragdollize()
	$UI.end_screen()
	pass

func start_level():
	if is_started : return
	elapsed_time = 0.0
	is_started = true
	pass

func finish_level():
	if is_finished or is_dead: return
	is_finished = true
	ScoreManager.add_level_time(elapsed_time)
	$UI.end_screen()
	
func fetch_level_times() -> Array:
	var par = get_parent()
	if par is Level:
		return [par.time_gold, par.time_silver, par.time_copper]
	else: 
		return [0,0,0]

func ragdollize():
	var stack : SkeletonModificationStack2D = skeleton.get_modification_stack()
	stack.enabled = true
	
	var mod_phys_bones : SkeletonModification2DPhysicalBones = stack.get_modification(0)
	mod_phys_bones.enabled = true
	
	fix_skeleton(skeleton)
	
	mod_phys_bones.fetch_physical_bones()
	mod_phys_bones.call_deferred("start_simulation")
	
	mod_phys_bones.call_deferred("stop_simulation")
	mod_phys_bones.call_deferred("start_simulation")
	
	fix_skeleton(skeleton)

func fix_skeleton(target: Skeleton2D):
	for child in target.get_children():
		if child is PhysicalBone2D:
			call_child_recursive(child, update_bone)

func call_child_recursive(node: Node2D, f: Callable):
	f.call(node)
	for child in node.get_children():
		call_child_recursive(child, f)

func update_bone(bone: Node2D):
	if bone is PhysicalBone2D:
		if !bone.simulate_physics:
			# there might be yet another bug regarding the resulting position of bone and its children after enabling simulate_physics
			# recommended to check it in the editor and ensure the position is correct
			print("warning: " + bone.name + " simulate_physics is not checked!")
		# this will undo the cpp constructor
		
		bone.set_deferred("freeze", true)
		bone.set_deferred("freeze", false)
		#bone.freeze = true
		#bone.freeze = false


func _on_head_area_body_entered(body: Node2D) -> void:
	# hit head
	if is_instance_valid(body) and !is_dead:
		die()
