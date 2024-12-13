# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# Partie emploi
# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
#
# Fonctions annexes

# Function to clean up and process the competences list
clean_competences = function(skills_text) {
  # Remove leading and trailing commas and whitespace
  cleaned_text = str_trim(gsub("^,|,$", "", skills_text))
  return(cleaned_text)
}

# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# Fonctions pour construire les colonnes de base_emp
# _____________________________________________________________________________________________________________________________
# --> Used for top_skill_req         
get_skills_req = function(line){ 
  # IN: skills <string> nombre de compétence sous les différents formats qui apparraissent dans competences_requises
  # OUT: <list of string> compétences requises, une compétence par string
  if (!is.null(line['competences_requises'])) {
    skills = line['competences_requises']
  } else {
    skills = NaN
  }
  return(str_split(string = stringi::stri_trans_general(tolower(skills), "Latin-ASCII"),
                   pattern = ', '))
}
# _____________________________________________________________________________________________________________________________
# --> Used for sector_name       
get_sector_name = function(line){ 
  # IN: sector <string> nombre de compétence sous les différents formats qui apparraissent dans competences_requises
  # OUT: <list of string> compétences requises, une compétence par string
  if (!is.null(line['secteur'])) {
    sector = line['secteur']
  } else {
    sector = NaN
  }
  return(str_split(string = stringi::stri_trans_general(tolower(sector), "Latin-ASCII"),
                   pattern = ', '))
}

# _____________________________________________________________________________________________________________________________
# Used for avg_wage

get_wage = function(wage) {
  # IN: wage <string> Salaire ou fourchette de salaire sous les différents formats 
  #                          qui apparraissent dans la colonne salaire
  # OUT: <float> Salaire ou salaire moyen s'il s'agit d'une fourchette

  if (is.na(wage) || wage == "") {
    return(NA_real_)
  }
  
  # Nettoyer le texte du salaire
  wage <- gsub(" ", "", wage)        # Supprimer les espaces
  wage <- gsub(",", ".", wage)       # Convertir les virgules en points

  # Détecter les multiplicateurs et normaliser
  multiplier <- 1
  if (grepl("K", wage, ignore.case = TRUE)) {
    multiplier <- 1000
    wage <- gsub("[Kk]", "", wage)
  } else if (grepl("000", wage)) {
    wage <- gsub("000", "", wage)
    multiplier <- 1000
  }
  
  # Extraire les nombres
  numbers <- as.numeric(unlist(str_extract_all(wage, "\\d+\\.?\\d*")))

  if (length(numbers) == 0 || any(is.na(numbers))) {
    return(NA_real_)
  }
  
  # Calculer la moyenne en cas de fourchette
  avg_wage <- mean(numbers) * multiplier
  
  # Ajuster pour les périodes (jour, mois, semaine)
  if (str_detect(wage, "jour")) {
    avg_wage <- avg_wage * 365
  } else if (str_detect(wage, "mois")) {
    avg_wage <- avg_wage * 12
  } else if (str_detect(wage, "semaine")) {
    avg_wage <- avg_wage * 52
  }
  

  # Retourner avec 2 décimales
  return(round(avg_wage, 2))
}


# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# Fonctions à appliquer après l'aggregation 
# _____________________________________________________________________________________________________________________________
#
set_firm_name = function(names) {
  # IN: names <list of string> Noms des entreprises
  # OUT: <string> Le premier nom, ou celui qui revient le plus souvent
  
  # If there are no name, return NA
  if (length(names) == 0) {
    return(NA)
  }
  
  # Count occurrences of each name
  names_counts = sort(table(names), decreasing = TRUE)
  
  # Get the top name
  top_names = names(names_counts)[1]
  
  # Concatenate the top name
  return(top_names)
}

# _____________________________________________________________________________________________________________________________
#
get_top_val = function(val_list, n) {
  # IN: val_lists <list> Liste de valeurs
  #     n <int> nombre de secteurs voulus
  # OUT: Liste des n valeurs qui reviennent le plus souvent
  
  # Ensure val_list is treated as a character vector
  val_list = as.character(val_list)
  
  # Split the string values by comma and remove extra spaces
  valid_val = unlist(strsplit(val_list, ",\\s*"))
  
  # Remove any empty or NA values
  valid_val = valid_val[!is.na(valid_val) & valid_val != ""]
  
  # If no valid val are found, return NA
  if (length(valid_val) == 0) {
    return(NA_character_)
  }
  
  # Count occurrences of each val
  val_counts = sort(table(valid_val), decreasing = TRUE)
  
  # Get the top n most frequent val (or fewer if there aren't n)
  top_val = names(val_counts)[1:min(n, length(val_counts))]
  
  # Concatenate the top val into a single string, separated by commas
  return(paste(top_val, collapse = ", "))
}

# _____________________________________________________________________________________________________________________________
#
get_id_firm = function(line) {
  if (!is.null(line['entreprise'])) {
    name = line['entreprise'] # Nom de l'entreprise
    name_norm = stringi::stri_trans_general(tolower(name), "Latin-ASCII") # Sans accent ni majuscule
    return (substring(name_norm, 1, min(4, nchar(name_norm)))) # 4 premiers caractères
  } else {
    stop("La colonne 'entreprise' est manquante dans l'objet 'line'")
  }
}
