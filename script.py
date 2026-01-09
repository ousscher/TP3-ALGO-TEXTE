import pandas as pd
import matplotlib.pyplot as plt
import sys

def parse_time(time_str):
    """Convertir une durée au format 0m0.123s en secondes"""
    if 'm' in time_str:
        parts = time_str.replace('s', '').split('m')
        return float(parts[0]) * 60 + float(parts[1])
    else:
        return float(time_str.replace('s', ''))

def plot_results(csv_file):
    # Lire les données
    df = pd.read_csv(csv_file)
    
    # Convertir les temps en secondes
    df['Temps_Secondes'] = df['Temps_Total'].apply(parse_time)
    
    # Créer une figure avec plusieurs sous-graphiques
    fig, axes = plt.subplots(2, 2, figsize=(15, 10))
    fig.suptitle('Performance Aho-Corasick : Matrice vs Table de Hachage', fontsize=16)
    
    # Graphique 1 : Temps par taille d'alphabet
    ax1 = axes[0, 0]
    for methode in ['matrice', 'hachage']:
        data = df[df['Methode'] == methode].groupby('Alphabet')['Temps_Secondes'].mean()
        ax1.plot(data.index, data.values, marker='o', label=methode.capitalize())
    ax1.set_xlabel('Taille de l\'alphabet')
    ax1.set_ylabel('Temps moyen (s)')
    ax1.set_title('Temps d\'exécution selon la taille de l\'alphabet')
    ax1.legend()
    ax1.grid(True)
    
    # Graphique 2 : Temps par longueur de mots
    ax2 = axes[0, 1]
    longueurs = df['Longueur_Mots'].unique()
    x_pos = range(len(longueurs))
    
    matrice_times = [df[(df['Methode'] == 'matrice') & 
                       (df['Longueur_Mots'] == l)]['Temps_Secondes'].mean() 
                    for l in longueurs]
    hachage_times = [df[(df['Methode'] == 'hachage') & 
                        (df['Longueur_Mots'] == l)]['Temps_Secondes'].mean() 
                     for l in longueurs]
    
    width = 0.35
    ax2.bar([x - width/2 for x in x_pos], matrice_times, width, label='Matrice')
    ax2.bar([x + width/2 for x in x_pos], hachage_times, width, label='Hachage')
    ax2.set_xlabel('Longueur des mots')
    ax2.set_ylabel('Temps moyen (s)')
    ax2.set_title('Temps d\'exécution selon la longueur des mots')
    ax2.set_xticks(x_pos)
    ax2.set_xticklabels(longueurs)
    ax2.legend()
    ax2.grid(True, axis='y')
    
    # Graphique 3 : Ratio matrice/hachage
    ax3 = axes[1, 0]
    for alpha in df['Alphabet'].unique():
        data = df[df['Alphabet'] == alpha]
        ratios = []
        labels = []
        for longueur in data['Longueur_Mots'].unique():
            subset = data[data['Longueur_Mots'] == longueur]
            matrice_time = subset[subset['Methode'] == 'matrice']['Temps_Secondes'].values[0]
            hachage_time = subset[subset['Methode'] == 'hachage']['Temps_Secondes'].values[0]
            ratios.append(matrice_time / hachage_time)
            labels.append(longueur)
        ax3.plot(labels, ratios, marker='o', label=f'Alphabet {alpha}')
    
    ax3.axhline(y=1.0, color='r', linestyle='--', label='Égalité')
    ax3.set_xlabel('Longueur des mots')
    ax3.set_ylabel('Ratio Matrice/Hachage')
    ax3.set_title('Comparaison relative des performances')
    ax3.legend()
    ax3.grid(True)
    
    # Graphique 4 : Occurrences trouvées
    ax4 = axes[1, 1]
    for alpha in df['Alphabet'].unique():
        data = df[(df['Alphabet'] == alpha) & (df['Methode'] == 'matrice')]
        ax4.plot(data['Longueur_Mots'], data['Occurrences'], 
                marker='o', label=f'Alphabet {alpha}')
    ax4.set_xlabel('Longueur des mots')
    ax4.set_ylabel('Nombre d\'occurrences')
    ax4.set_title('Occurrences trouvées par configuration')
    ax4.legend()
    ax4.grid(True)
    
    plt.tight_layout()
    plt.savefig('resultats_graphiques.png', dpi=300, bbox_inches='tight')
    print("Graphiques sauvegardés dans : resultats_graphiques.png")
    plt.show()

if __name__ == "__main__":
    csv_file = "resultats_perf.txt" if len(sys.argv) == 1 else sys.argv[1]
    try:
        plot_results(csv_file)
    except Exception as e:
        print(f"Erreur : {e}")
        print(f"Usage: {sys.argv[0]} [fichier_csv]")
        sys.exit(1)