extends Node3D

#Load the shaders
var green_glow_shader = load("res://Shaders/GreenGlow.gdshader")
var red_glow_shader = load("res://Shaders/RedGlow.gdshader")
@onready var ally_townhall_built = false
var green_shade = ShaderMaterial
var red_shade = ShaderMaterial
var original_material
var dehighlight_material
var off_map : bool
#Load the buildings
var TownHall : PackedScene = ResourceLoader.load("res://Scenes/Buildings/Townhall.tscn")
var ManaPump : PackedScene = ResourceLoader.load("res://Scenes/Buildings/ManaPump.tscn")
var Barracks : PackedScene = ResourceLoader.load("res://Scenes/Buildings/Barracks.tscn")

var Curr_Hovered_Building : StaticBody3D
var Curr_Selected_Building_Scene :PackedScene
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
		
		#Previewing Building
		Preview_Selected_Building()
		Display_Buildability()
		
		#Handling Build State Input
		if Input.is_action_just_pressed("left_click"):	
			Place_Selected_Building(Curr_Selected_Building_To_Build)
					
		if Input.is_action_just_pressed("right_click"):
			Exit_Build_State()


func Build_Town_Hall():
	Build(TownHall)

func Build_Mana_Pump():
	Build(ManaPump)
	
func Build_Barracks():
	Build(Barracks)
	
func Build(building):
	if Curr_Selected_Building_Scene != null:
		Curr_Selected_Building_Scene = null
	if Curr_Selected_Building_To_Build != null:
		Curr_Selected_Building_To_Build.queue_free()
	
	Curr_Selected_Building_Scene = building
	Curr_Selected_Building_To_Build = building.instantiate()
	get_tree().root.add_child(Curr_Selected_Building_To_Build)
	God.Curr_State = God.State.Build

func Place_Selected_Building(building):
	if can_build and Check_If_Affordable(Curr_Selected_Building_To_Build):
		var my_building = Curr_Selected_Building_Scene.instantiate()
		get_tree().get_nodes_in_group("buildingHolder")[0].add_child(my_building)
		my_building.position = Curr_Selected_Building_To_Build.position
		Purchase_Building(my_building)
		my_building.set_name(Curr_Selected_Building_To_Build.get_name())
		get_tree().get_nodes_in_group("NavMesh")[0].bake_navigation_mesh(true)
		my_building.is_built = true
	else:
		#print("TOO POOR")
		pass

func Display_Buildability():
	if can_build:
		Curr_Selected_Building_To_Build.get_node("MeshInstance3D").material_override = green_shade
	else:
		Curr_Selected_Building_To_Build.get_node("MeshInstance3D").material_override = red_shade
			
func Highlight_Hovered_Building(building):
	print(Curr_Hovered_Building.get_node("MeshInstance3D").material_override)
	dehighlight_material = Curr_Hovered_Building.get_node("MeshInstance3D").material_override
	Curr_Hovered_Building.get_node("MeshInstance3D").material_override = green_shade
	
func DeHighlight_Hovered_Building():
	if Curr_Hovered_Building != null:
		Curr_Hovered_Building.get_node("MeshInstance3D").material_override = dehighlight_material

func Preview_Selected_Building():
	var mouse_position_2d = God._get_curr_mouse_position_2D()
	if mouse_position_2d == Vector3(0,-100,0):
		Curr_Selected_Building_To_Build.queue_free()
		God.Curr_State = God.State.Play
	if(mouse_position_2d):
		Curr_Selected_Building_To_Build.position = Vector3(round(mouse_position_2d.x), mouse_position_2d.y, round(mouse_position_2d.z))
		
func Check_If_Affordable(building) -> bool:
	
	if not ally_townhall_built and not building.is_in_group("townhall"):
		return false
	if God.wood - building.woodcost < 0:
		return false
	if God.food - building.foodcost < 0:
		return false
	if God.ruby - building.rubycost < 0:
		return false
	if God.mana - building.manacost < 0:
		return false
	if building.is_in_group("townhall"):
		if not ally_townhall_built:
			ally_townhall_built = true
		else:
			return false
	return true
	
func Purchase_Building(building):
	God.wood -= building.woodcost
	God.food -= building.foodcost
	God.ruby -= building.rubycost
	God.mana -= building.manacost

func Exit_Build_State():
	Curr_Selected_Building_Scene = null
	Curr_Selected_Building_To_Build.queue_free()
	God.Curr_State = God.State.Play
