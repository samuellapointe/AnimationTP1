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

void main (void)
{
    H = (var_light_pos + V)/2;
    vec3 R = normalize(-reflect(var_light_pos, N));
    vec3 E = normalize(-V);
    
    ambiant = mat_ambient_color*ambiant_contrib;
    
    diffuse = clamp((mat_diffuse_color*diffuse_contrib) * max(dot(N, var_light_pos), 0.0), 0, 1);
    
    specular = clamp((mat_spec_color*spec_contrib)*pow(max(dot(R, E),0.0), mat_shininess), 0.0, 1.0);
    
    Color = vec4(ambiant + diffuse + specular, 1);
    
    frag_color = Color;
}
