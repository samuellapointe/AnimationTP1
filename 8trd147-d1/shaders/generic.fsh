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

vec4 mat_spec_color = vec4(0.48, 0.55, 0.69, 1.0);
vec4 mat_ambient_color = vec4(0.0, 0.1, 0.3, 1.0);
vec4 mat_diffuse_color = vec4(0.48, 0.55, 0.69, 1.0);

in vec3 var_light_pos;
in vec3 N;
in vec3 V;

in vec3 cam_eye;

void main (void)
{
    H = (var_light_pos + V)/2;
    ambiant = mat_ambient_color*ambiant_contrib;
    
    factorLN = max(0, dot(var_light_pos,N));
    diffuse = factorLN * (mat_diffuse_color*diffuse_contrib);
    
    specular = (mat_spec_color*spec_contrib)*pow(dot(H,V), mat_shininess);
    
    //if(dot(var_light_pos,N) < 0.0)
     //   specular = vec4(1.0, 0.0, 0.0, 1.0);
    
    Color = vec4(ambiant + diffuse + specular, 1);
    
    frag_color = Color;
}
