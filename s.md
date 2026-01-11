NB_MOTS=100              # Fixe
TEXT_LENGTH=5000000      # Fixe (5 millions)
ALPHABETS=(2 4 20 70)    # Variable
WORD_RANGES=("5-15" "15-30" "30-60")  # Variable
```

## 🎯 Ce qui Change vs Ce qui est Fixe

| Paramètre | Statut | Impact |
|-----------|--------|--------|
| Nombre de mots | **FIXE** (100) | - |
| Longueur texte | **FIXE** (5M) | - |
| Taille alphabet | **VARIABLE** | Change densité |
| Longueur mots | **VARIABLE** | Change structure trie |

## 🧮 Analyse Théorique

### 1. **Longueur Totale du Trie (L)**

Avec 100 mots :
- Range "5-15" : L ≈ 100 × 10 = **1000 caractères**
- Range "15-30" : L ≈ 100 × 22.5 = **2250 caractères**
- Range "30-60" : L ≈ 100 × 45 = **4500 caractères**

⚠️ **L augmente avec la longueur des mots !**

### 2. **Construction du Trie**

**Complexité** : O(L)
```
Temps construction ∝ L ∝ longueur_moyenne
```

✅ **C'EST NORMAL que le temps augmente avec la longueur des mots !**

### 3. **Recherche dans le Texte**

**Complexité** : O(T + occurrences) où T = 5M (fixe)
```
Temps recherche ≈ constant (si occurrences similaires)
```

### 4. **Temps Total Mesuré**
```
Temps total = Construction + Recherche
            = O(L) + O(T)
            = O(L) + constante
```

**Donc le temps DOIT augmenter avec la longueur des mots !**

## ✅ Le Graphique est CORRECT !

### Pourquoi le Hachage Croît Linéairement :
```
Longueur mots ↑ → L ↑ → Temps construction ↑ → Temps total ↑