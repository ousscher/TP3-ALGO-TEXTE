// #include <stdio.h>
// #include <stdlib.h>
// #include <time.h>

// // Génère un caractère aléatoire dans l'alphabet donné
// unsigned char random_char(int alphabet_size) {
//     return (unsigned char)(rand() % alphabet_size + 'a');
// }

// // Génère un mot aléatoire et l'affiche sur stdout
// void generate_and_print_word(int min_len, int max_len, int alphabet_size) {
//     int len = min_len + (rand() % (max_len - min_len + 1));
    
//     for (int i = 0; i < len; i++) {
//         putchar(random_char(alphabet_size));
//     }
//     putchar('\n');
// }

// int main(int argc, char *argv[]) {
//     if (argc != 5) {
//         fprintf(stderr, "Usage: %s <nb_mots> <longueur_min> <longueur_max> <taille_alphabet>\n", argv[0]);
//         return 1;
//     }
    
//     int nb_mots = atoi(argv[1]);
//     int longueur_min = atoi(argv[2]);
//     int longueur_max = atoi(argv[3]);
//     int taille_alphabet = atoi(argv[4]);
    
//     if (nb_mots <= 0 || longueur_min <= 0 || longueur_max < longueur_min || 
//         taille_alphabet <= 0 || taille_alphabet > 256) {
//         fprintf(stderr, "Parametres invalides\n");
//         return 1;
//     }
    
//     // Initialisation du générateur aléatoire
//     srand(time(NULL));
    
//     // Génération des mots
//     for (int i = 0; i < nb_mots; i++) {
//         generate_and_print_word(longueur_min, longueur_max, taille_alphabet);
//     }
    
//     return 0;
// }

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// Génère un caractère aléatoire dans l'alphabet donné
unsigned char random_char(int alphabet_size) {
    return (unsigned char)(rand() % alphabet_size + 'a');
}

// Génère un mot aléatoire
void generate_word(unsigned char *word, int min_len, int max_len, int alphabet_size) {
    int len = min_len + (rand() % (max_len - min_len + 1));
    for (int i = 0; i < len; i++) {
        word[i] = random_char(alphabet_size);
    }
    word[len] = '\0';
}

int main(int argc, char *argv[]) {
    if (argc != 5) {
        fprintf(stderr, "Usage: %s <nb_mots> <longueur_min> <longueur_max> <taille_alphabet>\n", argv[0]);
        return 1;
    }
    
    int nb_words = atoi(argv[1]);
    int min_len = atoi(argv[2]);
    int max_len = atoi(argv[3]);
    int alphabet_size = atoi(argv[4]);
    
    // Initialiser le générateur aléatoire
    srand(time(NULL));
    
    // Générer les mots et les afficher sur stdout
    unsigned char word[1000];
    for (int i = 0; i < nb_words; i++) {
        generate_word(word, min_len, max_len, alphabet_size);
        printf("%s\n", word);
    }
    
    return 0;
}