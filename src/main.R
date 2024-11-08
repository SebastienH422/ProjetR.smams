library(data.table)
library(stringr)

# 2.4 : Importation des données offres d'emploi
# --> Création de `offres` contenant les données suivantes:
#     entreprise, secteur, experience_requise, competences_requises, salaire, departement

data = data.table(read.csv(file = "emp_offers_fmt.tsv",
                  head = TRUE,
                  sep = ","))
names(data)
# Champs: "intitule_poste" "entreprise" "type_emploi" "secteur" "experience_requise" "competences_requises""poste_desc" "salaire" "departement"      

offres = data[, c("entreprise", "secteur", # On récupère les données qui nous intéressent
              "experience_requise", "competences_requises", "salaire", "departement")]

