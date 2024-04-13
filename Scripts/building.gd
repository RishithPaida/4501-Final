extends Node

@onready var health_bar = $SubViewport/HealthBar
@export var health = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar.max_value = health
	health_bar.value = health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func hit(damage):
	health -= damage
	health_bar.value = health
	
	if(health <= 0):
		queue_free()
