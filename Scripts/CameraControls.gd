extends Node3D

# Sensitivity factors for mouse movement.
var sensitivity = 30
var zoom_sensitivity = 2.0
var RAY_LENGTH = 1000
# Threshold distance from the edge of the screen to start moving the camera.
var edge_threshold = 2.0
@onready var cam = $Camera

@onready var selection_box = $Control
var start_sel_pos = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Initial setup can be added here.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var viewport_size = get_viewport().size
	var center_position = viewport_size / 2
	var mouse_position = get_viewport().get_mouse_position()
	
	# Calculate the direction vector for the mouse movement relative to the center of the screen.
	var direction = Vector2(mouse_position.x - center_position.x, mouse_position.y - center_position.y)
	
	# Normalize the direction if you want consistent speed regardless of distance from center.
	if direction.length() > 0:
		direction = direction.normalized()
	

	if mouse_position.x < edge_threshold or mouse_position.x > viewport_size.x - edge_threshold or mouse_position.y < edge_threshold or mouse_position.y > viewport_size.y - edge_threshold:
		position.x += direction.x * sensitivity * delta
		position.z += direction.y * sensitivity * delta 
	
	#zoom controls
	if Input.is_action_just_pressed("scroll_up"):
		if $Camera.global_position.distance_to(global_position) > 0.5:
			$Camera.global_position -= $Camera.global_transform.basis.z * zoom_sensitivity
	if Input.is_action_just_pressed("scroll_down"):
		if $Camera.global_position.distance_to(global_position) < 20:
			$Camera.global_position += $Camera.global_transform.basis.z * zoom_sensitivity
	
	if Input.is_action_just_pressed("left_click"):
		selection_box.start_sel_pos = mouse_position
		start_sel_pos = mouse_position
	if Input.is_action_pressed("left_click"):
		selection_box.mouse_position = mouse_position
		selection_box.is_visible = true
	else:
		selection_box.is_visible = false
	if Input.is_action_just_released("left_click"):
		select_units(mouse_position)

func get_unit_under_mouse(m_pos):
	var unit = 	God._get_object_under_mouse_position(m_pos)
	if unit and unit.is_in_group("allyunit"):
		return unit


func select_units(m_pos):
	var new_selected_units = []
	if m_pos.distance_squared_to(start_sel_pos) < 16:
		var u = get_unit_under_mouse(m_pos)
		if u != null:
			new_selected_units.append(u)
	else:
		new_selected_units = get_units_in_box(start_sel_pos, m_pos)
	if new_selected_units.size() != 0:
		for unit in God.Selected_Units:
			unit.deselect()
		for unit in new_selected_units:
			unit.select()
		God.Selected_Units = new_selected_units
		if new_selected_units.size() == 1:
			for unit in God.Selected_Units:
				God.Selected_Object = unit
		
func get_units_in_box(top_left, bot_right):
	if top_left.x > bot_right.x:
		var tmp = top_left.x
		top_left.x = bot_right.x
		bot_right.x = tmp
	if top_left.y > bot_right.y:
		var tmp = top_left.y
		top_left.y = bot_right.y
		bot_right.y = tmp
	var box = Rect2(top_left, bot_right - top_left)
	var box_selected_units = []
	for unit in get_tree().get_nodes_in_group("allyunit"):
		if box.has_point(cam.unproject_position(unit.global_transform.origin)):
			box_selected_units.append(unit)
	return box_selected_units

