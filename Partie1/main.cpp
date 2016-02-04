//
//  main.cpp
//  Partie1
//
//  Created by Etudiant on 2016-02-01.
//  Copyright © 2016 Etudiant. All rights reserved.
//

#include <iostream>
#include "PlyGenerator.h"

int main(int argc, const char * argv[]) {
    std::cout << "Début\n";
    
    char fileName[] = "/Users/etudiant/Desktop/x/test/AnimationTP1/x.ply";
    PlyGenerator plyGenerator = PlyGenerator(fileName);
    
    std::cout << "Fin\n";
    
    return 0;
}
