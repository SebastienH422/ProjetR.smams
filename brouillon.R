#brouillon 1

library(data.table)
library(readr)

dt_offres = read_tsv(file = "Data/emp_offers_fmt.tsv") 
head(dt_offres)

# on crée le vecteur contenant une fois le nom de chaque netreprise
firm_name = c(unique(dt_offres$entreprise))
firm_name
















































