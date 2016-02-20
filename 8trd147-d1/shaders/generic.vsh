#version 410

uniform mat4 modelview_proj_matrix;
uniform mat4 modelview_matrix;
uniform mat3 normal_matrix;

uniform vec3 light_pos;
uniform vec3 cam_pos;

// Attributs.
in vec3     position;
in vec3     normale;

out vec3 N;
out vec3 V;
out vec3 var_light_pos;

void main (void)
{
    var_light_pos = normalize(light_pos - position);
    V = normalize(cam_pos-position);
    N = normalize(normal_matrix*normale);
    
    gl_Position	= modelview_proj_matrix*vec4(position, 1);
}
