shader_type canvas_item;
// PEGA A IMAGEM DA TELA
uniform sampler2D screen_tex : hint_screen_texture;
// VARIAVEIS PARA A ONDA E ÁGUA
uniform float velocidade = 0.8;
uniform float forca_onda = 6.0;
uniform float compressao_reflexo = 0.5;
// CONTROLE DO FADE
uniform float fade_inicio = 0.08; 
uniform float fade_fim = 0.35;   
// DEFINE A COR DA ÁGUA
uniform vec4 cor_agua : source_color = vec4(0.05, 0.15, 0.8, 0.9);
void fragment() {
    
    // TEMPO
    float tempo = TIME * velocidade;
    // UV DE TELA
    vec2 suv = SCREEN_UV;
    // FADE POR PROFUNDIDADE
    float fade = 1.0 - smoothstep(fade_inicio, fade_fim, UV.y);
    // COMPRIME REFLEXO NO TOPO
    float escala_y = mix(compressao_reflexo, 1.0, UV.y);
    // INVERTE
    vec2 reflexo_uv = vec2(
        suv.x,
        1.0 - (suv.y * escala_y)
    );
    // ONDA SUAVE
    vec2 onda = vec2(
        sin((suv.y + tempo) * 20.0),
        cos((suv.x + tempo) * 25.0)
    );
    reflexo_uv += onda * SCREEN_PIXEL_SIZE * forca_onda;
    // AMOSTRA 
    vec4 reflexo = texture(screen_tex, reflexo_uv);
    reflexo.rgb *= vec3(0.6, 0.7, 0.85);
    reflexo.a *= fade;
    // ===== ÁGUA BASE =====
    vec4 agua = cor_agua;
    // MISTURA COM FADE 
    vec4 cor_final = mix(agua, reflexo, 0.45 * fade);
    // LINHA BRANCA NO TOPO 
    float linha = smoothstep(0.04, 0.0, UV.y);
    float onda_branca = sin(UV.x * 40.0 + tempo * 3.0) * 0.5 + 0.5;
    cor_final.rgb = mix(
        cor_final.rgb,
        vec3(1.0),
        linha * onda_branca * 0.25
    );
    COLOR = cor_final;
}