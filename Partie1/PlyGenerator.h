//
//  PlyGenerator.h
//  Partie1
//
//  Created by Etudiant on 2016-02-02.
//  Copyright © 2016 Etudiant. All rights reserved.
//

#ifndef PlyGenerator_h
#define PlyGenerator_h

#include "point3d.h"
#include <vector>
#include <string>

using namespace std;

struct Triangle
{
    int sommet1 = 0;
    int sommet2 = 0;
    int sommet3 = 0;
};

class PlyGenerator
{
private:
    string fileName;
    int surfaceType = 0;
    float delta = 0;
    float y = 0;
    vector<CPoint3D> vertices;
    vector<Triangle> triangles;
    
    typedef float (*fctgen_ptr)(const float& y);
    CPoint3D surfrevol(const float&, const float&, fctgen_ptr);
    
    void generateVertices();
    
    string getVerticesToString();
    string getFacesToString();
    
public:
    PlyGenerator(vector<string>);
    
    string generateFile();
};

#endif /* PlyGenerator_h */
