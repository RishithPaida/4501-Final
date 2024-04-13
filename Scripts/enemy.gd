extends CharacterBody3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var health_bar = $SubViewport/HealthBar
@onready var animation_player = $AnimationPlayer

enum Task{
	Idle,
	Attacking,
	AttackingBuilding
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
var target_unit
var target_building = null

var run_once = true
@export var speed = 2
@export var health : int = 100
@export var attack_speed: float = 1.0
@export var range: float = 2.0
@export var attack_damage: float = 20
@export var attack_mode_range: int = 6
@export_enum("melee", "ranged") var attack_type: String

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
		God.mana += 5
		animate('death')
		await get_tree().create_timer(0.5).timeout
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
					nav_agent.set_target_position(target_unit.global_position)
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
					nav_agent.set_target_position(target_building.global_position)
					walk()
			else:
				current_task = Task.Idle

func animate(key):
	animation_player.play(animations[key])

func hurt(damage):
	animate('hit')
	health -= damage
	health_bar.value = health

func attack():
	if target_unit != null :
		target_unit.hurt(attack_damage)
		var type = attack_type+'_attack'
		animate(type)
	else:
		target_unit = null

func attack_building():
	if(target_building != null):
		var type = attack_type+'_atkbuild'
		animate(type)
		target_building.hit(attack_damage)

func walk():
	animate("walking")
	var targetPos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	look_at(global_position + direction * Vector3(1, 0, 1))
	velocity = direction * speed
	
	move_and_slide()

func check_for_enemy():
	var enemy_list = get_tree().get_nodes_in_group("allyunit")
	var enemy_found = false
	for enemy in enemy_list:
		if global_position.distance_to(enemy.global_position) < attack_mode_range:
			target_unit = enemy
			enemy_found = true
			current_task = Task.Attacking
			break
	if(enemy_found == false):
		check_for_building()

func check_for_building():
	var building_list = get_tree().get_nodes_in_group("allybuilding")
	var building_found = false
	for building in building_list:
		if global_position.distance_to(building.global_position) < attack_mode_range * 5 and building.is_built:
			target_building = building
			building_found = true
			current_task = Task.AttackingBuilding
			break

func set_target_building(building):
	target_building = building
	current_task = Task.AttackingBuilding
