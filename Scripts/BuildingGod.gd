extends Node3D

#Load the buildings
var TownHall : PackedScene = ResourceLoader.load("res://Scenes/Townhall.tscn")

var Curr_Selected_Building : StaticBody3D

var can_build := true
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if God.Curr_State == God.State.Build:
		var camera = get_viewport().get_camera_3d()
		var from = camera.project_ray_origin(get_viewport().get_mouse_position())
		var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000
		var mouse_pos = Plane(Vector3.UP, transform.origin.y).intersects_ray(from, to)
		Curr_Selected_Building.position = Vector3(mouse_pos.x,mouse_pos.y,mouse_pos.z)
		
		if can_build:
			if Input.is_action_just_pressed("left_click"):
				var building := Curr_Selected_Building.duplicate()
				get_tree().root.add_child(building)
				building.position = Curr_Selected_Building.position
			
		if Input.is_action_just_pressed("right_click"):
			Curr_Selected_Building.queue_free()
			God.Curr_State = God.State.Play
		
func Build_Town_Hall():
	Build(TownHall)
	
func Build(building):
	if Curr_Selected_Building != null:
		Curr_Selected_Building.queue_free()
	
	Curr_Selected_Building = building.instantiate()
	get_tree().root.add_child(Curr_Selected_Building)
	God.Curr_State = God.State.Build
