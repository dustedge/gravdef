extends Node2D
class_name Level


@export var start_point_ix : int
@export var finish_point_ix : int 
@export var time_gold: float
@export var time_silver: float
@export var time_copper: float
@export var level_name : String = "Unnamed Level"

var flag_scene = preload("res://entities/flag.tscn")
@onready var geometry = $Geometry
@onready var poly = $Geometry/CollisionPolygon2D
@onready var player : RigidBody2D = $Player

var pseudo3d_offset_x = 10.0
var pseudo3d_offset_y = 20.0
var pseudo3d_offset = 30.0
var pseudo3d_divider = 10

var line_width := 1.0
var line_color : Color = Color.WHITE
var start_flags : Array = []
var finish_flags : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# on level start:
	#	spawn flags	
	LevelManager.current_level = self.level_name
	
	var start_point : Vector2 = poly.polygon[start_point_ix]
	var finish_point : Vector2 = poly.polygon[finish_point_ix]
	
	start_flags = spawn_flags(start_point)
	finish_flags = spawn_flags(finish_point)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	queue_redraw()
	
	if is_instance_valid(player) and is_instance_valid(poly):
		if player.position.x >= poly.polygon[finish_point_ix].x:
			finish()
		if player.position.x >= poly.polygon[start_point_ix].x:
			start()
	
	pass

func _draw() -> void:
	draw_level()
	update_flags()

func draw_level():
	var front_poly_points = []
	var back_poly_points = []
	var last_point : Vector2 = Vector2.INF
	var points : PackedVector2Array = poly.polygon
	points.append(points[0])
	
	var prev = []
	
	for point : Vector2 in points:
		var offx = pseudo3d_offset_x
		var offy = pseudo3d_offset_y
		
		if is_instance_valid(player):
			offx += (point.x - player.camera.global_position.x) / pseudo3d_divider
			offy += (point.y - player.camera.global_position.y) / pseudo3d_divider
		
		#var prev = [
		#	Vector2(last_point.x - offx, last_point.y - offy),
		#	Vector2(last_point.x + offx, last_point.y + offy),
		#]
		
		var cur = [
			Vector2(point.x - offx, point.y - offy),
			Vector2(point.x + offx, point.y + offy),
		]
		
		if prev.is_empty():
			draw_line(cur[1], cur[0], line_color, line_width)
		
		else:
			draw_line(prev[0], prev[1], line_color, line_width)
			draw_line(prev[0], cur[0], line_color, line_width)
			draw_line(cur[1], prev[1], line_color, line_width)
			draw_line(cur[1], cur[0], line_color, line_width)
			draw_colored_polygon([prev[0],prev[1], cur[1], cur[0]], Color.GRAY)
		
		prev = cur
		last_point = point
		
		front_poly_points.append(cur[1])
		
	
	draw_colored_polygon(front_poly_points, Color.DIM_GRAY)
		

func spawn_flags(where : Vector2) -> Array:
	var point1 = where - Vector2(pseudo3d_offset_x, pseudo3d_offset_y)
	var point2 = where + Vector2(pseudo3d_offset_x, pseudo3d_offset_y)
	
	var newflag = flag_scene.instantiate()
	self.add_child(newflag)
	newflag.position = point1
	newflag.z_index = -10
	
	var newflag2 = flag_scene.instantiate()
	self.add_child(newflag2)
	newflag2.position = point2
	newflag2.z_index = 10
	
	return [newflag, newflag2]

func update_flags():
	if not is_instance_valid(player) or not is_instance_valid(poly):
		return
		
	var start_anchor = poly.polygon[start_point_ix]
	var finish_anchor = poly.polygon[finish_point_ix]
	
	var offset = Vector2(pseudo3d_offset_x, pseudo3d_offset_y)
	
	offset += ((start_anchor - player.camera.global_position) / pseudo3d_divider)
	
	start_flags[0].position = start_anchor - offset
	start_flags[1].position = start_anchor + offset
	
	offset = Vector2(pseudo3d_offset_x, pseudo3d_offset_y)
	
	offset += ((finish_anchor - player.camera.global_position) / pseudo3d_divider)
	
	finish_flags[0].position = finish_anchor - offset
	finish_flags[1].position = finish_anchor + offset

func finish():
	player.finish_level()
	pass

func start():
	player.start_level()
	pass
