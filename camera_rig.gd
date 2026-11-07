extends Node3D

@export var target: Node3D
@export var target_offset := Vector3(0.0, -0.5, 0.0)

@export_range(0.0, 5.0, 0.05) var horizontal_margin := 0.01
@export_range(0.0, 5.0, 0.05) var vertical_margin := 0.4

@export var follow_horizontal := true
@export var follow_vertical := true
@export var follow_smoothness := 8.0

@onready var camera_yaw: Node3D = $CameraYaw
@onready var camera_pitch: Node3D = $CameraYaw/CameraPitch
@onready var camera: Camera3D = get_viewport().get_camera_3d()


func _process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	
	var target_position := target.global_position + target_offset
	if camera.is_position_behind(target_position):
		return
	
	var viewport_size := camera.get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	
	var viewport_center := viewport_size * 0.5
	var margin_center := viewport_size * Vector2(horizontal_margin, vertical_margin) * 0.5
	
	var margin_min := viewport_center - margin_center
	var margin_max := viewport_center + margin_center
	
	var screen_position := camera.unproject_position(target_position)
	
	var max_screen_position := Vector2(
		clampf(screen_position.x, margin_min.x, margin_max.x),
		clampf(screen_position.y, margin_min.y, margin_max.y)
	)
	
	if screen_position.is_equal_approx(max_screen_position):
		return
	
	# Get player's depth relative to the camera
	var camera_space_position := camera.to_local(target_position)
	var depth := -camera_space_position.z
	
	if depth <= camera.near:
		return
	
	var to_world_position := camera.project_position(max_screen_position,depth)
	
	var correction := target_position - to_world_position
	
	var weight := 1.0 - exp(-follow_smoothness * delta)
	
	global_position += correction * weight
