# Libraries
source("smams_src_utilities.R")

## IMPORT DES DATA

library(data.table)
library(stringr)
getwd()
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


# 2ème restriction: garder uniquement les brevets déposés entre 2010 et 2020: 
# même raisonnement que ci-dessus, mais cette fois-ci, on doit travailler sur la data table 'ipc'

ipc = ipc[prio_year >= 2010 & prio_year <= 2020]


# ensuite, nous devons modifier les codes ipc et les tronquer à 4 caractères. 

ipc$IPC = substr(ipc$IPC, 1 ,4)

# Ici ,tous les codes ipc sont maintenant de taille 4. 

# On va filtrer les noms d'entreprises. essayons de stocker dans un vecteur le premier mot de chaque entreprise.

# Le code ci-dessous fait deux choses. word('string', 1) conserve uniquement les charactères avant le premier espace. tolower() permet de mettre tous les noms d'entreprises en minuscules. 

brevets$app_name = tolower(word(brevets$app_name,1))

# En plus de cela, on enlève les accents. Je vais utiliser 'iconv' qui est une fonction de base de R. 
# iconv permet de convertir une chaine de charactère.ASCII ne gère pas les accents donc si on transcrit nos noms d'entreprises en ASCII, les accents disparaissent.  

brevets$app_name = iconv(brevets$app_name, to = "ASCII//TRANSLIT")

# Enfin, certains noms d'entreprises comportaient des virgules collées aux premiers mots ce qui fait qu'on les a conservées. On le supprime également.

brevets$app_name = gsub(',','',brevets$app_name)

# Maintenant qu'on a filtré les noms d'entreprises, on regarde le nombre de chaque IPC déposé par les entreprises. 


# Récapitulatif: On a :

  # _une data_table  "brevets" sur les données liées aux brevets. Cette data table a été triée afin de ne conserver que les données liées à la France.  
  #   _une data table "ipc" sur les ipc, triés de façon à garder seulement ceux entre les années 2010-2020, et tronqués à 4 ipc.


### ---
## CREATION DE LA DT BASE_BREVETS

# On veut maintenant : 
  
#   _créer la data table "base_brevets" qui contiendra : firm_names| n_patents | addr_city_main | addr_dept_main | ipc_main_code | ipc_main_desc ...........
#   _Déterminer quels sont les deux ipc principaux (en occurence), pour chaque entreprise présente dans "brevets". On les stockera dans "ipc_main_code" et "ipc_second_code"
#   _Trouver les descriptions des codes ipc trouvés. On les stockera dans "ipc_main_desc" et "ipc_second_desc".
  
# On commence par initialiser la data table : 

firm_name = unique(brevets$app_name) #ici, on attribue à firm name les noms des entreprises (sans redondance)

base_brevets <- data.table(firm_name=firm_name,
                          n_patents=0,  #au début, on initialise le nombre de brevets de chaque entreprise à 0, cette valeur sera actualisée au fur et à mesure. 
                          ipc_main_code="",
                          ipc_main_desc="",
                          ipc_second_code="",
                          ipc_second_desc="",
                          addr_city_main="",
                          addr_dept_main="")



### n_patents

# On veut maintenant déterminer combien de brevets chaque entreprise a déposé.

# il faut faire attention au fait que les dates ne sont pas triées dans brevets alors qu'elles le sont dans ipc. Donc, on ne doit considérer que les entreprises dont les dates sont comprises entre 2010 et 2020 dans ipc.
brevets = brevets[appln_id %in% ipc[, appln_id]]   #prio_year >= 2010 & prio_year <= 2020

nombre = brevets[, .N, by = app_name] # cette ligne créer une petite data.table avec deux colonnes : une app_name et une n_patent (nb de brevets déposé pour app_name correspondant)

base_brevets[nombre, n_patents := i.N, on = .(firm_name = app_name)] #On met à jour la colonne n_patents en joignant base_brevets et nombre selon firm_name;


### addr_city_main

# On va maintenant rechercher addr_city_main pour chaque entreprise. Suffit de regarder quelle ville dans la colonne "city" de la data table "brevets" apparaît le plus pour chaque ville de base_brevets. 

villes_principales = brevets[, .(ville = city[which.max(.N)]), by=app_name] # dans brevets, on compte les occurences de chaque ville. which.max() trouve l'indice de valeur max et on attribue a addr_city_main la ville concernée..
base_brevets[villes_principales, addr_city_main := ville, on=.(firm_name=app_name)] # mise a jour de base_brevets selon villes_principales;


### addr_dept_main

# On fait la même chose pour addr_dept_main, mais on doit quand même tronquer les codes postaux aux deux premiers chiffrs (seul les départements nous intéressent)

brevets$postal_code = substr(brevets$postal_code,1,2) #conserve seulement les deux premiers chiffres de postal_code dans brevets

dept_principaux = brevets[, .(departement = postal_code[which.max(.N)]), by=app_name]  #ici c'est quasimment la même structure que pour les villes..
base_brevets[dept_principaux, addr_dept_main := departement, on = .(firm_name = app_name)]


