extends Node3D

#Load the shaders
var green_glow_shader = load("res://Shaders/GreenGlow.gdshader")
var red_glow_shader = load("res://Shaders/RedGlow.gdshader")

var green_shade = ShaderMaterial
var red_shade = ShaderMaterial
var original_material

#Load the buildings
var TownHall : PackedScene = ResourceLoader.load("res://Scenes/Buildings/Townhall.tscn")
var ManaPump : PackedScene = ResourceLoader.load("res://Scenes/Buildings/ManaPump.tscn")
var Barracks : PackedScene = ResourceLoader.load("res://Scenes/Buildings/Barracks.tscn")

var Curr_Hovered_Building : StaticBody3D
var Curr_Selected_Building_To_Build : StaticBody3D


var can_build := true
# Called when the node enters the scene tree for the first time.

func _ready():
	# Create ShaderMaterials for each shader
	green_shade = ShaderMaterial.new()
	green_shade.shader = green_glow_shader

	red_shade = ShaderMaterial.new()
	red_shade.shader = red_glow_shader



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if God.Curr_State == God.State.Build:
		
		var camera = get_viewport().get_camera_3d()
		var from = camera.project_ray_origin(get_viewport().get_mouse_position())
		var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000
		var mouse_pos = Plane(Vector3.UP, transform.origin.y).intersects_ray(from, to)
		Curr_Selected_Building_To_Build.position = Vector3(round(mouse_pos.x),round(mouse_pos.y),round(mouse_pos.z))
		
		
		if can_build:
			Curr_Selected_Building_To_Build.get_node("MeshInstance3D").material_override = green_shade
		else:
			Curr_Selected_Building_To_Build.get_node("MeshInstance3D").material_override = red_shade
			
		if can_build:
			if Input.is_action_just_pressed("left_click"):
				var building := Curr_Selected_Building_To_Build.duplicate()
				get_tree().root.add_child(building)
				building.position = Curr_Selected_Building_To_Build.position
				building.get_node("MeshInstance3D").material_override = original_material

		if Input.is_action_just_pressed("right_click"):
			Curr_Selected_Building_To_Build.queue_free()
			God.Curr_State = God.State.Play
			
	if God.Curr_State == God.State.Play:
		if Curr_Hovered_Building:
			Curr_Hovered_Building.get_node("MeshInstance3D").material_override = green_shade		
		
func Build_Town_Hall():
	Build(TownHall)

func Build_Mana_Pump():
	Build(ManaPump)
	
func Build_Barracks():
	Build(Barracks)
	
func Build(building):
	if Curr_Selected_Building_To_Build != null:
		Curr_Selected_Building_To_Build.queue_free()
	Curr_Selected_Building_To_Build = building.instantiate()
	original_material = Curr_Selected_Building_To_Build.get_node("MeshInstance3D").material_override
	
	get_tree().root.add_child(Curr_Selected_Building_To_Build)
	God.Curr_State = God.State.Build
