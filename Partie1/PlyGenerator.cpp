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
#include <cmath>
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
    delta = stof(commandTokens[2]);
    y = stof(commandTokens[3]);
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
    
    // Écriture de l'entête
    plyFile << "ply\n" <<
        "format ascii 1.0\n" <<
        "comment this file is a revolution surface\n" <<
        "element vertex " << to_string(vertices.size()) << "\n" <<
        "property float x\n" <<
        "property float y\n" <<
        "property float z\n" <<
        "element face " << to_string(triangles.size()) << "\n" <<
        "end_header\n";
    
    // Écriture des vertices
    plyFile << getVerticesToString();
    
    // Écriture de faces (triangles)
    plyFile << getFacesToString();
    
    // Fermeture du fichier
    plyFile.close();
    
    return "Le fichier " + fileName + " a bien été écrit.";
}

string PlyGenerator::getVerticesToString()
{
    string result = "";
    for(size_t index = 0; index < vertices.size(); index++)
    {
        result += to_string(vertices[index][0]) + " "
                + to_string(vertices[index][1]) + " "
                + to_string(vertices[index][2]) + "\n";
    }
    return result;
}

float surface1(const float& x)
{
    return sin(sqrt(1-(x*x)));
}

float surface2(const float& x)
{
    return sin(sqrt(1-(x)));
}

float surface3(const float& x)
{
    return sin(x + M_PI_2);
}

void PlyGenerator::generateVertices()
{
    float maxY = 0;
    fctgen_ptr f;
    if(surfaceType == 1)
    {
        maxY = 1;
        f = surface1;
    }
    else if(surfaceType == 2)
    {
        maxY = 1;
        f = surface2;
    }
    else if(surfaceType == 3)
    {
        maxY = M_PI_2;
        f = surface3;
    }
    else
        return;
    
    // Génération des points
    int nbPointsRangee = 0;
    for(float currentY = 0; currentY <= (float)maxY; currentY += y)
    {
        nbPointsRangee = 0;
        for(float currentDelta = 0; currentDelta <= (float)360; currentDelta += delta)
        {
            CPoint3D x = surfrevol(currentDelta, currentY, f);
            vertices.push_back(x);
            
            ++nbPointsRangee;
        }
    }
    
    // Détermination des triangles
    bool debutGauche = true;
    int nbLignes = (int)vertices.size() / (int)nbPointsRangee;
    // On génère le carré de 2 triangles au dessus à droite du point actuel de la ligne.
    // On va donc générer un carré pour les point 0 à n-1 sur une ligne de n points.
    for(int cptLigne = 1; cptLigne < nbLignes; cptLigne++)
    {
        // Inverse le triangle de début à chaque ligne.
        // On commence par un carré de début triangle gauche, c'est-à-dire que
        // la diagonale du carré le séparant en 2 triangle va du coin en haut à gauche
        // au coin en bas à droite.
        debutGauche = cptLigne % 2 == 1;
        
        for(int cptPoints = 0; cptPoints < nbPointsRangee - 1; cptPoints++)
        {
            if(debutGauche)
            {
                // Carré de début gauche
                // Triangle de gauche
                Triangle triangleGauche;
                triangleGauche.sommet1 = (cptLigne - 1) * nbPointsRangee + cptPoints;
                triangleGauche.sommet2 = triangleGauche.sommet1 + 1;
                triangleGauche.sommet3 = triangleGauche.sommet1 + nbPointsRangee;
                triangles.push_back(triangleGauche);
                
                // Triangle de droite
                Triangle triangleDroite;
                triangleDroite.sommet1 = triangleGauche.sommet2;
                triangleDroite.sommet2 = triangleGauche.sommet3 + 1;
                triangleDroite.sommet3 = triangleGauche.sommet3;
                triangles.push_back(triangleDroite);
            }
            else
            {
                // Carré de début droite
                // Triangle de droite
                Triangle triangleDroite;
                triangleDroite.sommet1 = (cptLigne - 1) * nbPointsRangee + cptPoints;
                triangleDroite.sommet2 = triangleDroite.sommet1 + 1;
                triangleDroite.sommet3 = triangleDroite.sommet2 + nbPointsRangee;
                triangles.push_back(triangleDroite);
                
                // Triangle de gauche
                Triangle triangleGauche;
                triangleGauche.sommet1 = triangleDroite.sommet1;
                triangleGauche.sommet2 = triangleDroite.sommet3;
                triangleGauche.sommet3 = triangleDroite.sommet2 - 1;
                triangles.push_back(triangleGauche);
            }
            
            debutGauche = !debutGauche;
        }
    }
    
}

CPoint3D PlyGenerator::surfrevol(const float& theta, const float &y, fctgen_ptr f)
{
    CPoint3D p = CPoint3D(f(y)*cos(theta), y, f(y)*sin(theta));
    
    return p;
}

string PlyGenerator::getFacesToString()
{
    string result = "";
    for(size_t index = 0; index < triangles.size(); index++)
    {
        result += to_string(triangles[index].sommet1) + " "
        + to_string(triangles[index].sommet2) + " "
        + to_string(triangles[index].sommet3) + "\n";
    }
    return result;
}
