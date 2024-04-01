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

@export var health: int
@export var rubycost: int
@export var manacost: int

@onready var navAgent : NavigationAgent3D = $NavigationAgent3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var health_bar = $SubViewport/HealthBar

func _ready() -> void:

	health_bar.max_value = health 
	
	


func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		move_and_slide()
		
	match currentTask:
		Task.Idle:
			pass
		Task.Delivering:
			if(global_position.distance_to(Home) > 1):
				#print(position.distance_to(Home.global_position))
				walk()
			else:
				print("Dropped off!")
				God.ruby += resourcesHolding
				resourcesHolding = 0
				harvest(harvestUnit)
		Task.GettingResources:
			if(position.distance_to(harvestUnit.global_position) > 2):
				#print(position.distance_to(harvestUnit.global_position))
				walk()
			else:
				if runOnce:
					runOnce = false
					await get_tree().create_timer(2).timeout
					runOnce = true
					resourcesHolding = 10
					moveTo(Home)
					currentTask = Task.Delivering
					print("Harvested!")
		Task.Walking:
			if(navAgent.is_navigation_finished()):
				Task.Idle
			
			walk()
	
	#print(currentTask)

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
	
	

func setDeliver():
	if(resourcesHolding == 0):
		return
	moveTo(Home)
	currentTask = Task.Delivering

func select():
	$SelectionCircle.show()
 
func deselect():
	$SelectionCircle.hide()
