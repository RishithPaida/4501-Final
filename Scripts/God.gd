extends Node3D

enum State  {
	Play,
	Build,
	Combat,
}

var wood := 2000
var ruby := 3500
var mana := 2500
var food := 500

var RAY_LENGTH = 1000
var Curr_State = State.Play
var Curr_Hovered_Object
var Selected_Units = []
var Selected_Object = null

var Curr_Selected_Building
var Curr_Selected_Unit
var Curr_Action_Unit

var Curr_Selected_Position : Vector3 = Vector3.ZERO
@onready var previous_window = DisplayServer.window_get_mode()
@onready var current_window = DisplayServer.window_get_mode()

var hovering_building = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if Curr_Hovered_Object != null:
		if Curr_Hovered_Object.is_in_group("building"):
			if not hovering_building:
				BuildingGod.Curr_Hovered_Building = Curr_Hovered_Object
				BuildingGod.Highlight_Hovered_Building(Curr_Hovered_Object)
				hovering_building = true
				
		else:
			if hovering_building:
				BuildingGod.DeHighlight_Hovered_Building()
				BuildingGod.Curr_Hovered_Building = null
				hovering_building = false
				
func _input(event):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		current_window = DisplayServer.window_get_mode()
		if current_window != 4:
			previous_window = current_window
			DisplayServer.window_set_mode(4)
		else:
			if previous_window == 4:
				previous_window = 0
			DisplayServer.window_set_mode(previous_window)
			DisplayServer.window_set_size(Vector2i(1152, 648))

func _unhandled_input(event):
	if Curr_State == State.Play:
		if event is InputEventMouseMotion:
			# Perform the raycast to see what the mouse is hovering over.
			_get_object_under_mouse_position(event.position)

func _get_curr_mouse_position_2D():
		var camera = get_viewport().get_camera_3d()
		var from = camera.project_ray_origin(get_viewport().get_mouse_position())
		var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.exclude = [self]
		query.collision_mask = 2
		var result = space_state.intersect_ray(query)
		
		if(!result.is_empty()):
			return result.position
		else:
			return Vector3(0.0, -100, 0.0)
	
	
func _get_object_under_mouse_position(mouse_position):
	var from = get_viewport().get_camera_3d().project_ray_origin(mouse_position)
	var to = from + get_viewport().get_camera_3d().project_ray_normal(mouse_position) * 1000
	var space_state = get_world_3d().direct_space_state

	# Perform the raycast.
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	if result:	
		Curr_Hovered_Object = result.collider
