#version 330
layout (points) in;
layout (triangle_strip, max_vertices = 4) out;

uniform Projection {
    uniform mat4 matrix;
} proj;

uniform mat3 TextureTransform;

in float v_angle[1];
in vec4 v_color[1];
in vec2 v_size[1];
in vec4 v_sub_tex_coords[1];
in int vertex_id[1];

out vec2 gs_uv;
out vec4 gs_color;

#define VP_CLIP 1.0

void main() {
    // Sprite index 4294967294 means the sprite is deleted or disabled
    if (vertex_id[0] == 4294967294) return;

    // Get center of the sprite
    vec2 center = gl_in[0].gl_Position.xy;
    vec2 hsize = v_size[0] / 2.0;
    float angle = radians(v_angle[0]);
    mat2 rot = mat2(
        cos(angle), sin(angle),
        -sin(angle), cos(angle)
    );
    // Do viewport culling for sprites.
    // We do this in normalized device coordinates to make it simple
    // apply projection to the center point. This is important so we get zooming/scrollig right
    vec2 ct = (proj.matrix * vec4(center, 0.0, 1.0)).xy;
    // We can get away with cheaper calculation of size
    // The length of the diagonal is the cheapest estimation in case roations are applied
    float st = length(hsize * vec2(proj.matrix[0][0], proj.matrix[1][1]));
    // Discard sprites outside the viewport
    if ((ct.x + st) < -VP_CLIP || (ct.x - st) > VP_CLIP) return;
    if ((ct.y + st) < -VP_CLIP || (ct.y - st) > VP_CLIP) return;

    // Emit a quad with the right position, rotation and texture coordinates
    vec2 tex_offset = v_sub_tex_coords[0].xy;
    vec2 tex_size = v_sub_tex_coords[0].zw;

    // Upper left
    gl_Position = proj.matrix * vec4(rot * vec2(-hsize.x, hsize.y) + center, 0.0, 1.0);
    vec3 tex1 = TextureTransform * vec3((vec2(0.0, 1.0) * tex_size + tex_offset) * vec2(1, -1), 1.0);
    gs_uv = tex1.xy / tex1.z;
    gs_color = v_color[0];
    EmitVertex();

    // lower left
    gl_Position = proj.matrix * vec4(rot * vec2(-hsize.x, -hsize.y) + center, 0.0, 1.0);
    vec3 tex2 = TextureTransform * vec3((vec2(0.0, 0.0) * tex_size + tex_offset) * vec2(1, -1), 1.0);
    gs_uv = tex2.xy / tex2.z;
    gs_color = v_color[0];
    EmitVertex();

    // upper right
    gl_Position = proj.matrix * vec4(rot * vec2(hsize.x, hsize.y) + center, 0.0, 1.0);
    vec3 tex3 = TextureTransform * vec3((vec2(1.0, 1.0) * tex_size + tex_offset) * vec2(1, -1), 1.0);
    gs_uv = tex3.xy / tex3.z;
    gs_color = v_color[0];
    EmitVertex();

    // lower right
    gl_Position = proj.matrix * vec4(rot * vec2(hsize.x, -hsize.y) + center, 0.0, 1.0);
    vec3 tex4 = TextureTransform * vec3((vec2(1.0, 0.0) * tex_size + tex_offset) * vec2(1, -1), 1.0);
    gs_uv = tex4.xy / tex4.z;
    gs_color = v_color[0];
    EmitVertex();

    EndPrimitive();
}
