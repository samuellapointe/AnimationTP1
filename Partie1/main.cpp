//
//  main.cpp
//  Partie1
//
//  Created by Etudiant on 2016-02-01.
//  Copyright © 2016 Etudiant. All rights reserved.
//

#include <iostream>

int main(int argc, const char * argv[]) {
    // insert code here...
    std::cout << "Hello, World!\n";
    for(int i = 0; i < argc; i++) {
        std::cout << argv[i];
    }
    return 0;
}
