#!/bin/bash

echo "=== TEST ETAPE 1: GENERATEURS ==="
echo ""

# Compilation
echo "1. Compilation..."
make genere-texte genere-mots
if [ $? -ne 0 ]; then
    echo "ERREUR: Compilation échouée"
    exit 1
fi
echo "OK"
echo ""

# Test génération de texte
echo "2. Test genere-texte..."

echo "  - Texte court (100 caractères, alphabet=4)"
./genere-texte 100 4 > test_texte_court.txt
SIZE=$(wc -c < test_texte_court.txt)
if [ $SIZE -eq 100 ]; then
    echo "    OK: Taille correcte ($SIZE)"
else
    echo "    ERREUR: Taille incorrecte ($SIZE au lieu de 100)"
fi

echo "  - Texte moyen (10000 caractères, alphabet=20)"
./genere-texte 10000 20 > test_texte_moyen.txt
SIZE=$(wc -c < test_texte_moyen.txt)
if [ $SIZE -eq 10000 ]; then
    echo "    OK: Taille correcte ($SIZE)"
else
    echo "    ERREUR: Taille incorrecte ($SIZE au lieu de 10000)"
fi

echo ""

# Test génération de mots
echo "3. Test genere-mots..."

echo "  - 10 mots, longueur 5-10, alphabet=4"
./genere-mots 10 5 10 4 > test_mots.txt
NB_MOTS=$(wc -l < test_mots.txt)
if [ $NB_MOTS -eq 10 ]; then
    echo "    OK: Nombre de mots correct ($NB_MOTS)"
else
    echo "    ERREUR: Nombre de mots incorrect ($NB_MOTS au lieu de 10)"
fi

echo "  - Vérification des longueurs..."
while read line; do
    LEN=${#line}
    if [ $LEN -lt 5 ] || [ $LEN -gt 10 ]; then
        echo "    ATTENTION: Mot de longueur $LEN (hors intervalle [5,10])"
    fi
done < test_mots.txt
echo "    OK"

echo ""
echo "  - 50 mots, longueur 15-30, alphabet=20"
./genere-mots 50 15 30 20 > test_mots_longs.txt
NB_MOTS=$(wc -l < test_mots_longs.txt)
if [ $NB_MOTS -eq 50 ]; then
    echo "    OK: Nombre de mots correct ($NB_MOTS)"
else
    echo "    ERREUR: Nombre de mots incorrect ($NB_MOTS au lieu de 50)"
fi

echo ""
echo "4. Affichage d'exemples..."
echo "  Premiers caractères du texte (alphabet=4):"
head -c 50 test_texte_court.txt | od -An -tx1
echo ""
echo "  Premiers mots générés:"
head -5 test_mots.txt
echo ""

# Nettoyage
rm -f test_texte_court.txt test_texte_moyen.txt test_mots.txt test_mots_longs.txt

echo "=== TEST ETAPE 1 TERMINE ==="