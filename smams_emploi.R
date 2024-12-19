#
# Simon Fraile, Matilin Periat, Ahina Durrieu, Maina Boivent, Sébastien Hein
# 
# File smams_emploi.R 
# 
# Creation of the base_emp database
#
# Required files in the DATA folder:
# - emp_offers_fmt.tsv
#
#
###########################
### Importing libraries ###
###########################
source("smams_src_utilities.R")
library(data.table)
library(stringr)

# _________________________________________________________________________________________________________________________________
######################
### Importing data ###
######################
data = data.table(read.csv(file = "DATA/emp_offers_fmt.tsv", # Import
                           head = TRUE,
                           sep = ","))

# _________________________________________________________________________________________________________________________________
######################
### Data filtering ###
######################

# Keep only the following fields:
# entreprise, secteur, experience_requise, competences_requises, salaire, departement
offres = data[, .(entreprise, secteur, experience_requise, competences_requises, salaire, departement)]
# Apply the salary processing function
offres[, avg_wage := sapply(salaire, get_wage)]
# Clean competences_requises column before grouping
offres[, competences_requises := sapply(competences_requises, clean_competences)]

# _________________________________________________________________________________________________________________________________
#########################
### Name modification ###
#########################
#
# Create the firm_name column containing the company name,
# and id_firm_name to group companies together
# For example, 'Peugeot' and 'Peugeot SA' are the same company. In id_firm_name, the value will be 'peugeot' for both.
offres$id_firm_name = gsub(',','',iconv(tolower(word(offres$entreprise,1)), to = "ASCII//TRANSLIT"))


# _________________________________________________________________________________________________________________________________
############################
### Creating base_emploi ###
############################

# Group by firm_name, and calculate all other columns
base_emp = offres[, .(
  firm_name = get_top_val(entreprise, 1),                      # Firm name
  n_offres = .N,                                              # Number of offers
  sector_main = as.character(get_most_frequent(secteur)), # Most frequent sectors
  avg_req_exp = ifelse(is.na(mean(experience_requise, na.rm = TRUE)), NA_real_, round(mean(experience_requise, na.rm = TRUE))), # Average experience, round 1
  avg_wage = ifelse(is.nan(mean(avg_wage, na.rm = TRUE)), NA_real_, mean(avg_wage, na.rm = TRUE)), # Average annual salary
  addr_dept_main = get_top_val(departement, 1),  # Most common department
  top_skill_req = get_most_frequent(competences_requises)  # Most frequent skills
), by = id_firm_name]

# Remove the "id_firm_name" column
base_emp[, id_firm_name := NULL]
# Keep only companies with a name
base_emp = base_emp[firm_name != ""]

#___________________________________________________________________________________________________________________________________
###################################
### Writing the database to csv ###
###################################

fwrite(base_emp, "DATA/base_emp.csv")

#___________________________________________________________________________________________________________________________________
###########
### END ###
###########