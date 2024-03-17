extends Node3D

enum State  {
	Play,
	Build,
	Combat,
	Spawn
}

var wood := 30
var ruby := 30
var mana := 30
var food := 30

var RAY_LENGTH = 1000
var Curr_State = State.Play
var Curr_Hovered_Object
var Curr_Selected_Unit

var Curr_Selected_Position : Vector3 = Vector3.ZERO

var hovering_building = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Curr_Hovered_Object:
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

func _unhandled_input(event):
	if Curr_State == State.Play:
		if event is InputEventMouseMotion:
			# Perform the raycast to see what the mouse is hovering over.
			_perform_raycast_from_mouse_position(event.position)

func _perform_raycast_from_mouse_position(mouse_position):
	var from = get_viewport().get_camera_3d().project_ray_origin(mouse_position)
	var to = from + get_viewport().get_camera_3d().project_ray_normal(mouse_position) * 1000
	var space_state = get_world_3d().direct_space_state

	# Perform the raycast.
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)

	Curr_Hovered_Object = result.collider
	
