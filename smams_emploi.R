# Libraries
source("smams_src_utilities.R")
library(data.table)
library(stringr)


# Importation des données
# Champs: intitule_poste entreprise type_emploi secteur experience_requise competences_requises poste_desc salaire departement"
#
# --> Création de `offres` contenant les données suivantes:
#     entreprise, secteur, experience_requise, competences_requises, salaire, departement
#
data = data.table(read.csv(file = "Data/emp_offers_fmt.tsv", # Importation
                  head = TRUE,
                  sep = ","))
names(data) # Récupération des champs

offres = data[, c("entreprise", "secteur", # Création de 'offres'
              "experience_requise", "competences_requises", "salaire", "departement")]

base_emp$id_firm = apply(X = base_emp,
                         MARGIN = 1,
                         FUN = get_id_firm)
base_emp$firm_name = base_emp$entreprise
base_emp$n_offres = rep(1, dim(base_emp)[1])
base_emp$sector_name = base_emp$secteur
base_emp$avg_req_exp 
base_emp$top_skill_req
base_emp$avg_wage
base_emp$addre_dept_main = base_emp$departement

# TODO
# Fonctions pour construire les colonnes de base_emp
#     Transformer l'expérience requise et les salaires en nombre, 
#     Scinder les compétences et les secteurs
# 
# Fonctions à appliquer pour l'aggregation
#    firm_name: Choisir un nom au hasard (le premier)
#    n_offres: Sommer les valeurs (toutes initialisées à 1)
#    // sector_name: Prendre celui ou ceux qui apparaissent le plus souvent
#                 ou Fusionner les différents secteurs
#    avg_req_exp: Moyenne des valeurs
#    top_skill_req: Prendre les compétences qui apparraissent le plus souvent
#    avg_wage: Moyenne des valeurs
#    // addre_dept_main: Prendre celui qui apparait le plus souvent
#
# Aggregation:
# base_emp <- base_emp[{bool pour sélectionner les données},
#                      {fonctions pour aggréger les données, 
#                           par exemple sum(n_offers),
#                           séparées par des virgules},
#                      by = {identifiant, ici id_firm}]

