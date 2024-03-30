extends Node3D

var Curr_Selected_Building
var Curr_Selected_Unit

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
		
		if(God.Curr_Hovered_Object):
			if(God.Curr_Hovered_Object.is_in_group("allyUnit")):
				if Input.is_action_just_pressed("left_click"):
					print("Set selected unit")
					God.Curr_Selected_Unit = God.Curr_Hovered_Object
					God.Selected_Object = God.Curr_Hovered_Object
					
			elif(God.Curr_Hovered_Object.is_in_group("building")):
				if Input.is_action_just_pressed("left_click"):
					God.Curr_Selected_Building = God.Curr_Hovered_Object
					God.Selected_Object = God.Curr_Hovered_Object
					
					print(God.Curr_Hovered_Object.get_name())
					print("selected Building: " + str(God.Curr_Selected_Building.name) ) 	
			else:
				if Input.is_action_just_pressed("left_click"):
					God.Selected_Object = null
	
		if God.Curr_Selected_Unit:
			if Input.is_action_just_pressed("right_click") and (God.Curr_Selected_Unit.is_in_group("allyUnit")):
				if(God.Curr_Hovered_Object.is_in_group("resource")):
					God.Curr_Selected_Unit.harvest(God.Curr_Hovered_Object)
				elif (God.Curr_Hovered_Object.is_in_group("townhall")):
					God.Curr_Selected_Unit.setDeliver()
				else:
					God.Curr_Selected_Unit.moveTo(result.position)
					print("Move Unit")



