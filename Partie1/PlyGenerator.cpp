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
#include <vector>
#include "PlyGenerator.h"

using namespace std;
/*
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
}*/

PlyGenerator::PlyGenerator(vector<string> commandTokens)
{
    /*
     Index      Element
     0          Nom de la commande (gensurfevol)
     1          Type = 1, 2 ou 3
     2          M, correspondant au delta
     3          N, correspondant au y
     4          Nom du fichier (ex fichier.ply)
     */
    
    surfaceType = stoi(commandTokens[1]);
    delta = stoi(commandTokens[2]);
    y = stoi(commandTokens[3]);
    fileName = commandTokens[4];
}

string PlyGenerator::generateFile()
{
    // Génération des points de la surface de révolution
    generateVertices();
    
    // Création du fichier
    const char* cFileName = fileName.c_str();
    remove(cFileName);
    ofstream plyFile;
    plyFile.open(cFileName, ofstream::out | ofstream::app);
    if(!plyFile.is_open())
        return "Erreur lors de l'ouverture du fichier " + fileName;
    
    // Écriture du fichier
    plyFile << "TEST";
    
    // Fermeture du fichier
    plyFile.close();
    
    return "Le fichier " + fileName + " a bien été écrit.";
}

void PlyGenerator::generateVertices()
{
    // Seulement un point de test
    CPoint3D x = CPoint3D(1.0, 1.0, 1.0);
    vertices.push_back(x);
}
