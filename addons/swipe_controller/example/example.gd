extends Control

onready var inputs_label := $VBoxContainer/Inputs
onready var refresh_label := $VBoxContainer/RefreshTime
onready var refresh_timer := $Refresh


func _input(event: InputEvent) -> void:
	if event is InputEventAction:
		refresh_timer.wait_time = 3.0
		inputs_label.text += "%s \n" % event.action
		refresh_timer.start()


func _process(delta: float) -> void:
	refresh_label.text = " Refresh in: %1.2f" % refresh_timer.time_left

func _on_Refresh_timeout() -> void:
	inputs_label.text = ""
