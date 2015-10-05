# Q1  -> Lire le fichier raster UTCATF sous une variable nommée "mon_raster" 
# Q2  -> Extraire un sous-raster spatial pour la zone 14 à 16 degrés Est et 0 à 1 degrés Nord, nommer le "sub_raster"
# Q3  -> Générer une grille de 500 points sur clip appelée "ma_grille" (NB: conserver les coordonnées)
#        nb: faire en sorte que la grille soit sous format data.frame
# Q4  -> Renommer les colonnes de "ma_grille" avec les valeurs "x_coord", "y_coord" et "value". Ajouter une colonne avec un identifiant "id" unique
# Q5  -> Afficher la distribution des points pour chaque classe
# Q6  -> Extraire de "ma_grille" un jeu de 50 points aléatoires parmi la classe Forêt Marécageuse. le nommer "pts_FM" 
# Q7  -> Extraire de "sub_raster" les pixels avec de l'eau en tant que data.frame, les nommer "df_rast_eaU". Ajouter une colonne avec un identifiant "id" unique
# Q8  -> Extraire de "df_rast_eau" un jeu de 50 points aléatoires, le nommer "pts_Eau"
# Q9  -> Créer un graphique vide de la taille de "sub_raster", avec les labels "longitude" en abscisse et "latitude" en ordonnée
# Q10 -> Afficher "sub_raster" en fond de graphe, les points de ma_grille (en noir), les points pts_FM en vert et les points pts_eau en bleu

