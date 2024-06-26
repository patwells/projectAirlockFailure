extends CharacterBody2D

@export var walk_speed : float = 200.0
@export var jump_velocity : float = -300.0
@export var dash_speed : int = 900

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var screen_size : Vector2 = get_viewport_rect().size

enum Facing { LEFT, RIGHT }

var can_dash : bool = true
var is_dashing : bool = false
var is_actioning: bool = false
var is_sprinting : bool = false
var animation_locked : bool = false
var direction : Vector2 = Vector2.ZERO
var is_facing : Facing = Facing.RIGHT
var _is_on_floor : bool = is_on_floor()

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
		if is_sprinting:
			animated_sprite.play("sprint")
		elif direction.x:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")


func update_direction():
	if direction.x > 0:
		animated_sprite.flip_h = false
		is_facing = Facing.LEFT
	elif direction.x < 0:
		animated_sprite.flip_h = true
		is_facing = Facing.RIGHT


func back_was_pressed():
	if is_facing == Facing.RIGHT:
		return direction.x < 0
	else:
		return direction.x > 0


func player_setup(delta : float):
	_is_on_floor = is_on_floor()
	
	# prevent player going off screen
	#position.x = clamp(position.x, 100, screen_size.x)
	
	# set gravity
	if not _is_on_floor:
		velocity.y += gravity * delta
		can_dash = false
	else:
		can_dash = true


func handle_input():
	# JUMP
	if Input.is_action_just_pressed("jump") and _is_on_floor:
		velocity.y = jump_velocity
	
	# DASH
	if Input.is_action_just_pressed("dash") and can_dash:
		is_dashing = true
		can_dash = false
		# remove this line when we have a real dash animation
		animated_sprite.play("dash_2")
		animation_locked = true
		$dash_timer.start()
		$dash_again_timer.start()
	
	# ACTION -- buggy after dashing
	if Input.is_action_just_pressed("action"):
		is_actioning = true
		animated_sprite.play("melee")
		animation_locked = true
		$action_timer.start()

	# DIRECTION
	direction = Input.get_vector("left", "right", "up", "down")
	if is_dashing:
		# handle backwards dash
		velocity.x = dash_speed if is_facing == Facing.RIGHT else -1 * dash_speed
	else:
		velocity.x = direction.x * walk_speed if direction else move_toward(velocity.x, 0, walk_speed)


# Timer Functions
func _on_dash_timer_timeout():
	is_dashing = false
	animation_locked = false
	
func _on_action_timer_timeout():
	is_actioning = false
	animation_locked = false

func _on_dash_again_timer_timeout():
	can_dash = true
