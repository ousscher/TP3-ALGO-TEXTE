#ifndef TRIE_H
#define TRIE_H

#define ALPHA_SIZE 256

typedef struct _trie *Trie;

// Fonctions communes
Trie createTrie(int maxNode);
void insertInTrie(Trie trie, unsigned char *w);
int isInTrie(Trie trie, unsigned char *w);
void freeTrie(Trie trie);
void printTrieStats(Trie trie);

// Fonctions pour Aho-Corasick
typedef struct _queue *Queue;

Queue createQueue(int maxSize);
void Enfiler(Queue q, int value);
int Defiler(Queue q);
int isEmptyQueue(Queue q);
void freeQueue(Queue q);

// Structure pour les liens de suppléance
int getSuppleant(Trie trie, int state);
void setSuppleant(Trie trie, int state, int suppleant);
int getTransition(Trie trie, int state, unsigned char c);
int isFiniteState(Trie trie, int state);
int getNextNode(Trie trie);

// Construction de l'automate Aho-Corasick
void buildAhoCorasick(Trie trie);

// Recherche avec Aho-Corasick
int searchAhoCorasick(Trie trie, unsigned char *text);

#endif