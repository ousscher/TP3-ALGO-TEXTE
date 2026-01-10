#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script de visualisation des performances d'Aho-Corasick
Lit le fichier CSV généré et trace des courbes de comparaison
"""

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import sys
import os

# Configuration de style
sns.set_theme(style="whitegrid")
plt.rcParams['figure.figsize'] = (14, 10)
plt.rcParams['font.size'] = 10

# Fichier CSV à lire
CSV_FILE = "resultats_performances.csv"
OUTPUT_DIR = "graphiques"

def load_data():
    """Charge les données depuis le CSV"""
    if not os.path.exists(CSV_FILE):
        print(f"❌ Erreur: Le fichier {CSV_FILE} n'existe pas.")
        print(f"Exécutez d'abord: ./test_performances.sh")
        sys.exit(1)
    
    df = pd.read_csv(CSV_FILE)
    print(f"✓ Données chargées: {len(df)} mesures")
    print(f"\nAperçu des données:")
    print(df.head())
    print(f"\nStatistiques descriptives:")
    print(df.groupby(['implementation', 'alphabet'])['temps_execution'].describe())
    return df

def create_output_dir():
    """Crée le dossier de sortie pour les graphiques"""
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)
        print(f"\n✓ Dossier {OUTPUT_DIR}/ créé")

def plot_comparison_by_alphabet(df):
    """Compare les temps d'exécution Matrice vs Hachage par taille d'alphabet"""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Comparaison Matrice vs Hachage selon la taille d\'alphabet', 
                 fontsize=16, fontweight='bold')
    
    alphabets = sorted(df['alphabet'].unique())
    
    for idx, alpha in enumerate(alphabets):
        ax = axes[idx // 2, idx % 2]
        data = df[df['alphabet'] == alpha]
        
        # Grouper par longueur de mots et implémentation
        pivot = data.pivot_table(
            values='temps_execution', 
            index='longueur_mots', 
            columns='implementation'
        )
        
        pivot.plot(kind='bar', ax=ax, width=0.7)
        ax.set_title(f'Alphabet de taille {alpha}', fontsize=12, fontweight='bold')
        ax.set_xlabel('Longueur des mots')
        ax.set_ylabel('Temps d\'exécution (s)')
        ax.legend(title='Implémentation', loc='upper left')
        ax.grid(True, alpha=0.3)
        ax.tick_params(axis='x', rotation=0)
    
    plt.tight_layout()
    filename = f"{OUTPUT_DIR}/comparaison_par_alphabet.png"
    plt.savefig(filename, dpi=300, bbox_inches='tight')
    print(f"✓ Graphique sauvegardé: {filename}")
    plt.close()

def plot_scalability_alphabet(df):
    """Montre l'évolution du temps selon la taille de l'alphabet"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    fig.suptitle('Scalabilité selon la taille de l\'alphabet', 
                 fontsize=16, fontweight='bold')
    
    for idx, impl in enumerate(['matrice', 'hachage']):
        ax = axes[idx]
        data = df[df['implementation'] == impl]
        
        for longueur in data['longueur_mots'].unique():
            subset = data[data['longueur_mots'] == longueur]
            subset = subset.sort_values('alphabet')
            ax.plot(subset['alphabet'], subset['temps_execution'], 
                   marker='o', linewidth=2, markersize=8, label=f'Mots {longueur}')
        
        ax.set_title(f'Implémentation: {impl.capitalize()}', 
                    fontsize=12, fontweight='bold')
        ax.set_xlabel('Taille de l\'alphabet')
        ax.set_ylabel('Temps d\'exécution (s)')
        ax.legend(title='Longueur mots')
        ax.grid(True, alpha=0.3)
        ax.set_xticks(sorted(df['alphabet'].unique()))
    
    plt.tight_layout()
    filename = f"{OUTPUT_DIR}/scalabilite_alphabet.png"
    plt.savefig(filename, dpi=300, bbox_inches='tight')
    print(f"✓ Graphique sauvegardé: {filename}")
    plt.close()

