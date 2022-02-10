tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("SwipeScreenArea", "Node2D", preload("swipe_controller.gd"), preload("icon.svg"))
	pass


func _exit_tree() -> void:
	remove_custom_type("SwipeScreenArea")

	pass
