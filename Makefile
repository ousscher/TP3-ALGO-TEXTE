CC = gcc
CFLAGS = -Wall -Wextra -O3 -std=c99
LDFLAGS = -lm

# Exécutables
EXEC = genere-texte genere-mots ac-matrice ac-hachage

all: $(EXEC)

# Générateurs
genere-texte: genere-texte.c
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

genere-mots: genere-mots.c
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

# Aho-Corasick avec matrice
ac-matrice: ac-matrice.c trie_matrix.c trie.h
	$(CC) $(CFLAGS) -o $@ ac-matrice.c trie_matrix.c $(LDFLAGS)

# Aho-Corasick avec table de hachage
ac-hachage: ac-hachage.c trie_hash.c trie.h
	$(CC) $(CFLAGS) -o $@ ac-hachage.c trie_hash.c $(LDFLAGS)

clean:
	rm -f $(EXEC) *.o

mrproper: clean
	rm -f data/texte_*.txt data/mots_*.txt

.PHONY: all clean mrproper