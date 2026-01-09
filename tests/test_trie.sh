#!/bin/bash

echo "=== TEST ETAPE 3: TESTS DE PERFORMANCE ==="
echo ""

# Vérifier que tout est compilé
echo "1. Compilation..."
make all
if [ $? -ne 0 ]; then
    echo "ERREUR: Compilation échouée"
    exit 1
fi
echo "OK"
echo ""

# Créer le dossier data s'il n'existe pas
mkdir -p data

# Générer les textes
echo "2. Génération des textes (5 000 000 caractères)..."
ALPHABETS=(2 4 20 70)

for ALPHA in "${ALPHABETS[@]}"; do
    echo "  - Alphabet taille $ALPHA..."
    ./genere-texte 5000000 $ALPHA > data/texte_alpha${ALPHA}.txt
    SIZE=$(wc -c < data/texte_alpha${ALPHA}.txt)
    echo "    Généré: $SIZE caractères"
done
echo ""

# Générer les ensembles de mots
echo "3. Génération des mots..."

WORD_SETS=(
    "100 5 15"
    "100 15 30"
    "100 30 60"
)

for ALPHA in "${ALPHABETS[@]}"; do
    echo "  - Pour alphabet $ALPHA:"
    
    for SET in "${WORD_SETS[@]}"; do
        read -r NB MIN MAX <<< "$SET"
        FILENAME="data/mots_alpha${ALPHA}_${MIN}-${MAX}.txt"
        ./genere-mots $NB $MIN $MAX $ALPHA > $FILENAME
        NB_LINES=$(wc -l < $FILENAME)
        echo "    Généré: $FILENAME ($NB_LINES mots, longueur $MIN-$MAX)"
    done
done
echo ""

# Tests de performance
echo "4. Tests de recherche (avec mesure du temps)..."
echo ""

# Fichier de résultats
RESULTS="resultats_perf.txt"
echo "Alphabet,Longueur_Mots,Methode,Temps_User,Temps_System,Temps_Total,Occurrences" > $RESULTS

for ALPHA in "${ALPHABETS[@]}"; do
    echo "=== Alphabet $ALPHA ==="
    
    for SET in "${WORD_SETS[@]}"; do
        read -r NB MIN MAX <<< "$SET"
        MOTS_FILE="data/mots_alpha${ALPHA}_${MIN}-${MAX}.txt"
        TEXTE_FILE="data/texte_alpha${ALPHA}.txt"
        
        echo "  Mots longueur $MIN-$MAX:"
        
        # Test ac-matrice
        echo -n "    ac-matrice... "
        TIME_OUTPUT=$( { time ./ac-matrice $MOTS_FILE $TEXTE_FILE > temp_result.txt ; } 2>&1 )
        RESULT=$(cat temp_result.txt)
        USER_TIME=$(echo "$TIME_OUTPUT" | grep real | awk '{print $2}')
        echo "Temps: $USER_TIME, Occurrences: $RESULT"
        echo "$ALPHA,$MIN-$MAX,matrice,$USER_TIME,,$USER_TIME,$RESULT" >> $RESULTS
        
        # Test ac-hachage
        echo -n "    ac-hachage... "
        TIME_OUTPUT=$( { time ./ac-hachage $MOTS_FILE $TEXTE_FILE > temp_result.txt ; } 2>&1 )
        RESULT=$(cat temp_result.txt)
        USER_TIME=$(echo "$TIME_OUTPUT" | grep real | awk '{print $2}')
        echo "Temps: $USER_TIME, Occurrences: $RESULT"
        echo "$ALPHA,$MIN-$MAX,hachage,$USER_TIME,,$USER_TIME,$RESULT" >> $RESULTS
    done
    echo ""
done

rm -f temp_result.txt

echo "5. Résumé des résultats..."
echo ""
column -t -s',' $RESULTS
echo ""
echo "Résultats sauvegardés dans: $RESULTS"
echo ""

echo "=== TEST ETAPE 3 TERMINE ==="
echo ""
echo "Vous pouvez maintenant:"
echo "  - Analyser les résultats dans $RESULTS"
echo "  - Créer des graphiques avec ces données"
echo "  - Comparer les performances matrice vs hachage"