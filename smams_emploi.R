library(data.table)
library(stringr)
source("smams_src_utilities.R")

# Importation des données
# --> Création de `offres` contenant les données suivantes:
#     entreprise, secteur, experience_requise, competences_requises, salaire, departement

data = data.table(read.csv(file = "DATA/emp_offers_fmt.tsv",
                  head = TRUE,
                  sep = ","))
names(data)
# Champs: "intitule_poste" "entreprise" "type_emploi" "secteur" "experience_requise" "competences_requises""poste_desc" "salaire"              "departement"      

offres = data[, c("entreprise", "secteur", # On récupère les données qui nous intéressent
                  "experience_requise", "competences_requises", "salaire", "departement")]

# Création de la database
base_emp = data.table(id_firm = character(0), firm_name = character(0), n_offres = integer(0), 
                      sector_main = character(0), avg_req_exp = numeric(0), top_skill_req = character(0), 
                      avg_wage = numeric(0), addre_dept_main = character(0))

# Remplissage de la database
#
add_line = function(line, data_base) {
  name = line$entreprise # Nom de l'entreprise
  name_norm = stringi::stri_trans_general(tolower(name), "Latin-ASCII") # Sans accent ni majuscule
  name_red = substring(name_norm, 1, min(4, nchar(name_norm))) # 4 premiers caractères
  
  if (name_red %in% data_base$id_firm) {
    data_base[id_firm == name_red, `:=`(
      n_offres = n_offres + 1,
      sector_main = paste(sector_main, line$secteur, sep = ','),
      avg_req_exp = avg_req_exp + line$experience_requise,
      top_skill_req = paste(top_skill_req, line$competences_requises, sep = ','),
      avg_wage = paste(avg_wage, line$salaire, sep = ','),
      addre_dept_main = addre_dept_main
    )]
  } else {
    data_base <<- rbind(data_base, list(
      name_red, name, 1, line$secteur, line$experience_requise, line$competences_requises, line$salaire, line$departement
    ))
  }
  return(line)
}

for (i in 1:dim(offres)[1]){
  add_line(offres[i], base_emp)
}

offres[1]
dim(base_emp)
head(base_emp)$sector_main


offres[, add_line(.SD, base_emp), by = 1:nrow(offres)]
base_emp

# Utiliser apply pour appliquer la fonction add_line sur chaque ligne de offres
apply(offres, 1, function(line) add_line(as.list(line), base_emp))






















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
competences[0:10]

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














































































