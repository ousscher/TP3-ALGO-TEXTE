#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "trie.h"

struct _list {
    int startNode;
    int targetNode;
    unsigned char letter;
    struct _list *next;
};

typedef struct _list *List;

struct _trie {
    int maxNode;
    int nextNode;
    List *transition;
    char *finite;
    int *suppleant;
    int hashSize;
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

static unsigned int hashFunction(int state, unsigned char letter, int m) {
    return ((state * 256) + letter) % m;
}

Trie createTrie(int maxNode) {
    Trie trie = malloc(sizeof(struct _trie));
    if (!trie) return NULL;
    
    trie->maxNode = maxNode;
    trie->nextNode = 1;
    trie->hashSize = (maxNode * ALPHA_SIZE) / 0.75;
    
    trie->transition = calloc(trie->hashSize, sizeof(List));
    trie->finite = calloc(maxNode, sizeof(char));
    trie->suppleant = calloc(maxNode, sizeof(int));
    
    if (!trie->transition || !trie->finite || !trie->suppleant) {
        free(trie->transition);
        free(trie->finite);
        free(trie->suppleant);
        free(trie);
        return NULL;
    }
    
    return trie;
}

static int getTarget(Trie trie, int state, unsigned char c) {
    unsigned int h = hashFunction(state, c, trie->hashSize);
    List l = trie->transition[h];
    
    while (l) {
        if (l->startNode == state && l->letter == c)
            return l->targetNode;
        l = l->next;
    }
    return -1;
}

static void addTransition(Trie trie, int from, unsigned char c, int to) {
    unsigned int h = hashFunction(from, c, trie->hashSize);
    
    List newLink = malloc(sizeof(struct _list));
    if (!newLink) {
        fprintf(stderr, "Erreur allocation memoire\n");
        return;
    }
    
    newLink->startNode = from;
    newLink->targetNode = to;
    newLink->letter = c;
    newLink->next = trie->transition[h];
    trie->transition[h] = newLink;
}

void insertInTrie(Trie trie, unsigned char *w) {
    if (!trie || !w) return;
    
    int state = 0;
    int len = strlen((char*)w);
    
    for (int i = 0; i < len; i++) {
        unsigned char c = w[i];
        int target = getTarget(trie, state, c);
        
        if (target == -1) {
            if (trie->nextNode >= trie->maxNode) {
                fprintf(stderr, "Erreur: trie plein\n");
                return;
            }
            target = trie->nextNode;
            addTransition(trie, state, c, target);
            trie->nextNode++;
        }
        state = target;
    }
    
    trie->finite[state] = 1;
}

int getTransition(Trie trie, int state, unsigned char c) {
    if (!trie || state < 0 || state >= trie->nextNode) return -1;
    return getTarget(trie, state, c);
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
    
    // Initialisation: parcourir tous les fils de la racine
    for (int i = 0; i < trie->hashSize; i++) {
        List l = trie->transition[i];
        while (l) {
            if (l->startNode == 0) {
                trie->suppleant[l->targetNode] = 0;
                Enfiler(q, l->targetNode);
            }
            l = l->next;
        }
    }
    
    // Parcours en largeur
    while (!isEmptyQueue(q)) {
        int etat = Defiler(q);
        
        // Parcourir toutes les transitions depuis cet état
        for (int i = 0; i < trie->hashSize; i++) {
            List l = trie->transition[i];
            while (l) {
                if (l->startNode == etat) {
                    int fils = l->targetNode;
                    unsigned char c = l->letter;
                    
                    Enfiler(q, fils);
                    
                    // Calculer le suppléant du fils
                    int suppleant = trie->suppleant[etat];
                    
                    while (suppleant != 0 && getTarget(trie, suppleant, c) == -1) {
                        suppleant = trie->suppleant[suppleant];
                    }
                    
                    int trans = getTarget(trie, suppleant, c);
                    if (trans != -1 && trans != fils) {
                        trie->suppleant[fils] = trans;
                    } else {
                        trie->suppleant[fils] = 0;
                    }
                }
                l = l->next;
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
        while (state != 0 && getTarget(trie, state, c) == -1) {
            state = trie->suppleant[state];
        }
        
        int trans = getTarget(trie, state, c);
        if (trans != -1) {
            state = trans;
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
        int target = getTarget(trie, state, c);
        
        if (target == -1)
            return 0;
        
        state = target;
    }
    
    return trie->finite[state];
}

void freeTrie(Trie trie) {
    if (!trie) return;
    
    for (int i = 0; i < trie->hashSize; i++) {
        List l = trie->transition[i];
        while (l) {
            List tmp = l;
            l = l->next;
            free(tmp);
        }
    }
    
    free(trie->transition);
    free(trie->finite);
    free(trie->suppleant);
    free(trie);
}

void printTrieStats(Trie trie) {
    if (!trie) return;
    printf("Noeuds utilises: %d/%d\n", trie->nextNode, trie->maxNode);
    printf("Taille table de hachage: %d\n", trie->hashSize);
}