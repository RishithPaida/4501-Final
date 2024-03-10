extends Node

enum State  {
	Play,
	Build,
	Combat
}

var wood := 30
var ruby := 30
var mana := 30
var food := 30

var Curr_State = State.Play

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
