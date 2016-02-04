//
//  PlyGenerator.cpp
//  Partie1
//
//  Created by Etudiant on 2016-02-02.
//  Copyright © 2016 Etudiant. All rights reserved.
//

#include <stdio.h>
#include <fstream>
#include <iostream>
#include "PlyGenerator.h"

using namespace std;

PlyGenerator::PlyGenerator(char fileName[])
{
    this->fileName = fileName;
    
    // Création du fichier
    remove(this->fileName);
    ofstream plyFile;
    plyFile.open(this->fileName, ofstream::out | ofstream::app);
    if(!plyFile.is_open())
        cout << "Erreur lors de l'ouverture du fichier " << this->fileName << endl;
    
    // Écriture du fichier
    plyFile << "TEST";
    
    // Fermeture du fichier
    plyFile.close();
    cout << "Le fichier " << this->fileName << " a bien été écrit." << endl;
    
    
    
    
    //test
    std::ofstream ofs;
    ofs.open ("/Laboratoire/Utilisateurs/etudiant/Bureau/AnimationTP1/test.txt", std::ofstream::out | std::ofstream::app);
    ofs << " more lorem ipsum";
    ofs.close();
}