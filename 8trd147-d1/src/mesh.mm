/*
 *  mesh.cpp
 *  morph
 *
 *  Created by ychirico on 10-03-11.
 *  Copyright 2010 YC. All rights reserved.
 *
 */

#include "mesh.h"
#include "glutil.h"

#include <iostream>
#include <fstream>
#include <OpenGL/gl3.h>
#include <cstdlib>
#include <cmath>

using namespace std;

#define BUFFER_OFFSET(i) ((char *)NULL + (i))


// Facteur de grossissemement du mesh lors de la lecture de fichiers ply.
double mesh_plyimport_scale = 1.0;

#pragma mark -

void print_debug(const CPoint3D& P)
{
    const float& x(P[0]);
    const float& y(P[1]);
    const float& z(P[2]);
    
    cout << '(' << x << ',' << y << ',' << z << ')' << endl;
    
}



CVect3D CVertex::UpdateNormal()
{ 

    //**
    // À faire : mise à jour du vecteur normal à partir  des triangles.
    
    return N;
}

ostream& operator<<(ostream& os, const CVertex& v)
{     
    os << '(' << v[0] << ',' << v[1]  << ',' << v[2]  << ") (";
    os << '(' << v.N[0] << ',' << v.N[1]  << ',' << v.N[2]  << ')';

    //os << v.u << ' ' << v.v;
    return os;
}

ostream& operator<<(ostream& os, const CTriangle& tri)
{ 
    os << tri.v0->idx << ' ' <<tri.v1->idx  << ' ' <<tri.v2->idx  << ' ';
    return os;
}


#pragma mark -
#pragma mark CMesh

CMesh::CMesh() : 
    diffuse_tex_id(0),
    ogl_buf_vextex_id(0),
    ogl_buf_index_id(0)
{
}


CMesh::~CMesh()
{    
    int iv;
    for ( iv = 0; iv < vertices.size(); iv++ )
    { 
        if ( vertices[iv] ) 
            delete vertices[iv] ; 
    }

    list<CTriangle*>::iterator it;
    for ( it = triangles.begin(); it != triangles.end(); it++ )
    { 
        if ( *it ) delete *it; 
    }
    
    if ( ogl_buf_index_id != 0 )
        glDeleteBuffers(1, &ogl_buf_index_id);
    
    if ( ogl_buf_vextex_id != 0 )
        glDeleteBuffers(1, &ogl_buf_vextex_id);
    
    if ( vao_id != 0 )
        glDeleteVertexArrays(1, &vao_id);
}

ostream& operator<<(ostream& os, const CMesh& m)
{ 
    os << m.vertices.size() << ' ' << m.triangles.size() << endl;
    int iv;
    for ( iv = 0; iv < m.vertices.size(); iv++ )
        os << *m.vertices[iv] << endl;
    
    list<CTriangle*>::const_iterator it;
    for ( it = m.triangles.begin(); it != m.triangles.end(); it++ )
        os << **it << endl;

    
    return os;
}



void    CMesh::UpdateNormals()
{ 
    //**
}

// Format du VBO: 
// GLfloat x,y,z;           // Position
// GLfloat nx, ny, nz;      // Normal
// GLfloat u,v;             // Coordonnées de texture.
static
GLfloat* put_vertex(const CVertex& v, GLfloat* p)
{
    *p++ = v[0];
    *p++ = v[1];
    *p++ = v[2];
    
    *p++ = v.N[0];
    *p++ = v.N[1];
    *p++ = v.N[2];
    
    *p++ = v.u;
    *p++ = v.v;
    return p;
}

static
GLuint* put_triangle(const CTriangle& tri, GLuint* p)
{
    *p++ = tri.v0->idx;
    *p++ = tri.v1->idx;
    *p++ = tri.v2->idx;

    return p;
}

void    CMesh::AllocVBOData()
{
    glGenVertexArrays(1, &vao_id);
    glBindVertexArray(vao_id);
    
    // Conversion en VBO.
    
    glGenBuffers(1, &ogl_buf_vextex_id);
    glGenBuffers(1, &ogl_buf_index_id);
    
    // Transfert des données vers la carte graphique.
    glBindBuffer(GL_ARRAY_BUFFER, ogl_buf_vextex_id);
    glBufferData(GL_ARRAY_BUFFER, vertices.size(), &vertices, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ogl_buf_index_id);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, triangles.size(), &triangles, GL_STATIC_DRAW);
}


#pragma mark -
#pragma mark PLY

// Parser élémentaire.

// Les mots doivent être séparés par un unique espace.
int split(const string& line, vector<string>& words)
{
    string buf(line);
    words = vector<string>(10); // On lit 10 mots au plus.

    int pos, i=0;
    while ( ((pos = buf.find(' ')) != -1 ) && (i < words.size()-1) )
    {
        //cout << buf.substr(0, pos) << ' ';
        words[i++] = (buf.substr(0, pos ));
        buf = buf.substr(pos+1, buf.size());
    }
    if ( pos == -1 )
        words[i] = (buf);
    return i;
}


