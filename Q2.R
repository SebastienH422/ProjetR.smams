library(data.table)
library(stringr)

# Importation des données
# --> Création de `offres` contenant les données suivantes:
#     entreprise, secteur, experience_requise, competences_requises, salaire, departement

data = data.table(read.csv(file = "emp_offers_fmt.tsv",
                  head = TRUE,
                  sep = ","))
names(data)
# Champs: "intitule_poste" "entreprise" "type_emploi" "secteur" "experience_requise" "competences_requises""poste_desc" "salaire"              "departement"      

offres = data[, c("entreprise", "secteur", # On récupère les données qui nous intéressent
              "experience_requise", "competences_requises", "salaire", "departement")]

offres_red = offres[, c("entreprise", "secteur", # On récupère les données qui nous intéressent
              "experience_requise", "salaire", "departement")]






# Récupération des compétences
# --> Création de competences contenant chaque compétences utilisées dans le champs 
#     competences_requises. Les doublons sont supprimés.
head(offres)
separateur = function(x){ # Fonction qui sera appliquée sur 
  str_split(string = x, # chaque élément de la colonnes competences_requises
            pattern = ",")
}
competences = unique(sapply(X = offres$competences_requises, # Application de separateur
                     FUN = separateur)) # On utilise unique() pour enlever les doublons

# Suppression des valeurs qui se ressemblent
semblable = function(x, y){
  # Détecte si x et y sont semblables en tronquant x et y
  limInf = 0.2
  limSup = 0.7
  
  n_x = as.integer(x)
  inf = as.integer(n_x * limInf)
  sup = as.integer(n_x * limSup) + 1
  
  return str_sub(x, inf, sup) == str_sub(y, inf, sup)
}

est_semblable = function(liste_string){
  # Renvoie une liste de booléen 
  liste_minuscule = tolower(liste_string)
  sapply(X = liste_string,
         FUN = function(x) sapply(X = liste_string,
                                  FUN = function(y) semblable(x, y)))
  
}

test = "Hello World"
as.integer(nchar(test) * 0.7)
str_sub(test, 2, 11)














































































