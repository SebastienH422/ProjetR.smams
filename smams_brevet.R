# Libraries
source("smams_src_utilities.R")

## IMPORT DES DATA

library(data.table)
library(stringr)

data = data.table(read.csv(file = "Data/emp_offers_fmt.tsv",
                           head = TRUE,
                           sep = ","))

brevets = data.table(read.csv(file = "Data/202202_EPO_App_reg_small.txt",
                              head = TRUE,
                              sep = ","))

ipc = data.table(read.csv(file = "Data/202202_EPO_IPC_small.txt",
                          head = TRUE,
                          sep = ","))


### Filtrage des données  
# Question 1: 

# 1ère restriction: garder uniquement les entreprises françaises. 
# Donc il suffit d'appliquer un filtre selon la variable ctry_code:

brevets = brevets[ctry_code == "FR"]
# idem pour ipc
ipc = ipc[appln_id %in% brevets[, appln_id]]  

# On se débarrasse des colonnes inutiles
brevets[, ctry_code := NULL]
brevets[, app_nbr := NULL]
brevets[, pub_nbr := NULL]
brevets[, person_id := NULL]
brevets[, reg_code := NULL]
brevets[, reg_share := NULL]
brevets[, app_share := NULL]
ipc[, app_year := NULL]

# On formate les codes postales en numéros de département
brevets[, postal_code := as.integer(substr(postal_code, 1, 2))]

# 2ème restriction: garder uniquement les brevets déposés entre 2010 et 2020: 
# même raisonnement que ci-dessus, mais cette fois-ci, on doit travailler sur la data table 'ipc'

ipc = ipc[prio_year >= 2010 & prio_year <= 2020]
# Idem pour les brevets
brevets = brevets[appln_id %in% ipc[, appln_id]]   #prio_year >= 2010 & prio_year <= 2020

# On n'a plus besoin de la variable prio-year
ipc[, prio_year := NULL]
# ensuite, nous devons modifier les codes ipc et les tronquer à 4 caractères. 

ipc$IPC = substr(ipc$IPC, 1 ,4)
# Ici ,tous les codes ipc sont maintenant de taille 4. 

# _________________________________________________________________________________________________________________________________
###########################
### Modification du nom ###
###########################

# On crée la colonne firm_name contenant le nom de l'entreprise,
# ainsi que id_firm_name permettant de rassembler les entreprises entre elles 
# Par exemple, 'Peugeot' et 'Peugeot SA' sont les mêmes entreprises. Dans id_firm_name, la valeur sera 'peugeot' pour les deux.
brevets$firm_name = brevets$app_name
brevets$id_firm_name = gsub(',','',iconv(tolower(word(brevets$app_name,1)), to = "ASCII//TRANSLIT"))
brevets[, app_name := NULL]

# _________________________________________________________________________________________________________________________________
################################
### Création de base_brevets ###
################################

# On veut maintenant : 

#   _créer la data table "base_brevets" qui contiendra : id_firm_names| n_patents | addr_city_main | addr_dept_main | ipc_main_code | ipc_main_desc ...........
#   _Déterminer quels sont les deux ipc principaux (en occurence), pour chaque entreprise présente dans "brevets". On les stockera dans "ipc_main_code" et "ipc_second_code"
#   _Trouver les descriptions des codes ipc trouvés. On les stockera dans "ipc_main_desc" et "ipc_second_desc".

# On commence par initialiser la data table : 

# id_firm_name = unique(brevets$app_name) #ici, on attribue à firm name les noms des entreprises (sans redondance)
# firm_name = unique(brevets$firm_name)

base_brevets = merge(brevets, ipc, by='appln_id')
base_brevets[, n_patents := 1]

#___________________________________________________________________________________________________________________________________
#####################
### Ajout des ipc ###
#####################

find_top_ipc <- function(ipc_codes) {
  ipc_counts <- sort(table(ipc_codes), decreasing = TRUE)
  top_ipc <- names(ipc_counts)[1:2]
  return(top_ipc)
}

# Ajouter les colonnes ipc_main_code et ipc_second_code
base_brevets[, c("ipc_main_code", "ipc_second_code") := {
  top_ipc <- find_top_ipc(IPC)
  list(top_ipc[1], ifelse(length(top_ipc) > 1, top_ipc[2], NA))
}, by = id_firm_name]

base_brevets[, IPC := NULL]

base_brevets = base_brevets[, .(
  firm_name = first(firm_name),
  n_patents = sum(n_patents),
  ipc_main_code = first(ipc_main_code),
  ipc_second_code = first(ipc_second_code),
  addr_city_main = first(address),
  addr_dept_main = first(postal_code)
), by = id_firm_name]

# On n'a plus besoin de id_firm_name
base_brevets[, id_firm_name := NULL]

#___________________________________________________________________________________________________________________________________
######################################
### Ajout des descriptions des ipc ###
######################################

# Nom des fichiers
lettres = LETTERS[1:8] # vecteur avec A,B,..,H
fichiers = paste0("Data/EN_ipc_section_", lettres, "_title_list_20120101.txt") # Description des IPC

# Import des fichiers
desc_separe = lapply(fichiers, function(f){
  data.table(read.csv(file = f, head = TRUE, sep = "\t"))
})
names(desc_separe) = LETTERS[1:8]

# desc_separe est une liste qui contient les data table pour les 8 fichiers (A à H)
# Chaque data table est nommée par sa lettre

### ipc_main_desc / ipc_second_desc

# On va déterminer les ipc_main_desc. Il faut:
# - isoler la première lettre de chaque ipc code, 
# - aller chercher dans desc_separe$'X' la description associée,
# - l'ajouter à la variable ipc_main_desc. 

# On extrait la première lettre de chaque ipc_main_code
base_brevets[, first_letter_main := substr(ipc_main_code, 1, 1)]
base_brevets[, first_letter_second := substr(ipc_second_code, 1, 1)]

# Pour chaque première lettre, on fait une jointure avec la data table correspondante
for (letter in LETTERS[1:8]) {
  # On récupère le nom de la deuxième colonne
  desc_col = names(desc_separe[[letter]])[2]
  
  base_brevets[first_letter_main == letter, 
               ipc_main_desc := desc_separe[[letter]][.(ipc_main_code), get(desc_col), on=letter]]
  base_brevets[first_letter_second == letter, 
               ipc_second_desc := desc_separe[[letter]][.(ipc_second_code), get(desc_col), on=letter]]
}

# On supprime la colonne temporaire first_letter
base_brevets[, first_letter_main := NULL]
base_brevets[, first_letter_second := NULL]


#___________________________________________________________________________________________________________________________________
#############################################
### Ecriture de la base de données en csv ###
#############################################

fwrite(base_brevets, "Data/base_brevets.csv")


# On obtient bien la data table finale 'base_brevets' avec toutes les données souhaitées. 

### -- 
## FIN