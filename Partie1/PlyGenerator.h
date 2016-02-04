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

using namespace std;

class PlyGenerator
{
private:
    CPoint3D test;
    char* fileName;
    vector<CPoint3D> vertices;
    
    void generateRevolutionSurface();
    
public:
    PlyGenerator(char[]);
};

#endif /* PlyGenerator_h */
