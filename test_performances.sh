#!/bin/bash

# Script de tests de performance pour Aho-Corasick
# Génère des textes et mots, puis mesure les temps d'exécution

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DATA_DIR="test_performances_data"
CSV_FILE="resultats_performances.csv"
TEXTE_LENGTH=5000000
ALPHABETS=(2 4 20 70)
MOT_RANGES=("5 15" "15 30" "30 60")
NB_MOTS=100

echo -e "${GREEN}=== Tests de performance Aho-Corasick ===${NC}\n"

# Créer le dossier de données
echo -e "${YELLOW}Création du dossier de données...${NC}"
mkdir -p "$DATA_DIR"

# Initialiser le fichier CSV
echo "alphabet,longueur_mots,implementation,temps_execution,nb_occurrences" > "$CSV_FILE"
echo -e "${GREEN}✓ Fichier CSV initialisé${NC}\n"

# Vérifier que les exécutables existent
for prog in genere-texte genere-mots ac-matrice ac-hachage; do
    if [ ! -f "./$prog" ]; then
        echo -e "${RED}Erreur: $prog n'existe pas. Exécutez 'make all' d'abord.${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✓ Tous les exécutables sont présents${NC}\n"

# Fonction pour mesurer le temps d'exécution
measure_time() {
    local command=$1
    local start=$(date +%s.%N)
    local output=$($command)
    local end=$(date +%s.%N)
    local duration=$(awk "BEGIN {print $end - $start}")
    echo "$duration|$output"
}

# Étape 1: Génération des textes
echo -e "${YELLOW}=== Étape 1: Génération des textes ===${NC}"
for alpha in "${ALPHABETS[@]}"; do
    texte_file="$DATA_DIR/texte_alpha${alpha}.txt"
    echo -n "  Génération texte (alphabet=$alpha, longueur=$TEXTE_LENGTH)... "
    ./genere-texte $TEXTE_LENGTH $alpha > "$texte_file"
    echo -e "${GREEN}✓${NC}"
done
echo ""

# Étape 2: Génération des mots
echo -e "${YELLOW}=== Étape 2: Génération des ensembles de mots ===${NC}"
for alpha in "${ALPHABETS[@]}"; do
    echo "  Alphabet $alpha:"
    for range in "${MOT_RANGES[@]}"; do
        read -r min_len max_len <<< "$range"
        mots_file="$DATA_DIR/mots_alpha${alpha}_len${min_len}-${max_len}.txt"
        echo -n "    Mots longueur $min_len-$max_len... "
        ./genere-mots $NB_MOTS $min_len $max_len $alpha > "$mots_file"
        echo -e "${GREEN}✓${NC}"
    done
done
echo ""

# Étape 3: Tests de performance
echo -e "${YELLOW}=== Étape 3: Tests de performance ===${NC}"
total_tests=$((${#ALPHABETS[@]} * ${#MOT_RANGES[@]} * 2))
current_test=0

for alpha in "${ALPHABETS[@]}"; do
    texte_file="$DATA_DIR/texte_alpha${alpha}.txt"
    
    for range in "${MOT_RANGES[@]}"; do
        read -r min_len max_len <<< "$range"
        mots_file="$DATA_DIR/mots_alpha${alpha}_len${min_len}-${max_len}.txt"
        longueur_label="${min_len}-${max_len}"
        
        # Test avec ac-matrice
        current_test=$((current_test + 1))
        echo -n "  [$current_test/$total_tests] Alpha=$alpha, Longueur=$longueur_label, Matrice... "
        result=$(measure_time "./ac-matrice $mots_file $texte_file")
        temps=$(echo "$result" | cut -d'|' -f1)
        occurrences=$(echo "$result" | cut -d'|' -f2)
        echo "$alpha,$longueur_label,matrice,$temps,$occurrences" >> "$CSV_FILE"
        echo -e "${GREEN}✓${NC} (${temps}s, $occurrences occ.)"
        
        # Test avec ac-hachage
        current_test=$((current_test + 1))
        echo -n "  [$current_test/$total_tests] Alpha=$alpha, Longueur=$longueur_label, Hachage... "
        result=$(measure_time "./ac-hachage $mots_file $texte_file")
        temps=$(echo "$result" | cut -d'|' -f1)
        occurrences=$(echo "$result" | cut -d'|' -f2)
        echo "$alpha,$longueur_label,hachage,$temps,$occurrences" >> "$CSV_FILE"
        echo -e "${GREEN}✓${NC} (${temps}s, $occurrences occ.)"
    done
    echo ""
done

echo -e "${GREEN}=== Tests terminés ===${NC}"
echo -e "Résultats sauvegardés dans: ${YELLOW}$CSV_FILE${NC}"
echo -e "Données générées dans: ${YELLOW}$DATA_DIR/${NC}"
echo ""
echo -e "${YELLOW}Pour visualiser les résultats, exécutez:${NC}"
echo -e "  python3 plot_performances.py"