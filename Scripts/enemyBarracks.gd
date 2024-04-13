extends StaticBody3D

var Waves = [
	[1,2],
	[2,2],
	[2,4],
	[3,5],
	[5,7],
	[5,9],
	[6,10],
]

var curr_wave = []
@export var health : int = 100
@onready var spawn_timer = $WaveTimer
@onready var health_bar = $SubViewport/HealthBar
@onready var orc_training_time= 2.0
@onready var wizard_training_time = 3.0

var started_spawning = false

var Orc : PackedScene = ResourceLoader.load("res://Scenes/Units/EnemyUnits/Orc.tscn")
var Wizard : PackedScene = ResourceLoader.load("res://Scenes/Units/EnemyUnits/CrazyWizard.tscn")
#Called when the node enters the scene tree for the first time.
func _ready():
	health_bar.max_value = health
	health_bar.value = health


#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(started_spawning == false):
		var townhall = get_tree().get_first_node_in_group("townhall")
		
		if(townhall != null):
			started_spawning = true
			await get_tree().create_timer(120.0).timeout
			spawn_timer.start()

func Spawn(unit : PackedScene):
	var spawned = unit.instantiate()
	get_tree().root.add_child(spawned)
	spawned.global_position = self.get_node("SpawnPoint").global_position
	curr_wave.append(spawned)

func SpawnWave(num):
	var wave = []
	for i in Waves[num][0]:
		await get_tree().create_timer(orc_training_time).timeout
		Spawn(Orc)

	for j in Waves[num][1]:
		await get_tree().create_timer(wizard_training_time).timeout
		Spawn(Wizard)

	EnemyGod.Curr_wave_index +=1
	spawn_timer.start()
	#send the wave to attack!!
	var townhall = get_tree().get_first_node_in_group("townhall")
	
	if(townhall != null):
		for unit in curr_wave:
			unit.set_target_building(townhall)
	
	curr_wave = []

func hit(damage):
	health -= damage
	health_bar.value = health
	
	if(health <= 0):
		queue_free()

func _on_timer_timeout():
	SpawnWave(min(EnemyGod.Curr_wave_index, Waves.size() - 1 ))
