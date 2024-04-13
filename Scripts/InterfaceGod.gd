extends Control

var Curr_Interface

var children:Array = get_children()
var shared_groups = ['building', 'allyunit', 'enemyUnit', 'resource']
var Curr_Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Resources/VBoxContainer/food/foodval.text = str(God.food)
	$Resources/VBoxContainer/wood/woodval.text = str(God.wood)
	$Resources/VBoxContainer/ruby/rubyval.text = str(God.ruby)
	$Resources/VBoxContainer/mana/manaval.text = str(God.mana)
	
	var panels = get_panels()
	# Nothing selected
	
	if God.Selected_Object == null:
		change_ui(panels, 'buildingpanel')
		# UI for build mode
		if God.Curr_State == God.State.Build:
			change_ui(panels, 'buildmode')
	else:
		Curr_Interface = God.Selected_Object.get_groups()
		for group in Curr_Interface:
			if group not in shared_groups:
				change_ui(panels, group)
	# Top layer
	if God.Selected_Units.size() > 1:
		change_ui(panels, 'selectedunits')
		
# =================================User Interface=================================

func change_ui(panels, group):
	for panel in panels:
		if group.to_lower() in panel.get_name().to_lower():
			panel.visible = true
			enable_buttons_in_panel(panel)
			update_labels(panel)
			show_selected_units(panel)
			Curr_Panel = panel
		else:
			panel.visible = false
			disable_buttons_in_panel(panel)

func show_selected_units(panel):
	for child in panel.get_children():
		pass

func update_labels(panel):
	for child in panel.get_children():
		if child is VBoxContainer:
			for stat in child.get_children():
				for value in stat.get_children():
					if value.get_name() == 'Health':
						value.text = str(God.Selected_Object.health)
					elif value.get_name() == 'ATK':
						value.text = str(God.Selected_Object.attack_speed)
					elif value.get_name() == 'SPD':
						value.text = str(God.Selected_Object.speed)
					elif value.get_name() == 'RANGE':
						value.text = str(God.Selected_Object.range)
					elif value.get_name() == 'RubyCap':
						value.text = str(God.Selected_Object.capacity)

func enable_buttons_in_panel(panel_node):
	for child in panel_node.get_children():
		if child is Button:
			child.disabled = false

func disable_buttons_in_panel(panel_node):
	for child in panel_node.get_children():
		if child is Button:
			child.disabled = true
# =================================Visibility=================================

func get_panels():
	var panel_list: Array = []
	for child in get_children():
		if child is Panel:
			panel_list.append(child)
	return panel_list

func _on_ui_area_area_entered(area):
	if area.is_in_group("mouse_area"):
		BuildingGod.can_build = false

func _on_ui_area_area_exited(area):
	if area.is_in_group("mouse_area"):
		BuildingGod.can_build = true

# =================================Build Buttons=================================

func _on_build_mana_pump_button_button_down():
	BuildingGod.Build_Mana_Pump()

func _on_build_barracks_button_3_button_down():
	BuildingGod.Build_Barracks()

func _on_build_town_hall_button_button_down():
	BuildingGod.Build_Town_Hall()

# =================================Spawn Buttons=================================

func _spawn_unit(unit_type):
	var children = Curr_Panel.get_children()
	var units = God.Curr_Selected_Building.spawnable_units
	# unit = packedscn
	for unit in units:
		var temp = unit.instantiate()
		if temp.is_in_group(unit_type):
			God.Curr_Selected_Building.Spawn(unit)
		temp.queue_free()

	God.Curr_Hovered_Object = null

func _on_knight_spawn_button_down():
	_spawn_unit('knight')

func _on_wisp_spawn_button_down():
	_spawn_unit('wisp')

func _on_spawn_gatherer_button_down():
	_spawn_unit('gatherer')

