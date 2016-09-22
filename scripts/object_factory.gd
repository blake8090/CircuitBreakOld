
extends Node

var root = null

var fx_explosion = preload("res://objects/fx/explosion.tscn")
var obj_character = preload("res://objects/player/character.tscn")
var obj_bullet = preload("res://objects/bullet.tscn")

func _ready():
	root = get_tree().get_root().get_node("game")

func create_obj_bullet(shooter, pos, velocity):
	var obj = obj_bullet.instance()
	obj.init(shooter, velocity)
	obj.set_pos(pos)
	root.add_child(obj)

func create_obj_character(pos):
	var obj = obj_character.instance()
	obj.set_pos(pos)
	root.add_child(obj)
	obj.get_node("Camera2D").make_current()
	return obj

func create_fx_explosion(pos):
	var obj = fx_explosion.instance()
	obj.set_pos(pos)
	root.add_child(obj)
	obj.set_emitting(true)
	return obj
