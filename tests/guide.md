# Guide de Tests - TP3 Aho-Corasick

## Installation et Préparation

### 1. Structure du projet
```bash
# Créer la structure
mkdir -p tp3/data
cd tp3

# Copier tous les fichiers sources
# Placer mots.txt et texte.txt du prof dans data/
```

### 2. Vérifier les fichiers
```bash
ls -la
# Vous devez avoir :
# - trie.h
# - trie_matrix.c, trie_hash.c
# - genere-texte.c, genere-mots.c
# - ac-matrice.c, ac-hachage.c
# - Makefile
# - README
```

### 3. Compilation initiale
```bash
make all
```

Si erreurs, vérifier :
- GCC installé : `gcc --version`
- Tous les fichiers présents
- Pas d'erreurs de syntaxe

---

## Tests Étape par Étape

### ÉTAPE 1 : Tests des Générateurs

#### Test 1.1 : Générateur de texte
```bash
# Test basique
./genere-texte 100 4 > test1.txt
wc -c test1.txt  # Doit afficher 100

# Test avec différents alphabets
./genere-texte 1000 2 > test_alpha2.txt
./genere-texte 1000 20 > test_alpha20.txt
./genere-texte 1000 70 > test_alpha70.txt

# Vérifier que les caractères sont dans la plage
od -An -tx1 test_alpha2.txt | head  # Doit montrer 00 et 01 uniquement
```

**Résultats attendus :**
- Taille exacte du fichier = longueur demandée
- Caractères dans la plage [0, taille_alphabet-1]

#### Test 1.2 : Générateur de mots
```bash
# Test basique
./genere-mots 10 5 10 4 > test_mots.txt
wc -l test_mots.txt  # Doit afficher 10

# Vérifier les longueurs
while read line; do echo ${#line}; done < test_mots.txt
# Toutes les longueurs doivent être entre 5 et 10

# Test avec différentes configurations
./genere-mots 100 5 15 20 > mots_5_15.txt
./genere-mots 100 15 30 20 > mots_15_30.txt
./genere-mots 100 30 60 20 > mots_30_60.txt
```

**Résultats attendus :**
- Nombre de lignes = nombre de mots demandé
- Chaque mot a une longueur dans [min, max]
- Un mot par ligne

#### Test 1.3 : Script automatique
```bash
chmod +x test_step1_genere.sh
./test_step1_genere.sh
```

**À vérifier :**
- Tous les tests passent
- Pas d'erreur de segmentation
- Les tailles sont correctes

---

### ÉTAPE 2 : Tests Aho-Corasick

#### Test 2.1 : Test manuel simple
```bash
# Créer un texte simple
echo -n "abcabcabc" > test_simple.txt

# Créer des mots
cat > mots_simple.txt << EOF
abc
ab
bc
EOF

# Tester
./ac-matrice mots_simple.txt test_simple.txt
./ac-hachage mots_simple.txt test_simple.txt
```

**Résultat attendu :** 9
- "abc" apparaît 3 fois (positions 0, 3, 6)
- "ab" apparaît 3 fois (positions 0, 3, 6)
- "bc" apparaît 3 fois (positions 1, 4, 7)

#### Test 2.2 : Test avec chevauchement
```bash
echo -n "aaaa" > test_overlap.txt
cat > mots_overlap.txt << EOF
aa
aaa
EOF

./ac-matrice mots_overlap.txt test_overlap.txt
./ac-hachage mots_overlap.txt test_overlap.txt
```

**Résultat attendu :** 5
- "aa" : positions 0, 1, 2 = 3 occurrences
- "aaa" : positions 0, 1 = 2 occurrences

#### Test 2.3 : Test avec fichiers du prof
```bash
# Vérifier que les fichiers existent
ls -lh data/mots.txt data/texte.txt

# Tester
./ac-matrice data/mots.txt data/texte.txt
./ac-hachage data/mots.txt data/texte.txt
```

**Résultat attendu :** 80 (pour les deux)

#### Test 2.4 : Test de cohérence
```bash
# Générer des données aléatoires
./genere-texte 10000 20 > test_random.txt
./genere-mots 50 5 10 20 > mots_random.txt

# Les deux méthodes doivent donner le même résultat
RESULT_M=$(./ac-matrice mots_random.txt test_random.txt)
RESULT_H=$(./ac-hachage mots_random.txt test_random.txt)

if [ "$RESULT_M" -eq "$RESULT_H" ]; then
    echo "OK: Résultats identiques ($RESULT_M)"
else
    echo "ERREUR: Résultats différents! M=$RESULT_M, H=$RESULT_H"
fi
```

#### Test 2.5 : Script automatique
```bash
chmod +x test_step2_ac.sh
./test_step2_ac.sh
```

