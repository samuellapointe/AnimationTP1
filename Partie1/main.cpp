#include <iostream>
#include "PlyGenerator.h"
#include <string>

using namespace std;

std::vector<string> splitCommandTokens(std::string command)
{
    std::vector<std::string> results;
    size_t lastOffset = 0;
    while(true)
    {
        size_t offset = command.find_first_of(" ", lastOffset);
        results.push_back(command.substr(lastOffset, offset - lastOffset));
        if (offset == std::string::npos)
            break;
        
        lastOffset = offset + 1; // add one to skip the delimiter
    }
    
    return results;
}

string readCommand()
{
    cout << endl << "Entrez une commande sous le format suivant:" << endl
    << "gensurfevol type M N fichier.ply" << endl
    << "où le type = 1, 2 ou 3 et M et N correspondent au delta et au y déterminant la finesse du maillage." << endl
    << "Tapez q pour quitter." << endl;
    
    string input;
    getline(cin, input);
    return input;
}

void executeCommand(string command)
{
    vector<string> commandTokens = splitCommandTokens(command);
    if(commandTokens.size() < 1)
        return; // Pas de commande entrée
    
    string resultat = "Aucune opération effectuée.";
    if(commandTokens[0] == "gensurfevol")
    {
        if(commandTokens.size() != 5)
        {
            cout << "Erreur: Nombre de paramètres insuffisant." << endl;
            return;
        }
        
        PlyGenerator plyGenerator = PlyGenerator(commandTokens);
        resultat = plyGenerator.generateFile();
    }
    else
    {
        cout << "Commande inconnue: " << commandTokens[0] << endl;
        return;
    }
    
    cout << resultat << endl;
}

// ATTENTION
// Pour la fonction 1: Un delta  de 0.01 semble planter le viewer.
// Pour la fonction 3: Un y de moins de 0.05 semble planter le viewer.

// Formes lisses et plus arrondies.
// Commande: gensurfevol 1 0.5 0.01 /Users/etudiant/Desktop/AnimationTP1/1.ply
// Commande: gensurfevol 2 0.5 0.01 /Users/etudiant/Desktop/AnimationTP1/2.ply
// Commande: gensurfevol 3 0.5 0.05 /Users/etudiant/Desktop/AnimationTP1/3.ply

// Formes avec un maillage moins lisse, afin de mieux voir les polygones.
// Commande: gensurfevol 1 0.8 0.1 /Users/etudiant/Desktop/AnimationTP1/1.ply
// Commande: gensurfevol 2 0.8 0.1 /Users/etudiant/Desktop/AnimationTP1/2.ply
// Commande: gensurfevol 3 1 0.1 /Users/etudiant/Desktop/AnimationTP1/3.ply

int main(int argc, const char * argv[]) {
    std::cout << "Début" << endl;
    
    // L'utilisateur entre des commandes jusqu'à ce
    // qu'il entre q ou Q.
    bool quit = false;
    while(!quit)
    {
        string command = readCommand();
        if(command == "q" || command == "Q")
            quit = true;
        else
            executeCommand(command);
    }
    
    cout << "Fin" << endl;
    
    return 0;
}
