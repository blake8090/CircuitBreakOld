
extends KinematicBody2D

const MAX_SPEED = 300
const ACCELERATION = 15
const JUMP_HEIGHT = 350
const FRICTION = 50
var GRAVITY

var velocity = Vector2()
var can_wall_jump = true
var is_jumping = false
var is_falling = false

func _fixed_process(delta):
	if test_move(Vector2(0,1)) && velocity.y > 0:
		# apply sufficient downward force to stick character to slopes
		GRAVITY = 10000
		velocity.y = 0;
		is_jumping = false
		is_falling = false
	else:
		GRAVITY = 800
		is_falling = true
		
	# reset y velocity if char hit ceiling
	if test_move(Vector2(0,-1)):
		velocity.y = 0
	
	# double checking left and right avoids buggy movement 
	# along y-axis when pressing against walls
	var can_move_left = true
	if is_falling and test_move(Vector2(-1,0)):
		can_move_left = false
		
	var can_move_right = true
	if is_falling and test_move(Vector2(1,0)):
		can_move_right = false
	
	if Input.is_action_pressed("ui_left") and can_move_left:
		# kill velocity if pressing against an opposing wall for faster response time
		if test_move(Vector2(1,-1)): velocity.x = 0
		velocity.x -= ACCELERATION
		# recalculate gravity for current x-velocity to avoid sliding down slopes at low speeds
		if not is_jumping and not is_falling: GRAVITY = calc_gravity_on_slope(abs(velocity.x))
	elif Input.is_action_pressed("ui_right") and can_move_right:
		if test_move(Vector2(-1,-1)): velocity.x = 0
		velocity.x += ACCELERATION
		if not is_jumping and not is_falling: GRAVITY = calc_gravity_on_slope(abs(velocity.x))
	else:
		# apply friction if not moving (unless we hit a wall, then stop immediately)
		if test_move(Vector2(-1,-1)) or test_move(Vector2(1,-1)):
			velocity.x = 0
		else: 
			if velocity.x < 0: 
				velocity.x += FRICTION
				if velocity.x > 0: velocity.x = 0
			elif velocity.x > 0:
				velocity.x -= FRICTION
				if velocity.x < 0: velocity.x = 0
	
	if abs(velocity.x) > MAX_SPEED:
		if velocity.x < 0: velocity.x = -MAX_SPEED
		if velocity.x > 0: velocity.x = MAX_SPEED
	
	get_node("../Label").set_text(str(velocity.x))
	
	velocity.y += delta * GRAVITY
	
	if Input.is_action_pressed("ui_up") and not is_falling:
		velocity.y = -JUMP_HEIGHT
		is_jumping = true
	elif Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_left"):
		if is_falling and not can_move_left and can_wall_jump:
			pass
	
	var motion = velocity * delta
	
	# record old x pos and velocity. setting the x pos to the old 
	# x pos after moving (if there was no x-axis movement in the
	# first place) avoids gravity affecting x-axis on slopes
	var old_x = get_global_pos().x;
	var old_velocity_x = velocity.x;
	motion = move(motion)
	
	if is_colliding():
		# avoid slow movement on slopes
		var n = get_collision_normal()
		motion = n.slide(motion).normalized() * abs(motion.x)
		move(motion)
	
	# reset x pos if there was no movement on x-axis
	if old_velocity_x == 0:
		set_global_pos(Vector2(old_x,get_global_pos().y))
	
func calc_gravity_on_slope(speed):
	# best ratio for 45 degree slopes is 10000 gravity per 200 speed
	return (10000 * speed) / 200
	
func _ready():
	set_fixed_process(true)
