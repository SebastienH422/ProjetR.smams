#
# Simon Fraile, Matilin Periat, Ahina Durrieu, Maina Boivent, Sébastien Hein
# 
# File smams_emploi.R
# 
# Creation of the base_emp database
#
# Required files in the DATA folder:
# - base_brevets.csv
# - base_emp.csv
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
base_emp = fread("Data/base_emp.csv")
base_brevets = fread("Data/base_brevets.csv")


# _________________________________________________________________________________________________________________________________
#############
### Merge ###
#############

# Create id_firm_name in both data tables
base_emp$id_firm_name = gsub(',','',iconv(tolower(word(base_emp$firm_name,1)), to = "ASCII//TRANSLIT"))
base_brevets$id_firm_name = gsub(',','',iconv(tolower(word(base_brevets$firm_name,1)), to = "ASCII//TRANSLIT"))

# Merge
base_emp_inno = merge(base_emp, base_brevets, all = TRUE)


# _________________________________________________________________________________________________________________________________
###################
### Aggregation ###
###################

base_emp_inno <- base_emp_inno[, {
  
  list(
    firm_name = first(firm_name),  
    addr_dept_main = as.character(choose_non_na(addr_dept_main)),
    n_offres = choose_non_na(n_offres),
    sector_main = as.character(choose_non_na(sector_main)),
    avg_req_exp = choose_non_na(avg_req_exp),
    avg_wage = choose_non_na(avg_wage),
    top_skill_req = as.character(choose_non_na(top_skill_req)),
    n_patents = choose_non_na(n_patents),
    ipc_main_code = as.character(choose_non_na(ipc_main_code)),
    ipc_main_desc = as.character(choose_non_na(ipc_main_desc)),
    ipc_second_code = as.character(choose_non_na(ipc_second_code)),
    ipc_second_desc = as.character(choose_non_na(ipc_second_desc)),
    addr_city_main = as.character(choose_non_na(addr_city_main))
  )
}, by = id_firm_name] 

# Remove the "id_firm_name" column
base_emp_inno[, id_firm_name := NULL] 


#___________________________________________________________________________________________________________________________________
###################################
### Writing the database to csv ###
###################################

fwrite(base_emp_inno, "Data/base_emp_inno.csv")

#___________________________________________________________________________________________________________________________________
###########
### END ###
###########