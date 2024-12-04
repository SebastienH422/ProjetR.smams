# Fonctions Simon (del)

# Fonctions Maïna (del)

# Fonctions Ahina (del)

# Fonctions Matilin (del)

# Fonctions Seb (del)
get_id_firm = function(line) {
  if (!is.null(line['entreprise'])) {
    name = line['entreprise'] # Nom de l'entreprise
    name_norm = stringi::stri_trans_general(tolower(name), "Latin-ASCII") # Sans accent ni majuscule
    return (substring(name_norm, 1, min(4, nchar(name_norm)))) # 4 premiers caractères
  } else {
    stop("La colonne 'entreprise' est manquante dans l'objet 'line'")
  }
}