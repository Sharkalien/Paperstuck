extends CharacterBody3D

const SPEED = 3.0
const JUMP_VELOCITY = 4.5

@onready var sprite: Sprite3D = $Sprite3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera3D = $"../Camera"


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
	
	#if Input.is_action_just_pressed("ui_right"):
		#sprite.flip_h = false
		#sprite.offset.x = 14.39
	#if Input.is_action_just_pressed("ui_left"):
		#sprite.flip_h = true
		#sprite.offset.x = -14.39

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (camera.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
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
