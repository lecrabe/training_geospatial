##########################################################################################
##################        Module de gestion des formats vecteurs                   #######
##########################################################################################

# Points abord�s :
# - lire, modifier, �crire un fichier DBF
# - lire, modifier, exporter un fichier vecteur (shape)
# - extraire des modalit�s (points, lignes, polygones)
# - transformer un fichier vecteur en fichier raster

########################################################################################### 
# Derni�re mise � jour 01/09/2015
# remi.dannunzio@fao.org
##########################################################################################

##########################################################################################
################## Options de base, paquets
##########################################################################################
options(stringsAsFactors=FALSE)

# changer votre chemin
# setwd("C:/Users/dannunzio/Documents/countries/congo_brazza/formation_R/module_1/")
getwd()

library(rgdal) # pour lire les format GDAL/OGR
library(foreign) # pour lire les fichiers DBF
library(raster) # pour lire les fichiers raster, obtenir les projections
library(rgeos) # pour faire des op�rations sur les g�ometries
library(tmap) # pour faire des cartes esth�tiques
library(dplyr) # a rajouter!
library(maps)

### Lire un fichier DBF: fonction "read.dbf"
df     <- read.dbf("../data/points_NFI.dbf")

### Lire un fichier geospatial/vecteur: fonction "readOGR"
poly_admin <- readOGR(dsn="../data",
                      layer="congo_departement_geo")
points_IFN <- readOGR(dsn="../data",
                      layer="points_NFI")

### Obtenir les caract�ristiques d'un fichier vecteur
summary(poly_admin)

names(df)[4] <- "ce_truc"


### Projeter un fichier vecteur
poly_utm <- spTransform(poly_admin, 
                        CRS("+init=epsg:32633"))
point_utm<- spTransform(points_IFN, CRS("+init=epsg:32633"))

### Extraire le syst�me de projection et l'�tendue comme des variables
my_crs <- projection(poly_utm)
my_ext <- extent(poly_utm)

extent(poly_admin)

### Cr�er un raster vide de la meme �tendue et projection que le vecteur, avec une r�solution de 100 km
temp   <- raster(poly_utm,resolution=1000,
                 ext=my_ext,crs=my_crs)

### Emplir le raster avec les valeurs du vecteur initial pour le champs "CDE_PR_FEC"
raster <- rasterize(x=poly_utm,y=temp,
                    field="CDE_PR_FEC",
                    background=0,fun='first',
                    update=TRUE)

### Afficher le raster et le vecteur par dessus
plot(raster)
plot(poly_utm,add=TRUE)
plot(point_utm,add=T)

### Cr�er un extrait du fichier vecteur (d�partement des Plateaux)
mon_poly <-poly_utm[poly_utm$NOM_PR_FEC=="PLATEAUX",]
mon_poly

### Ajouter le d�partement en Bleu
plot(mon_poly,add=T,col="blue")

### Afficher le polygones par ses sommets
plot(mon_poly@polygons[[1]]@Polygons[[1]]@coords)
coord<-mon_poly@polygons[[1]]@Polygons[[1]]@coords

### Cr�er un deuxi�me d�partement
sangha <-poly_utm[poly_utm$NOM_PR_FEC=="SANGHA",]


### Fusionner les deux polygones
union <- gUnion(sangha,mon_poly)
plot(union)

### S�lectionner des �l�ments dans un vecteur par leur localisation 
pts_sangha <- point_utm[sangha,]
plot(pts_sangha)

### Calculer le nombre d'�l�ment d'un vecteur 
# selon les g�om�trie d'un autre vecteur
poly_utm_ifn<-aggregate(x = point_utm["Code_Point"],by = poly_utm,FUN = length)

poly_utm$IFN_pts <- poly_utm_ifn$Code_Point
poly_utm@data

### Joindre des attributs spatiaux
point_utm$DPT <- aggregate(x = poly_utm["NOM_PR_FEC"], by = point_utm,FUN=first)$NOM_PR_FEC
head(point_utm)

### Transformer une table en fichier spatial-vecteur
df    <- read.csv("../data/NFI_data_biomasse.csv")
summary(df)

sp_df <- SpatialPointsDataFrame(
      coords = df[,c(1,2)],
      data   = data.frame(df[,c(3)]),
      proj4string=CRS("+proj=longlat +datum=WGS84")
)

nfi_utm <- spTransform(sp_df, CRS("+init=epsg:32633"))
names(nfi_utm)<-"biomass"

?tmap
### Utiliser le package tmap
tm_shape(poly_utm) +
  tm_fill("NOM_PR_FEC", style="kmeans", title="D�partement du Congo")+ 
  tm_borders()+

tm_shape(nfi_utm)+
  tm_bubbles(size="biomass","darkgrey",scale=0.5,border.col = "black", border.lwd=1, size.lim = c(0,800), 
             sizes.legend = seq(0,800, by=200), title.size="Biomasse t/ha")+
tm_layout( title.position = c("center", "center"), title.size = 20)


