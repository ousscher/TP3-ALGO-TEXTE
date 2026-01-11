#!/bin/bash

# Dossier pour les données temporaires
DATA_DIR="test_performances_data"

# Créer le dossier s'il n'existe pas
mkdir -p "$DATA_DIR"

# Compilation
echo "Compilation des programmes..."
# gcc -O2 -o genere-mots genere-mots.c
# gcc -O2 -o genere-texte genere-texte.c
# gcc -O2 -o ac-matrice ac-matrice.c trie_matrix.c
# gcc -O2 -o ac-hachage ac-hachage.c trie_hash.c
make clean
make all

if [ $? -ne 0 ]; then
    echo "Erreur de compilation!"
    exit 1
fi

echo "Compilation réussie!"
echo ""

# Créer le fichier CSV
echo "alphabet,longueur_mots,implementation,temps_execution,nb_occurrences" > resultats.csv

# Paramètres de test
ALPHABETS=(2 4 20 70)
WORD_RANGES=("5-15" "15-30" "30-60")
NB_MOTS=100
TEXT_LENGTH=1000000  # 1 million de caractères

echo "Début des tests..."
echo "Paramètres: $NB_MOTS mots, texte de $TEXT_LENGTH caractères"
echo ""

for ALPHABET in "${ALPHABETS[@]}"; do
    for RANGE in "${WORD_RANGES[@]}"; do

        IFS='-' read -ra LIMITS <<< "$RANGE"
        MIN_LEN=${LIMITS[0]}
        MAX_LEN=${LIMITS[1]}

        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Test: alphabet=$ALPHABET, longueur=$RANGE"

        PREFIX="test_${ALPHABET}_${RANGE}"
        WORDS_FILE="$DATA_DIR/${PREFIX}_words.txt"
        TEXT_FILE="$DATA_DIR/${PREFIX}_text.txt"

        echo "  Génération des mots..."
        ./genere-mots $NB_MOTS $MIN_LEN $MAX_LEN $ALPHABET > "$WORDS_FILE"

        if [ ! -s "$WORDS_FILE" ]; then
            echo "  ERREUR: fichier mots vide!"
            continue
        fi

        echo "  Génération du texte..."
        ./genere-texte $TEXT_LENGTH $ALPHABET > "$TEXT_FILE"

        if [ ! -s "$TEXT_FILE" ]; then
            echo "  ERREUR: fichier texte vide!"
            continue
        fi

        ACTUAL_SIZE=$(wc -c < "$TEXT_FILE")
        echo "  Taille texte: $ACTUAL_SIZE caractères"

        # Test matrice
        echo -n "  Test matrice... "
        START=$(date +%s.%N)
        RESULT_MATRICE=$(./ac-matrice "$WORDS_FILE" "$TEXT_FILE" 2>/dev/null)
        END=$(date +%s.%N)
        TIME_MATRICE=$(awk "BEGIN {print $END - $START}")

        echo "${TIME_MATRICE}s → $RESULT_MATRICE occurrences"
        echo "$ALPHABET,$RANGE,matrice,$TIME_MATRICE,$RESULT_MATRICE" >> resultats.csv

        # Test hachage
        echo -n "  Test hachage... "
        START=$(date +%s.%N)
        RESULT_HACHAGE=$(./ac-hachage "$WORDS_FILE" "$TEXT_FILE" 2>/dev/null)
        END=$(date +%s.%N)
        TIME_HACHAGE=$(awk "BEGIN {print $END - $START}")

        echo "${TIME_HACHAGE}s → $RESULT_HACHAGE occurrences"
        echo "$ALPHABET,$RANGE,hachage,$TIME_HACHAGE,$RESULT_HACHAGE" >> resultats.csv

        if [ "$RESULT_MATRICE" != "$RESULT_HACHAGE" ]; then
            echo "  ⚠️  ERREUR: résultats différents!"
        else
            echo "  ✓ Résultats cohérents"
        fi

        if (( $(echo "$TIME_MATRICE > 0" | bc -l) )); then
            SPEEDUP=$(awk "BEGIN {printf \"%.2f\", $TIME_HACHAGE / $TIME_MATRICE}")
            echo "  Speedup matrice: ${SPEEDUP}x"
        fi

        echo ""
        sleep 0.1
    done
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Tests terminés! Résultats dans resultats.csv"
echo ""

# Résumé
echo "=== RÉSUMÉ ==="
printf "%-10s %-15s %-12s %-12s %-12s\n" "Alphabet" "Longueur" "Impl." "Temps(s)" "Occur."
echo "────────────────────────────────────────────────────────────"

tail -n +2 resultats.csv | while IFS=, read -r alpha len impl temps occ; do
    printf "%-10s %-15s %-12s %-12s %-12s\n" "$alpha" "$len" "$impl" "$temps" "$occ"
done

echo ""

# Analyse
echo "=== ANALYSE ==="
AVG_MAT=$(tail -n +2 resultats.csv | grep matrice | awk -F, '{sum+=$4; c++} END {if(c) printf "%.4f", sum/c; else print 0}')
AVG_HASH=$(tail -n +2 resultats.csv | grep hachage | awk -F, '{sum+=$4; c++} END {if(c) printf "%.4f", sum/c; else print 0}')

echo "Temps moyen matrice:  ${AVG_MAT}s"
echo "Temps moyen hachage:  ${AVG_HASH}s"

if (( $(echo "$AVG_MAT > 0" | bc -l) )); then
    RATIO=$(awk "BEGIN {printf \"%.2f\", $AVG_HASH / $AVG_MAT}")
    echo "Ratio: matrice est ${RATIO}x plus rapide en moyenne"
fi


mkdir -p graphiques

# Run Python script from venv
./venv/bin/python script.py