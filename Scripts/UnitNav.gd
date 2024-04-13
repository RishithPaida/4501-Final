extends CharacterBody3D

enum Task{
	Idle,
	Selected,
	GettingResources,
	Walking,
	Delivering,
	Attacking,
	AttackingBuilding,
}

var animations = {
	"idle":"Idle",
	"melee_attack":"1H_Melee_Attack_Chop",
	"melee_atkbuild":"1H_Melee_Attack_Slice_Diagonal",
	"ranged_attack":"1H_Ranged_Shoot",
	"ranged_atkbuild":"2H_Ranged_Shoot",
	"walking":"Running_A",
	"hit":"Hit_A",
	"death":"Death_C_Skeletons"
}

var current_task = Task.Idle
var resources_holding = 0
var Home
var rand_animation = RandomNumberGenerator.new()

var harvest_unit
var target_unit
var run_once = true
@export var speed = 2

@export var health: int
@export var rubycost: int
@export var manacost: int
@export var woodcost: int
@export var foodcost: int
@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var health_bar = $SubViewport/HealthBar
@onready var animation_player = $AnimationPlayer

@export var can_attack: bool = true
@export var attack_speed: float = 1.0
@export var range: float = 2.0
@export var attack_damage: float = 50
@export var attack_mode_range: int = 5
@export_enum("melee", "ranged") var attack_type: String

func _ready() -> void:
	health_bar.max_value = health 
	health_bar.value = health

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		move_and_slide()

	if health <= 0:
		God.Selected_Units.erase(self)
		animate('death')
		await get_tree().create_timer(0.5).timeout
		queue_free()

	match current_task:
		Task.Idle:
			var enemy_list = get_tree().get_nodes_in_group("enemy")
			for enemy in enemy_list:
				if global_position.distance_to(enemy.global_position) < attack_mode_range:
					target_unit = enemy
					attack(target_unit)
					current_task = Task.Attacking
					break
		Task.Delivering:
			if(global_position.distance_to(Home) > 1):
				walk()
			else:
				deliver()
				resources_holding = 0
				harvest(harvest_unit)
		Task.GettingResources:
			if(global_position.distance_to(harvest_unit.global_position) > range):
				walk()
			else:
				if run_once:
					run_once = false
					await get_tree().create_timer(2).timeout
					run_once = true
					resources_holding = harvest_unit.collect()
					move_to(Home)
					current_task = Task.Delivering
		Task.Walking:
			if(nav_agent.is_navigation_finished()):
				current_task = Task.Idle
			walk()
		Task.Attacking:
			if(target_unit != null):
				if global_position.distance_to(target_unit.global_position) < range :
					if run_once:
						run_once = false
						await get_tree().create_timer(attack_speed).timeout
						run_once = true
						attack_unit()
				else:
					nav_agent.set_target_position(target_unit.global_position)
					walk()
			else:
				current_task = Task.Idle
		Task.AttackingBuilding:
			if(target_unit != null):
				if global_position.distance_to(target_unit.global_position) < range * 2 :
					if run_once:
						run_once = false
						await get_tree().create_timer(attack_speed).timeout
						run_once = true
						hit_building()
				else:
					nav_agent.set_target_position(target_unit.global_position)
					walk()
			else:
				current_task = Task.Idle
	
	
func animate(key):
	animation_player.play(animations[key])
	
func move_to(pos : Vector3):
	current_task = Task.Walking
	nav_agent.set_target_position(pos)
	
func harvest(resource):
	harvest_unit = resource
	move_to(harvest_unit.global_position)
	current_task = Task.GettingResources
	
func walk():
	var targetPos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	animate("walking")
	look_at(global_position + direction * Vector3(1, 0, 1))
	velocity = direction * speed
	move_and_slide()
	
func set_deliver():
	if(resources_holding == 0):
		return
	move_to(Home)
	current_task = Task.Delivering
	
func attack(enemy):
	if can_attack:
		target_unit = enemy
		var type = attack_type+'_attack'
		animate(type)
		move_to(enemy.global_position)
		current_task = Task.Attacking

func attack_unit():
	if target_unit != null :
		target_unit.hurt(attack_damage)
	else:
		target_unit = null

func hit_building():
	if target_unit != null :
		target_unit.hit(attack_damage)
	else:
		target_unit = null

func attack_building(building):
	if can_attack:
		var type = attack_type+'_atkbuild'
		animate(type)
		target_unit = building
		move_to(building.global_position)
		current_task = Task.AttackingBuilding

func hurt(damage):
	animate('hit')
	health -= damage
	health_bar.value = health

func deliver():
	if harvest_unit.is_in_group("rubyclump"):
		God.ruby += resources_holding
	elif harvest_unit.is_in_group("tree"):
		God.wood += resources_holding
	
	var random_food = randi_range(10, 15)
	God.food += random_food

func select():
	$SelectionCircle.show()
 
func deselect():
	$SelectionCircle.hide()
