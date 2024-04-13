extends CharacterBody3D

@onready var navAgent : NavigationAgent3D = $NavigationAgent3D
@onready var health_bar = $SubViewport/HealthBar

enum Task{
	Idle,
	Attacking,
	AttackingBuilding
}

var current_task = Task.Idle
var target_unit
var target_building = null

var run_once = true
@export var speed = 2
@export var health : int = 100
@export var attack_speed: float = 1.0
@export var range: float = 2.0
@export var attack_damage: float = 20
@export var attack_mode_range: int = 6

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
		
	match current_task:
		Task.Idle:
			if(target_building != null):
				current_task =Task.AttackingBuilding
			check_for_enemy()
		Task.Attacking:
			if(target_unit != null):
				if global_position.distance_to(target_unit.global_position) < range :
					if run_once:
						run_once = false
						await get_tree().create_timer(attack_speed).timeout
						run_once = true
						attack()
						
						print("Attacked!")
						
				elif global_position.distance_to(target_unit.global_position) > attack_mode_range:
					target_unit = null
					current_task = Task.Idle
				else:
					navAgent.set_target_position(target_unit.global_position)
					walk()
			else:
				current_task = Task.Idle
		Task.AttackingBuilding:
			check_for_enemy()
			if(current_task == Task.Attacking):
				pass
			elif(target_building != null):
				if global_position.distance_to(target_building.global_position) < range * 2 :
					if run_once:
						run_once = false
						await get_tree().create_timer(attack_speed).timeout
						run_once = true
						attack_building()
						print("Attacked!")
				else:
					navAgent.set_target_position(target_building.global_position)
					walk()
			else:
				current_task = Task.Idle

func hurt(damage):
	health -= damage
	health_bar.value = health

func attack():
	if target_unit != null :
		target_unit.hurt(attack_damage)
	else:
		target_unit = null

func attack_building():
	if(target_building != null):
		target_building.hit(attack_damage)

func walk():
	var targetPos = navAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	look_at(global_position + direction * Vector3(1, 0, 1))
	velocity = direction * speed
	
	move_and_slide()

func check_for_enemy():
	var enemyList = get_tree().get_nodes_in_group("allyunit")
	var enemyFound = false
	for enemy in enemyList:
		if global_position.distance_to(enemy.global_position) < attack_mode_range:
			target_unit = enemy
			enemyFound = true
			current_task = Task.Attacking
			break
	if(enemyFound == false):
		check_for_building()

func check_for_building():
	var buildingList = get_tree().get_nodes_in_group("allybuilding")
	var buildingFound = false
	for building in buildingList:
		if global_position.distance_to(building.global_position) < attack_mode_range * 5 and building.is_built:
			target_building = building
			buildingFound = true
			current_task = Task.AttackingBuilding
			break

func set_target_building(building):
	target_building = building
	current_task = Task.AttackingBuilding
