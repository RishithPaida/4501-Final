extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if God.Curr_State == God.State.Play:
			
		var camera = get_viewport().get_camera_3d()
		var from = camera.project_ray_origin(get_viewport().get_mouse_position())
		var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000

		#var mouse_pos = Plane(Vector3.UP, transform.origin.y).intersects_ray(from, to)
		#Curr_Selected_Building_To_Build.position = Vector3(round(mouse_pos.x),round(mouse_pos.y),round(mouse_pos.z))

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.exclude = [self]
		query.collision_mask = 2
		var result = space_state.intersect_ray(query)
		
		if result :
			print(result.collider.name)
		
		if(God.Curr_Hovered_Object.is_in_group("allyUnit")):
			print("ally unit")

