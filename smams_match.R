# import des data table

source("smams_src_utilities.R")
library(data.table)
library(stringr)

base_emp = fread("DATA/base_emp.csv")
base_brevets = fread("DATA/base_brevets.csv")


View(base_brevets)

#merging des deux bases 

base_emp_inno = merge(base_emp, base_brevets, all = TRUE)

View(base_emp_inno)

# Nous avons une colonne 'id_firm_name' qui contient des NA, quand c'est le cas, on copie le 
# nom d'entreprise dans 'firm_name' et on l'insère, sur la même ligne, dans 'id_firm_name'

# Remplacer les NA dans id_firm_name par les valeurs de firm_name
base_emp_inno[is.na(id_firm_name), id_firm_name := firm_name]
resultat <- base_emp_inno[, .N, by = id_firm_name]

View(base_emp_inno)
View(resultat)

names(base_emp_inno)


id_firm_counts <- base_emp_inno[, .(
  n_apparitions = .N  # Compte le nombre d'occurrences de chaque id_firm_name
), by = id_firm_name]
# Supprimer les lignes où n_apparitions = 1

# Trier les résultats par n_apparitions décroissant
id_firm_counts <- id_firm_counts[order(-n_apparitions)]
id_firm_counts = id_firm_counts[n_apparitions !=1]
sum(id_firm_counts)

View(id_firm_counts)


# Aggrégation

dt <- base_emp_inno[, {
  # Pour firm_name : sélectionner celle différente de id_firm_name en priorité
  fn = unique(firm_name)
  if(length(fn) > 1) {
    fn = fn[fn != id_firm_name[1]][1]
    if(is.na(fn)) fn = fn[1]
  }
  
  # Fonction helper pour choisir une valeur non-NA, ou au hasard si plusieurs valeurs non-NA
  choose_non_na <- function(x) {
    # S'assurer que x est un vecteur du même type
    x <- as.vector(x)
    x_unique <- unique(x[!is.na(x)])
    if(length(x_unique) == 0) return(x[1])  # Retourne NA du bon type
    if(length(x_unique) == 1) return(x_unique[1])
    return(sample(x_unique, 1))
  }
  
  list(
    firm_name = as.character(fn),  # Forcer le type character
    addr_dept_main = as.character(choose_non_na(addr_dept_main)),
    n_offres = sum(n_offres, na.rm = TRUE),
    sector_main = as.character(choose_non_na(sector_main)),
    avg_req_exp = mean(avg_req_exp, na.rm = TRUE),
    avg_wage = mean(avg_wage, na.rm = TRUE),
    top_skill_req = as.character(choose_non_na(top_skill_req)),
    n_patents = sum(n_patents, na.rm = TRUE),
    ipc_main_code = as.character(choose_non_na(ipc_main_code)),
    ipc_main_desc = as.character(choose_non_na(ipc_main_desc)),
    ipc_second_code = as.character(choose_non_na(ipc_second_code)),
    ipc_second_desc = as.character(choose_non_na(ipc_second_desc)),
    addr_city_main = as.character(choose_non_na(addr_city_main))
  )
}, by = id_firm_name]

View(dt)


#suppression des lignes inutiles

dt <- dt[id_firm_name != firm_name]  # Enlever où id = name
dt <- dt[ipc_main_code != 'NA']  

View(dt)

