tool
extends Node2D
#autor : @Jjony-dev
"""
This Script detect swipes on touch screens devices on area defined
and emmit an action event set
"""

export var debug: bool = false setget set_debug
export var reset_on_finish: bool = false
export var input_actions: PoolStringArray = ["ui_up", "ui_right", "ui_down", "ui_left"] setget set_input_actions
export var area_size: Vector2 = Vector2(200, 200) setget set_area_detect
export var color_area_debug: Color = Color.purple setget set_color_area_debug
export var color_angle_separation: Color = Color.white setget set_color_angle_separation
export(float, 0, 3.1416) var angle_offset : float = PI / 4  setget set_angle_offset
export(int, 5, 5000) var MIN_LENGTH_VECTOR = 20 setget set_min_length

onready var radians_range : float = 2 * PI / float(max(1,input_actions.size()))

var area2d: Area2D
var area_detect_shape: CollisionShape2D
var scan : bool = false
var touch_position : Vector2 = Vector2()
var drag_position : Vector2 = Vector2()
var font: Font
var temp := Control.new()


func _enter_tree() -> void:
	area2d = Area2D.new()
	area_detect_shape = CollisionShape2D.new()
	add_child(area2d)
	area2d.add_child(area_detect_shape)
	area2d.connect("input_event", self, "_on_Areadetect_input_event")
	area_detect_shape.visible =false


func _ready() -> void:
	if debug:
		font = temp.get_font("font")
	temp.queue_free()
	area_detect_shape.shape = RectangleShape2D.new() 
	area_detect_shape.shape.extents = area_size / 2


func _unhandled_input(event: InputEvent) -> void:
	if Engine.editor_hint:
		pass
	#deshabilita el escaneo
	if event is InputEventScreenTouch and not event.is_pressed():
		scan = false
		update()


func set_debug(value: bool) -> void:
	debug = value
	update()


func set_color_area_debug(new_color: Color)-> void:
	color_area_debug = new_color
	update()


func set_color_angle_separation(new_color: Color)-> void:
	color_angle_separation = new_color
	update()


func set_input_actions(new: PoolStringArray)-> void:
	input_actions = new
	update()


func set_angle_offset(new_offset: float) -> void:
	angle_offset = new_offset
	update()


func set_min_length(new_length: int)-> void:
	MIN_LENGTH_VECTOR = new_length
	update()


func set_area_detect(new_size) -> void:
	area_size = new_size
	update()


func is_area_detection(_position : Vector2) -> bool:
	if _position.x <= -area_size.x / 2 or _position.x >= area_size.x:
		return false
	if _position.y <= -area_size.y / 2 or _position.y >= area_size.y:
		return false
	return true


func process_action(number : int) -> void:
	if number >= input_actions.size():
		print_debug("action not defined for: swipe " + str(number))
		return
	var ev_p = InputEventAction.new()
	ev_p.action = input_actions[number]
	ev_p.pressed = true
	Input.parse_input_event(ev_p)
	var ev_r = InputEventAction.new()
	scan = false
	ev_r.pressed = false
	Input.parse_input_event(ev_r)
	if reset_on_finish:
		touch_position += drag_position
		scan = true
		update()


func _on_Areadetect_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if Engine.editor_hint or input_actions.empty():
		return
	
	if event is InputEventScreenTouch:
		touch_position = event.position
		drag_position = Vector2.ZERO
		scan = event.is_pressed()
	
	if scan and event is InputEventScreenDrag:
		drag_position = event.position - touch_position
		if (drag_position).length() > MIN_LENGTH_VECTOR:
			var angle_direction : = angle_offset
			var count : int = 0
			var swipe_angle : float = drag_position.angle() + PI
			swipe_angle += 2 * PI if swipe_angle < angle_offset else 0.0
			while swipe_angle > angle_direction:
				if angle_direction >= 2 * PI + angle_offset:
#					print_debug("overflow: " + str(angle_direction))
					break
				angle_direction += radians_range
				count += 1
			self.process_action(count - 1)
			drag_position = Vector2.ZERO
	update()


func _draw():
	if not debug and not Engine.editor_hint:
		return
	draw_rect(Rect2(-area_size / 2, area_size), color_area_debug, false)
	if scan:
		var angle_direction : = angle_offset
		var origin: Vector2 = touch_position - global_position
		var count: int = 0
		while angle_direction < 2 * PI + angle_offset:
			draw_line(origin, origin - Vector2(1, 0).rotated(angle_direction) * MIN_LENGTH_VECTOR, Color.white, 2.5)
			draw_circle(origin - Vector2(1, 0).rotated(angle_direction + radians_range/2) * MIN_LENGTH_VECTOR, 7.5, Color.black)
			font.draw(self.get_canvas_item(), origin - Vector2(1, 0).rotated(angle_direction + radians_range/2) * MIN_LENGTH_VECTOR + Vector2(-5,5), str(count))
			count += 1
			angle_direction += radians_range
		draw_line(origin, origin + drag_position, Color.red, 2.0)
	if Engine.editor_hint and not input_actions.empty():
		var angle_direction : = angle_offset
		radians_range = 2 * PI / float(max(1,input_actions.size()))
		while angle_direction < 2 * PI + angle_offset:
			draw_line(Vector2.ZERO, - Vector2(1, 0).rotated(angle_direction) * MIN_LENGTH_VECTOR, color_angle_separation, 2.5)
			draw_line(Vector2.ZERO, - Vector2(1, 0).rotated(angle_offset) * MIN_LENGTH_VECTOR, color_angle_separation.inverted(), 2.5)
			angle_direction += radians_range
