extends CharacterBody2D

@export var walk_speed : float = 200.0
@export var jump_velocity : float = -300.0
@export var dash_speed : int = 900

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var screen_size : Vector2 = get_viewport_rect().size

var can_dash : bool = true
var is_dashing : bool = false
var is_sprinting : bool = false
var animation_locked : bool = false
var direction : Vector2 = Vector2.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta : float):
	player_setup(delta)

	handle_input()

	move_and_slide()
	
	update_animation()
	update_direction()


func update_animation():
	if not animation_locked:
		# idle or runa
		if is_sprinting:
			animated_sprite.play("sprint")
		elif direction.x:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")


func update_direction():
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true

func was_back_pressed(direction : float):
	# TODO: figure out this function
	if (direction > 0):
		return not animated_sprite.flip_h
	elif (direction < 0 and ):
		return animated_sprite.flip_h
	
	return false

func player_setup(delta : float):
	# prevent player going off screen
	#position.x = clamp(position.x, 100, screen_size.x)d
	# set gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		#can_dash = false


func handle_input():
	# JUMP
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# DASH
	if Input.is_action_just_pressed("dash") and can_dash:
		is_dashing = true
		can_dash = false
		animated_sprite.play("dash")
		animation_locked = true
		$dash_timer.start()
		$dash_again_timer.start()

	# DIRECTION
	direction = Input.get_vector("left", "right", "up", "down")
	if direction:
		if is_dashing:
			velocity.x = direction.x * dash_speed
		else:
			velocity.x = direction.x * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)


# Timer Functions
func _on_dash_timer_timeout():
	is_dashing = false
	animation_locked = false

func _on_dash_again_timer_timeout():
	can_dash = true
