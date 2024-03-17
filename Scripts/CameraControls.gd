extends Node3D

# Sensitivity factors for mouse movement.
var sensitivity = 30
var zoom_sensitivity = 2.0
var RAY_LENGTH = 1000
# Threshold distance from the edge of the screen to start moving the camera.
var edge_threshold = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Initial setup can be added here.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var viewport_size = get_viewport().size
	var center_position = viewport_size / 2
	var mouse_position = get_viewport().get_mouse_position()
	
	# Calculate the direction vector for the mouse movement relative to the center of the screen.
	var direction = Vector2(mouse_position.x - center_position.x, mouse_position.y - center_position.y)
	
	# Normalize the direction if you want consistent speed regardless of distance from center.
	if direction.length() > 0:
		direction = direction.normalized()
	
	# Apply the calculated direction to the camera's position, with sensitivity adjustments.
	if mouse_position.x < edge_threshold or mouse_position.x > viewport_size.x - edge_threshold or mouse_position.y < edge_threshold or mouse_position.y > viewport_size.y - edge_threshold:
		position.x += direction.x * sensitivity * delta
		position.z += direction.y * sensitivity * delta # In Godot 3D, Z is often used for forward/backward movement.
	
	#zoom controls
	if Input.is_action_just_pressed("scroll_up"):
		if $Camera.global_position.distance_to(global_position) > 0.5:
			$Camera.global_position -= $Camera.global_transform.basis.z * zoom_sensitivity
	if Input.is_action_just_pressed("scroll_down"):
		if $Camera.global_position.distance_to(global_position) < 100:
			$Camera.global_position += $Camera.global_transform.basis.z * zoom_sensitivity
