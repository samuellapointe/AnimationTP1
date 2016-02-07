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
    int delta = 0;
    int y = 0;
    vector<CPoint3D> vertices;
    
    void generateVertices();
    
public:
    PlyGenerator(vector<string>);
    
    string generateFile();
};

#endif /* PlyGenerator_h */
