
extends RigidBody2D

const Utils = preload("utils.gd")

onready var health_node = get_node("health")
var root = null

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

func _fixed_process(delta):
	root.get_node("HUDLayer/ship_health").set_text("Ship Health: " + str(health_node.health))
	
	current_speed = get_linear_velocity().length()
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
			apply_impulse(Vector2(0,0), Utils.get_velocity_from_angle(get_rotd(), acceleration * delta))
	
	if on_ground and abs(int(current_speed)) == 0:
		landed = true
	else: 
		landed = false

func body_enter(who):
	if current_speed > max_landing_speed:
		ObjectFactory.create_fx_explosion(get_global_pos())
		health_node.hit(self,1)

func _input(event):
	if event.is_action("exit_ship") and not event.is_echo() and event.is_pressed() and not exited_ship:
		exit_ship()
	elif event.is_action("exit_ship") and not event.is_echo() and event.is_pressed() and exited_ship:
		enter_ship()
		
	if event.is_action("shoot") and not event.is_echo() and event.is_pressed() and not exited_ship:
		ObjectFactory.create_obj_bullet(self, get_node("shoot_pos").get_global_pos(), Utils.get_velocity_from_angle(get_rotd(), 700))

func exit_ship():
	if landed:
		# freeze ship in place - no collisions, no gravity
		get_node("CollisionShape2D").set_trigger(true)
		get_node("Area2D").set_monitorable(false)
		set_gravity_scale(0)
		
		ObjectFactory.create_obj_character(get_global_pos())
		root.get_node("camera_anchor").set_target("character")
		root.get_node("camera_anchor").set_target_zoom(0.8, 0.05)
		exited_ship = true

func enter_ship():
	var root = get_tree().get_root().get_node("game")
	var p1 = root.get_node("character").get_pos()
	var p2 = get_pos()
	var distance = p1.distance_to(p2)
	
	if distance <= enter_distance:
		root.get_node("character").queue_free()
		
		root.get_node("camera_anchor").set_target("ship")
		root.get_node("camera_anchor").set_target_zoom(1, 0.05)
		
		# unfreeze ship
		get_node("CollisionShape2D").set_trigger(false)
		set_gravity_scale(gravity)
		
		exited_ship = false

func _death(projectile):
	root.get_node("HUDLayer/ship_health").set_text("Ship Destroyed")
	root.get_node("HUDLayer/ship_health").add_color_override("font_color", Color(1,0,0))
	if not exited_ship:
		root.get_node("HUDLayer/player_health").set_text("Player Killed")
		root.get_node("HUDLayer/player_health").add_color_override("font_color", Color(1,0,0))
	queue_free()


func _ready():
	root = get_tree().get_root().get_node("game")
	set_contact_monitor(true)
	set_max_contacts_reported(5)
	connect("body_enter", self, "body_enter")
	set_gravity_scale(gravity)
	set_fixed_process(true)
	set_process_input(true)
