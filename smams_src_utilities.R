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
get_wage = function(line) {
  # IN: wage <string> Salaire ou fourchette de salaire sous les différents formats 
  #                          qui apparraissent dans la colonne salaire
  # OUT: <float> Salaire ou salaire moyen s'il s'agit d'une fourchette

  if (!is.null(line['salaire'])) {
    wage = line['salaire']
  } else {
    wage = NaN
  }

  # Check if the wage text is empty or NA
  if (is.na(wage) || wage == "") {
    return(NA)  # Return NA for empty or missing salaries
  }
  
  # Remove all spaces between numbers
  cleaned_wage = gsub(" ", "", wage)

  # Convert commas to periods for consistency
  cleaned_wage = gsub(",", ".", cleaned_wage)
  
  # If the wage ends with "000", multiply by 1000
  wage_value = 1
  if (grepl("000", cleaned_wage) || grepl("K", cleaned_wage)) {
    wage_value = as.numeric(cleaned_wage) * 1000
  } else {
    wage_value = as.numeric(cleaned_wage)
  }
  
  # Extract all numbers from the wage string
  numbers = as.numeric(unlist(str_extract_all(cleaned_wage, "\\d+\\.?\\d*")))
  
  # If no numbers are found, return NA
  if (length(numbers) == 0) {
    return(NA)
  }

  mult = 1
  if (str_detect(wage, "k") || str_detect(wage, "K")) {
    mult = 1000
  }
  
  # Calculate the average of the numbers if there are multiple
  avg_wage = if (length(numbers) > 1) mean(numbers) else numbers[1]
  
  # Apply multipliers based on keywords only if the text is not NA or empty
  if (!is.na(wage) && wage != "") {
    if (str_detect(wage, "\\bjour\\b")) {
      avg_wage = avg_wage * 365  # Multiply by 365 for "jour"
    } else if (str_detect(wage, "\\bmois\\b")) {
      avg_wage = avg_wage * 12   # Multiply by 12 for "mois"
    } else if (str_detect(wage, "\\bsemaine\\b")) {
      avg_wage = avg_wage * 52   # Multiply by 52 for "semaine"
    }
  }
  
  if (avg_wage == floor(avg_wage)) {
    formatted_wage = format(avg_wage, nsmall = 0)  # No decimal places
  } else {
    formatted_wage = format(round(avg_wage, 2), nsmall = 2)  # Two decimal places
  }
  
  return(as.numeric(formatted_wage) * mult)
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

  # Remove any empty or NA values
  valid_val = val_list[!is.na(val_list) & val_list != ""]
  
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