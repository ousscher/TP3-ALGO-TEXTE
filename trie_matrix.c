#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "trie.h"

struct _trie {
    int maxNode;
    int nextNode;
    int **transition;
    char *finite;
    int *suppleant;
};

struct _queue {
    int *data;
    int front;
    int rear;
    int size;
    int maxSize;
};

Queue createQueue(int maxSize) {
    Queue q = malloc(sizeof(struct _queue));
    if (!q) return NULL;
    
    q->data = malloc(maxSize * sizeof(int));
    if (!q->data) {
        free(q);
        return NULL;
    }
    
    q->front = 0;
    q->rear = 0;
    q->size = 0;
    q->maxSize = maxSize;
    
    return q;
}

void Enfiler(Queue q, int value) {
    if (!q || q->size >= q->maxSize) return;
    
    q->data[q->rear] = value;
    q->rear = (q->rear + 1) % q->maxSize;
    q->size++;
}

int Defiler(Queue q) {
    if (!q || q->size == 0) return -1;
    
    int value = q->data[q->front];
    q->front = (q->front + 1) % q->maxSize;
    q->size--;
    
    return value;
}

int isEmptyQueue(Queue q) {
    return (q == NULL || q->size == 0);
}

void freeQueue(Queue q) {
    if (!q) return;
    free(q->data);
    free(q);
}

Trie createTrie(int maxNode) {
    Trie trie = malloc(sizeof(struct _trie));
    if (!trie) return NULL;
    
    trie->maxNode = maxNode;
    trie->nextNode = 1;
    
    trie->transition = malloc(maxNode * sizeof(int*));
    trie->finite = calloc(maxNode, sizeof(char));
    trie->suppleant = calloc(maxNode, sizeof(int));
    
    if (!trie->transition || !trie->finite || !trie->suppleant) {
        free(trie->transition);
        free(trie->finite);
        free(trie->suppleant);
        free(trie);
        return NULL;
    }
    
    for (int i = 0; i < maxNode; i++) {
        trie->transition[i] = malloc(ALPHA_SIZE * sizeof(int));
        if (!trie->transition[i]) {
            for (int j = 0; j < i; j++) 
                free(trie->transition[j]);
            free(trie->transition);
            free(trie->finite);
            free(trie->suppleant);
            free(trie);
            return NULL;
        }
        for (int j = 0; j < ALPHA_SIZE; j++)
            trie->transition[i][j] = -1;
    }
    
    return trie;
}

void insertInTrie(Trie trie, unsigned char *w) {
    if (!trie || !w) return;
    
    int state = 0;
    int len = strlen((char*)w);
    
    for (int i = 0; i < len; i++) {
        unsigned char c = w[i];
        
        if (trie->transition[state][c] == -1) {
            if (trie->nextNode >= trie->maxNode) {
                fprintf(stderr, "Erreur: trie plein\n");
                return;
            }
            trie->transition[state][c] = trie->nextNode;
            trie->nextNode++;
        }
        state = trie->transition[state][c];
    }
    
    trie->finite[state] = 1;
}

int getTransition(Trie trie, int state, unsigned char c) {
    if (!trie || state < 0 || state >= trie->nextNode) return -1;
    return trie->transition[state][c];
}

int isFiniteState(Trie trie, int state) {
    if (!trie || state < 0 || state >= trie->nextNode) return 0;
    return trie->finite[state];
}

int getSuppleant(Trie trie, int state) {
    if (!trie || state < 0 || state >= trie->nextNode) return 0;
    return trie->suppleant[state];
}

void setSuppleant(Trie trie, int state, int suppleant) {
    if (!trie || state < 0 || state >= trie->nextNode) return;
    trie->suppleant[state] = suppleant;
}

int getNextNode(Trie trie) {
    if (!trie) return 0;
    return trie->nextNode;
}

void buildAhoCorasick(Trie trie) {
    if (!trie) return;
    
    Queue q = createQueue(trie->nextNode);
    if (!q) return;
    
    // Initialisation: fils de la racine ont la racine comme suppléant
    for (int c = 0; c < ALPHA_SIZE; c++) {
        int fils = trie->transition[0][c];
        if (fils != -1) {
            trie->suppleant[fils] = 0;
            Enfiler(q, fils);
        }
    }
    
    // Parcours en largeur pour calculer les suppléants
    while (!isEmptyQueue(q)) {
        int etat = Defiler(q);
        
        for (int c = 0; c < ALPHA_SIZE; c++) {
            int fils = trie->transition[etat][c];
            if (fils == -1) continue;
            
            Enfiler(q, fils);
            
            // Calculer le suppléant du fils
            int suppleant = trie->suppleant[etat];
            
            while (suppleant != 0 && trie->transition[suppleant][c] == -1) {
                suppleant = trie->suppleant[suppleant];
            }
            
            if (trie->transition[suppleant][c] != -1 && 
                trie->transition[suppleant][c] != fils) {
                trie->suppleant[fils] = trie->transition[suppleant][c];
            } else {
                trie->suppleant[fils] = 0;
            }
        }
    }
    
    freeQueue(q);
}

int searchAhoCorasick(Trie trie, unsigned char *text) {
    if (!trie || !text) return 0;
    
    int count = 0;
    int state = 0;
    int len = strlen((char*)text);
    
    for (int i = 0; i < len; i++) {
        unsigned char c = text[i];
        
        // Suivre les suppléants jusqu'à trouver une transition valide
        while (state != 0 && trie->transition[state][c] == -1) {
            state = trie->suppleant[state];
        }
        
        if (trie->transition[state][c] != -1) {
            state = trie->transition[state][c];
        }
        
        // Compter tous les mots qui se terminent à cette position
        int temp = state;
        while (temp != 0) {
            if (trie->finite[temp]) {
                count++;
            }
            temp = trie->suppleant[temp];
        }
    }
    
    return count;
}

int isInTrie(Trie trie, unsigned char *w) {
    if (!trie || !w) return 0;
    
    int state = 0;
    int len = strlen((char*)w);
    
    for (int i = 0; i < len; i++) {
        unsigned char c = w[i];
        
        if (trie->transition[state][c] == -1)
            return 0;
        
        state = trie->transition[state][c];
    }
    
    return trie->finite[state];
}

void freeTrie(Trie trie) {
    if (!trie) return;
    
    for (int i = 0; i < trie->maxNode; i++)
        free(trie->transition[i]);
    
    free(trie->transition);
    free(trie->finite);
    free(trie->suppleant);
    free(trie);
}

void printTrieStats(Trie trie) {
    if (!trie) return;
    printf("Noeuds utilises: %d/%d\n", trie->nextNode, trie->maxNode);
}