// Lecture de l'entête. Le fichier sera placé sur le premier sommet à lire après l'appel de cette fonction.
static 
bool ReadPLYHeader(std::ifstream& f_in, int& nb_vtx, int& nb_tri)
{
    int bufsz = 256;
    char  buf[bufsz];
    string line;
    string endHeader = "end_header";
    vector<string> words;
    nb_tri = nb_vtx = 0;
    
    f_in.getline(buf, bufsz, '\n');
    line = buf;

    while ( (line.compare(0, endHeader.length(), endHeader) != 0) && !f_in.eof() )
    {
        split(line, words);
        if ( words[0] == "element"  && words[1] == "vertex" )
            nb_vtx = atoi(words[2].c_str());

        if ( words[0] == "element"  && words[1] == "face" )
            nb_tri = atoi(words[2].c_str());
        
        f_in.getline(buf, bufsz, '\n');
        line = buf;
    }
    return nb_tri != 0 && nb_vtx != 0;
}


//** Vous aurez éventuellement à changer ces valeurs pour que votre maillage s'affiche correctement.
static float scale = 40.0;
static float yoffset = -3.0;
bool CMesh::ReadPLY(std::ifstream& f_in)
{
    int bufsz = 256;
    char  buf[bufsz];
    string line;
    vector<string> words;
    int nb_tri, nb_vtx;

    if ( !ReadPLYHeader(f_in, nb_vtx, nb_tri) )
        return false;
    
    vertices = std::vector<CVertex*>(nb_vtx);
    
    int i = 0;
    float x,y,z;
    float xmin = HUGE_VAL, xmax = -HUGE_VAL, ymin = HUGE_VAL, ymax=-HUGE_VAL;
    while ( !f_in.eof() && i<nb_vtx )
    {
        f_in.getline(buf, bufsz, '\n');
        line = buf;
        
        words.clear();
        split(line, words);
        
        x = scale*atof(words[0].c_str());
        y = scale*atof(words[1].c_str()) + yoffset;
        z = scale*atof(words[2].c_str());
        
        x *= mesh_plyimport_scale;
        y *= mesh_plyimport_scale;
        z *= mesh_plyimport_scale;
        
        if ( xmin > x ) xmin = x;
        if ( ymin > y ) ymin = y;
        if ( xmax < x ) xmax = x;
        if ( ymax < y ) ymax = y;
        
        vertices[i] = new CVertex(i, CPoint3D(x, y, z), 0.0, 0.0);
        i++;
    }
    
    // Coordonnées uv de base.
    for ( i=0; i<nb_vtx; i++ )
    {
        const float& x((*vertices[i])[0]);
        (*vertices[i]).u = (x-xmin)/(xmax - xmin);
        const float& y((*vertices[i])[1]);
        (*vertices[i]).v = (y-ymin)/(ymax - ymin);
    }
    
    i = 0;
    int v0, v1, v2;
    while ( !f_in.eof() && i++ < nb_tri )
    {
        f_in.getline(buf, bufsz, '\n');
        line = buf;
        
        words.clear();
        split(line, words);
        
        v0 = atoi(words[1].c_str());
        v1 = atoi(words[2].c_str());
        v2 = atoi(words[3].c_str());
        CTriangle* tri(new CTriangle(vertices[v0], vertices[v1], vertices[v2]));
        
        triangles.push_back(tri);
    }
    
    UpdateNormals();
    
    AllocVBOData();
    return true;
}


void CMesh::Draw(GLint prog)
{
    
    attrib_position = glGetAttribLocation(prog, "P");
    attrib_normal = glGetAttribLocation(prog, "N0");
    attrib_color = glGetAttribLocation(prog, "C0");
    
    glBindVertexArray(vao_id);
    
    glEnableVertexAttribArray(attrib_position);
    glEnableVertexAttribArray(attrib_normal);
    glEnableVertexAttribArray(attrib_color);
    
    glBindBuffer(GL_ARRAY_BUFFER, ogl_buf_vextex_id);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ogl_buf_index_id);
    
    int stride = 8*sizeof(GLfloat);
    glVertexAttribPointer(attrib_position, 3, GL_FLOAT, GL_FALSE, stride, BUFFER_OFFSET(0));
    glVertexAttribPointer(attrib_normal, 3, GL_FLOAT, GL_FALSE,  stride, BUFFER_OFFSET(12));
    glVertexAttribPointer(attrib_color, 4, GL_FLOAT, GL_FALSE,  stride, BUFFER_OFFSET(24));
    
    glDrawElements(GL_TRIANGLES, triangles.size(), GL_UNSIGNED_INT, BUFFER_OFFSET(0));
}
















