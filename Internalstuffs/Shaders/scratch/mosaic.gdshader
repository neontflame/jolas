shader_type canvas_item;

uniform float amount = 0.0;

void vertex() {
	if (amount != 0.0) {
		float newAmount = trunc(((abs(amount) + 5.0) / 10.0) + 1.0);
		UV = UV * vec2(newAmount);
	}
}
