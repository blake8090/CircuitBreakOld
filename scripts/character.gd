
extends KinematicBody2D

var root = null
onready var sprite = get_node("AnimatedSprite")

const MAX_SPEED = 300
const ACCELERATION = 15
const JUMP_HEIGHT = 350
const FRICTION = 50
var GRAVITY

var frameTimer = 0
var frameDuration = 0.08
var velocity = Vector2()
var can_wall_jump = true
var can_jump = true
var is_jumping = false
var is_falling = false
var jump_pressed = false
var facing_right = true
var health = 5

func _fixed_process(delta):
	# if done playing the shoot anim then play the idle anim
	if get_node("AnimationPlayer").get_current_animation() == "idle_shoot" and not get_node("AnimationPlayer").is_playing():
		get_node("AnimationPlayer").play("idle")
		
	if test_move(Vector2(0,1)) && velocity.y > 0:
		# apply sufficient downward force to stick character to slopes
		GRAVITY = 10000
		velocity.y = 0;
		is_jumping = false
		is_falling = false
	else:
		GRAVITY = 800
		is_falling = true
	
	#if facing_right and test_move(Vector2(0,1)) and test_move(Vector2(1,-0.5)) and not test_move(Vector2(1,-1)):
	#	root.get_node("HUDLayer/Label").set_text("on right slope")
	#else:
	#	root.get_node("HUDLayer/Label").set_text("")
	
	# reset y velocity if char hit ceiling
	if test_move(Vector2(0,-1)):
		velocity.y = 0

	# force player to release button in order to jump again
	if not is_falling and jump_pressed:
		can_jump = false

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
		# ensure quick direction switching
		if velocity.x > 0: 
			velocity.x -= ACCELERATION + FRICTION
		else: 
			velocity.x -= ACCELERATION
		# recalculate gravity for current x-velocity to avoid sliding down slopes at low speeds
		if not is_jumping and not is_falling: GRAVITY = calc_gravity_on_slope(abs(velocity.x))
		
		if facing_right:
			sprite.set_flip_h(true)
			facing_right = false
			# flip shoot_pos to match sprite
			var p = get_node("shoot_pos")
			p.set_pos(Vector2(p.get_pos().x * -1, 0))
	elif Input.is_action_pressed("ui_right") and can_move_right:
		if test_move(Vector2(-1,-1)): velocity.x = 0
		if velocity.x < 0: 
			velocity.x += ACCELERATION + FRICTION
		else: 
			velocity.x += ACCELERATION
		if not is_jumping and not is_falling: GRAVITY = calc_gravity_on_slope(abs(velocity.x))
		
		if not facing_right:
			sprite.set_flip_h(false)
			facing_right = true
			var p = get_node("shoot_pos")
			p.set_pos(Vector2(p.get_pos().x * -1, 0))
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
	
	velocity.y += delta * GRAVITY

	if Input.is_action_pressed("ui_up"):
		jump_pressed = true
		if not is_falling and can_jump:
			is_jumping = true
			velocity.y = -JUMP_HEIGHT
	#elif Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_left"):
		#jump_pressed = true
		#if is_falling and not can_move_left and can_wall_jump:
		#	pass
	else:
		if jump_pressed: # jump button has been released 
			if is_jumping and velocity.y < -100:
				velocity.y = -100
			jump_pressed = false
			can_jump = true

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

func hit(bullet):
	var p = ObjectFactory.create_fx_explosion(get_global_pos())
	p.set_color(Color(1,0,0))
	health -= 1
	if health < 0: 
		health = 0
	root.get_node("HUDLayer/player_health").set_text("Player Health: " + str(health))
	if health == 0:
		root.get_node("HUDLayer/player_health").set_text("Player Killed")
		root.get_node("HUDLayer/player_health").add_color_override("font_color", Color(1,0,0))
		hide()
		#turn off collision & gravity & everything
		get_node("CollisionShape2D").set_trigger(true)
		set_fixed_process(false)
		set_process_input(false)
		set_process(false)
		set_name("player_dead") # hack to get turrets to stop firing

func _input(event):
	if event.is_action("shoot") and not event.is_echo() and event.is_pressed():
		get_node("AnimationPlayer").play("idle_shoot")
		var speed
		if facing_right: speed = Vector2(1,0) * 500
		else: speed = Vector2(-1,0) * 500
		var b = ObjectFactory.create_obj_bullet(self, get_node("shoot_pos").get_global_pos(), speed)
		b.set_scale(Vector2(0.5, 0.5))

func _ready():
	root = get_tree().get_root().get_node("game")
	root.get_node("HUDLayer/player_health").set_text("Player Health: " + str(health))
	set_fixed_process(true)
	set_process_input(true)