---

### ÉTAPE 3 : Tests de Performance

#### Test 3.1 : Génération des données
```bash
# Créer le dossier
mkdir -p data

# Générer les textes (peut prendre quelques secondes)
echo "Génération des textes..."
./genere-texte 5000000 2 > data/texte_alpha2.txt
./genere-texte 5000000 4 > data/texte_alpha4.txt
./genere-texte 5000000 20 > data/texte_alpha20.txt
./genere-texte 5000000 70 > data/texte_alpha70.txt

# Vérifier les tailles
ls -lh data/texte_*.txt
# Chaque fichier doit faire environ 5 Mo
```

#### Test 3.2 : Génération des mots
```bash
# Pour chaque alphabet
for ALPHA in 2 4 20 70; do
    echo "Alphabet $ALPHA..."
    ./genere-mots 100 5 15 $ALPHA > data/mots_alpha${ALPHA}_5-15.txt
    ./genere-mots 100 15 30 $ALPHA > data/mots_alpha${ALPHA}_15-30.txt
    ./genere-mots 100 30 60 $ALPHA > data/mots_alpha${ALPHA}_30-60.txt
done

# Vérifier
ls -1 data/mots_*.txt | wc -l  # Doit afficher 12
```

#### Test 3.3 : Test de performance manuel
```bash
# Exemple avec alphabet 20, mots 5-15
echo "Test matrice..."
time ./ac-matrice data/mots_alpha20_5-15.txt data/texte_alpha20.txt

echo "Test hachage..."
time ./ac-hachage data/mots_alpha20_5-15.txt data/texte_alpha20.txt
```

**À observer :**
- Temps d'exécution (real)
- Nombre d'occurrences
- Différence entre matrice et hachage

#### Test 3.4 : Script automatique complet
```bash
chmod +x test_step3_perf.sh
./test_step3_perf.sh
```

Ce script :
1. Génère toutes les données
2. Lance tous les tests
3. Enregistre les résultats dans `resultats_perf.txt`

#### Test 3.5 : Analyse des résultats
```bash
# Afficher les résultats
column -t -s',' resultats_perf.txt

# Générer les graphiques (si Python disponible)
python3 plot_results.py
# Cela crée resultats_graphiques.png
```

---

## Tests de Validation Finale

### Test global
```bash
# Tout recompiler
make clean
make all

# Test avec fichiers du prof
./ac-matrice data/mots.txt data/texte.txt
./ac-hachage data/mots.txt data/texte.txt
# Les deux doivent afficher 80

# Si script.sh fourni par le prof
chmod +x script.sh
./script.sh
```

### Vérification de la soumission
```bash
# Vérifier les fichiers à soumettre
ls -la

# Doit contenir :
# - trie.h, trie_matrix.c, trie_hash.c
# - genere-texte.c, genere-mots.c
# - ac-matrice.c, ac-hachage.c
# - Makefile
# - README
# - rapport.pdf (à créer)

# NE DOIT PAS contenir :
# - Les exécutables
# - Les fichiers .o
# - Les fichiers de test
```

---

## Résolution de Problèmes

### Problème : Segmentation fault
```bash
# Vérifier avec valgrind
valgrind ./ac-matrice data/mots.txt data/texte.txt

# Causes fréquentes :
# - maxNode trop petit
# - Débordement de buffer
# - Accès hors limites
```

### Problème : Résultats différents matrice/hachage
```bash
# Déboguer avec un petit exemple
echo -n "abc" > debug.txt
echo "ab" > debug_mots.txt

./ac-matrice debug_mots.txt debug.txt
./ac-hachage debug_mots.txt debug.txt

# Vérifier la logique d'Aho-Corasick
```

### Problème : Temps trop longs
```bash
# Vérifier la complexité
# - Construction : O(somme longueurs mots)
# - Recherche : O(longueur texte + occurrences)

# Optimiser :
# - Compiler avec -O3
# - Vérifier les allocations inutiles
```

---

## Checklist Finale

- [ ] Compilation sans warnings
- [ ] genere-texte fonctionne correctement
- [ ] genere-mots fonctionne correctement
- [ ] ac-matrice donne 80 avec fichiers prof
- [ ] ac-hachage donne 80 avec fichiers prof
- [ ] Les deux méthodes donnent les mêmes résultats
- [ ] Tests de performance effectués
- [ ] Graphiques générés
- [ ] Rapport rédigé
- [ ] README complet
- [ ] Archive créée sans exécutables

```bash
# Créer l'archive finale
tar -czf tp3_nom_prenom.tar.gz \
    trie.h trie_matrix.c trie_hash.c \
    genere-texte.c genere-mots.c \
    ac-matrice.c ac-hachage.c \
    Makefile README rapport.pdf
```