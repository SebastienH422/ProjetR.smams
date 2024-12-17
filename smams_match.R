###################################################################################################
###################################################################################################
###################################################################################################
################ par rapport à avant, j'ai mis choose_non_na() à la place de sum() ou (mean) pour les variables numériques
################ car sinon on avait 0 au lieu de NA
################ ça a l'air de marcher, au niveau des stat j'ai tout pareil que dans les tables séparées, à part la moyenne du nombre de brevets (je comprends pas pk)
###################################################################################################
###################################################################################################
###################################################################################################




# import des data table

source("smams_src_utilities.R")
library(data.table)
library(stringr)

base_emp = fread("Data/base_emp.csv")
base_brevets = fread("Data/base_brevets.csv")


# On crée id_firm_name pour le merge
base_emp$id_firm_name = gsub(',','',iconv(tolower(word(base_emp$firm_name,1)), to = "ASCII//TRANSLIT"))
base_brevets$id_firm_name = gsub(',','',iconv(tolower(word(base_brevets$firm_name,1)), to = "ASCII//TRANSLIT"))

# Merge
base_emp_inno = merge(base_emp, base_brevets, all = TRUE)

# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# ____________________________________________________   VERIF   ______________________________________________________________
# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________

# id_firm_counts <- base_emp_inno[, .(
#   n_apparitions = .N  # Compte le nombre d'occurrences de chaque id_firm_name
# ), by = id_firm_name]
# # Supprimer les lignes où n_apparitions = 1

# # Trier les résultats par n_apparitions décroissant
# id_firm_counts <- id_firm_counts[order(-n_apparitions)]
# id_firm_counts = id_firm_counts[n_apparitions ==1]
# sum(id_firm_counts)

# View(id_firm_counts)
# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# _____________________________________________________   END   _______________________________________________________________
# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________


# Aggrégation

base_emp_inno <- base_emp_inno[, {
  # Pour firm_name : sélectionner celle différente de id_firm_name en priorité
  # fn = unique(firm_name)
  # if(length(fn) > 1) {
  #   fn = fn[fn != id_firm_name[1]][1]
  #   if(is.na(fn)) fn = fn[1]
  # }
  
  
  
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

#suppression des lignes inutiles

base_emp_inno[, id_firm_name := NULL] 


# Sauvegarde des données
fwrite(base_emp_inno, "Data/base_emp_inno.csv")

View(base_emp_inno)
