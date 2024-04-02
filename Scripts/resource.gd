extends Node

@export var capacity : int = 500
@export var harvestAmount : int = 15

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func collect() -> int:
	if capacity > 0:
		capacity -= harvestAmount
		return harvestAmount 
	else:
		return 0
	
