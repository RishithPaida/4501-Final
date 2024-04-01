extends CharacterBody3D


@onready var nav_agent:NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	nav_agent.velocity_computed.connect(move)
	
	
func _input(event:InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		print(God._get_curr_mouse_position_2D())
		nav_agent.set_target_position(God._get_curr_mouse_position_2D())

func move(new_velocity:Vector3) -> void:
	velocity = new_velocity
	move_and_slide()

func _physics_process(delta):
	if nav_agent.is_navigation_finished():return
	
	var next_position:Vector3 = nav_agent.get_next_path_position()
	var direction:Vector3 = global_position.direction_to(next_position) * nav_agent.max_speed
	var new_agent_velocity:Vector3 = velocity + (direction - velocity)
	nav_agent.set_velocity(new_agent_velocity)

func select():
	$SelectionCircle.show()
 
func deselect():
	$SelectionCircle.hide()
