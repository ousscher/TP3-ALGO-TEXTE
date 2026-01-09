#!/bin/bash

echo "=== TEST ETAPE 2: AHO-CORASICK ==="
echo ""

# Compilation
echo "1. Compilation..."
make ac-matrice ac-hachage
if [ $? -ne 0 ]; then
    echo "ERREUR: Compilation échouée"
    exit 1
fi
echo "OK"
echo ""

# Test simple
echo "2. Test simple avec mots connus..."

# Créer un texte de test simple
echo -n "abcabcabc" > test_texte_simple.txt

# Créer des mots de test
cat > test_mots_simple.txt << EOF
abc
ab
bc
EOF

echo "  Texte: abcabcabc"
echo "  Mots: abc, ab, bc"
echo "  Occurrences attendues: abc=3, ab=3, bc=3 => Total=9"
echo ""

echo "  - Test ac-matrice:"
RESULT_M=$(./ac-matrice test_mots_simple.txt test_texte_simple.txt)
echo "    Résultat: $RESULT_M"
if [ "$RESULT_M" -eq 9 ]; then
    echo "    OK"
else
    echo "    ERREUR: Attendu 9"
fi

echo "  - Test ac-hachage:"
RESULT_H=$(./ac-hachage test_mots_simple.txt test_texte_simple.txt)
echo "    Résultat: $RESULT_H"
if [ "$RESULT_H" -eq 9 ]; then
    echo "    OK"
else
    echo "    ERREUR: Attendu 9"
fi

echo ""

# Test avec les fichiers du prof
echo "3. Test avec les fichiers fournis par le prof..."
if [ -f "data/mots.txt" ] && [ -f "data/texte.txt" ]; then
    echo "  - Test ac-matrice:"
    RESULT_M=$(./ac-matrice data/mots.txt data/texte.txt)
    echo "    Résultat: $RESULT_M"
    if [ "$RESULT_M" -eq 80 ]; then
        echo "    OK: Résultat attendu (80)"
    else
        echo "    ATTENTION: Résultat différent de 80"
    fi
    
    echo "  - Test ac-hachage:"
    RESULT_H=$(./ac-hachage data/mots.txt data/texte.txt)
    echo "    Résultat: $RESULT_H"
    if [ "$RESULT_H" -eq 80 ]; then
        echo "    OK: Résultat attendu (80)"
    else
        echo "    ATTENTION: Résultat différent de 80"
    fi
    
    if [ "$RESULT_M" -eq "$RESULT_H" ]; then
        echo "  - Les deux versions donnent le même résultat: OK"
    else
        echo "  - ERREUR: Les deux versions donnent des résultats différents!"
    fi
else
    echo "  ATTENTION: Fichiers data/mots.txt et data/texte.txt non trouvés"
    echo "  Placez-les dans le dossier data/"
fi

echo ""

# Test avec chevauchement
echo "4. Test avec motifs qui se chevauchent..."
echo -n "aaaa" > test_texte_overlap.txt
cat > test_mots_overlap.txt << EOF
aa
aaa
EOF

echo "  Texte: aaaa"
echo "  Mots: aa, aaa"
echo "  Occurrences: aa apparaît 3 fois (pos 0,1,2), aaa apparaît 2 fois (pos 0,1) => Total=5"
echo ""

RESULT_M=$(./ac-matrice test_mots_overlap.txt test_texte_overlap.txt)
echo "  - ac-matrice: $RESULT_M"
if [ "$RESULT_M" -eq 5 ]; then
    echo "    OK"
else
    echo "    ERREUR: Attendu 5"
fi

RESULT_H=$(./ac-hachage test_mots_overlap.txt test_texte_overlap.txt)
echo "  - ac-hachage: $RESULT_H"
if [ "$RESULT_H" -eq 5 ]; then
    echo "    OK"
else
    echo "    ERREUR: Attendu 5"
fi

# Nettoyage
rm -f test_texte_simple.txt test_mots_simple.txt
rm -f test_texte_overlap.txt test_mots_overlap.txt

echo ""
echo "=== TEST ETAPE 2 TERMINE ==="