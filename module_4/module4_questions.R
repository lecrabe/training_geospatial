# Q1 -> Lire les fichiers : 
# "congo_departement_geo.shp" sous une variable nommée  "DPT"
# "gfc_aggrege.tif"           sous une variable nommée  "GFC"
# "NFI_data_biomasse.csv"     sous un variable nommée   "IFN"

# Q2 -> Créer un nouveau raster appelé "tc_class" des classes de couverture arborée 
# classe 1 : TC 0-30  
# classe 2 : TC 30-70 
# classe 3 : TC 70-100

# Q3 -> Extraire la valeur de couverture arborée pour chaque point de l'IFN
### l'insérer comme nouvelle colonne ("couverture") dans le fichier table

# Q4 -> Afficher le graphique biomasse VS couverture

# Q5 -> Afficher les moyennes et quantiles de couverture arboree par classe de biomasse

# Q6 -> Créer un vecteur de 1 à 4

# Q7 -> Créer une fonction qui affiche le nombre de ligne du fichier biomasse pour une modalité donnée

# Q8 -> Appliquer la fonction à la liste 1:4.
# Quelle est la fonction globale que vous avez recréé ?

# Q9 -> Créer un raster de la couverture arborée à ~1km de résolution (facteur=4)

# Q10 -> Créer un raster des départements du pays à la même résolution

# Q11 -> Chercher la fonction "zonal" et Calculer la moyenne, le min et le max de couverture arborée par département

