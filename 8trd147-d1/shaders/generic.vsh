#version 410

uniform mat4 modelview_proj_matrix;
uniform mat3 normal_matrix;


// Attributs.
in vec3     P;  // Position
in vec4     C0; // Couleur
in vec3     N0; // Vecteur normal.


out vec3 N;
out vec4 C;


void main (void)
{
    N = normal_matrix*N0;
    C = C0;
    gl_Position	= modelview_proj_matrix*vec4(P, 1.0);
}