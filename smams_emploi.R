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
#     get_exp_req: IN: exp <string> nombre d'expérience sous les différents formats qui apparraissent dans experience_requise
#                  OUT: <list of string> Expériences requises, une expérience par string
#     get_wage: IN: wages <string> Salaire ou fourchette de salaire sous les différents formats qui apparraissent dans salaire
#               OUT: <float> Salaire ou salaire moyen s'il s'agit d'une fourchette
#     get_skills: IN: skills <string> Compétences requises
#                 OUT: <list of string> Une compétence requise par string
#     get_sector: IN: sectors <string> Secteurs d'activités
#                 OUT: <list of string> Un secteur d'activité par string
# 
# Fonctions à appliquer pour l'aggregation
#     set_firm_name: IN: names <list of string> Noms des entreprises
#                    OUT: <string> Le premier nom, ou celui qui revient le plus souvent
#     set_sector_name: IN: sectors_lists <list of list of string> Liste de liste des secteurs d'activités
#                          n <int> nombre de secteurs voulus
#                      OUT: String des n secteurs qui reviennent le plus souvent
#                      TODO: Fusionner les listes, 
#                            trier les secteurs par ordre d'apparition, 
#                            prendre les n valeurs qui apparaissent le plus souvent,
#                            fusionner les n valeurs dans un seul string à retourner
#     set_top_skill_req: IN: skils_lists <list of list of string> Liste de liste des compétences
#                            n <int> nombre de compétences voulues 
#                        OUT: String des n compétences qui reviennent le plus souvent
#                        TODO: Fusionner les listes, 
#                              trier les compétences par ordre d'apparition, 
#                              prendre les n valeurs qui apparaissent le plus souvent,
#                              fusionner les n valeurs dans un seul string à retourner
#     set_addre_dept_main: IN: dep <list of int> Liste de int des départements
#                          OUT: int du département qui revient le plus souvent
#
# Aggregation:
# base_emp <- base_emp[{bool pour sélectionner les données},
#                      {fonctions pour aggréger les données, 
#                           par exemple sum(n_offers),
#                           séparées par des virgules},
#                      by = {identifiant, ici id_firm}]
