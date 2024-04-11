extends CharacterBody3D

@onready var navAgent : NavigationAgent3D = $NavigationAgent3D
@onready var health_bar = $SubViewport/HealthBar

enum Task{
	Idle,
	Attacking,
	AttackingBuilding
}

var currentTask = Task.Idle
var targetUnit
var targetBuilding = null

var runOnce = true
@export var speed = 2
@export var health : int = 100
@export var attackSpeed: float = 1.0
@export var range: float = 2.0
@export var attackDamage: float = 20
@export var attackModeRange: int = 6

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar.max_value = health 
	health_bar.value = health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		move_and_slide()
	
	if(health <= 0):
		queue_free()
		
	match currentTask:
		Task.Idle:
			if(targetBuilding != null):
				currentTask =Task.AttackingBuilding
			checkForEnemy()
		Task.Attacking:
			if(targetUnit != null):
				if global_position.distance_to(targetUnit.global_position) < range :
					if runOnce:
						runOnce = false
						await get_tree().create_timer(attackSpeed).timeout
						runOnce = true
						attack()
						
						print("Attacked!")
						
				elif global_position.distance_to(targetUnit.global_position) > attackModeRange:
					targetUnit = null
					currentTask = Task.Idle
				else:
					navAgent.set_target_position(targetUnit.global_position)
					walk()
			else:
				currentTask = Task.Idle
		Task.AttackingBuilding:
			checkForEnemy()
			if(currentTask == Task.Attacking):
				pass
			elif(targetBuilding != null):
				if global_position.distance_to(targetBuilding.global_position) < range * 2 :
					if runOnce:
						runOnce = false
						await get_tree().create_timer(attackSpeed).timeout
						runOnce = true
						attackBuilding()
						print("Attacked!")
				else:
					navAgent.set_target_position(targetBuilding.global_position)
					walk()
			else:
				currentTask = Task.Idle

func hurt(damage):
	health -= damage
	health_bar.value = health

func attack():
	if targetUnit != null :
		targetUnit.hurt(attackDamage)
	else:
		targetUnit = null

func attackBuilding():
	if(targetBuilding != null):
		targetBuilding.hit(attackDamage)

func walk():
	var targetPos = navAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	look_at(global_position + direction * Vector3(1, 0, 1))
	velocity = direction * speed
	
	move_and_slide()

func checkForEnemy():
	var enemyList = get_tree().get_nodes_in_group("allyunit")
	var enemyFound = false
	for enemy in enemyList:
		if global_position.distance_to(enemy.global_position) < attackModeRange:
			targetUnit = enemy
			enemyFound = true
			currentTask = Task.Attacking
			break
	if(enemyFound == false):
		checkForBuilding()

func checkForBuilding():
	var buildingList = get_tree().get_nodes_in_group("allybuilding")
	var buildingFound = false
	for building in buildingList:
		if global_position.distance_to(building.global_position) < attackModeRange * 5:
			targetBuilding = building
			buildingFound = true
			currentTask = Task.AttackingBuilding
			break

func setTargetBuilding(building):
	targetBuilding = building
	currentTask = Task.AttackingBuilding
