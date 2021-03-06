##########################################################################################
################## Module creation d'une grille point,   extraction d'information  #######
##########################################################################################

# Points abord�s :
# - lire un fichier raster
# - cr�er une grille de point
# - extraire des informations
# - s�lectionner un sous-jeu de donn�es
# - exporter les r�sultats en format vecteur

#############################################################a############################# 
# Derni�re mise � jour 30/08/2015
# remi.dannunzio@fao.org
##########################################################################################

##########################################################################################
################## Options de base, paquets
##########################################################################################
options(stringsAsFactors=FALSE)

# changer votre chemin
# setwd("C:/Users/dannunzio/Documents/countries/congo_brazza/formation_R/module_1/")
getwd()

library(rgdal)
library(raster)

### Lire un fichier raster: fonction "raster"
rast_congo <- raster("../data/raster_utcatf.tif")
str(rast_congo)

# ######### Cr�er un extrait spatial
e<-extent(14,16,0,2)
rast<-crop(rast_congo,e)
plot(rast_congo)
#rast <- rast_congo

# ######### Tirer des points al�atoires sur l'etendue du raster: fonction "sampleRandom"
# ######### "xy=TRUE" signifie que les coordonn�es seront maintenues
tmp <- sampleRandom(rast,1000,xy=TRUE)

# ######### Convertir en data frame
my_sample <- data.frame(tmp)

# ######### Changer les noms des colonnes
names(my_sample) <- c("x_coord","y_coord","value")
str(my_sample)

# ######### Extraire les colonnes latitude et longitude seulement
x<-my_sample$x_coord
y<-my_sample$y_coord

# ######### Afficher les points: fonction "plot"
plot(x,y)

# ######### Effacer le graphique
dev.off()

# ######### Cr�er un cadre vide de la taille du raster de d�part
plot(my_sample$x_coord,my_sample$y_coord,
     type="n",xlab="longitude",ylab="latitude")

# ######### Afficher le raster: fonction "rasterImage"
rasterImage(as.raster(rast),xmin(rast),ymin(rast),xmax(rast),ymax(rast))

# ######### Afficher le raster: fonction "plot"
class <-c(0,1,5,10,12,13,31,32,33,34)  
cols <- c("black","grey","blue","darkgreen","green","green","red","yellow","orange","yellow")
#plot(rast,col=cols,breaks=class)

# ######### Rajouter des points sur un graphique existant: fonction "points"
points(my_sample$x_coord,my_sample$y_coord)

# ######### Cr�er une colonne avec des identificateurs uniques: fonction "row"
my_sample$id <- row(my_sample)[,1]

head(my_sample)

# ######### Cr�er le vecteur logique qui indique si la valeur du raster est diff�rente de zero: op�rateur logique "!="
list_logic <- my_sample$value != 0
head(list_logic)

# ######### Cr�er un sous-jeu de donn�es (points � l'int�rieur du pays)
in_country <- my_sample[list_logic,]

points(in_country$x_coord,in_country$y_coord,col="grey")

# ######### Voir la distribution des points par valeurs
table(in_country$value)

# ######### S�lectionner al�atoirement 100 points parmi la classe Foret Primaire: fonction "sample"
# ######### NB: la liste logique qui indique si la valeur du raster est egale a la classe Foret Primaire est int�gr�e directement
pts_FP <- my_sample[
                sample(my_sample[
                my_sample$value==11,]$id,50)
  ,]

# ######### Ajouter les points sur le graphique
points(pts_FP$x_coord,pts_FP$y_coord,col="darkgreen",pch=19)

################################################
################################################
# Cette proc�dure a permis de s�lectionner des points dans la classe Foret Primaire
# Mais qu'en est-il des classes plus rares ?
################################################


# ######### Extraire des points avec une valeur particuli�re: fonction "rasterToPoints"
start<-Sys.time()
rast_PP<-rasterToPoints(rast,
          fun=function(rast){rast==31})
Sys.time()-start

# ######### Transformer en data frame et ajouter une colonne identifiant unique
df_pts_PP<-as.data.frame(rast_PP)
names(df_pts_PP) <- c("x_coord","y_coord","value")
df_pts_PP$id<-row(df_pts_PP)[,1]

# ######### S�lectionner al�atoirement 50 points parmi ces pixels individualis�s
pts_PP<-df_pts_PP[sample(df_pts_PP$id,50),]

# ######### Afficher les points de pertes en rouge
points(pts_PP$x_coord,pts_PP$y_coord,col="red",pch=19)

# ######### Combiner les deux jeux de donn�es: fonction "rbind"
mes_points <- rbind(pts_FP,pts_PP)

# ######### V�rifier les valeurs des points finaux
table(mes_points$value)

# ######### Trasnformer en data frame spatial
sp_df<-SpatialPointsDataFrame(
                              coords = mes_points[,c(1,2)],
                              data   = data.frame(mes_points[,c(4,3)]),
                              proj4string=CRS("+proj=longlat +datum=WGS84")
                              )

# ######### Exporter en KML
writeOGR(obj=sp_df,dsn="mes_points.kml",layer="mes_points",driver = "KML")
?crop
?writeOGR
rast_agg <- aggregate(rast,fact=3,fun=max)
rast_disagg <- disaggregate(rast,fact=2)
ogrDrivers()
writeRaster(rast,"clip.tif")
writeRaster(rast_agg,"clip_agg2.tif")
writeRaster(rast_disagg,"clip_disagg.tif")

res_init<- (xmax(rast)-xmin(rast))/rast@ncols
res_init*111000


  (xmax(rast_disagg)-xmin(rast_disagg))/
  rast_disagg@ncols
res_disag*111000
