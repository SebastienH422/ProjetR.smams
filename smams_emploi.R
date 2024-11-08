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

# Création de la database
base_emp = data.table(id_firm = character(0), firm_name = character(0), n_offres = integer(0), 
                      sector_main = character(0), avg_req_exp = numeric(0), top_skill_req = character(0), 
                      avg_wage = numeric(0), addre_dept_main = character(0))

# Remplissage de la database
add_line = function(line){
  name = line['entreprise'] # Nom de l'entreprise
  name_norm = stringi::stri_trans_general(tolower(name), "Latin-ASCII") # Sans accent ni majuscule
  name_red = substring(name_norm, 1, min(4, nchar(name_norm))) # 4 premiers caractères
  if (name_red in base_emp){
    base_emp[n_offres, id_firm = name_red] = base_emp[n_offres, id_firm = name_red] + 1
    base_emp[sector_main, id_firm = name_red] = paste(base_emp[sector_main, id_firm = name_red], line$sector_main, sep = '//')
    base_emp[avg_req_exp, id_firm = name_red] = base_emp[avg_req_exp, id_firm = name_red] + line$avg_req_exp
    base_emp[top_skill_req, id_firm = name_red] = paste(base_emp[top_skill_req, id_firm = name_red], line$top_skill_req, sep = '//')
    base_emp[avg_wage, id_firm = name_red] = base_emp[avg_wage, id_firm = name_red] + line$avg_wage
    base_emp[addre_dept_main, id_firm = name_red] = paste(base_emp[addre_dept_main, id_firm = name_red], line$addre_dept_main, sep = '//')
  }else{
    base_emp = rbind(base_emp, list(name_red, name, 1, line$sector_main, line$avg_req_exp, line$top_skill_req, line$avg_wage, line$addre_dept_main))
  }
  return (line)
}

# Fonction add_line corrigée
add_line <- function(line) {
  name <- line$entreprise # Nom de l'entreprise
  name_norm <- stringi::stri_trans_general(tolower(name), "Latin-ASCII") # Sans accent ni majuscule
  name_red <- substring(name_norm, 1, min(4, nchar(name_norm))) # 4 premiers caractères
  
  if (name_red %in% base_emp$id_firm) {
    base_emp[id_firm == name_red, `:=`(
      n_offres = n_offres + 1,
      sector_main = paste(sector_main, line$secteur, sep = ','),
      avg_req_exp = avg_req_exp + line$experience_requise,
      top_skill_req = paste(top_skill_req, line$competences_requises, sep = ','),
      avg_wage = paste(avg_wage, line$salaire, sep = ','),
      addre_dept_main = addre_dept_main
    )]
  } else {
    base_emp <<- rbind(base_emp, list(
      name_red, name, 1, line$secteur, line$experience_requise, line$competences_requises, line$salaire, line$departement
    ))
  }
  return(line)
}

for (i in 1:dim(offres)[1]){
  add_line(offres[i])
}

offres[1]
dim(base_emp)
head(base_emp)$sector_main


offres[, add_line(.SD), by = 1:nrow(offres_red)]
base_emp


























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














































































