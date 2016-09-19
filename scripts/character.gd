
extends KinematicBody2D

const WALK_SPEED = 200
const JUMP_HEIGHT = 350
var GRAVITY = 800.0

var velocity = Vector2()
var grounded = false

func _fixed_process(delta):
	if test_move(Vector2(0,1)) && velocity.y > 0:
		# apply sufficient downward force to stick character to slopes
		GRAVITY = 10000
		velocity.y = 0;
		grounded = true
		#get_node("../Label").set_text("ground")
	else:
		GRAVITY = 800
		grounded = false
		
	# reset y velocity if char hit ceiling
	if (test_move(Vector2(0,-1))):
		velocity.y = 0
		
	# double checking left and right avoids buggy movement 
	# along y-axis when pressing against walls
	var can_move_left = true
	if not grounded and test_move(Vector2(-1,0)):
		can_move_left = false
		
	var can_move_right = true
	if not grounded and test_move(Vector2(1,0)):
		can_move_right = false
		
	velocity.y += delta * GRAVITY
	
	if Input.is_action_pressed("ui_left") and can_move_left:
		velocity.x = - WALK_SPEED
	elif Input.is_action_pressed("ui_right") and can_move_right:
		velocity.x =   WALK_SPEED
	else:
		velocity.x = 0
	
	if Input.is_action_pressed("ui_up") and grounded:
		velocity.y = -JUMP_HEIGHT
		
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
		
func _ready():
	set_fixed_process(true)
