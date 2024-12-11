# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# Partie emploi
#
# Reste à faire:
#     get_skills: IN: skills <string> Compétences requises
#                 OUT: <list of string> Une compétence requise par string
#     get_sector: IN: sectors <string> Secteurs d'activités
#                 OUT: <list of string> Un secteur d'activité par string

# _____________________________________________________________________________________________________________________________
# Fonctions annexes

# Function to clean up and process the competences list
clean_competences = function(skills_text) {
  # Remove leading and trailing commas and whitespace
  cleaned_text = str_trim(gsub("^,|,$", "", skills_text))
  return(cleaned_text)
}
# _____________________________________________________________________________________________________________________________
# Fonctions pour construire les colonnes de base_emp
#                  
get_exp_req = function(exp){
  # IN: exp <string> nombre d'expérience sous les différents formats qui apparraissent dans experience_requise
  # OUT: <list of string> Expériences requises, une expérience par string
  return(str_split(string = stringi::stri_trans_general(tolower(exp), "Latin-ASCII"),
                   pattern = ', '))
}

get_wage = function(wage) {
  # IN: wage <string> Salaire ou fourchette de salaire sous les différents formats 
  #                          qui apparraissent dans la colonne salaire
  # OUT: <float> Salaire ou salaire moyen s'il s'agit d'une fourchette

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
#     get_skills: IN: skills <string> Compétences requises
#                 OUT: <list of string> Une compétence requise par string
#     get_sector: IN: sectors <string> Secteurs d'activités
#                 OUT: <list of string> Un secteur d'activité par string
#
# _____________________________________________________________________________________________________________________________
# Fonctions à appliquer pour l'aggregation 
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

get_top_sectors = function(sector_list, n) {
  # IN: sectors_lists <list of list of string> Liste de liste des secteurs d'activités
  #     n <int> nombre de secteurs voulus
  # OUT: String des n secteurs qui reviennent le plus souvent

  # Remove any empty or NA values
  valid_sectors = sector_list[!is.na(sector_list) & sector_list != ""]
  
  # If no valid sectors are found, return NA
  if (length(valid_sectors) == 0) {
    return(NA_character_)
  }
  
  # Count occurrences of each sector
  sector_counts = sort(table(valid_sectors), decreasing = TRUE)
  
  # Get the top n most frequent sectors (or fewer if there aren't n)
  top_sectors = names(sector_counts)[1:min(n, length(sector_counts))]
  
  # Concatenate the top sectors into a single string, separated by commas
  return(paste(top_sectors, collapse = ", "))
}

get_top_skills = function(skills_list, n) {
  # IN: skills_lists <list of list of string> Liste de liste des compétences
  #     n <int> nombre de compétences voulues 
  # OUT: String des n compétences qui reviennent le plus souvent

  # Clean the competences list and flatten into a single vector
  cleaned_skills = unlist(str_split(clean_competences(skills_list), ",\\s*"))
  cleaned_skills = cleaned_skills[cleaned_skills != ""]
  
  # If there are no skills, return NA as a character
  if (length(cleaned_skills) == 0) {
    return(NA_character_)
  }
  
  # Count occurrences of each skill
  skill_counts = sort(table(cleaned_skills), decreasing = TRUE)
  
  # Get the top skills, limiting to n or fewer
  top_skills = names(skill_counts)[1:min(n, length(skill_counts))]
  
  # Concatenate the top skills into a single string
  return(paste(top_skills, collapse = ", "))
}

set_addre_dept_main = function(dep) {
  # IN: dep <list of int> Liste de int des départements
  # OUT: int du département qui revient le plus souvent
  
  # If there are no departement, return NA
  if (length(dep) == 0) {
    return(NA)
  }
  
  # Count occurrences of each departement
  dep_counts = sort(table(dep), decreasing = TRUE)
  
  # Get the top departement
  top_dep = names(dep_counts)[1]
  
  # Concatenate the top departement
  return(top_dep)
}


get_id_firm = function(line) {
  if (!is.null(line['entreprise'])) {
    name = line['entreprise'] # Nom de l'entreprise
    name_norm = stringi::stri_trans_general(tolower(name), "Latin-ASCII") # Sans accent ni majuscule
    return (substring(name_norm, 1, min(4, nchar(name_norm)))) # 4 premiers caractères
  } else {
    stop("La colonne 'entreprise' est manquante dans l'objet 'line'")
  }
}