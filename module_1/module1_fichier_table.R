##########################################################################################
################## Module gestion de table, creation d'une matrice de confusion    #######
##########################################################################################

# Points abordés :
# - lire fichier CSV, TXT
# - écrire fichier CSV, TXT
# - créer un data frame
# - manipuler un data frame
# - créer une matrice
# - remplir une matrice
#############################################################a############################# 
# Dernière mise à jour 26/08/2015
# remi.dannunzio@fao.org
##########################################################################################

##########################################################################################
################## Options de base, paquets
##########################################################################################
options(stringsAsFactors=FALSE)

# changer votre chemin
# setwd("C:/Users/dannunzio/Documents/countries/congo_brazza/formation_R/module_1/")
getwd()

### Lire la table de donnees: fonctions "<-" et "read.csv"
df    <- read.csv("../data/table_evaluation_precision_classes.csv")
areas <- read.csv("../data/table_superficies_classes.csv")

### Afficher un résumé des tables: fonction "str"
str(df)
str(areas)

### Afficher le haut d'une table: fonction "head"
head(df)
head(df,2)

### Afficher le nom des colonnes d'une table: fonction "names"
names(df) 
areas
### Extraire une colonne d'une table: fonction "$"
areas$area

### Afficher la longueur d'un vecteur/table: fonction "length"
length(df$map_code)

### Afficher la classe d'un vecteur/table: fonction "class"
class(df$map_code)

### Supprimer les doublons d'un vecteur/table: fonction "unique"
unique(df$map_code)

### Afficher les niveaux d'une variable: fonction "levels" 
levels(df$map_code)

### Changer le type d'une variable: fonction "as.XXXXX"
### NB: plusieurs fonctions imbriquées, l'indentation est automatique

(legend <- levels(as.factor(df$map_code)
                  )
 )

### Afficher un comptage des éléments par colonne: fonction "table"
table(df$map_code)

### Créer un tableau croisé
matrix <- table(df$map_code,df$ref_code)
matrix
### Calculer une somme: fonction "sum"
sum(areas$area)

### Extraire un élément / une ligne / une colonne: fonction "[,]" 
areas[5,]
areas[areas$code>20,]
areas[,"class"]
areas[areas$code==13,"class"]
areas[areas$code==13,]$area

### Calculer la matrice des proportions
matrix_w <- matrix

for(i in 1:length(legend)){
  for(j in 1:length(legend)){
    matrix_w[i,j] <- matrix[i,j]/
      sum(matrix[i,])*
      areas[areas$code==legend[i],]$area/
      sum(areas$area)
                             }
                          }

### Calculer la matrice des erreurs standard
matrix_se<-matrix
for(i in 1:length(legend)){
  for(j in 1:length(legend)){
      matrix_se[i,j]<-
      (areas[areas$code==legend[i],]$area/sum(areas$area))^2*
      matrix[i,j]/
      sum(matrix[i,])*
      (1-matrix[i,j]/sum(matrix[i,]))/
      (sum(matrix[i,])-1)
  }
}

### Creation du Jeu de donnees de synthese
confusion<-data.frame(matrix(nrow=length(legend)+1,ncol=9))
names(confusion)<-c("class","code","Pa","PaW","Ua","area","area_adj","se","ci")

### Integration des elements dans le jeu de donnees synthese
for(i in 1:length(legend)){
  confusion[i,]$class    <- areas[areas$code==legend[i],]$class
  confusion[i,]$code     <- areas[areas$code==legend[i],]$code
  confusion[i,]$Pa       <- matrix[i,i]/sum(matrix[,i])
  confusion[i,]$Ua       <- matrix[i,i]/sum(matrix[i,])
  confusion[i,]$PaW      <- matrix_w[i,i]/sum(matrix_w[,i])
  confusion[i,]$area_adj <- sum(matrix_w[,i])*sum(areas$area)
  confusion[i,]$area     <- areas[areas$code==legend[i],]$area
  confusion[i,]$se       <- sqrt(sum(matrix_se[,i]))*sum(areas$area)
  confusion[i,]$ci       <- confusion[i,]$se*1.96
  }

### Calculer la Precision Generale
confusion[length(legend)+1,]<-c("overall","",sum(diag(matrix))/sum(matrix[]),sum(diag(matrix_w))/sum(matrix_w[]),"",sum(areas$area),sum(areas$area),"","")

### Afficher Resultats
confusion
matrix

### Exporter resultats en CSV
write.csv(file="matrix_confusion_gisele.csv",matrix,row.names=T)
write.csv(file="results_summary_20150826.csv",confusion,row.names=FALSE)

### Faire un graphique avec les intervalles de confiance
library(ggplot2)

confusion$ci      <- as.numeric(confusion$ci)
confusion$area_adj<- as.numeric(confusion$area_adj)

### Créer un graphique 
avg.plot<-qplot(class,
                area_adj,
                data=confusion,
                geom="bar",
                stat="identity")

### Afficher le graphique
avg.plot+geom_bar()

### Effacer la zone graphique
dev.off()

### Rajouter les barres d'erreur sur le graphique
avg.plot+geom_bar()+
  geom_errorbar(aes(ymax=area_adj+ci, ymin=area_adj-ci))+
  theme_bw()

