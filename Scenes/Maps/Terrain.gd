extends MeshInstance3D

@onready var colShape = $StaticBody3D/CollisionShape3D
@export var chunkSize = 2.0
@export var heightRatio = 1.0
@export var colShapeSizeRatio = 0.1

var img = Image.new()
var shape = HeightMapShape3D.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	colShape.shape = shape
	mesh.size = Vector2(chunkSize, chunkSize)
	updateTerrain(heightRatio, colShapeSizeRatio)
	get_tree().get_nodes_in_group("NavMesh")[0].bake_navigation_mesh(true)

func updateTerrain(_heightRatio, _colShapeSizeRatio):
	material_override.set("shader_param/heightRatio", _heightRatio)
	img.load("res://Assets/heightmap.exr")
	img.convert(Image.FORMAT_RF)
	img.resize(img.get_width()*_colShapeSizeRatio, img.get_height()*_colShapeSizeRatio)
	
	var data = img.get_data().to_float32_array()
	for i in range(0, data.size()):
		data[i] *= _heightRatio
	
	shape.map_width = img.get_width()
	shape.map_depth = img.get_height()
	shape.map_data = data
	
	var scaleRatio = chunkSize/float(img.get_width())
	colShape.scale = Vector3(scaleRatio, 1, scaleRatio)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
