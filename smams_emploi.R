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
data = data.table(read.csv(file = "emp_offers_fmt.tsv", # Importation
                  head = TRUE,
                  sep = ","))
names(data) # Récupération des champs

offres = data[, c("entreprise", "secteur", # Création de 'offres'
              "experience_requise", "competences_requises", "salaire", "departement")]


# Création de la data.table 'base_emp'
#
base_emp = data.table(id_firm = character(0), firm_name = character(0), n_offres = integer(0), 
                      sector_main = character(0), avg_req_exp = numeric(0), top_skill_req = character(0), 
                      avg_wage = numeric(0), addre_dept_main = character(0))
