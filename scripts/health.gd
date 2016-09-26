# A health component that manages an object's health whenever it is hit by a projectile.
# Objects using this component must child it as a Node and have a _death(killer) method.
# Objects may also "overload" the hit(projectile, damage) method

extends Node

onready var parent = get_node("../")
export var max_health = 1
export(bool) var is_invincible = false
var health

func _ready():
	health = max_health

# called by a projectile when it hits an actor
func hit(projectile, damage):
	# "overloading"...
	if parent.has_method("hit"):
		parent.hit(projectile, damage)
	if not is_invincible:
		health -= damage
		if health <= 0:
			health = 0
			parent._death(projectile)

# heals by a specified amount
func heal(amount):
	health += amount
	if health > max_health: 
		health = max_health

# fully heals
func full_heal():
	health = max_health
