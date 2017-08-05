
extends "ground_actor.gd"

const Utils = preload("utils.gd")

var root = null
onready var sprite = get_node("Sprite")
onready var health_node = get_node("health")
onready var anim_player = get_node("AnimationPlayer")

var _shoot_anim_map = {           # List of looped animations (like running and idling) and their corresponding shooting animations.
    idle = "idle_shoot",          # If a looped anim does not have a corresponding shooting anim, no anim switching will occur
    run  = ""
}
var _current_shoot_anim = ""      # Stores the current shooting animation as our looped animations might change in the future. If we
                                  # directly used the list instead, checking to see if it's done playing would be inaccurate
var _current_looped_anim = "idle" # Used to reset animation to what was originally playing after finishing one-shot animations like shoot
var _play_shoot_anim = false

func _fixed_process(delta):
    root.get_node("HUDLayer/player_health").set_text("Player Health: " + str(health_node.health))
    
    if Input.is_action_pressed("ui_left"):
        action_move_left = true
        action_move_right = false
        _current_looped_anim = "run"
        if _facing_right:
            sprite.set_flip_h(true)
            # flip shoot_pos to match sprite
            var p = get_node("shoot_pos")
            p.set_pos(Vector2(p.get_pos().x * -1, p.get_pos().y))
    elif Input.is_action_pressed("ui_right"):
        action_move_right = true
        action_move_left = false
        _current_looped_anim = "run"
        if not _facing_right:
            sprite.set_flip_h(false)
            # flip shoot_pos to match sprite
            var p = get_node("shoot_pos")
            p.set_pos(Vector2(p.get_pos().x * -1, p.get_pos().y))
    else:
        # halt movement
        action_move_left = false
        action_move_right = false
        _current_looped_anim = "idle"
    
    if Input.is_action_pressed("ui_up"):
        action_jump = true
    
    _handle_animation()

func _anim_shoot():
    if _shoot_anim_map[_current_looped_anim] != "":
        _play_shoot_anim = true
        _current_shoot_anim = _shoot_anim_map[_current_looped_anim]
        anim_player.play(_current_shoot_anim)

func _handle_animation():
    if _play_shoot_anim:
        # reset animation if shoot animation has finished
        if anim_player.get_current_animation() == _current_shoot_anim and not anim_player.is_playing():
            anim_player.play(_current_looped_anim)
            _play_shoot_anim = false
    else:
        # update looped animation
        if anim_player.get_current_animation() != _current_looped_anim:
            anim_player.play(_current_looped_anim)
        
        # scale running animation speed to horizontal velocity if playing
        if anim_player.get_current_animation() == "run":
            var speed = abs(Utils.scale_to_range(0, max_speed, _velocity.x))
            # limit playing speed to base value above 0 to ensure fluid motion at low speeds
            if speed < 0.3: speed = 0.3
            anim_player.set_speed(speed)
        else: # make sure all other animations are at full speed
            anim_player.set_speed(1)

func _death(projectile):
    if projectile.shooter.get_ref() != null:
        print("that bastard '" + str(projectile.shooter.get_ref().get_name()) + "' killed me!")
    root.get_node("HUDLayer/player_health").set_text("Player Killed")
    root.get_node("HUDLayer/player_health").add_color_override("font_color", Color(1,0,0))
    queue_free()

func _input(event):
    if event.is_action("shoot") and not event.is_echo() and event.is_pressed():
        _anim_shoot()
        var speed
        if _facing_right: speed = Vector2(1,0) * 500
        else: speed = Vector2(-1,0) * 500
        var b = ObjectFactory.create_obj_bullet(self, get_node("shoot_pos").get_global_pos(), speed)
        b.set_scale(Vector2(0.5, 0.5))

func _ready():
    root = get_tree().get_root().get_node("game")
    set_fixed_process(true)
    set_process_input(true)
