#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <longueur> <taille_alphabet>\n", argv[0]);
        return 1;
    }
    
    long longueur = atol(argv[1]);
    int taille_alphabet = atoi(argv[2]);
    
    if (longueur <= 0 || taille_alphabet <= 0 || taille_alphabet > 256) {
        fprintf(stderr, "Parametres invalides (taille_alphabet max: 256)\n");
        return 1;
    }
    
    // Seed avec plusieurs sources d'aléa
    srand(time(NULL) ^ (getpid() << 16) ^ clock());
    
    // Génération par blocs pour meilleures performances
    const long BUFFER_SIZE = 65536;
    char *buffer = malloc(BUFFER_SIZE);
    if (!buffer) {
        fprintf(stderr, "Erreur allocation memoire\n");
        return 1;
    }
    
    long reste = longueur;
    
    while (reste > 0) {
        long taille_bloc = (reste < BUFFER_SIZE) ? reste : BUFFER_SIZE;
        
        for (long i = 0; i < taille_bloc; i++) {
            buffer[i] = 'a' + (rand() % taille_alphabet);
        }
        
        fwrite(buffer, 1, taille_bloc, stdout);
        reste -= taille_bloc;
    }
    
    free(buffer);
    
    return 0;
}