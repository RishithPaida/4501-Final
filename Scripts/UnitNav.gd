extends CharacterBody3D

enum Task{
	Idle,
	Selected,
	GettingResources,
	Walking,
	Delivering,
	Attacking,
}

var currentTask = Task.Idle
var resourcesHolding = 0
var Home
var rand_animation = RandomNumberGenerator.new()

var harvestUnit
var targetUnit
var runOnce = true
@export var speed = 2

@export var health: int
@export var rubycost: int
@export var manacost: int

@onready var navAgent : NavigationAgent3D = $NavigationAgent3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var health_bar = $SubViewport/HealthBar
@onready var animation_player = $AnimationPlayer

@export var canAttack: bool = true
@export var attackSpeed: float = 1.0
@export var range: float = 2.0
@export var attackDamage: float = 50
@export var attackModeRange: int = 5

func _ready() -> void:
	health_bar.max_value = health 
	health_bar.value = health

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		move_and_slide()

	if health <= 0:
		God.Selected_Units.erase(self)
		queue_free()

	match currentTask:
		Task.Idle:
			#animation_player.current_animation = "Idle"
			#animate_either("Idle", "2H_Melee_Idle")
			var enemyList = get_tree().get_nodes_in_group("enemy")
			for enemy in enemyList:
				if global_position.distance_to(enemy.global_position) < attackModeRange:
					targetUnit = enemy
					attack(targetUnit)
					currentTask = Task.Attacking
					#print("found another enemy")
					break
				
		Task.Delivering:
			if(global_position.distance_to(Home) > 1):
				#print(position.distance_to(Home.global_position))
				walk()
			else:
				print("Dropped off!")
				deliver()
				resourcesHolding = 0
				harvest(harvestUnit)
				
		Task.GettingResources:
			if(global_position.distance_to(harvestUnit.global_position) > range):
				#print(position.distance_to(harvestUnit.global_position))
				walk()
			else:
				if runOnce:
					runOnce = false
					await get_tree().create_timer(2).timeout
					runOnce = true
					resourcesHolding = harvestUnit.collect()
					moveTo(Home)
					currentTask = Task.Delivering
					print("Harvested!")
					
		Task.Walking:
			if(navAgent.is_navigation_finished()):
				currentTask = Task.Idle
			walk()
			#animation_player.current_animation = "Running_A"
			
		Task.Attacking:
			if(targetUnit != null):
				if global_position.distance_to(targetUnit.global_position) < range :
					if runOnce:
						runOnce = false
						#animation_player.current_animation = "1H_Melee_Attack_Chop"
						await get_tree().create_timer(attackSpeed).timeout
						runOnce = true
						attackUnit()
						print("Attacked!")
				else:
					navAgent.set_target_position(targetUnit.global_position)
					walk()
			else:
				currentTask = Task.Idle
	
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
	
	look_at(global_position + direction * Vector3(1, 0, 1))
	velocity = direction * speed
	move_and_slide()
	

func setDeliver():
	if(resourcesHolding == 0):
		return
	moveTo(Home)
	currentTask = Task.Delivering
	

func attack(enemy):
	if canAttack:
		targetUnit = enemy
		moveTo(enemy.global_position)
		currentTask = Task.Attacking

func attackUnit():
	if targetUnit != null :
		targetUnit.hurt(attackDamage)
	else:
		targetUnit = null

func hurt(damage):
	health -= damage
	health_bar.value = health

func deliver():
	if harvestUnit.is_in_group("rubyclump"):
		God.ruby += resourcesHolding
	elif harvestUnit.is_in_group("tree"):
		God.wood += resourcesHolding

func select():
	$SelectionCircle.show()
 
func deselect():
	$SelectionCircle.hide()
