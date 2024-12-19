#
# Simon Fraile, Matilin Periat, Ahina Durrieu, Maina Boivent, Sébastien Hein
#
# Fichier smams_brevet.R
# 
# Création de la base de données base_brevets
#
# Fichiers requis dans le dossier DATA:
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
#################################
### Importation des libraries ###
#################################

library(data.table)
library(stringr)

# _________________________________________________________________________________________________________________________________
###############################
### Importation des données ###
###############################

brevets = data.table(read.csv(file = "Data/202202_EPO_App_reg_small.txt",
                              head = TRUE,
                              sep = ","))

ipc = data.table(read.csv(file = "Data/202202_EPO_IPC_small.txt",
                          head = TRUE,
                          sep = ","))

# On se débarrasse des colonnes inutiles
brevets[, c("app_nbr", "pub_nbr", "person_id", "address", "reg_code", "reg_share", "app_share") := NULL]
ipc[, app_year := NULL]

# On formate les codes postales en numéros de département
brevets[, postal_code := as.integer(substr(postal_code, 1, 2))]

# _________________________________________________________________________________________________________________________________
############################
### Filtrage des données ###
############################

# 1er filtrage: Garder uniquement les entreprises françaises. 
brevets = brevets[ctry_code == "FR"]
# idem pour les données dans ipc
ipc = ipc[appln_id %in% brevets[, appln_id]]  
# On se débarrasse de la colonne ctry_code
brevets[, ctry_code := NULL]

# 2ème filtrage: Garder uniquement les brevets déposés entre 2010 et 2020.
ipc = ipc[prio_year >= 2010 & prio_year <= 2020]
# Idem pour les brevets
brevets = brevets[appln_id %in% ipc[, appln_id]]   #prio_year >= 2010 & prio_year <= 2020
# On n'a plus besoin de la variable prio-year
ipc[, prio_year := NULL]

# 3ème filtrage: Garder uniquement les 4 premiers caractères des ipc
ipc$IPC = substr(ipc$IPC, 1 ,4)

# _________________________________________________________________________________________________________________________________
###########################
### Modification du nom ###
###########################
#
# On crée la colonne firm_name contenant le nom de l'entreprise,
# ainsi que id_firm_name permettant de rassembler les entreprises entre elles 
# Par exemple, 'Peugeot' et 'Peugeot SA' sont les mêmes entreprises. Dans id_firm_name, la valeur sera 'peugeot' pour les deux.
brevets$firm_name = brevets$app_name
# On garde uniquement le premier mot, en minuscule, on supprime les accents, virgules et autres symboles
brevets$id_firm_name = gsub(',','',iconv(tolower(word(brevets$app_name,1)), to = "ASCII//TRANSLIT"))
brevets[, app_name := NULL]

# _________________________________________________________________________________________________________________________________
################################
### Création de base_brevets ###
################################

# Merge des deux data table
base_brevets = merge(brevets, ipc, by='appln_id')
# Initialisation du nombre de brevet à 1
base_brevets[, n_patents := 1]

#___________________________________________________________________________________________________________________________________
#####################
### Ajout des ipc ###
#####################

# Ajouter les colonnes ipc_main_code et ipc_second_code
base_brevets[, c("ipc_main_code", "ipc_second_code") := {
  top_ipc <- find_top_ipc(IPC)
  list(top_ipc[1], ifelse(length(top_ipc) > 1, top_ipc[2], NA))
}, by = id_firm_name]

base_brevets[, IPC := NULL]

#___________________________________________________________________________________________________________________________________
###################
### Aggrégation ###
###################

# On agrège selon id_firm_name pour considérer que les noms d'entreprises telles que 'Peugeot SA' et 'peugeot' 
# décrivent les mêmes entreprises
base_brevets = base_brevets[, .(
  firm_name = first(firm_name),
  n_patents = sum(n_patents),
  ipc_main_code = first(ipc_main_code),
  ipc_second_code = first(ipc_second_code),
  addr_city_main = first(city),
  addr_dept_main = first(postal_code)
), by = id_firm_name]

# On n'a plus besoin de id_firm_name
base_brevets[, id_firm_name := NULL]

#___________________________________________________________________________________________________________________________________
######################################
### Ajout des descriptions des ipc ###
######################################

# Nom des fichiers de description des ipc
lettres = LETTERS[1:8] # vecteur avec A,B,..,H
fichiers = paste0("Data/EN_ipc_section_", lettres, "_title_list_20120101.txt") # Description des IPC

# Import des fichiers
desc_separe = lapply(fichiers, function(f){
  data.table(read.csv(file = f, head = TRUE, sep = "\t"))
})
names(desc_separe) = LETTERS[1:8]

# On va déterminer les ipc_main_desc. Il faut:
# - isoler la première lettre de chaque ipc code, 
# - aller chercher dans desc_separe$'X' la description associée,
# - l'ajouter à la variable ipc_main_desc. 
#
# Et faire de même pour ipc_second_desc

# On extrait la première lettre de chaque ipc_main_code
base_brevets[, first_letter_main := substr(ipc_main_code, 1, 1)]
base_brevets[, first_letter_second := substr(ipc_second_code, 1, 1)]
View(base_brevets)
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
base_brevets[, c('first_letter_main', 'first_letter_second') := NULL]


#___________________________________________________________________________________________________________________________________
#############################################
### Ecriture de la base de données en csv ###
#############################################

fwrite(base_brevets, "Data/base_brevets.csv") 

#___________________________________________________________________________________________________________________________________
###########
### FIN ###
###########