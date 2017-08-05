
extends KinematicBody2D

var action_move_left = false
var action_move_right = false
var action_jump = false

export var max_speed = 300
export var acceleration = 15
export var jump_height = 350
export var variable_jump_height = 100
export var friction = 50
export var gravity = 800
export(bool) var can_double_jump = false

var _velocity = Vector2()
var _can_wall_jump = true
var _can_jump = true
var _is_jumping = false
var _is_falling = false
var _facing_right = true
var _jump_pressed = false
var _double_jumped = false

func _ready():
    set_fixed_process(true)

func _fixed_process(delta):
    var frame_gravity # gravity only for this current frame
    if test_move(Vector2(0,1)) && _velocity.y > 0:
        # apply sufficient downward force to stick actor to slopes
        frame_gravity = 10000
        _velocity.y = 0;
        _is_jumping = false
        _is_falling = false
        _double_jumped = false
    else:
        frame_gravity = gravity
        _is_falling = true
    
    # reset y velocity if actor hit ceiling
    if test_move(Vector2(0,-1)):
        _velocity.y = 0

    # force player to release button in order to jump again
    if  _jump_pressed:
        _can_jump = false

    # double checking left and right avoids buggy movement 
    # along y-axis when pressing against walls
    var can_move_left = true
    if _is_falling and test_move(Vector2(-1,0)):
        can_move_left = false

    var can_move_right = true
    if _is_falling and test_move(Vector2(1,0)):
        can_move_right = false

    if action_move_left and can_move_left:
        # kill velocity if pressing against an opposing wall for faster response time
        if test_move(Vector2(1,-1)): _velocity.x = 0
        # ensure quick direction switching
        if _velocity.x > 0: 
            _velocity.x -= acceleration + acceleration
        else: 
            _velocity.x -= acceleration
        # recalculate gravity for current x-velocity to avoid sliding down slopes at low speeds
        if not _is_jumping and not _is_falling: frame_gravity = _calc_gravity_on_slope(abs(_velocity.x))
        # update facing
        _facing_right = false
    elif action_move_right and can_move_right:
        if test_move(Vector2(-1,-1)): _velocity.x = 0
        if _velocity.x < 0: 
            _velocity.x += acceleration + acceleration
        else: 
            _velocity.x += acceleration
        if not _is_jumping and not _is_falling: frame_gravity = _calc_gravity_on_slope(abs(_velocity.x))
        # update facing
        _facing_right = true
    else:
        # apply friction if not moving (unless we hit a wall, then stop immediately)
        if test_move(Vector2(-1,-1)) or test_move(Vector2(1,-1)):
            _velocity.x = 0
        else: 
            if _velocity.x < 0: 
                _velocity.x += friction
                if _velocity.x > 0: _velocity.x = 0
            elif _velocity.x > 0:
                _velocity.x -= friction
                if _velocity.x < 0: _velocity.x = 0

    if abs(_velocity.x) > max_speed:
        if _velocity.x < 0: _velocity.x = -max_speed
        if _velocity.x > 0: _velocity.x = max_speed
    
    _velocity.y += delta * frame_gravity

    if action_jump:
        _jump_pressed = true
        if (not _is_falling or (can_double_jump and not _double_jumped)) and _can_jump:
            if _is_falling: 
                _double_jumped = true
            _is_jumping = true
            _velocity.y = -jump_height
    else:
        if _jump_pressed: # jump button has been released 
            if _is_jumping and _velocity.y < -variable_jump_height:
                _velocity.y = -variable_jump_height
            _jump_pressed = false
            _can_jump = true
    
    var motion = _velocity * delta

    # record old x pos and velocity. setting the x pos to the old 
    # x pos after moving (if there was no x-axis movement in the
    # first place) avoids gravity affecting x-axis on slopes
    var old_x = get_global_pos().x;
    var old_velocity_x = _velocity.x;
    motion = move(motion)

    if is_colliding():
        # avoid slow movement on slopes
        var n = get_collision_normal()
        motion = n.slide(motion).normalized() * abs(motion.x)
        move(motion)

    # reset x pos if there was no movement on x-axis
    if old_velocity_x == 0:
        set_global_pos(Vector2(old_x,get_global_pos().y))
    
    action_jump = false

func _calc_gravity_on_slope(speed):
    # best ratio for 45 degree slopes is 10000 gravity per 200 speed
    return (10000 * speed) / 200