def plot_word_length_impact(df):
    """Montre l'impact de la longueur des mots"""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Impact de la longueur des mots sur les performances', 
                 fontsize=16, fontweight='bold')
    
    alphabets = sorted(df['alphabet'].unique())
    
    for idx, alpha in enumerate(alphabets):
        ax = axes[idx // 2, idx % 2]
        data = df[df['alphabet'] == alpha]
        
        # Convertir longueur_mots en valeur numérique (moyenne)
        data = data.copy()
        data['longueur_moyenne'] = data['longueur_mots'].apply(
            lambda x: sum(map(int, x.split('-'))) / 2
        )
        
        for impl in ['matrice', 'hachage']:
            subset = data[data['implementation'] == impl]
            subset = subset.sort_values('longueur_moyenne')
            ax.plot(subset['longueur_moyenne'], subset['temps_execution'], 
                   marker='o', linewidth=2, markersize=8, label=impl.capitalize())
        
        ax.set_title(f'Alphabet de taille {alpha}', fontsize=12, fontweight='bold')
        ax.set_xlabel('Longueur moyenne des mots')
        ax.set_ylabel('Temps d\'exécution (s)')
        ax.legend(title='Implémentation')
        ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    filename = f"{OUTPUT_DIR}/impact_longueur_mots.png"
    plt.savefig(filename, dpi=300, bbox_inches='tight')
    print(f"✓ Graphique sauvegardé: {filename}")
    plt.close()

def plot_heatmap_comparison(df):
    """Heatmap pour comparer les deux implémentations"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    fig.suptitle('Cartes de chaleur des temps d\'exécution', 
                 fontsize=16, fontweight='bold')
    
    for idx, impl in enumerate(['matrice', 'hachage']):
        ax = axes[idx]
        data = df[df['implementation'] == impl]
        
        pivot = data.pivot_table(
            values='temps_execution',
            index='alphabet',
            columns='longueur_mots'
        )
        
        sns.heatmap(pivot, annot=True, fmt='.3f', cmap='YlOrRd', 
                   ax=ax, cbar_kws={'label': 'Temps (s)'})
        ax.set_title(f'Implémentation: {impl.capitalize()}', 
                    fontsize=12, fontweight='bold')
        ax.set_xlabel('Longueur des mots')
        ax.set_ylabel('Taille de l\'alphabet')
    
    plt.tight_layout()
    filename = f"{OUTPUT_DIR}/heatmap_comparaison.png"
    plt.savefig(filename, dpi=300, bbox_inches='tight')
    print(f"✓ Graphique sauvegardé: {filename}")
    plt.close()

def plot_speedup_ratio(df):
    """Calcule et affiche le ratio de speedup (matrice vs hachage)"""
    fig, ax = plt.subplots(figsize=(12, 6))
    
    # Pivoter pour avoir matrice et hachage côte à côte
    df_pivot = df.pivot_table(
        values='temps_execution',
        index=['alphabet', 'longueur_mots'],
        columns='implementation'
    ).reset_index()
    
    # Calculer le ratio speedup (temps_hachage / temps_matrice)
    df_pivot['speedup'] = df_pivot['hachage'] / df_pivot['matrice']
    
    # Créer des labels pour l'axe x
    df_pivot['label'] = df_pivot['alphabet'].astype(str) + '\n' + df_pivot['longueur_mots']
    
    colors = ['green' if x > 1 else 'red' for x in df_pivot['speedup']]
    bars = ax.bar(range(len(df_pivot)), df_pivot['speedup'], color=colors, alpha=0.7)
    
    # Ligne horizontale à y=1 (performances égales)
    ax.axhline(y=1, color='black', linestyle='--', linewidth=2, label='Performances égales')
    
    ax.set_xlabel('Alphabet / Longueur mots')
    ax.set_ylabel('Ratio (Hachage / Matrice)')
    ax.set_title('Speedup: Matrice vs Hachage\n(>1 = Matrice plus rapide, <1 = Hachage plus rapide)', 
                fontsize=14, fontweight='bold')
    ax.set_xticks(range(len(df_pivot)))
    ax.set_xticklabels(df_pivot['label'], fontsize=8)
    ax.legend()
    ax.grid(True, alpha=0.3, axis='y')
    
    # Annoter les barres avec les valeurs
    for i, (bar, val) in enumerate(zip(bars, df_pivot['speedup'])):
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height,
               f'{val:.2f}x', ha='center', va='bottom', fontsize=8)
    
    plt.tight_layout()
    filename = f"{OUTPUT_DIR}/speedup_ratio.png"
    plt.savefig(filename, dpi=300, bbox_inches='tight')
    print(f"✓ Graphique sauvegardé: {filename}")
    plt.close()

def plot_occurrences(df):
    """Affiche le nombre d'occurrences trouvées"""
    fig, ax = plt.subplots(figsize=(12, 6))
    
    # Vérifier que matrice et hachage donnent les mêmes résultats
    df_check = df.pivot_table(
        values='nb_occurrences',
        index=['alphabet', 'longueur_mots'],
        columns='implementation'
    )
    
    if (df_check['matrice'] == df_check['hachage']).all():
        print("\n✓ Validation: Matrice et Hachage donnent le même nombre d'occurrences")
    else:
        print("\n⚠ Attention: Différence détectée entre Matrice et Hachage!")
    
    # Prendre seulement les données de la matrice (identiques au hachage)
    data = df[df['implementation'] == 'matrice']
    data = data.copy()
    data['label'] = data['alphabet'].astype(str) + '\n' + data['longueur_mots']
    
    bars = ax.bar(range(len(data)), data['nb_occurrences'], color='steelblue', alpha=0.7)
    ax.set_xlabel('Alphabet / Longueur mots')
    ax.set_ylabel('Nombre d\'occurrences')
    ax.set_title('Nombre d\'occurrences trouvées par configuration', 
                fontsize=14, fontweight='bold')
    ax.set_xticks(range(len(data)))
    ax.set_xticklabels(data['label'], fontsize=8)
    ax.grid(True, alpha=0.3, axis='y')
    
    # Annoter les barres
    for bar, val in zip(bars, data['nb_occurrences']):
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height,
               f'{int(val)}', ha='center', va='bottom', fontsize=8)
    
    plt.tight_layout()
    filename = f"{OUTPUT_DIR}/occurrences.png"
    plt.savefig(filename, dpi=300, bbox_inches='tight')
    print(f"✓ Graphique sauvegardé: {filename}")
    plt.close()

