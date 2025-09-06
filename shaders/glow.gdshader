shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.9, 0.3, 1.0);
uniform float intensity = 1.0; // needs to be >1.0 to trigger glow

void fragment() {
    COLOR = glow_color * intensity;
}
