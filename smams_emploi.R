#
# Simon Fraile, Matilin Periat, Ahina Durrieu, Maina Boivent, Sébastien Hein
#
# Fichier smams_emploi.R
# 
# Création de la base de données base_emp
#
# Fichiers requis dans le dossier DATA:
# - emp_offers_fmt.tsv
#
#
#################################
### Importation des libraries ###
#################################
source("smams_src_utilities.R")
library(data.table)
library(stringr)

# _________________________________________________________________________________________________________________________________
###############################
### Importation des données ###
###############################
data = data.table(read.csv(file = "Data/emp_offers_fmt.tsv", # Importation
                           head = TRUE,
                           sep = ","))

# _________________________________________________________________________________________________________________________________
############################
### Filtrage des données ###
############################
# On conserve uniquement les champs suivant:
# entreprise, secteur, experience_requise, competences_requises, salaire, departement

offres = data[, .(entreprise, secteur, experience_requise, competences_requises, salaire, departement)]

offres$id_firm_name = gsub(',','',iconv(tolower(word(offres$entreprise,1)), to = "ASCII//TRANSLIT"))


# Apply the salary processing function
offres[, avg_wage := sapply(salaire, get_wage)]
# Clean competences_requises column before grouping
offres[, competences_requises := sapply(competences_requises, clean_competences)]

# Group by firm_name, and calculate all other columns
base_emp = offres[, .(
  firm_name = get_top_val(entreprise, 1),                      # Firm name
  n_offres = .N,                                              # Number of offers
  sector_main = as.character(get_most_frequent(secteur)), # Most frequent sectors
  avg_req_exp = ifelse(is.na(mean(experience_requise, na.rm = TRUE)), NA, mean(experience_requise, na.rm = TRUE)), # Average experience, round 1
  avg_wage = ifelse(is.nan(mean(avg_wage, na.rm = TRUE)), NA_real_, mean(avg_wage, na.rm = TRUE)), # Average annual salary
  addr_dept_main = get_top_val(departement, 1),  # Most common department
  top_skill_req = get_most_frequent(competences_requises)  # Most frequent skills
), by = id_firm_name]

# Remove the "id_firm_name" column
base_emp[, id_firm_name := NULL]

base_emp = base_emp[firm_name != ""]

View(base_emp)

# export en fichier csv

fwrite(base_emp, "Data/base_emp.csv")
