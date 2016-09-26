
extends "ground_actor.gd"

var root = null
onready var sprite = get_node("Sprite")
onready var health_node = get_node("health")

func _fixed_process(delta):
	root.get_node("HUDLayer/player_health").set_text("Player Health: " + str(health_node.health))
	
	# if done playing the shoot anim then play the idle anim
	if get_node("AnimationPlayer").get_current_animation() == "idle_shoot" and not get_node("AnimationPlayer").is_playing():
		get_node("AnimationPlayer").play("idle")

	if Input.is_action_pressed("ui_left"):
		action_move_left = true
		action_move_right = false
		
		if _facing_right:
			sprite.set_flip_h(true)
			# flip shoot_pos to match sprite
			var p = get_node("shoot_pos")
			p.set_pos(Vector2(p.get_pos().x * -1, p.get_pos().y))
	elif Input.is_action_pressed("ui_right"):
		action_move_right = true
		action_move_left = false
		
		if not _facing_right:
			sprite.set_flip_h(false)
			# flip shoot_pos to match sprite
			var p = get_node("shoot_pos")
			p.set_pos(Vector2(p.get_pos().x * -1, p.get_pos().y))
	else:
		# halt movement
		action_move_left = false
		action_move_right = false
	
	if Input.is_action_pressed("ui_up"):
		action_jump = true

func hit(projectile, damage):
	var p = ObjectFactory.create_fx_explosion(get_global_pos())
	p.set_color(Color(1,0,0))

func _death(projectile):
	if projectile.shooter.get_ref() != null:
		print("that bastard '" + str(projectile.shooter.get_ref().get_name()) + "' killed me!")
	root.get_node("HUDLayer/player_health").set_text("Player Killed")
	root.get_node("HUDLayer/player_health").add_color_override("font_color", Color(1,0,0))
	hide()
	#turn off collision & gravity
	get_node("CollisionShape2D").set_trigger(true)
	set_fixed_process(false)
	set_process_input(false)
	set_process(false)
	set_name("player_dead") # hack to get turrets to stop firing

func _input(event):
	if event.is_action("shoot") and not event.is_echo() and event.is_pressed():
		get_node("AnimationPlayer").play("idle_shoot")
		var speed
		if _facing_right: speed = Vector2(1,0) * 500
		else: speed = Vector2(-1,0) * 500
		var b = ObjectFactory.create_obj_bullet(self, get_node("shoot_pos").get_global_pos(), speed)
		b.set_scale(Vector2(0.5, 0.5))

func _ready():
	root = get_tree().get_root().get_node("game")
	set_fixed_process(true)
	set_process_input(true)
