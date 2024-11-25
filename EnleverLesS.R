text = "Statistiques, Collaboration, Prouts, Cacsa"
text
gsub("s\\b", "", text)


library(data.table)

dt = data.table(entreprise = c("Renault", "Caca", "Safran,"), 
                competences = c("Statistiques, Collaboration, Prouts, SQL", "Cacas, Statistique, équipe", "Esprit d'equipe, Equipe, pipis"))
dt


dt = dt[, .(entreprise, competences = gsub("s\\b", "", competences))]
dt


