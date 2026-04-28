shader_type canvas_item;

uniform float velocidade = 0.8;
uniform float forca_onda = 0.05;

void fragment() {
    float tempo = TIME * velocidade;
    vec2 suv = UV;

    vec2 onda = vec2(
        sin((suv.y + tempo) * 20.0),
        0
    );

    vec2 uv_deslocado = suv + onda * forca_onda;

    COLOR = texture(TEXTURE, uv_deslocado);
}