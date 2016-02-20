#version 410


vec3 H;
vec4 ambiant;
vec4 diffuse;
vec4 specular;
vec4 Color;

float factorLN;
float factorNH;

out vec4    frag_color;

uniform sampler2D tex_diffuse;

uniform float diffuse_contrib;
uniform float ambiant_contrib;
uniform float spec_contrib;
uniform float mat_shininess;

vec4 mat_spec_color = vec4(0.48, 0.55, 0.69, 1.0);
vec4 mat_ambient_color = vec4(0.0, 0.1, 0.3, 1.0);
vec4 mat_diffuse_color = vec4(0.48, 0.55, 0.69, 1.0);

in vec3 var_light_pos;
in vec3 N;
in vec3 V;

in vec3 cam_eye;

void main (void)
{
    H = normalize(var_light_pos + V);
    ambiant = mat_ambient_color*ambiant_contrib;
    
    factorLN = max(dot(var_light_pos,N),0.0);
    diffuse = factorLN * (mat_diffuse_color*diffuse_contrib);
    
    factorNH = pow(max(dot(N,H),0.0),mat_shininess);
    specular = factorNH * (spec_contrib * mat_spec_color);
    
    if(dot(var_light_pos,N) < 0.0)
        specular = vec4(0.0, 0.0, 0.0, 1.0);
    
    Color = (ambiant + diffuse + specular);
    
    frag_color = Color;
}
