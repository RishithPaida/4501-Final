extends Node

var curr_building_collisions = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	if body.is_in_group("building"):
		if body != self:
			curr_building_collisions += 1
			set_building_perms()
	
	


func _on_area_3d_body_exited(body):
	if body.is_in_group("building"):
		if body != self:
			curr_building_collisions -= 1
			set_building_perms()
		
func set_building_perms():
	BuildingGod.can_build = (curr_building_collisions == 0)



func _on_mouse_entered():
	print("Hovering over: ")
	pass # Replace with function body.
