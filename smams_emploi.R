

# Libraries
source("smams_src_utilities.R")
library(data.table)
library(stringr)
getwd()
setwd('/net/cremi/mboivent/Bureau/espaces/travail/S7/R/projet/ProjetR.smams-main')
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
offres = data[, .(entreprise, secteur, experience_requise, competences_requises, salaire, departement)]

# Apply the salary processing function
offres[, avg_wage := sapply(salaire, get_wage)]

# Clean competences_requises column before grouping
offres[, competences_requises := sapply(competences_requises, clean_competences)]
offres$id_firm_name = gsub(',','',iconv(tolower(word(offres$entreprise,1)), to = "ASCII//TRANSLIT"))
# Group by firm_name, and calculate all other columns
base_emp = offres[, .(
  firm_name = set_firm_name(entreprise),                      # Firm name
  n_offres = .N,                                              # Number of offers
  sector_main = as.character(get_most_frequent(secteur)), # Most frequent sectors
  avg_req_exp = round(sum(experience_requise, na.rm = TRUE) / sum(!is.na(experience_requise)), 1), # Average experience, round 1
  # avg_wage = 0,
  avg_wage = mean(avg_wage, na.rm = TRUE),                     # Average annual salary
  addr_dept_main = get_top_val(departement, 1),  # Most common department
  top_skill_req = as.character(get_most_frequent(competences_requises))  # Most frequent skills
), by = id_firm_name]


# Remove the "id_firm_name" column
base_emp[, id_firm_name := NULL]

base_emp = base_emp[firm_name != ""]

View(base_emp)

# export en fichier csv

fwrite(base_emp, "Data/base_emp.csv")
