extends Control

var Curr_Interface

var children:Array = get_children()
var shared_groups = ['building', 'allyUnit', 'enemyUnit', 'resource']

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
		for panel in panels:
			panel.visible = false
			disable_buttons_in_panel(panel)
			
		$BuildingPanel.visible = true
		$BuildingPanel/BuildTownHallButton.set_disabled(false)
		$BuildingPanel/BuildManaPumpButton.set_disabled(false)
		$BuildingPanel/BuildBarracksButton3.set_disabled(false)
		
		# UI for build mode
		if God.Curr_State == God.State.Build:
			for panel in panels:
				panel.visible = false
				disable_buttons_in_panel(panel)
	else:
		Curr_Interface = God.Selected_Object.get_groups()
		for group in Curr_Interface:
			if group not in shared_groups:
				change_ui(panels, group)
	
func change_ui(panels, group):
	for panel in panels:
		if group.to_lower() in panel.get_name().to_lower():
			panel.visible = true
			enable_buttons_in_panel(panel)
		else:
			panel.visible = false
			disable_buttons_in_panel(panel)

func get_panels():
	var panel_list: Array = []
	for child in get_children():
		if child is Panel:
			panel_list.append(child)
	return panel_list

func enable_buttons_in_panel(panel_node):
	for child in panel_node.get_children():
		if child is Button:
			child.disabled = false

func disable_buttons_in_panel(panel_node):
	for child in panel_node.get_children():
		if child is Button:
			child.disabled = true

func _on_ui_area_area_entered(area):
	if area.is_in_group("mouse_area"):
		BuildingGod.can_build = false


func _on_ui_area_area_exited(area):
	if area.is_in_group("mouse_area"):
		BuildingGod.can_build = true


func _on_build_mana_pump_button_button_down():
	BuildingGod.Build_Mana_Pump()


func _on_build_barracks_button_3_button_down():
	BuildingGod.Build_Barracks()


func _on_build_town_hall_button_button_down():
	BuildingGod.Build_Town_Hall()


func _on_spawn_gatherer_button_button_down():
	God.Curr_Selected_Building.Spawn()
	God.Curr_Selected_Building = null
	God.Curr_Hovered_Object = null
	print(God.Curr_State)
	#God.Curr_Selected_Building.Spawn()
