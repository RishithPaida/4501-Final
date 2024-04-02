extends CharacterBody3D

@onready var navAgent : NavigationAgent3D = $NavigationAgent3D
@onready var health_bar = $SubViewport/HealthBar

enum Task{
	Idle,
	Attacking
}

var currentTask = Task.Idle
var targetUnit

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
			var enemyList = get_tree().get_nodes_in_group("allyunit")
			var enemyFound = false
			for enemy in enemyList:
				if global_position.distance_to(enemy.global_position) < attackModeRange:
					targetUnit = enemy
					enemyFound = true
					currentTask = Task.Attacking
					break
		Task.Attacking:
			if(targetUnit != null):
				if global_position.distance_to(targetUnit.global_position) < range :
					if runOnce:
						runOnce = false
						await get_tree().create_timer(attackSpeed).timeout
						runOnce = true
						attack()
						
						print("Attacked!")
				else:
					navAgent.set_target_position(targetUnit.global_position)
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

func walk():
	var targetPos = navAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	velocity = direction * speed
	
	move_and_slide()
