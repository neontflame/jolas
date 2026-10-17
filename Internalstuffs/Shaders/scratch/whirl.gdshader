shader_type canvas_item;

uniform float amount = 0.0;

void fragment() {
	float newAmount = -amount/50.0;
	
	vec2 texcoord0 = UV;
	vec2 kCenter = vec2(0.5);
	
	const float kRadius = 0.5;
	vec2 offset = texcoord0 - kCenter;
	float offsetMagnitude = length(offset);
	float whirlFactor = max(1.0 - (offsetMagnitude / kRadius), 0.0);
	float whirlActual = newAmount * whirlFactor * whirlFactor;
	float sinWhirl = sin(whirlActual);
	float cosWhirl = cos(whirlActual);
	mat2 rotationMatrix = mat2(
		vec2(cosWhirl, -sinWhirl),
		vec2(sinWhirl, cosWhirl)
	);

	texcoord0 = rotationMatrix * offset + kCenter;
	
	COLOR = texture(TEXTURE, texcoord0);
}
