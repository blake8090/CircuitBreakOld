
extends Node2D

func _input(event):
	if event.is_action("ui_cancel") and not event.is_echo() and event.is_pressed():
		SceneHelper.setScene("res://levels/main.tscn")

func _ready():
	set_process_input(true)


