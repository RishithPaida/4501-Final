extends CharacterBody3D

enum Task{
	Idle,
	Selected,
	GettingRessources,
	Walking
}

var currentTask = Task.Idle
var ressourcesHolding = 0
var Home

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
			if(God.Curr_Selected_Unit):
				if(God.Curr_Selected_Unit.name == self.name):
					currentTask = Task.Selected
			
		Task.Selected:
			if(God.Curr_Selected_Unit):
				if(God.Curr_Selected_Unit.name == self.name):
					currentTask = Task.Selected
			
			if(God.Curr_Selected_Position != Vector3.ZERO):
				navAgent.set_target_position(God.Curr_Selected_Position)
				currentTask = Task.Walking
				
		Task.GettingRessources:
			if(God.Curr_Selected_Unit):
				if(God.Curr_Selected_Unit.name == self.name):
					pass
					
		Task.Walking:
			if(navAgent.is_navigation_finished()):
				Task.Idle #If they are going to harvest the ressource then we can change it
				#print("Made it!")
			
			if(God.Curr_Selected_Unit):
				if(God.Curr_Selected_Unit.name == self.name):
					if(God.Curr_Selected_Position != navAgent.get_target_position()) and (God.Curr_Selected_Position != Vector3.ZERO):
						print("resetting target pos")
						navAgent.set_target_position(God.Curr_Selected_Position)
			
			var targetPos = navAgent.get_next_path_position()
			var direction = global_position.direction_to(targetPos)
			velocity = direction * speed
			
			#print(targetPos)
			move_and_slide()
