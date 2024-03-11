extends Node

var curr_building_collisions = 0
@export var selected : bool = false
@export var Unit : PackedScene

@export var woodcost : int
@export var foodcost : int
@export var rubycost : int
@export var manacost : int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if selected:
		if is_in_group("townhall"):
			
			God.Curr_State = God.State.Spawn
		elif is_in_group("barracks"):
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

