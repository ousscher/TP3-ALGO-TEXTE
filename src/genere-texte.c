#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <longueur> <taille_alphabet>\n", argv[0]);
        return 1;
    }
    
    long longueur = atol(argv[1]);
    int taille_alphabet = atoi(argv[2]);
    
    if (longueur <= 0 || taille_alphabet <= 0 || taille_alphabet > 256) {
        fprintf(stderr, "Parametres invalides\n");
        return 1;
    }
    
    // Initialisation du générateur aléatoire
    srand(time(NULL));
    
    // Génération du texte
    for (long i = 0; i < longueur; i++) {
        unsigned char c = (unsigned char)(rand() % taille_alphabet);
        putchar(c);
    }
    
    return 0;
}