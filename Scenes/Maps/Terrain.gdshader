shader_type spatial;

uniform sampler2D _a;
uniform sampler2D heightmap;
uniform float heightRatio = 1.0;

void vertex() {
	VERTEX.y += texture(heightmap, UV).r * heightRatio;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = texture(_a, UV).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
