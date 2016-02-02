#version 410


//**
// Il manque des variables...   ;-)

out vec4    frag_color;

uniform sampler2D tex_diffuse;

uniform float diffuse_contrib;
uniform float ambiant_contrib;
uniform float spec_contrib;
uniform float mat_shininess;

vec4 mat_spec_color = vec4(0.9, 0.9, 0.9, 1.0);
vec4 mat_ambient_color = vec4(0.2, 0.2, 0.2, 1.0);

in vec3 var_light_pos;
in vec3 N;
in vec3 V;

in vec3 cam_eye;

void main (void)
{
    //**
    // Implémenter phong.
     
    frag_color = vec4(0.5, 0.5, 0.5, 1.0);
}
