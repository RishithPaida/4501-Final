shader_type spatial;
render_mode depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
render_mode blend_mix;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform int pixel_size = 2;

void fragment() {
    float x = float(int(FRAGCOORD.x) % pixel_size);
    float y = float(int(FRAGCOORD.y) % pixel_size);

    x = FRAGCOORD.x + floor(float(pixel_size) / 2.0) - x;
    y = FRAGCOORD.y + floor(float(pixel_size) / 2.0) - y;

    ALBEDO = texture(SCREEN_TEXTURE, vec2(x, y) / VIEWPORT_SIZE).xyz;
}
