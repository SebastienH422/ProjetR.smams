#
# Simon Fraile, Matilin Periat, Ahina Durrieu, Maina Boivent, Sébastien Hein
# 
# File smams_brevet.R
#  
# Creation of the base_brevets database
#
# Required files in the DATA folder:
# - 202202_EPO_App_reg_small.txt
# - 202202_EPO_IPC_small.txt
# - EN_ipc_section_A_title_list_20120101.txt
# - EN_ipc_section_B_title_list_20120101.txt
# - EN_ipc_section_C_title_list_20120101.txt
# - EN_ipc_section_D_title_list_20120101.txt
# - EN_ipc_section_E_title_list_20120101.txt
# - EN_ipc_section_F_title_list_20120101.txt
# - EN_ipc_section_G_title_list_20120101.txt
# - EN_ipc_section_H_title_list_20120101.txt
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

brevets = data.table(read.csv(file = "DATA/202202_EPO_App_reg_small.txt",
                              head = TRUE,
                              sep = ","))

ipc = data.table(read.csv(file = "DATA/202202_EPO_IPC_small.txt",
                          head = TRUE,
                          sep = ","))

# Remove unnecessary columns
brevets[, c("app_nbr", "pub_nbr", "person_id", "address", "reg_code", "reg_share", "app_share") := NULL]
ipc[, app_year := NULL]

# Format postal codes to department numbers
brevets[, postal_code := as.integer(substr(postal_code, 1, 2))]

# _________________________________________________________________________________________________________________________________
######################
### Data filtering ###
######################

# 1st filter: Keep only French companies
brevets = brevets[ctry_code == "FR"]
# Same for ipc data
ipc = ipc[appln_id %in% brevets[, appln_id]]  
# Remove the ctry_code column
brevets[, ctry_code := NULL]

# 2nd filter: Keep only patents filed between 2010 and 2020
ipc = ipc[prio_year >= 2010 & prio_year <= 2020]
# Same for patents
brevets = brevets[appln_id %in% ipc[, appln_id]]
# No longer need the prio_year variable
ipc[, prio_year := NULL]

# 3rd filter: Keep only the first 4 characters of ipc
ipc$IPC = substr(ipc$IPC, 1, 4)

# _________________________________________________________________________________________________________________________________
#########################
### Name modification ###
#########################
#
# Create the firm_name column containing the company name,
# and id_firm_name to group companies together
# For example, 'Peugeot' and 'Peugeot SA' are the same company. In id_firm_name, the value will be 'peugeot' for both.
brevets$firm_name = brevets$app_name
# Keep only the first word, in lowercase, remove accents, commas, and other symbols
brevets$id_firm_name = gsub(',','',iconv(tolower(word(brevets$app_name,1)), to = "ASCII//TRANSLIT"))
brevets[, app_name := NULL]

# _________________________________________________________________________________________________________________________________
#############################
### Creating base_brevets ###
#############################

# Merge the two data tables
base_brevets = merge(brevets, ipc, by='appln_id')
# Initialize the number of patents to 1
base_brevets[, n_patents := 1]

#___________________________________________________________________________________________________________________________________
##################
### Adding ipc ###
##################

# Add ipc_main_code and ipc_second_code columns
base_brevets[, c("ipc_main_code", "ipc_second_code") := {
  top_ipc <- find_top_ipc(IPC)
  list(top_ipc[1], ifelse(length(top_ipc) > 1, top_ipc[2], NA))
}, by = id_firm_name]

base_brevets[, IPC := NULL]

#___________________________________________________________________________________________________________________________________
###################
### Aggregation ###
###################

# Aggregate by id_firm_name to consider that company names like 'Peugeot SA' and 'peugeot'
# describe the same companies
base_brevets = base_brevets[, .(
  firm_name = first(firm_name),
  n_patents = sum(n_patents),
  ipc_main_code = first(ipc_main_code),
  ipc_second_code = first(ipc_second_code),
  addr_city_main = first(city),
  addr_dept_main = first(postal_code)
), by = id_firm_name]

# No longer need id_firm_name
base_brevets[, id_firm_name := NULL]

#___________________________________________________________________________________________________________________________________
###############################
### Adding ipc descriptions ###
###############################

# Names of ipc description files
lettres = LETTERS[1:8] # vector with A,B,..,H
fichiers = paste0("DATA/EN_ipc_section_", lettres, "_title_list_20120101.txt") # IPC descriptions

# Import files
desc_separe = lapply(fichiers, function(f){
  data.table(read.csv(file = f, head = TRUE, sep = "\t"))
})
names(desc_separe) = LETTERS[1:8]

# Determine ipc_main_desc. Need to:
# - isolate the first letter of each ipc code,
# - look up the associated description in desc_separe$'X',
# - add it to the ipc_main_desc variable.
#
# Do the same for ipc_second_desc

# Extract the first letter of each ipc_main_code
base_brevets[, first_letter_main := substr(ipc_main_code, 1, 1)]
base_brevets[, first_letter_second := substr(ipc_second_code, 1, 1)]

# For each first letter, join with the corresponding data table
for (letter in LETTERS[1:8]) {
  # Get the name of the second column
  desc_col = names(desc_separe[[letter]])[2]
  
  base_brevets[first_letter_main == letter, 
               ipc_main_desc := desc_separe[[letter]][.(ipc_main_code), get(desc_col), on=letter]]
  base_brevets[first_letter_second == letter, 
               ipc_second_desc := desc_separe[[letter]][.(ipc_second_code), get(desc_col), on=letter]]
}

# Remove the temporary first_letter column
base_brevets[, c('first_letter_main', 'first_letter_second') := NULL]


#___________________________________________________________________________________________________________________________________
###################################
### Writing the database to csv ###
###################################

fwrite(base_brevets, "DATA/base_brevets.csv") 

#___________________________________________________________________________________________________________________________________
###########
### END ###
###########
