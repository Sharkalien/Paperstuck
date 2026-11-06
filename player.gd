extends CharacterBody3D

const SPEED = 3.0
const JUMP_VELOCITY = 4.5

@onready var sprite: Sprite3D = $Sprite3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera3D : 
	get: 
		return get_viewport().get_camera_3d()
@onready var camera_yaw: Node3D = $CameraYaw
@onready var camera_pitch: Node3D = $CameraYaw/CameraPitch
@onready var camera_spring_arm: SpringArm3D = $CameraYaw/CameraPitch/SpringArm3D

@export var mouse_sensitivity: float = 0.003
@export var min_pitch_degrees: float = -45.0
@export var max_pitch_degrees: float = 25.0
@export var zoom_distance: float = 2.0
@export var zoom_step: float = 0.5
@export var min_zoom_distance: float = 1.5
@export var max_zoom_distance: float = 5.0
@export var zoom_smoothness: float = 8.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	if is_on_floor() and velocity == Vector3.ZERO:
		anim_player.play("RESET")

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (camera_yaw.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		#anim_player.play("RESET")
	
	if is_on_floor():
		anim_player.play("walk")
	else: anim_player.play("jump")
	
	move_and_slide()
	
	# Flip sprite based on velocity direction rather than hardcoded controls
	var movement := get_real_velocity()
	movement.y = 0.0
	#print(movement)
	
	var camera_right := camera.global_transform.basis.x
	camera_right.y = 0.0
	camera_right = camera_right.normalized()
	
	var horizontal_speed := movement.dot(camera_right)
	# Left
	if horizontal_speed < -0.01:
		sprite.flip_h = true
		sprite.offset.x = -14.39
	# Right
	elif horizontal_speed > 0.01:
		sprite.flip_h = false
		sprite.offset.x = 14.39


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	
	# Zoom
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			MOUSE_BUTTON_WHEEL_UP:
				zoom_distance -= zoom_step
			MOUSE_BUTTON_WHEEL_DOWN:
				zoom_distance += zoom_step
		zoom_distance = clampf(
			zoom_distance,
			min_zoom_distance,
			max_zoom_distance
		)
	
	# Camera orbit
	elif event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			# Horizontal
			camera_yaw.rotation.y -= (event.screen_relative.x * mouse_sensitivity)
			# Vertical
			camera_pitch.rotation.x -= (event.screen_relative.y * mouse_sensitivity)
			# Clamp up and down rotation
			camera_pitch.rotation.x = clampf(
				camera_pitch.rotation.x,
				deg_to_rad(min_pitch_degrees),
				deg_to_rad(max_pitch_degrees)
			)

func _process(delta: float) -> void:
	var weight := 1.0 - exp(-zoom_smoothness * delta)
	
	camera_spring_arm.spring_length = lerpf(
		camera_spring_arm.spring_length,
		zoom_distance,
		weight
	)
