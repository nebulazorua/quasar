shader_type canvas_item;
render_mode blend_add;
uniform sampler2D screen_tex: hint_screen_texture;

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
	vec3 hsv = rgb2hsv(texture(TEXTURE, UV).rgb);
	vec3 target_hsv = rgb2hsv(modulate.rgb);
	hsv.x = target_hsv.x;
	hsv.y *= target_hsv.y;
	hsv.z *= target_hsv.z;

	vec3 FINAL_COLOR = hsv2rgb(hsv);

	COLOR.rgb = FINAL_COLOR;
}
