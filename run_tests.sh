#!/bin/bash

# ==========================================
# TP3 - Tests automatiques Questions 4 à 7
# Algorithme d'Aho-Corasick
# ==========================================

echo "=========================================="
echo "TP3 - Tests automatiques Questions 4-7"
echo "Algorithme d'Aho-Corasick"
echo "=========================================="
echo ""

# =============================
# [1/4] Création des dossiers
# =============================
echo "[1/4] Création des dossiers..."
mkdir -p data/textes data/mots resultats
echo "✓ Dossiers créés"
echo ""

# =============================
# Vérifications
# =============================
for exe in ac-matrice ac-hachage; do
    if [ ! -x "./$exe" ]; then
        echo "ERREUR: $exe introuvable ou non exécutable"
        exit 1
    fi
done

if ! command -v time >/dev/null 2>&1; then
    echo "ERREUR: commande time absente"
    exit 1
fi

echo "✓ Exécutables vérifiés"
echo ""

# =============================
# [2/4] Vérif fichiers d'entrée
# =============================
echo "[2/4] Vérification des fichiers d'entrée..."

missing=0
for alpha in 2 4 20 70; do
    texte="data/textes/texte_${alpha}.txt"
    if [ ! -f "$texte" ]; then
        echo "  ⚠ Fichier manquant: $texte"
        missing=1
    fi
    for taille in "5-15" "15-30" "30-60"; do
        mots="data/mots/mots_${alpha}_${taille}.txt"
        if [ ! -f "$mots" ]; then
            echo "  ⚠ Fichier manquant: $mots"
            missing=1
        fi
    done
done

if [ $missing -ne 0 ]; then
    echo "ERREUR: certains fichiers d'entrée sont manquants."
    exit 1
fi

echo "✓ Fichiers d'entrée présents"
echo ""

# =============================
# [3/4] Tests
# =============================
echo "[3/4] Exécution des tests..."
echo ""

RESULT_FILE="resultats/resultats.csv"
echo "Alphabet,Taille_Mots,Implementation,Occurrences,Temps_Reel_sec,Temps_User_sec,Temps_Sys_sec" > "$RESULT_FILE"

total_tests=24
current_test=0

for alpha in 2 4 20 70; do
    for taille in "5-15" "15-30" "30-60"; do

        mots="data/mots/mots_${alpha}_${taille}.txt"
        texte="data/textes/texte_${alpha}.txt"

        for impl in matrice hachage; do
            current_test=$((current_test + 1))
            exe="./ac-$impl"

            echo "  [$current_test/$total_tests] $exe | alpha=$alpha | mots=$taille"

            # On capture TOUTE la sortie (stdout + stderr) + le code de retour
            output=$(
                command time -f "%e %U %S" "$exe" "$mots" "$texte" 2>&1
            )
            exit_code=$?

            if [ $exit_code -ne 0 ]; then
                echo "    ⚠ ERREUR ($exe), code=$exit_code — test ignoré"
                echo "$output" | sed 's/^/      /'
                echo "$alpha,$taille,$impl,ERREUR,NA,NA,NA" >> "$RESULT_FILE"
                continue
            fi

            # Première ligne: occurrences, dernière ligne: temps
            occurrences=$(echo "$output" | head -n 1)
            temps=$(echo "$output" | tail -n 1)
            read -r t_real t_user t_sys <<< "$temps"

            echo "$alpha,$taille,$impl,$occurrences,$t_real,$t_user,$t_sys" >> "$RESULT_FILE"
        done

        echo ""
    done
done

echo "✓ Tests terminés"
echo ""

# =============================
# [4/4] Résumé
# =============================
echo "[4/4] Génération du résumé..."

SUMMARY_FILE="resultats/resume.txt"

{
echo "========================================"
echo "TP3 - Résumé des performances"
echo "========================================"
echo ""

for impl in matrice hachage; do
    echo "Implémentation : $impl"
    echo "----------------------------------------"

    for alpha in 2 4 20 70; do
        echo ""
        echo "Alphabet $alpha"
        printf "%-12s | %-12s | %-12s\n" "Taille" "Temps (ms)" "Occ"
        echo "----------------------------------------"

        for taille in "5-15" "15-30" "30-60"; do
            ligne=$(grep "^$alpha,$taille,$impl," "$RESULT_FILE")

            if echo "$ligne" | grep -q "ERREUR"; then
                printf "%-12s | %-12s | %-12s\n" "$taille" "ERREUR" "ERREUR"
                continue
            fi

            t=$(echo "$ligne" | cut -d',' -f5)
            occ=$(echo "$ligne" | cut -d',' -f4)
            ms=$(awk "BEGIN { printf \"%.2f\", $t * 1000 }")
            printf "%-12s | %-12s | %-12s\n" "$taille" "$ms" "$occ"
        done
    done
    echo ""
done
} > "$SUMMARY_FILE"

echo "✓ Résumé généré"
echo ""
cat "$SUMMARY_FILE"

echo ""
echo "=========================================="
echo "TP3 TERMINÉ AVEC SUCCÈS"
echo "=========================================="
