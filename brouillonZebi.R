library(data.table)

dt_brevets = fread("../DATA/202202_EPO_App_reg_small.txt")
dt_brevets

#création de la base. 
#1 on commence par filtrer les entreprises françaises

dt_france = dt_brevets[ctry_code == "FR", .(
  firm_name = app_name, appln_id = appln_id, city = city, 
  dept = substr(postal_code, 1, 2) # on garde les 2 premiers chiffres de postal_code. (departement principal)
)]
#ça marche, on obtient bien le nom, la ville et le departement principal par entreprise. 

#maintenant, on lit les données des ipc.

dt_ipc = fread("../DATA/202202_EPO_IPC_small.txt")

#il faut filtrer la période 2010-2020 et garder les IPC4. 

dt_ipc4 = dt_ipc[prio_year <= 2020 & prio_year >= 2010, .(
  appln_id = appln_id, ipc_4 = substr(IPC, 1, 4)
)]


dt_union = merge(dt_france, dt_ipc4, by = "appln_id")  # on fusionne les deux tables. on va pouvoir travailler dessus.

#on commence par compter le nombre d'occurences des ipc4 pr chacune des entreprises.
#avant cela, il faut nettoyer les noms. certains noms d'entreprises présentent des majuscules et d'autre non. On homogénise tout ça. 
# on créé une fonction qu'on appliquera pour chaque nom. 

#fonction nettoyage

nettoyage = function(name){
  name = tolower(name)
  return(name)
}

ipc_compteur = dt_union[, .(
  c = .N ), by = .(firm_name, ipc_4) # on compte le nb lignes pr les combinaisons (firm_name, ipc_4).
]

# on nettoie 
ipc_compteur[, firm_name := nettoyage(firm_name)]


# on organise 

setorder(ipc_compteur, firm_name, -c)  # ici , on organise la table d'abord selon les noms des entreprises puis par le nombre 
                                        # décroissant d'ipc4.


# on garde seulement les deux premières colonnes pour chaque nom d'entreprise. 

main_two_ipc = ipc_compteur[, .SD[1:2], by = firm_name]


#ça marche mais il semble que certaines entreprises n'aient déposé de brevets que pour un seul ipc. Par conséquent, on se retrouve avec des lignes 
#'NA' car un seul type d'ipc déposé implique une seule ligne existante dans ipc_compteur. 
# on enlève donc les lignes avec des 'NA'. 

no_NA = subset(main_two_ipc, c != 'NA')

#ça marche, no_Na ne contient pas de 'NA'. 

# on peut créer base_brevets à partir de no_NA

base_brevets = no_NA[, .(
  ipc_main_code = first(ipc_4), ipc_second_code = if(.N > 1) ipc_4[2] else'NA', n_patents = sum(c)), by = firm_name
]
base_brevets

# dans le bloc ci-dessus, on créer brevets. dans le cas ou une entreprise n'a pas déposé de second ipc_4 : on attribue NA. (PAS SUR QUE CE SOIT BON DE FAIRE CA)

# pour la création de addr_city_main, il suffit de regarder le nombre le plus présent pour chaque entreprise. 







