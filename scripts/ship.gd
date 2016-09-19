
extends RigidBody2D

const SPEED = 300
const TORQUE = 4000
const ACCELERATION = 300
const MAX_SPEED = 250
const MAX_LANDING_SPEED = 100
const DRAG = 0
const GRAVITY = 50
const ENTER_DISTANCE = 25

var speed = 0
var crashed = false
var on_ground = false
var landed = false
var exited_ship = false
	
func _fixed_process(delta):
	var velocity = Vector2(0,0)
	speed = sqrt(pow(get_linear_velocity().x,2) + pow(get_linear_velocity().y,2))
	on_ground = false
	
	if(get_colliding_bodies().size()>0):
		for body in get_colliding_bodies():
			if body.get_name() == "TileMap":
				on_ground = true

	if not exited_ship:
		if Input.is_action_pressed("ui_left"):
			set_applied_torque(-TORQUE)
		elif Input.is_action_pressed("ui_right"):
			set_applied_torque(TORQUE)
		else:
			set_applied_torque(0)
			
		if Input.is_action_pressed("ui_up"):
			var angleRad = (get_rotd() * PI) / 180
			velocity.x -= sin(angleRad) * ACCELERATION * delta
			velocity.y -= cos(angleRad) * ACCELERATION * delta
			apply_impulse(Vector2(0,0),velocity)
	
	if(on_ground and abs(int(speed)) == 0):
		landed = true
		#get_node("../Label").set_text("LANDED")
	else: 
		landed = false
		#get_node("../Label").set_text("SPEED: " + str(speed))
	
func body_enter(who):
	if ( speed > MAX_LANDING_SPEED ):
		print("CRASH!")
		play_explosion()
	
func _input(event):
	if(event.is_action("exit_ship") and not event.is_echo() and event.is_pressed() and not exited_ship):
		print("exit ship")
		exit_ship()
	elif (event.is_action("exit_ship") and not event.is_echo() and event.is_pressed() and exited_ship):
		enter_ship()
	
func play_explosion():
	var spark = preload("res://objects/fx/explosion.tscn").instance()
	spark.set_pos(get_global_pos())
	get_node("../").add_child(spark)
	spark.set_emitting(true)
	
func exit_ship():
	if landed:
		get_node("CollisionShape2D").set_trigger(true)
		set_gravity_scale(0)
		var char = preload("res://objects/player/character.tscn").instance()
		char.set_pos(get_global_pos())
		get_node("../").add_child(char)
		exited_ship = true

func enter_ship():
	var p1 = get_node("../character").get_pos()
	var p2 = get_pos()
	var distance = p1.distance_to(p2)
	
	if distance <= ENTER_DISTANCE:
		get_node("../character").queue_free()
		get_node("CollisionShape2D").set_trigger(false)
		set_gravity_scale(1)
		exited_ship = false
		print("entered ship")
		
func _ready():
	set_contact_monitor(true)
	set_max_contacts_reported(5)
	connect("body_enter", self, "body_enter")
	set_fixed_process(true)
	set_process_input(true)
	