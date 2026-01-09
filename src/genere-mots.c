#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char *argv[]) {
    if (argc != 5) {
        fprintf(stderr, "Usage: %s <nb_mots> <longueur_min> <longueur_max> <taille_alphabet>\n", argv[0]);
        return 1;
    }
    
    int nb_mots = atoi(argv[1]);
    int longueur_min = atoi(argv[2]);
    int longueur_max = atoi(argv[3]);
    int taille_alphabet = atoi(argv[4]);
    
    if (nb_mots <= 0 || longueur_min <= 0 || longueur_max < longueur_min || 
        taille_alphabet <= 0 || taille_alphabet > 256) {
        fprintf(stderr, "Parametres invalides\n");
        return 1;
    }
    
    // Initialisation du générateur aléatoire
    srand(time(NULL));
    
    // Génération des mots
    for (int i = 0; i < nb_mots; i++) {
        int longueur = longueur_min + (rand() % (longueur_max - longueur_min + 1));
        
        for (int j = 0; j < longueur; j++) {
            unsigned char c = (unsigned char)(rand() % taille_alphabet);
            putchar(c);
        }
        putchar('\n');
    }
    
    return 0;
}