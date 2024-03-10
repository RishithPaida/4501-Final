shader_type spatial;

uniform float alpha_oscillation_speed = 1.0;
uniform float alpha_scale = 0.5;
uniform vec4 force_field_color = vec4(0.0, 1.0, 0.0, 1.0); // Color of the force field

varying vec3 pos;

void vertex(){
	pos = VERTEX.xyz;
}

void fragment() {
	// Obtain fragment position in world coordinates
	vec3 worldPos = (MODEL_MATRIX * vec4(pos, 1.0)).xyz;
	
	float angle = dot(NORMAL, VIEW);
	
	float oscillation = sin(TIME * alpha_oscillation_speed) / 4.0;
	float alpha = pow(1.0 - angle, alpha_scale);
	
	ALBEDO = force_field_color.rgb;
	ALPHA = alpha + oscillation;
}