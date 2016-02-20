/*
 *  mesh.h
 *  morph
 *
 *  Created by ychirico on 10-03-11.
 *  Copyright 2010 YC. All rights reserved.
 *
 */
#pragma once

#include "point3d.h"

#include <list>
#include <vector>

class CSurface;
class CTriangle;


extern double mesh_import_scale;
//--------------------------------------------------------------------------------
// class: CVertex
//
// Date : 11/03/2010 ychirico
// MAJ  : 
//--------------------------------------------------------------------------------
class CVertex : public CPoint3D {
public:
    CVertex(int _idx, const CPoint3D& P, const float& _u, const float& _v) :
        CPoint3D(P),
        u(_u),
        v(_v),
        idx(_idx)
    {}
    
    std::list<CTriangle*>   triangles;  // Triangles adjacents.
    
    CVect3D UpdateNormal();
    
    friend std::ostream& operator<<(std::ostream&, const CVertex&);
    
//protected:
    
    int     idx;                        // Indice dans le mesh.
    CVect3D N;
    float u,v;                          // Coordonnées de texture.

};


//--------------------------------------------------------------------------------
// class: CTriangle
//
// Date : 11/03/2010 ychirico
// MAJ  : 02/11/2011 ychirico Vecteur inversé pour être conforme aux fichiers ply.
//--------------------------------------------------------------------------------
class CTriangle {
public:   
    CTriangle(CVertex* _v0, CVertex* _v1, CVertex* _v2) : v0(_v0), v1(_v1), v2(_v2) 
    { 
        _v0->triangles.push_back(this); 
        _v1->triangles.push_back(this); 
        _v2->triangles.push_back(this); 
    }
    
    CVect3D Normal() const { return N; }
        
    friend std::ostream& operator<<(std::ostream&, const CTriangle&);
    
    void UpdateNormal()
    {
        CVect3D vecteur1 = CPoint3D(*v0-*v1);
        CVect3D vecteur2 = *v0-*v2;
 
        N = Normalise(ProdVect(vecteur1,vecteur2));
    }

//protected:
    
    const CVertex *v0, *v1, *v2;
    CVect3D N;

};


//--------------------------------------------------------------------------------
// class: CMesh
// 
// Date : 11/03/2010 ychirico
// MAJ  : 
//--------------------------------------------------------------------------------
class CMesh {
public:
    CMesh();
    virtual ~CMesh();
    
    bool    ReadPLY(std::ifstream&);    
    void    AllocVBOData();
    void    Draw(GLint prog);
    
    void    set_diffuse_tex_id(GLint id) { diffuse_tex_id = id; }
    GLint   get_diffuse_tex_id() const { return diffuse_tex_id; }
    
    void    delete_diffuse_tex() { glDeleteTextures(1, &diffuse_tex_id); }
    
    friend std::ostream& operator<<(std::ostream&, const CMesh&);
    
protected:
    
    // OpenGL
    GLuint diffuse_tex_id;          // Texture
    GLuint ogl_buf_vextex_id;       // VBO
    GLuint vao_id;
    GLuint ogl_buf_index_id;    
    GLint attrib_position, attrib_normal, attrib_texcoord, attrib_color;
        
    std::vector<CVertex*>    vertices;
    std::list<CTriangle*>    triangles;
    
    std::vector<float>    tmpVertices;
    std::vector<float>    tmpTriangles;

    void    UpdateNormals();
};