### --- 
## AJOUT DES VARIABLES SUR LES IPC

# Maintenant, on doit trouver : ipc_main_code; ipc_main_desc; ipc_second_code; ipc_second_desc. 

# Pour commencer, on joint les deux DT brevets et ipc. IL FAUT absolument considérer le fait que seul les appln_id présents dans brevets doivent être fusionnés avec ipc
merged = merge(brevets, ipc, by="appln_id")
merged

# Je vais maintenant chercher les deux ipc principaux pour chaque nom d'entreprise. Je fais la recherche dans la table "merged"

merged = as.data.table(merged)
ipc_count = merged[, .N, by=.(app_name, IPC)]


# On a obtenu une data table qui nous donne le nombre d'occurence de chaque ipc pour chaque entreprise. On peut donc effectuer un tri par ordre décroissant. 

ipc_ordre = ipc_count[order(app_name,-N)]


### ipc_main_code / ipc_second_code

# Enfin, on peut conserver les deux ipcs qui arrivent en premier pour chaque nom d'entreprise. 
main_ipc = ipc_ordre[,head(.SD,1), by=app_name]
second_ipc = ipc_ordre[, tail(head(.SD, 2), 1), by = app_name]
#fonctionnement : "by_appname" trie selon les noms. 
                  #"head(.SD, 2) permet de conserver seulement les deux premières lignes apparaissant pour un nom d'entreprise. 


base_brevets[main_ipc, ipc_main_code := i.IPC, on=.(firm_name = app_name)]
base_brevets[second_ipc, ipc_second_code := i.IPC, on=.(firm_name = app_name)]

#On peut supprimer les lignes pour lesquelles n_patents < 0. 
base_brevets = base_brevets[n_patents > 0]


# Maintenant, on doit déterminer les ipc_main_desc et ipc_second_desc pour chaque ipc trouvé.
# Les descriptions associées à chaque ipc sont stockées dans différents fichiers. Un code Ipc commençant par la lettre "A" vera ses données stockées dans le fichier 
# "EN_ipc_section_A_title_list_20120101.txt" par exemple. 
# On doit donc importer chacun de ces fichiers et les stocker soit dans autant de data table que de fichier/ soit une seule data table. C'est ce que je choisis de faire. 


# Je code pour pouvoir importer les différents fichiers sans réécrire à chaque fois la même chose. 

### import des dt ipc. 

lettres = LETTERS[1:8] # vecteur avec A,B,..,H

fichiers = paste0("Data/EN_ipc_section_", lettres, "_title_list_20120101.txt")

desc_separe = lapply(fichiers, function(f){
  data.table(read.csv(file = f, head = TRUE, sep = "\t"))
})

# desc_separe est une liste qui contient les data table  pour les 8 fichiers (A à H)
#pour faciliter l'accès à ces data table, on nomme les éléments de la liste avec names :
  
  names(desc_separe) = LETTERS[1:8]
desc_separe$A

#On obtient plusieurs data.table contenant chacune les données liées au différentes lettres de A à H. On combine toutes ces data table :
desc_separe$H[H == "H01M"]


### ipc_main_desc / ipc_second_desc

# On va essayer de déterminer les ipc_main_desc. Il faut isoler la première lettre de chaque ipc code, aller cherche dans desc_separe$'X' la description associée et l'ajouter à la variable ipc_main_desc. 


# D'abord on extrait la première lettre de chaque ipc_main_code
base_brevets[, first_letter := substr(ipc_main_code, 1, 1)]

# Pour chaque première lettre, on fait une jointure avec la data table correspondante
for (letter in LETTERS[1:8]) {
  # On récupère le nom de la deuxième colonne
  desc_col = names(desc_separe[[letter]])[2]
  
  base_brevets[first_letter == letter, 
               ipc_main_desc := desc_separe[[letter]][.(ipc_main_code), get(desc_col), on=letter]]
}

# On supprime la colonne temporaire first_letter
base_brevets[, first_letter := NULL]



# On reproduit exactement la même chose mais pour la variable 'ipc_second_desc'. 

# D'abord on extrait la première lettre de chaque ipc_second_code
base_brevets[, first_letter := substr(ipc_second_code, 1, 1)]

# Pour chaque première lettre, on fait une jointure avec la data table correspondante
for (letter in LETTERS[1:8]) {
  # On récupère le nom de la deuxième colonne
  desc_col = names(desc_separe[[letter]])[2]
  
  base_brevets[first_letter == letter, 
               ipc_second_desc := desc_separe[[letter]][.(ipc_second_code), get(desc_col), on=letter]]
}

# On supprime la colonne temporaire first_letter
base_brevets[, first_letter := NULL]
fwrite(base_brevets, "Data/base_brevets.csv")

# ça fonctionne. On obtient bien la data table finale 'base_brevets' avec toutes les données souhaitées. 

### -- 
## FIN
