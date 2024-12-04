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
#     get_exp_req: Retourner l'expérience requise en liste de string contenant les expériences
#     get_wage: Transformer les salaires en nombre, 
#               faire la moyenne lorsqu'il s'agit d'une fourchette, 
#               retourner le salaire
#     get_skills: Scinder le string des compétences en liste de string des compétences
#                 retourner la liste de string des compétences
#     get_sector: Scinder le string des secteurs en liste de string des secteurs
#                 retourner la liste de string des secteurs
# 
# Fonctions à appliquer pour l'aggregation
#     set_firm_name: IN: Liste des noms (string)
#                    OUT: Le premier nom, ou celui qui revient le plus souvent
#     set_sector_name: IN: Liste de listes de secteurs (string, même format que le retour de get_sector)
#                          n: nombre de secteurs voulus à la fin
#                      OUT: String des n secteurs qui reviennent le plus souvent
#                      TODO: Fusionner les listes, 
#                            trier par ordre d'apparition, 
#                            prendre les n valeurs qui apparraissent le plus souvent
#     set_top_skill_req: IN: Liste de liste des compétences (string, même format que le retour de get_skills)
#                            n: nombre de compétences voulus à la fin
#                        OUT: String des n compétences qui reviennent le plus souvent
#                        TODO: Fusionner les listes, 
#                              trier par ordre d'apparition, 
#                              prendre les n valeurs qui apparraissent le plus souvent
#     set_addre_dept_main: IN: Liste de int des départements
#                          OUT: int du département qui revient le plus souvent
#
# Aggregation:
# base_emp <- base_emp[{bool pour sélectionner les données},
#                      {fonctions pour aggréger les données, 
#                           par exemple sum(n_offers),
#                           séparées par des virgules},
#                      by = {identifiant, ici id_firm}]
