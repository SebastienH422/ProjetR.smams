#brouillon 1

library(data.table)
library(readr)

#base_emp <- data.frame(entreprise = firm_name,
#                       n_offres = n_offres$N[match(firm_name, n_offres$entreprise)],
#                       avg_req_exp = avg_req_exp[match(firm_name, resultat$entreprise)])

# read_tsv
dt_offres = read.csv(file = "emp_offers_fmt.tsv",
                      head = TRUE,
                      sep =",")[c("entreprise", "secteur", "experience_requise", "competences_requises", "salaire", "departement")]

setDT(dt_offres)

head(dt_offres)

# on crée le vecteur contenant une fois le nom de chaque netreprise
firm_name = unique(dt_offres$entreprise)
firm_name

# nombre d'offres par entreprise 
n_offres = dt_offres[, .N, by = entreprise]
n_offres

# vecteur de l'expereince requise par entreprise (en moyenne)
somme_experience = dt_offres[, .(somme_experience = sum(experience_requise, na.rm = TRUE)), by = entreprise]

resultat = merge(somme_experience, n_offres, by = "entreprise", all = TRUE) # Utiliser all=TRUE pour garder toutes les entreprises

resultat[, experience_moyenne := somme_experience / N]

resultat = resultat[!is.na(experience_moyenne)]

resultat_ordered = resultat[match(firm_name, entreprise)]

avg_req_exp = resultat_ordered$experience_moyenne

print(avg_req_exp)

# vecteur des departements : 
addr_dept_main = dt_offres[, .(dept_principal = names(which.max(table(departement)))), by = entreprise]
addr_dept_main

# salaire moyen par entreprise : 

# Filtrer les lignes où la colonne salaire n'est pas vide
dt_offres = dt_offres[!is.na(salaire) & salaire != ""]

# Nettoyer et extraire le salaire
dt_offres[, salaire_num := {
  # 1. Enlever tout ce qui n'est pas un nombre ou un espace
  cleaned_salary = gsub(".*?([0-9]+)[Kk]?[^0-9]*([0-9]*)?.*", "\\1\\2", salaire)
  
  # 2. Extraire le premier nombre avant la fourchette
  cleaned_salary = gsub(".*?([0-9]+).*", "\\1", salaire)  # Conserver le premier nombre
  cleaned_salary = gsub(" ", "", cleaned_salary)  # Enlever les espaces
  
  # 3. Vérifier s'il contient "K" pour multiplier par 1000
  if (grepl("K", salaire, ignore.case = TRUE)) {
    first_number = as.numeric(cleaned_salary) * 1000
  } else {
    # 4. Convertir en numérique
    first_number = as.numeric(cleaned_salary)
  }
  
  # 5. Gérer les NAs si la conversion échoue
  first_number = ifelse(is.na(first_number), NA, first_number)
  
  # 6. Si le chiffre est inférieur à 10 000 (et pas en "K"), le multiplier par 12
  ifelse(!is.na(first_number) & first_number < 10000, first_number * 12, first_number)
}]

# Vérifier les salaires numériques
print(dt_offres[, .(entreprise, salaire, salaire_num)])

# Afficher les salaires uniques pour débogage
avg_wage = unique(dt_offres$salaire_num)
print(avg_wage)
































