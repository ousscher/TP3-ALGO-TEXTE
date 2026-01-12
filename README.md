# TP3 - Algorithme d'Aho-Corasick

## Description
Implémentation de l'algorithme d'Aho-Corasick pour la recherche de multiples motifs dans un texte, avec deux structures de données :
- Matrice de transitions
- Table de hachage

## Compilation

```bash
make all
```

Cela génère 4 exécutables :
- `genere-texte` : générateur de textes pseudo-aléatoires
- `genere-mots` : générateur de mots pseudo-aléatoires
- `ac-matrice` : recherche avec matrice de transitions
- `ac-hachage` : recherche avec table de hachage

## Utilisation

### Génération de texte
```bash
./genere-texte <longueur> <taille_alphabet>
```
Exemple :
```bash
./genere-texte 1000 20 > texte.txt
```

### Génération de mots
```bash
./genere-mots <nb_mots> <longueur_min> <longueur_max> <taille_alphabet>
```
Exemple :
```bash
./genere-mots 100 5 15 20 > mots.txt
```

### Recherche avec Aho-Corasick
```bash
./ac-matrice <fichier_mots> <fichier_texte>
./ac-hachage <fichier_mots> <fichier_texte>
```
Exemple :
```bash
./ac-matrice data/mots.txt data/texte.txt
./ac-hachage data/mots.txt data/texte.txt
```

Les deux commandes affichent uniquement le nombre total d'occurrences trouvées.

## Tests

### Test étape par étape

1. **Test des générateurs** :
```bash
chmod +x test_step1_genere.sh
./test_step1_genere.sh
```

2. **Test d'Aho-Corasick** :
```bash
chmod +x test_step2_ac.sh
./test_step2_ac.sh
```

3. **Tests de performance** :
```bash
chmod +x test_step3_perf.sh
./test_step3_perf.sh
```

### Test avec les fichiers fournis

Placez les fichiers `mots.txt` et `texte.txt` fournis par le professeur dans le dossier `data/`, puis :

```bash
./ac-matrice data/mots.txt data/texte.txt
./ac-hachage data/mots.txt data/texte.txt
```

Les deux commandes doivent afficher `80`.

## Structure du projet

```
tp3/
├── Makefile
├── README
├── trie.h                      # Header commun
├── trie_matrix.c               # Implémentation avec matrice
├── trie_hash.c                 # Implémentation avec hachage
├── genere-texte.c              # Générateur de textes
├── genere-mots.c               # Générateur de mots
├── ac-matrice.c                # Programme principal (matrice)
├── ac-hachage.c                # Programme principal (hachage)
├── test_performances.sh        # Tests de performance
└── data/                       # Données de test
    ├── mots.txt                # Fourni par le prof
    └── texte.txt               # Fourni par le prof
```

## Algorithme d'Aho-Corasick

L'algorithme se déroule en deux phases :

1. **Construction** : 
   - Insertion des mots dans un trie
   - Calcul des liens de suppléance (parcours BFS)
   - Complexité : O(Σ|mots|)

2. **Recherche** :
   - Parcours du texte avec l'automate
   - Complexité : O(|texte| + nombre d'occurrences)

## Nettoyage

```bash
make clean       # Supprime les exécutables
make mrproper    # Supprime aussi les données générées
```

## Auteurs

- CHERGUELAINE OUSSAMA
- SOULEYMAN SALEH MOUSSA
## Remarques

- Les fichiers de mots doivent contenir un mot par ligne
- Les deux implémentations (matrice et hachage) donnent le même résultat
- La matrice est plus rapide en accès pour les petits alphabets