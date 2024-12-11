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

base_emp = data[, c("entreprise", "secteur", # Création de 'offres'
              "experience_requise", "competences_requises", "salaire", "departement")]

# Création des nouvelles colonnes de la database
base_emp$id_firm = apply(X = base_emp,
                         MARGIN = 1,
                         FUN = get_id_firm)
base_emp$firm_name = base_emp$entreprise
base_emp$n_offres = rep(1, dim(base_emp)[1])
base_emp$sector_name = apply(X = base_emp,
                             MARGIN = 1,
                             FUN = get_sector_name)
base_emp$avg_req_exp = base_emp$experience_requise
base_emp$top_skill_req = apply(X = base_emp,
                               MARGIN = 1,
                               FUN = get_skills_req)
base_emp$avg_wage = apply(X = base_emp,
                          MARGIN = 1,
                          FUN = get_wage)
base_emp$addre_dept_main = base_emp$departement

head(base_emp)
# Problèmes: sector_name et top_skill_req ont un problème de type, 
#            wage_avg ne s'applique pas correctement sur les premières lignes
# A priori, les fonctions sont correctes. A retester avec l'argument 'line', peut-être que le problème vient de là. 
# J'ai l'impression qu'elles renvoient des vecteurs de vecteurs (de vecteurs ?). 

# Suppression des anciennes colonnes
# A faire (voir plus bas)

# Aggrégation
# A faire (voir plus bas)

# Application des fonctions
# A faire (voir plus bas)

# Nettoyage manuel
# A faire (voir plus bas)


# Schéma à suivre:
# 
# Appliquer les fonctions : (fait, voir problèmes ci-dessus)
#   - get_id_firm sur entreprise pour construire la colonne id_firm
#   - get_skills sur secteur, competences_requises, pour construire les colonnes sector_name, top_skill_req
#   - get_wage sur salaire pour construire la colonne avg_wage
# Initialiser:
#   - firm_name sur entreprise
#   - n_offres à 1
#   - avg_req_exp à experience_requise
#   - addre_dept_main à departement
#
# Supprimer les colonnes entreprise, secteur, experience_requise, competences_requises, salaire, departement
#
# Aggréger selon id_firm en fusionnant:
#   - Concaténation des listes sur firm_name, sector_name, top_skill_req, addre_dept_main
#   - Somme des numerics sur n_offres
#   - Moyenne des valeurs sur avg_req_exp, avg_wage
#
# Appliquer les fonctions:
#   - get_top_val sur la colonne firm_name, sector_name, top_skill_req, addre_dept_main
#
