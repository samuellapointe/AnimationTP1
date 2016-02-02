#version 410

uniform mat4 modelview_proj_matrix;
uniform mat4 modelview_matrix;
uniform mat3 normal_matrix;

uniform vec3 light_pos;
uniform vec3 cam_pos;

// Attributs.
in vec4     pos;
in vec3     N0;

//**
// Il manque une variable

out vec3 N;
out vec3 V;
out vec3 var_light_pos;


void main (void)
{
    //**
    // Transformez les attributs.
    
	gl_Position	= modelview_proj_matrix*pos;
}


