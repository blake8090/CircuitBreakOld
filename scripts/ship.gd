
extends RigidBody2D

export var speed = 300
export var torque = 4000
export var acceleration = 300
export var max_landing_speed = 180
export var drag = 0
export var gravity = 1.0
export var enter_distance = 25

var crashed = false
var on_ground = false
var landed = false
var exited_ship = false
	
var current_speed = 0
var health = 10

func _fixed_process(delta):
	var velocity = Vector2(0,0)
	current_speed = sqrt(pow(get_linear_velocity().x,2) + pow(get_linear_velocity().y,2))
	on_ground = false
	
	if get_colliding_bodies().size() > 0:
		for body in get_colliding_bodies():
			if body.get_name() == "TileMap":
				on_ground = true

	if not exited_ship:
		if Input.is_action_pressed("ui_left"):
			set_applied_torque(-torque)
		elif Input.is_action_pressed("ui_right"):
			set_applied_torque(torque)
		else:
			set_applied_torque(0)
			
		if Input.is_action_pressed("ui_up"):
			var angleRad = (get_rotd() * PI) / 180
			velocity.x -= sin(angleRad) * acceleration * delta
			velocity.y -= cos(angleRad) * acceleration * delta
			apply_impulse(Vector2(0,0),velocity)
	
	if on_ground and abs(int(current_speed)) == 0:
		landed = true
	else: 
		landed = false
	
func body_enter(who):
	if current_speed > max_landing_speed:
		hit(self)
		#print("CRASH!")
		#ObjectFactory.create_fx_explosion(get_global_pos())
	
func _input(event):
	if event.is_action("exit_ship") and not event.is_echo() and event.is_pressed() and not exited_ship:
		print("exit ship")
		exit_ship()
	elif event.is_action("exit_ship") and not event.is_echo() and event.is_pressed() and exited_ship:
		enter_ship()
		
	if event.is_action("shoot") and not event.is_echo() and event.is_pressed() and not exited_ship:
		ObjectFactory.create_obj_bullet(self, \
										get_node("shoot_pos").get_global_pos(), \
										calc_velocity_from_angle(get_rotd(), 700))

func exit_ship():
	if landed:
		# freeze ship in place - no collisions, no gravity
		get_node("CollisionShape2D").set_trigger(true)
		get_node("Area2D").set_monitorable(false)
		set_gravity_scale(0)
		
		ObjectFactory.create_obj_character(get_global_pos())
		exited_ship = true

func enter_ship():
	var root = get_tree().get_root().get_node("game")
	var p1 = root.get_node("character").get_pos()
	var p2 = get_pos()
	var distance = p1.distance_to(p2)
	
	if distance <= enter_distance:
		root.get_node("character").queue_free()
		get_node("Camera2D").make_current()
		
		# unfreeze ship
		get_node("CollisionShape2D").set_trigger(false)
		set_gravity_scale(gravity)
		
		exited_ship = false

func hit(bullet):
	ObjectFactory.create_fx_explosion(get_global_pos())
	var root = get_tree().get_root().get_node("game")
	health -= 1
	if health < 0: 
		health = 0
	root.get_node("HUDLayer/ship_health").set_text("Ship Health: " + str(health))
	if health == 0:
		root.get_node("HUDLayer/ship_health").set_text("Ship Destroyed")
		root.get_node("HUDLayer/ship_health").add_color_override("font_color", Color(1,0,0))
		if exited_ship:
			queue_free()
		else:
			root.get_node("HUDLayer/player_health").set_text("Player Killed")
			root.get_node("HUDLayer/player_health").add_color_override("font_color", Color(1,0,0))
			hide()
			#turn off collision & gravity & everything
			get_node("CollisionShape2D").set_trigger(true)
			get_node("Area2D").set_monitorable(false)
			set_linear_velocity(Vector2(0,0))
			set_gravity_scale(0)
			set_fixed_process(false)
			set_process_input(false)
			set_name("ship_dead") # hack to get turrets to stop firing

func _ready():
	var root = get_tree().get_root().get_node("game")
	root.get_node("HUDLayer/ship_health").set_text("Ship Health: " + str(health))
	set_contact_monitor(true)
	set_max_contacts_reported(5)
	connect("body_enter", self, "body_enter")
	set_gravity_scale(gravity)
	set_fixed_process(true)
	set_process_input(true)

func calc_velocity_from_angle(angle, speed):
	var angleRad = (angle * PI) / 180
	var velocity = Vector2(0,0)
	velocity.x -= sin(angleRad) * speed
	velocity.y -= cos(angleRad) * speed
	return velocity
