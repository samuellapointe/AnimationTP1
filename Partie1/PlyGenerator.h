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

class PlyGenerator
{
private:
    string fileName;
    int surfaceType = 0;
    float delta = 0;
    float y = 0;
    vector<CPoint3D> vertices;
    //vector<int, int, int> faces;
    
    typedef float (*fctgen_ptr)(const float& y);
    CPoint3D surfrevol(const float&, const float&, fctgen_ptr);
    
    void generateVertices();
    
    string getVerticesToString();
    
public:
    PlyGenerator(vector<string>);
    
    string generateFile();
};

#endif /* PlyGenerator_h */
