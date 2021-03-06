##########################################################################################
################## Module interaction entre les sources de donn�es                 #######
##########################################################################################

# Points abord�s :
# - faire un graphique avec moyenne, quantile et outliers, par cat�gories
# - croiser raster et point
# - croiser vecteur et raster
# - reclassifier un raster


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

library(rgdal) # pour lire les format GDAL/OGR
library(foreign) # pour lire les fichiers DBF
library(raster) # pour lire les fichiers raster, obtenir les projections
library(rgeos) # pour faire des op�rations sur les g�ometries
library(tmap) # pour faire des cartes esth�tiques
library(dplyr) # a rajouter!
library(maps)


### Lire les fichiers: fonction "raster", "readOGR" et "read.csv"
raster <- raster("../data/raster_utcatf.tif")
poly   <- readOGR(dsn="../data",layer="congo_departement_geo")
points <- readOGR(dsn="../data",layer="points_NFI")
table  <- read.csv("../data/NFI_data_biomasse.csv")
gfc_tc <- raster("../data/gfc_aggrege.tif")

### Afficher graphiquement toutes les valeurs du fichier biomasse
plot(table$biomass_tha)
res(gfc_tc)*111000
projection(gfc_tc)
### Faire un masque foret non foret a partir du fichier gfc_tc: 
#mask <- (gfc_tc > 30)*gfc_tc
#plot(mask)
#plot(gfc_tc)
### Extraire la valeur du raster (nouvelle colonne "UTCATF") pour chaque point du fichier biomasse 
table$utcatf <- extract(raster,table[,c(1:2)])
head(table,2)
### Afficher les Boites � Moustache de la biomasse pour chaque classe de la carte
graphics::boxplot(table$biomass_tha ~ table$utcatf)

### Faire une reclassification th�matique (sur une portion plus petite)
clip<-crop(raster,extent(14,15,1,2))
plot(clip)

rcl <- data.frame(cbind(c(2,4,11,12,13,31,32,33,34),
                        c(2,4,1,1,1,3,3,3,3)
                        )
                  )

reclass <- reclassify(clip,rcl)

writeRaster(reclass,"reclass.tif")

### Cr�er les statistiques zonales d'un raster sur un polygone
sangha <- poly[poly$NOM_PR_FEC == "SANGHA",]
#ext <- as.data.frame(extract(clip,sangha,method="simple"))
#table(ext)
writeOGR(obj=sangha,dsn="sangha.shp",
         layer="sangha",driver = "ESRI Shapefile")

### Cr�er un raster de plus basse r�solution
agg<-aggregate(raster,fact=10,fun=max)

### Cr�er la liste des d�partements
list<-levels(as.factor(poly$NOM_PR_FEC))

### Cr�er une fonction zonale
cgo_zonal <- function(dpt,raster){
  table(data.frame(
    extract(raster,
            poly[poly$NOM_PR_FEC == dpt,]
    )
  )
  )
}

### Appliquer la fonction zonale avec le raster aggr�g� pour un d�partement
cgo_zonal("BOUENZA",agg)

### Appliquer la fonction � tous les d�partements
sapply(list,function(x){cgo_zonal(x,agg)})



