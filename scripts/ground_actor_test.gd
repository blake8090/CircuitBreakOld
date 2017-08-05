# This actor implements simple obstacle avoidance to test the features of ground_actor

extends "ground_actor.gd"

var left = false # if we're moving left
var ray_length = 80
var ray_y_offset = 10
var double_jump_accuracy = 40 # minumum absolute y velocity to attempt double jump

func _ready():
    set_fixed_process(true)

func _fixed_process(delta):
    action_move_left = left
    action_move_right = not left
    var shape = get_node("CollisionShape2D").get_shape()
    
    # used to point the raycast in the direction the actor is facing
    var direction = 1
    if left: direction = -1
    
    # positions are in the bottom right corner of collision box, extended and shifted up a few pixels
    var pos1 = Vector2(shape.get_extents().x * direction, shape.get_extents().y - ray_y_offset)
    var pos2 = Vector2(pos1.x + ray_length * direction, pos1.y)
    
    # set markers to beginning and end of raycast line
    get_node("point1").set_global_pos(get_global_pos() + pos1)
    get_node("point2").set_global_pos(get_global_pos() + pos2)
    
    # check if an obstacle is in our way
    var space_state = get_world_2d().get_direct_space_state()
    var result = space_state.intersect_ray( get_global_pos() + pos1, get_global_pos() + pos2, [self])
    if not result.empty():
        if result.collider.get_name() == "TileMap":
            # reverse directions if we hit a tilemap wall
            if test_move(Vector2(1,-5)):
                left = true
            elif test_move(Vector2(-1,-5)):
                left = false
        else:
            var can_move = test_move(Vector2(1 * direction,-3))
            # if we're not jumping and can't move forward, then we're stuck
            if not _is_jumping and can_move:
                print("i am stuck!")
                # move backwards a pixel
                move(Vector2(1 * -direction, 0))
                # stop all other movement util next frame
                action_move_right = false
                action_move_left = false
                action_jump = false
            # we need to double jump to try and get over this obstacle, so do nothing until next frame
            elif _is_falling and (abs(_velocity.y) < double_jump_accuracy) and can_move:
                action_jump = false
            else:  # try to jump (or double jump) over the obstacle!
                action_jump = true

