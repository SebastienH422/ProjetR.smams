
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

# changement
offres <- data[, .(entreprise, secteur, experience_requise, competences_requises, salaire, departement)]

# Apply the salary processing function
offres[, avg_wage := sapply(salaire, get_wage)]

# Clean competences_requises column before grouping
offres[, competences_requises := sapply(competences_requises, clean_competences)]

# Group by firm_name, and calculate all other columns
base_emp = offres[, .(
  firm_name = set_firm_name(entreprise),                      # Firm name
  n_offres = .N,                                              # Number of offers
  sector_main = get_top_val(secteur, 4), # Flattened and top 4 sectors
  avg_req_exp = round(sum(experience_requise, na.rm = TRUE) / sum(!is.na(experience_requise)), 1), # Average experience, round 1
  # avg_wage = 0,
  avg_wage = mean(avg_wage, na.rm = TRUE),                     # Average annual salary
  addr_dept_main = get_top_val(departement, 1),  # Most common department
  top_skill_req = get_top_val(competences_requises, 4),  # Top 4 most frequent skills
  id_firm_name = get_id_firm() #tolower(word(set_firm_name(entreprise), 1))
), by = entreprise]


# Remove the "entreprise" column and rename grouped by "firm_name"
base_emp[, entreprise := NULL]

# Print the final grouped results
View(base_emp)

head(base_emp)


# Regroupement par id_firm_name pour obtenir les statistiques demandées
# Compter les occurrences de chaque id_firm_name
id_firm_counts <- base_emp[, .(
  n_apparitions = .N  # Compte le nombre d'occurrences de chaque id_firm_name
), by = id_firm_name]
# Supprimer les lignes où n_apparitions = 1
id_firm_counts <- id_firm_counts[n_apparitions > 1]

# Trier les résultats par n_apparitions décroissant
id_firm_counts <- id_firm_counts[order(-n_apparitions)]


View(id_firm_counts)
######################################################

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
# Aggréger selon id_firm en fusionnant:
#   - Concaténation des listes sur firm_name, sector_name, top_skill_req, addre_dept_main
#   - Somme des numerics sur n_offres
#   - Moyenne des valeurs sur avg_req_exp, avg_wage
#
# Appliquer les fonctions:
#   - get_top_val sur la colonne sector_name, top_skill_req, addre_dept_main
#
