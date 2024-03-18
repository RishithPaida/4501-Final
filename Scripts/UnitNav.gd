extends CharacterBody3D

enum Task{
	Idle,
	Selected,
	GettingRessources,
	Walking,
	Delivering
}

var currentTask = Task.Idle
var ressourcesHolding = 0
var Home

var harvestUnit
var runOnce = true
@export var speed = 2

@onready var navAgent : NavigationAgent3D = $NavigationAgent3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	pass


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		move_and_slide()
		
	match currentTask:
		Task.Idle:
			pass
		Task.Delivering:
			pass
		Task.GettingRessources:
			if(position.distance_to(harvestUnit.position) > 1):
				walk()
			else:
				if runOnce:
					runOnce = false
					await get_tree().create_timer(2).timeout
					runOnce = true
					ressourcesHolding = 20
					currentTask = Task.Delivering
		Task.Walking:
			if(navAgent.is_navigation_finished()):
				Task.Idle
			
			walk()

func moveTo(pos : Vector3):
	currentTask = Task.Walking
	navAgent.set_target_position(pos)
	
func harvest(ressource):
	pass
	
func walk():
	var targetPos = navAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	velocity = direction * speed
	move_and_slide()
