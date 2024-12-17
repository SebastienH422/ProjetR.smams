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

get_most_frequent = function(val_list) {
  # IN: val_lists <list> Liste de valeurs (skills)
  # OUT: Liste des valeurs qui reviennent le plus souvent (>1 apparition),
  #      ou toutes les valeurs si elles apparaissent seulement une fois
  
  # Ensure val_list is treated as a character vector
  val_list = as.character(val_list)
  
  # Split the string values by comma and remove extra spaces
  valid_val = unlist(strsplit(val_list, ",\\s*"))
  
  # Remove any empty or NA values
  valid_val = valid_val[!is.na(valid_val) & valid_val != ""]
  
  # If no valid val are found, return NA
  if (length(valid_val) == 0) {
    return(NA_real_)
  }
  
  # Count occurrences of each value
  val_counts = table(valid_val)
  
  # Filter to keep only values that appear more than once
  frequent_vals = names(val_counts[val_counts > 1])
  
  if (length(frequent_vals) > 0) {
    # Sort frequent values by occurrence
    frequent_counts = sort(val_counts[frequent_vals], decreasing = TRUE)
    top_skills = names(frequent_counts)
  } else {
    # If all values appear only once, return all values
    top_skills = names(sort(val_counts, decreasing = TRUE))
  }
  
  # Concatenate the top skills into a single string, separated by commas
  return(paste(top_skills, collapse = ", "))
}

# _____________________________________________________________________________________________________________________________
#
get_id_firm = function(line) {
  if (!is.null(line['entreprise'])) {
    name = line['entreprise'] # Nom de l'entreprise
    
    # Les mots suivant apparraissent souvent comme premier mot dans le nom d'entreprise, ils ne sont pas suffisant pour identifier l'entreprise, on les ignore pour construire l'identificateur id_firm_name
    to_ignore = c('groupe', 'la', 'caisse', 'le', 'groupement', 'air', 'the', 'centre', 'direction', 'departement')
    name = tolower(name)

    name = stringi::stri_trans_general(tolower(name), "Latin-ASCII")


    name = gsub(',','',name)
    k = 0
    while (word(name, k, k) %in% to_ignore){
      k = k + 1
    }

    return (word(name, k, k)) # 4 premiers caractères
  } else {
    stop("La colonne 'entreprise' est manquante dans l'objet 'line'")
  }
}

# _____________________________________________________________________________________________________________________________
# Fonction helper pour choisir une valeur non-NA, ou au hasard si plusieurs valeurs non-NA
#
  choose_non_na = function(x) {
    # S'assurer que x est un vecteur du même type
    x <- as.vector(x)
    x_unique <- unique(x[!is.na(x)])
    if(length(x_unique) == 0) return(x[1])  # Retourne NA du bon type
    if(length(x_unique) == 1) return(x_unique[1])
    return(sample(x_unique, 1))
  }