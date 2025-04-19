shader_type canvas_item;
render_mode blend_mix;

varying vec4 modulate;
uniform bool enabled;

void vertex() {
	modulate = COLOR;
}

void fragment(){
	vec4 finalColor = texture(TEXTURE,UV);
	float diff = finalColor.r - ((finalColor.g + finalColor.b) / 2.0);
	COLOR = mix(
		finalColor,
		vec4(((finalColor.g + finalColor.b) / 2.0) + (modulate.r * diff), finalColor.g + (modulate.g * diff), finalColor.b + (modulate.b * diff),COLOR.a),
		float(enabled)
	);

 }
