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


func _process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	
	var target_position := target.global_position + target_offset
	var difference := target_position - global_position
	
	var camera_right := camera_yaw.global_basis.x.normalized()
	var camera_up := camera_pitch.global_basis.y.normalized()
	
	var correction := Vector3.ZERO
	
	if follow_horizontal:
		var horizontal_error := difference.dot(camera_right)
		var horizontal_excess := ( signf(horizontal_error) * maxf(absf(horizontal_error) - horizontal_margin, 0.0) )
		correction += camera_right * horizontal_excess
	
	if follow_vertical:
		var vertical_error := difference.dot(camera_up)
		var vertical_excess := ( signf(vertical_error) * maxf(absf(vertical_error) - vertical_margin, 0.0) )
		correction += camera_up * vertical_excess
	
	var weight := 1.0 - exp(-follow_smoothness * delta)
	
	global_position += correction * weight
