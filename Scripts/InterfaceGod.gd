extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$BuildingPanel/Resources/VBoxContainer/food/foodval.text = str(God.food)
	$BuildingPanel/Resources/VBoxContainer/wood/woodval.text = str(God.wood)
	$BuildingPanel/Resources/VBoxContainer/ruby/rubyval.text = str(God.ruby)
	$BuildingPanel/Resources/VBoxContainer/mana/manaval.text = str(God.mana)
	
		
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

