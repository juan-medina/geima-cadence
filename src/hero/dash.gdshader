shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 2.0;

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    vec2 ps = TEXTURE_PIXEL_SIZE;

    float outline_alpha = 0.0;
    // Look in all 4 directions to create a complete 1-pixel outline
    for (float x = -outline_width; x <= outline_width; x += 1.0) {
        for (float y = -outline_width; y <= outline_width; y += 1.0) {
            vec2 offset = vec2(x, y) * ps;
            if (texture(TEXTURE, UV + offset).a > 0.1) {
                outline_alpha = 1.0;
            }
        }
    }
    
    // The user wants alpha to decrease as we move left.
    // UV.x goes from 0.0 (left) to 1.0 (right).
    // Multiplying by UV.x means the alpha is solid (1.0) on the right edge (front of the dash),
    // and fades down to 0.0 on the left edge (trailing back).
    outline_alpha *= UV.x;

    vec4 outline = outline_color;
    outline.a = outline_alpha;

    COLOR = mix(outline, col, col.a);
}
