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

    CVect3D N = CPoint3D(-P[1],P[0],P[2]);
    
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
    list<CTriangle*>::const_iterator monIt;
    for(monIt = triangles.begin(); monIt != triangles.end(); ++monIt)
    {
        (*monIt)->UpdateNormal();
    }
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

// Variables OpenGL
GLuint diffuse_tex_id;          // Texture
GLuint ogl_buf_vextex_id;       // VBO
GLuint vao_id;
GLuint ogl_buf_index_id;
GLint attrib_position, attrib_normal, attrib_color;

/*int sz_vertice = 10;
GLfloat mesVertices[] =
{
    // Sommet 0
    -1.0, 0.0, 0.0,     // Pos
    -1.0, 1.0, 0.0,     // N
    1.0, 0.0, 0.0, 1.0, // Couleur
    
    // Sommet 1
    0.0, 1.0, 0.5,
    0.0, 1.0, 0.0,
    1.0, 1.0, 0.0, 1.0,
    
    // Sommet 2
    1.0, 0.0, 0.0,
    1.0, 1.0, 0.0,
    0.0, 1.0, 0.0, 1.0,
    
    // Sommet 3
    0.0, 1.0, -0.5,
    0.0, 1.0, 0.0,
    0.0, 0.0, 1.0, 1.0,
};

// Tableau d'indice.
GLint mesIndices[] = {
    0, 1, 3, // Triangle 1
    1, 2, 3  // Triangle 2
};*/

void    CMesh::AllocVBOData()
{
    /*vertices = std::vector<CVertex*>();
    vertices.push_back(new CVertex(0, CPoint3D(-1.0f, 0.0f, 0.2f), 0.0, 0.0));
    vertices.push_back(new CVertex(1, CPoint3D(0.1f, 1.0f, 0.5f), 0.0, 0.0));
    vertices.push_back(new CVertex(2, CPoint3D(1.0f, 0.0f, 0.0f), 0.0, 0.0));
    vertices.push_back(new CVertex(3, CPoint3D(0.0f, 1.0f, -0.5f), 0.0, 0.0));

    triangles = std::list<CTriangle*>();
    triangles.push_back(new CTriangle(vertices[0], vertices[1], vertices[3]));
    triangles.push_back(new CTriangle(vertices[1], vertices[2], vertices[3]));*/
    
    
    GLfloat* myVertices = new GLfloat[8*vertices.size()]();
    GLfloat* currentVertice = &myVertices[0];
    
    for (int i = 0; i < vertices.size(); i++) {
        currentVertice = put_vertex(*vertices[i], currentVertice);
    }
    
    GLuint* myTriangles = new GLuint[3*triangles.size()]();
    GLuint* currentTriangle = &myTriangles[0];
    
    list<CTriangle*>::const_iterator monIt;
    for(monIt = triangles.begin(); monIt != triangles.end(); ++monIt) {
        currentTriangle = put_triangle(*(*monIt), currentTriangle);
    }
    
    
    /*cout << "\n--- sommets ---\n";
    tmpVertices = std::vector<float>();
    for (int i = 0; i < vertices.size(); i++) {
        cout << vertices[i]->P[0] << ", " << vertices[i]->P[1] << ", " << vertices[i]->P[2] << "\n";
        tmpVertices.push_back(vertices[i]->P[0]);
        tmpVertices.push_back(vertices[i]->P[1]);
        tmpVertices.push_back(vertices[i]->P[2]);
    }
    
    cout << "--- indices ---\n";
    
    tmpTriangles = std::vector<float>();
    list<CTriangle*>::const_iterator monIt;
    for(monIt = triangles.begin(); monIt != triangles.end(); ++monIt)
    {
        cout << (*monIt)->v0->idx << ", " << (*monIt)->v1->idx << ", " << (*monIt)->v2->idx << "\n";
        tmpTriangles.push_back((*monIt)->v0->idx);
        tmpTriangles.push_back((*monIt)->v1->idx);
        tmpTriangles.push_back((*monIt)->v2->idx);
    }*/
    
    glGenVertexArrays(1, &vao_id); //Place 1 nom de tableau de sommets dans vao_id
    glBindVertexArray(vao_id); //Dire à openGL d'utiliser ce tableau de sommets
    
    glGenBuffers(1, &ogl_buf_vextex_id); //Créer un tampon pour les sommets?
    glGenBuffers(1, &ogl_buf_index_id); //Créer un tampon pour les indices?
    
    // Transfert des données vers la carte graphique.
    glBindBuffer(GL_ARRAY_BUFFER, ogl_buf_vextex_id); //Dire à openGL de travailler sur le tampon de sommets
    glBufferData(GL_ARRAY_BUFFER, 8*vertices.size(), myVertices, GL_STATIC_DRAW); //Placer des données dans le tampon
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ogl_buf_index_id); //Travailler sur le tampon d'indices
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 3*triangles.size(), myTriangles, GL_STATIC_DRAW); //Placer les données dans le tampon
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
static float scale = 1.0;
static float yoffset = 0.0;
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
    
    //UpdateNormals();
    
    AllocVBOData();
    return true;
}


void CMesh::Draw(GLint prog)
{
    
    attrib_position = glGetAttribLocation(prog, "P"); //Attribut de position dans le vertex shader
    attrib_normal = glGetAttribLocation(prog, "N0");
    attrib_texcoord = glGetAttribLocation(prog, "C0");
    
    glBindVertexArray(vao_id); //Travailler sur ce tableau
    
    glEnableVertexAttribArray(attrib_position); //Activer l'attribut de position
    glEnableVertexAttribArray(attrib_normal);
    glEnableVertexAttribArray(attrib_texcoord);
    
    glBindBuffer(GL_ARRAY_BUFFER, ogl_buf_vextex_id);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ogl_buf_index_id);
    
    int stride = 8*sizeof(GLfloat);
    glVertexAttribPointer(attrib_position, 3, GL_FLOAT, GL_FALSE, stride, 0);
    glVertexAttribPointer(attrib_normal, 3, GL_FLOAT, GL_FALSE,  stride, BUFFER_OFFSET(12));
    glVertexAttribPointer(attrib_texcoord, 2, GL_FLOAT, GL_FALSE,  stride, BUFFER_OFFSET(24));
    
    cout << triangles.size();
    
    glDrawElements(GL_TRIANGLES, 3*triangles.size(), GL_UNSIGNED_INT, BUFFER_OFFSET(0));
}
















