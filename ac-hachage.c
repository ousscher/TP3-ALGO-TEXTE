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
    int max_word_len = 0;
    char line[MAX_LINE];
    
    while (fgets(line, MAX_LINE, f_mots)) {
        nb_mots++;
        int len = strlen(line) - 1; // -1 pour le \n
        if (len > 0) {
            total_len += len;
            if (len > max_word_len) max_word_len = len;
        }
    }
    
    // On estime que 80% des caractères seront des nœuds uniques (partage de préfixes)
    int maxNode = (int)(total_len * 0.8) + nb_mots;
    
    // Sécurité : au moins nb_mots nœuds, au plus total_len
    if (maxNode < nb_mots) maxNode = nb_mots;
    if (maxNode > total_len + 100) maxNode = total_len + 100;
    
    
    Trie trie = createTrie(maxNode);
    if (!trie) {
        fprintf(stderr, "Erreur creation trie\n");
        fclose(f_mots);
        return 1;
    }
    
    rewind(f_mots);
    
    while (fgets(line, MAX_LINE, f_mots)) {
        line[strcspn(line, "\n")] = 0;
        if (strlen(line) > 0) {
            insertInTrie(trie, (unsigned char*)line);
        }
    }
    fclose(f_mots);
    
    // int actual_nodes = getNextNode(trie);
    // printf("Nœuds réellement utilisés: %d/%d (%.1f%%)\n", 
    //        actual_nodes, maxNode, (actual_nodes * 100.0) / maxNode);
    
    buildAhoCorasick(trie);
    
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
    
    int count = searchAhoCorasick(trie, text);
    
    printf("%d\n", count);
    
    // Libération
    free(text);
    freeTrie(trie);
    
    return 0;
}