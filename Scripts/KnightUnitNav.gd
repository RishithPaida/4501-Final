extends CharacterBody3D

enum Task{
	Idle,
	Selected,
	Attacking,
	Walking,
}

var currentTask = Task.Idle
var resourcesHolding = 0
var Home


var target
var runOnce = true

@export var health : int
@export var speed : int

@onready var navAgent : NavigationAgent3D = $NavigationAgent3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var health_bar = $SubViewport/HealthBar

func _ready() -> void:
	health_bar.max_value = health 
	health_bar.value = health_bar.max_value


func _physics_process(delta):
	
	if not is_on_floor():
		
		velocity.y -= gravity * delta
		move_and_slide()
		
	match currentTask:
		Task.Idle:
			pass
		Task.Attacking:
			pass
		Task.Walking:
			if(navAgent.is_navigation_finished()):
				Task.Idle
			
			walk()
	
	#print(currentTask)

func moveTo(pos : Vector3):
	currentTask = Task.Walking
	navAgent.set_target_position(pos)
	

func walk():
	var targetPos = navAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	velocity = direction * speed
	move_and_slide()
	

func attack(enemy):
	target = enemy

func select():
	$SelectionCircle.show()
 
func deselect():
	$SelectionCircle.hide()
