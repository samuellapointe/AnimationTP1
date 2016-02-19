#version 410



in vec3 N;
in vec4 C;

out vec4    frag_color;

void main (void)
{
    //frag_color = vec4(0.0, 0.5, 0.0, 1.0);//C;
    frag_color =  C;
}
