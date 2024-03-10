extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_build_town_hall_button_button_down():
	BuildingGod.Build_Town_Hall()


func _on_ui_area_area_entered(area):
	if area.is_in_group("mouse_area"):
		BuildingGod.can_build = false


func _on_ui_area_area_exited(area):
	if area.is_in_group("mouse_area"):
		BuildingGod.can_build = true
