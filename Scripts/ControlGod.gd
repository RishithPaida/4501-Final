extends Node3D

var Curr_Selected_Building
var Curr_Selected_Unit

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if God.Curr_State == God.State.Play:		
		if(God.Curr_Hovered_Object != null):
			if(God.Curr_Hovered_Object.is_in_group("allyunit")):
				if Input.is_action_just_pressed("left_click"):
					print("Set selected unit")
					God.Selected_Units.append(God.Curr_Hovered_Object)
					God.Curr_Hovered_Object.select()
					God.Selected_Object = God.Curr_Hovered_Object
					
			elif(God.Curr_Hovered_Object.is_in_group("building")):
				if Input.is_action_just_pressed("left_click"):
					God.Curr_Selected_Building = God.Curr_Hovered_Object
					God.Selected_Object = God.Curr_Hovered_Object
					
			elif(God.Curr_Hovered_Object.is_in_group("resource")):
				if Input.is_action_just_pressed("left_click"):
					God.Selected_Object = God.Curr_Hovered_Object
		
			else:
				if Input.is_action_just_pressed("left_click"):
					God.Selected_Object = null
					for unit in God.Selected_Units:
						unit.deselect()
					God.Selected_Units = []
	
		if Input.is_action_just_pressed("right_click"):
			var index = 0
			if God.Selected_Units.size() != 0:
				var mouse_position_2d = God._get_curr_mouse_position_2D()
				for unit in God.Selected_Units:
					index += 1
					if(God.Curr_Hovered_Object.is_in_group("resource") and unit.is_in_group("gatherer")):
						unit.harvest(God.Curr_Hovered_Object)
					elif (God.Curr_Hovered_Object.is_in_group("townhall") and unit.is_in_group("gatherer")):
						unit.set_deliver()
					elif God.Curr_Hovered_Object.is_in_group("enemy"):
						unit.attack(God.Curr_Hovered_Object)
					elif God.Curr_Hovered_Object.is_in_group("enemybuilding"):
						unit.attack_building(God.Curr_Hovered_Object)
					else:
						var variation_Size = clamp(0.5 + 0.2 * God.Selected_Units.size(), 0.5, 2.0)
						var varied_Pos = Vector3(rng.randf_range(-variation_Size, variation_Size), 0, rng.randf_range(-variation_Size, variation_Size))
						unit.move_to(mouse_position_2d + varied_Pos)
						print("Move Unit")
