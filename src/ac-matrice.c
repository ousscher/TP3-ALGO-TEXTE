#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "trie.h"

#define MAX_LINE 1024
#define MAX_TEXT 10000000

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <fichier_mots> <fichier_texte>\n", argv[0]);
        return 1;
    }
    
    // Ouvrir le fichier de mots
    FILE *f_mots = fopen(argv[1], "r");
    if (!f_mots) {
        fprintf(stderr, "Erreur ouverture %s\n", argv[1]);
        return 1;
    }
    
    // Compter les mots pour dimensionner le trie
    int nb_mots = 0;
    int total_len = 0;
    char line[MAX_LINE];
    
    while (fgets(line, MAX_LINE, f_mots)) {
        nb_mots++;
        total_len += strlen(line);
    }
    
    // Créer le trie avec une taille suffisante
    int maxNode = total_len + 100;
    Trie trie = createTrie(maxNode);
    if (!trie) {
        fprintf(stderr, "Erreur creation trie\n");
        fclose(f_mots);
        return 1;
    }
    
    // Insérer les mots dans le trie
    rewind(f_mots);
    while (fgets(line, MAX_LINE, f_mots)) {
        // Enlever le retour à la ligne
        line[strcspn(line, "\n")] = 0;
        if (strlen(line) > 0) {
            insertInTrie(trie, (unsigned char*)line);
        }
    }
    fclose(f_mots);
    
    // Construire l'automate Aho-Corasick
    buildAhoCorasick(trie);
    
    // Lire le texte
    FILE *f_texte = fopen(argv[2], "r");
    if (!f_texte) {
        fprintf(stderr, "Erreur ouverture %s\n", argv[2]);
        freeTrie(trie);
        return 1;
    }
    
    unsigned char *text = malloc(MAX_TEXT);
    if (!text) {
        fprintf(stderr, "Erreur allocation texte\n");
        fclose(f_texte);
        freeTrie(trie);
        return 1;
    }
    
    size_t text_len = fread(text, 1, MAX_TEXT - 1, f_texte);
    text[text_len] = '\0';
    fclose(f_texte);
    
    // Rechercher avec Aho-Corasick
    int count = searchAhoCorasick(trie, text);
    
    // Afficher UNIQUEMENT le résultat
    printf("%d\n", count);
    
    // Libération
    free(text);
    freeTrie(trie);
    
    return 0;
}