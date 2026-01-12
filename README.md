# TP3 - Algorithme d'Aho-Corasick

## Description
Implémentation de l'algorithme d'Aho-Corasick pour la recherche de multiples motifs dans un texte, avec deux structures de données :
- **Matrice de transitions** : Accès O(1), consommation mémoire élevée
- **Table de hachage avec cache** : Accès O(1) amorti, consommation mémoire optimisée

## Compilation

```bash
make all
```

Cela génère 4 exécutables :
- `genere-texte` : générateur de textes pseudo-aléatoires
- `genere-mots` : générateur de mots pseudo-aléatoires
- `ac-matrice` : recherche avec matrice de transitions
- `ac-hachage` : recherche avec table de hachage optimisée

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

## Tests et Benchmarks

### Tests automatiques complets

Pour lancer tous les tests et générer les comparaisons de performance :

```bash
make all
chmod +x test_performances.sh
./test_performances.sh
```

Ce script va :
1. Créer le dossier `data_performances/`
2. Générer automatiquement des jeux de tests avec différents paramètres :
   - Tailles d'alphabet : 2, 4, 20, 70
   - Longueurs de mots : [5-15], [15-30], [30-60]
   - Texte de 5 millions de caractères
   - 100 mots par ensemble
3. Exécuter `ac-matrice` et `ac-hachage` sur chaque configuration
4. Générer les graphiques de comparaison dans le dossier `graphiques/`

**Résultats attendus** :
- Graphique des temps d'exécution par alphabet et longueur de mots
- Tableau CSV avec les statistiques détaillées
- Fichiers PNG dans `graphiques/`.

### Test avec les fichiers fournis

Placez les fichiers `mots.txt` et `texte.txt` dans le dossier `data/`, puis :

```bash
./ac-matrice data/mots.txt data/texte.txt
./ac-hachage data/mots.txt data/texte.txt
```

Les deux commandes doivent afficher `80`.

## Structure du projet

```
tp3/
├── Makefile
├── README.md
├── trie.h                      # Header commun
├── trie_matrix.c               # Implémentation avec matrice
├── trie_hash.c                 # Implémentation avec hachage + cache
├── genere-texte.c              # Générateur de textes
├── genere-mots.c               # Générateur de mots
├── ac-matrice.c                # Programme principal (matrice)
├── ac-hachage.c                # Programme principal (hachage)
├── test_performances.sh        # Script de benchmark automatique
├── test_step1_genere.sh        # Test des générateurs
├── test_step2_ac.sh            # Test d'Aho-Corasick
├── test_step3_perf.sh          # Test de performance manuel
├── data/                       # Données de test fournies
│   ├── mots.txt
│   └── texte.txt
├── data_performances/          # Généré par test_performances.sh
│   ├── mots_*.txt
│   ├── texte_*.txt
│   └── resultats.csv
└── graphiques/                 # Généré par test_performances.sh
    ├── comparaison_temps.png
    └── temps_par_alphabet.png
```

## Algorithme d'Aho-Corasick

L'algorithme se déroule en deux phases :

1. **Construction** : 
   - Insertion des mots dans un trie
   - Calcul des liens de suppléance (parcours BFS)
   - Complexité : O(Σ|mots|)

2. **Recherche** :
   - Parcours du texte avec l'automate
   - Utilisation d'un cache pour les transitions (version hachage)
   - Complexité : O(|texte| + nombre d'occurrences)


## Nettoyage

```bash
make clean       # Supprime les exécutables
```

```bash
rm -rf data_performances/ graphiques/
```

## Auteurs

- CHERGUELAINE OUSSAMA
- SOULEYMAN SALEH MOUSSA

## Remarques techniques

- Les fichiers de mots doivent contenir un mot par ligne
- Les deux implémentations donnent exactement le même résultat
- La matrice est plus rapide mais consomme plus de mémoire
- Le hachage est optimal en mémoire avec le cache de transitions
- Alphabet supporté : ASCII (256 caractères max)
- Les scripts nécessitent Python 3 avec matplotlib, pandas et seaborn pour les graphiques 

