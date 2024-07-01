extends CharacterBody2D

@export var walk_speed := 200.0
@export var jump_velocity := -300.0
@export var dash_speed := 900

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var screen_size : Vector2 = get_viewport_rect().size

enum Facing { LEFT, RIGHT }

var can_dash := true
var is_dashing := false
var can_action := true
var is_actioning:= false
var is_sprinting := false
var animation_locked := false
var direction : Vector2 = Vector2.ZERO
var is_facing : Facing = Facing.LEFT
var _is_on_floor := is_on_floor()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var FALL_GRAVITY = GRAVITY * 2

func _physics_process(delta : float):
	player_setup(delta)

	handle_input()

	move_and_slide()
	
	if not animation_locked:
		update_animation()
		update_direction()


func update_animation():
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


func player_setup(delta : float):
	_is_on_floor = is_on_floor()
	
	# prevent player going off screen
	#position.x = clamp(position.x, 100, screen_size.x)
	
	# set GRAVITY
	if not _is_on_floor:
		velocity.y += get_gravity(velocity) * delta
		can_dash = false
		can_action = false
	else:
		can_dash = true
		can_action = true

func get_gravity(velocity: Vector2):
	if velocity.y < 0:
		return GRAVITY
	return FALL_GRAVITY

# Input Handlers
func handle_input():
	# JUMP
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = jump_velocity / 4
	if Input.is_action_just_pressed("jump") and _is_on_floor and not is_actioning:
		velocity.y = jump_velocity
	
	# DASH
	if Input.is_action_just_pressed("dash") and can_dash:
		if is_actioning:
			is_actioning = false
		is_dashing = true
		can_dash = false
		can_action = false
		# remove this line when we have a real dash animation
		animated_sprite.play("dash_2")
		animation_locked = true
		$dash_timer.start()
		$dash_again_timer.start()
	
	# ACTION -- buggy after dashing
	if Input.is_action_just_pressed("action") and can_action:
		is_actioning = true
		can_action = false
		animated_sprite.play("melee")
		animation_locked = true
		$action_timer.start()
		velocity.x = 0
		#$action_again_timer.start()

	# DIRECTION
	direction = Input.get_vector("left", "right", "up", "down")
	if is_dashing:
		# handle backwards dash
		print("is facing: ", is_facing)
		velocity.x = dash_speed if is_facing == Facing.RIGHT else -1 * dash_speed
	elif not is_actioning:
		velocity.x = direction.x * walk_speed if direction else move_toward(velocity.x, 0, walk_speed)


func back_was_pressed():
	if is_facing == Facing.RIGHT:
		return direction.x < 0
	else:
		return direction.x > 0


# Timer Functions
func _on_dash_timer_timeout():
	is_dashing = false
	can_action = true
	animation_locked = false
	$dash_timer.stop()
	
func _on_action_timer_timeout():
	is_actioning = false
	can_action = true
	animation_locked = false
	$action_timer.stop()

func _on_dash_again_timer_timeout():
	can_dash = true
	$dash_again_timer.stop()