def generate_summary_table(df):
    """Génère un tableau récapitulatif"""
    print("\n" + "="*80)
    print("TABLEAU RÉCAPITULATIF DES PERFORMANCES")
    print("="*80)
    
    summary = df.groupby(['alphabet', 'longueur_mots', 'implementation']).agg({
        'temps_execution': 'mean',
        'nb_occurrences': 'first'
    }).round(4)
    
    print(summary)
    print("="*80)
    
    # Temps moyen par implémentation
    print("\nTEMPS MOYEN PAR IMPLÉMENTATION:")
    print(df.groupby('implementation')['temps_execution'].mean())
    
    # Meilleure implémentation par alphabet
    print("\nMEILLEURE IMPLÉMENTATION PAR ALPHABET:")
    for alpha in sorted(df['alphabet'].unique()):
        data = df[df['alphabet'] == alpha]
        best = data.groupby('implementation')['temps_execution'].mean().idxmin()
        avg_time = data.groupby('implementation')['temps_execution'].mean()[best]
        print(f"  Alphabet {alpha}: {best.upper()} (temps moyen: {avg_time:.4f}s)")

def main():
    print("="*80)
    print("VISUALISATION DES PERFORMANCES - ALGORITHME AHO-CORASICK")
    print("="*80 + "\n")
    
    # Charger les données
    df = load_data()
    
    # Créer le dossier de sortie
    create_output_dir()
    
    print("\n" + "="*80)
    print("GÉNÉRATION DES GRAPHIQUES")
    print("="*80 + "\n")
    
    # Générer tous les graphiques
    plot_comparison_by_alphabet(df)
    plot_scalability_alphabet(df)
    plot_word_length_impact(df)
    plot_heatmap_comparison(df)
    plot_speedup_ratio(df)
    plot_occurrences(df)
    
    # Générer le tableau récapitulatif
    generate_summary_table(df)
    
    print("\n" + "="*80)
    print(f"✓ TERMINÉ - Tous les graphiques ont été sauvegardés dans {OUTPUT_DIR}/")
    print("="*80)

if __name__ == "__main__":
    main()