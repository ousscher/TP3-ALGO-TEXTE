#!/usr/bin/env python3
"""
Script de génération des graphiques - TP3
Adapté aux données réelles fournies
"""

import pandas as pd
import matplotlib.pyplot as plt
import os

# ===================== CONFIG =====================
plt.style.use('seaborn-v0_8-darkgrid')
plt.rcParams.update({
    'font.size': 11,
    'axes.titlesize': 14,
    'axes.labelsize': 12,
    'legend.fontsize': 11,
    'lines.linewidth': 2.5,
    'lines.markersize': 8
})

os.makedirs('resultats/graphiques', exist_ok=True)

# ===================== CHARGEMENT =====================
print("[1/5] Chargement des données...")
df = pd.read_csv('resultats.csv')

# Conversion secondes → millisecondes
df['Temps_ms'] = df['temps_execution'] * 1000

print(f"✓ {len(df)} lignes chargées\n")

alphabets = [2, 4, 20, 70]
tailles = ['5-15', '15-30', '30-60']

# =====================================================
# GRAPHIQUE 1 : Temps vs Alphabet
# =====================================================
print("[2/5] Graphique 1 : Temps vs Alphabet")

moyennes = (
    df.groupby(['alphabet', 'implementation'])['Temps_ms']
    .mean()
    .unstack()
    .fillna(0)
)

fig, ax = plt.subplots(figsize=(12, 7))

ax.plot(moyennes.index, moyennes['matrice'], marker='o', label='Matrice')
ax.plot(moyennes.index, moyennes['hachage'], marker='s', label='Hachage')

ax.set_xlabel("Taille de l'alphabet")
ax.set_ylabel("Temps moyen (ms)")
ax.set_title("Temps d'exécution vs Taille de l'alphabet")
ax.legend()
ax.grid(True)

plt.tight_layout()
plt.savefig("resultats/graphiques/1_temps_vs_alphabet.png", dpi=300)
plt.close()
print("✓ Sauvegardé\n")

# =====================================================
# GRAPHIQUE 2 : Temps vs Taille des mots (4 sous-graphes)
# =====================================================
print("[3/5] Graphique 2 : Temps vs Taille des mots")

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Influence de la taille des mots", fontsize=16, fontweight='bold')

for i, alpha in enumerate(alphabets):
    ax = axes[i // 2, i % 2]
    sub = df[df['alphabet'] == alpha]

    grouped = (
        sub.groupby(['longueur_mots', 'implementation'])['Temps_ms']
        .mean()
        .unstack()
        .fillna(0)
    )

    ax.plot(grouped.index, grouped['matrice'], marker='o', label='Matrice')
    ax.plot(grouped.index, grouped['hachage'], marker='s', label='Hachage')

    ax.set_title(f'Alphabet {alpha}')
    ax.set_xlabel("Taille des mots")
    ax.set_ylabel("Temps (ms)")
    ax.legend()
    ax.grid(True)

plt.tight_layout()
plt.savefig("resultats/graphiques/2_temps_vs_taille_mots.png", dpi=300)
plt.close()
print("✓ Sauvegardé\n")

# =====================================================
# GRAPHIQUE 3 : Tableau récapitulatif
# =====================================================
print("[4/5] Graphique 3 : Tableau récapitulatif")

fig, ax = plt.subplots(figsize=(14, 6))
ax.axis('off')

table_data = [
    ['Alphabet', 'Implémentation', 'Temps moyen (ms)', 'Min (ms)', 'Max (ms)', 'Occurrences moy.']
]

for alpha in alphabets:
    for impl in ['matrice', 'hachage']:
        d = df[(df['alphabet'] == alpha) & (df['implementation'] == impl)]
        table_data.append([
            alpha if impl == 'matrice' else '',
            impl.capitalize(),
            f"{d['Temps_ms'].mean():.2f}",
            f"{d['Temps_ms'].min():.2f}",
            f"{d['Temps_ms'].max():.2f}",
            f"{d['nb_occurrences'].mean():.0f}"
        ])

table = ax.table(cellText=table_data, loc='center', cellLoc='center')
table.scale(1, 2)
table.auto_set_font_size(False)
table.set_fontsize(11)

plt.title("Tableau récapitulatif des performances", fontsize=16, fontweight='bold')
plt.savefig("resultats/graphiques/3_tableau_recapitulatif.png", dpi=300)
plt.close()
print("✓ Sauvegardé\n")

# =====================================================
# GRAPHIQUE 4 : Vue globale (points)
# =====================================================
print("[5/5] Graphique 4 : Vue globale")

fig, ax = plt.subplots(figsize=(14, 8))

x = []
y = []
colors = []
labels = []

pos = 0
for alpha in alphabets:
    for taille in tailles:
        for impl, c in [('matrice', 'blue'), ('hachage', 'red')]:
            row = df[
                (df['alphabet'] == alpha) &
                (df['longueur_mots'] == taille) &
                (df['implementation'] == impl)
            ]
            if not row.empty:
                x.append(pos)
                y.append(row['Temps_ms'].values[0])
                colors.append(c)
                labels.append(f"α{alpha}-{taille}-{impl}")
        pos += 1
    pos += 1  # espace entre alphabets

ax.scatter(x, y, c=colors, s=120, edgecolors='black')
ax.set_ylabel("Temps (ms)")
ax.set_title("Vue globale des performances")
ax.grid(True)

plt.tight_layout()
plt.savefig("resultats/graphiques/4_vue_globale.png", dpi=300)
plt.close()
print("✓ Sauvegardé\n")

print("=== GÉNÉRATION TERMINÉE AVEC SUCCÈS ===")
