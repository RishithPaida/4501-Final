extends CharacterBody3D

enum Task{
	Idle,
	Selected,
	GettingResources,
	Walking,
	Delivering
}

var currentTask = Task.Idle
var resourcesHolding = 0
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
			print("Finished harvesting")
			print(resourcesHolding)
			currentTask = Task.Idle
		Task.GettingResources:
			if(position.distance_to(harvestUnit.global_position) > 7):
				print(position.distance_to(harvestUnit.global_position))
				walk()
			else:
				if runOnce:
					runOnce = false
					await get_tree().create_timer(2).timeout
					runOnce = true
					resourcesHolding = 20
					currentTask = Task.Delivering
		Task.Walking:
			if(navAgent.is_navigation_finished()):
				Task.Idle
			
			walk()

func moveTo(pos : Vector3):
	currentTask = Task.Walking
	navAgent.set_target_position(pos)
	
func harvest(resource):
	harvestUnit = resource
	moveTo(harvestUnit.global_position)
	currentTask = Task.GettingResources
	print("Going to harvest!")
	
func walk():
	var targetPos = navAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	velocity = direction * speed
	move_and_slide()
