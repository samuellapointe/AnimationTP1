#version 410


vec3 H;
vec3 ambiant;
vec3 diffuse;
vec3 specular;
vec4 Color;

float factorLN;
vec3 factorNH;

out vec4    frag_color;

uniform sampler2D tex_diffuse;

uniform float diffuse_contrib;
uniform float ambiant_contrib;
uniform float spec_contrib;
uniform float mat_shininess;

vec3 mat_spec_color = vec3(0.48, 0.55, 0.69);
vec3 mat_ambient_color = vec3(0.0, 0.1, 0.3);
vec3 mat_diffuse_color = vec3(0.9, 0.55, 0.69);

in vec3 var_light_pos;
in vec3 N;
in vec3 V;

in vec3 cam_eye;

void main (void)
{
    H = (var_light_pos + V)/2;
    ambiant = mat_ambient_color*ambiant_contrib;
    
    factorLN = max(dot(var_light_pos, N), 0);
    diffuse = clamp(factorLN * (mat_diffuse_color*diffuse_contrib), 0, 1);
    
    specular = (mat_spec_color*spec_contrib)*pow(dot(H,V), mat_shininess);
    
    if(dot(var_light_pos,N) < 0.0)
        specular = vec3(0.0, 0.0, 0.0);
    
    Color = vec4(ambiant + diffuse + specular, 1);
    
    frag_color = Color;
}
