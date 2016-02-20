#version 410

uniform mat4 modelview_proj_matrix;
uniform mat4 modelview_matrix;
uniform mat3 normal_matrix;

uniform vec3 light_pos;
uniform vec3 cam_pos;

// Attributs.
in vec3     position;
in vec3     normale;

vec3 light;

out vec3 N;
out vec3 V;
out vec3 var_light_pos;


void main (void)
{
    light = light_pos;
    
    var_light_pos = normalize(light - position);
    V = normalize(-position);
    N = normal_matrix*normalize(normale);
    
    gl_Position	= modelview_proj_matrix*vec4(position, 1);
}
