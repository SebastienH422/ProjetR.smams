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

base_emp = data[, c("entreprise", "secteur", # On récupère les données qui nous intéressent
                  "experience_requise", "competences_requises", "salaire", "departement")]

base_emp$id_firm = apply(X = base_emp,
                         MARGIN = 1,
                         FUN = get_id_firm)
base_emp$firm_name = base_emp$entreprise
base_emp$n_offres = rep(1, dim(base_emp)[1])
base_emp$sector_name
base_emp$avg_req_exp
base_emp$top_skill_req
base_emp$avg_wage
base_emp$addre_dept_main = base_emp$departement

# Création de la database
# base_emp = data.table(id_firm = character(0), firm_name = character(0), n_offres = integer(0), 
#                       sector_main = character(0), avg_req_exp = numeric(0), top_skill_req = character(0), 
#                       avg_wage = numeric(0), addre_dept_main = character(0))

# Modification du nom
#
get_id_firm = function(line) {
  if (!is.null(line['entreprise'])) {
    name = line['entreprise'] # Nom de l'entreprise
    name_norm = stringi::stri_trans_general(tolower(name), "Latin-ASCII") # Sans accent ni majuscule
    return (substring(name_norm, 1, min(4, nchar(name_norm)))) # 4 premiers caractères
  } else {
    stop("La colonne 'entreprise' est manquante dans l'objet 'line'")
  }
}

# Transformation du salaire en numérique
#
get_wage = function(line) {
  if (!is.null(line['salaire'])) {
    if (line['salaire'] == "") return (0)
    else {
      print(line[['salaire']])
    }
  } else {
    stop("La colonne 'salaire' est manquante dans l'objet 'line'")
  }
}

x = apply(X = base_emp,
          MARGIN = 1,
          FUN = get_wage)
# de SSS € à SSS € par an/mois/jour
# à partir de SSS € par an/mois/jour
# SSS € par an/mois/jour
# jusqu'à SSS € par ...
# Salaire : Non spécifié
# Salaire : 45K à 55K €
# Salaire : 50K à 70K € par mois (PAR MOIS !!!!)

au_format = function(line){
  salaire = line['salaire']

  if (substring(salaire, 1, 3) == "de "){
    num = gsub("[^0-9]", "", salaire)
    begin = substring(num, 1, 5)
    end = substring(num, 6, 10)
    return ((as.integer(begin) + as.integer(end)) / 2)
  } else if (substring(salaire, 1, 12) == 'à partir de ' ||
             substring(salaire, 1, 5) == 'jusqu') {
    return (as.integer(gsub("[^0-9]", "", salaire)))
  } else if (substring(salaire, 1, 7) == "Salaire") {
    return (salaire)
  } else if (salaire == "") {
    return (0)
  } else {
    print(line[['salaire']])
  }
}
x = apply(X = base_emp,
          MARGIN = 1,
          FUN = au_format)
?gsub





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














































































